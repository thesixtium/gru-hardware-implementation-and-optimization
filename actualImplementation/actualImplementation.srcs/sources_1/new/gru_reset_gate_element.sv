// ============================================================================
// Reset Gate Element Module (r_t)
// Computes: r_t[n] = sigmoid(W_ir[n,:] @ x_t + W_hr[n,:] @ h_t_prev + b_ir[n] + b_hr[n])
//
// pre_act is now registered before being fed into sigmoid, breaking the
// acc_reg → saturate (CARRY chain) → sigmoid_comparators → slope_r_reg
// path that was sitting at only 0.795ns slack and would become a
// violation under slightly worse routing conditions.
// ============================================================================
module gru_reset_gate_element #(
    parameter int D = 128,
    parameter int H = 256,
    parameter int INT_BITS = 16,
    parameter int FRAC_BITS = 8,
    parameter int DATA_WIDTH = INT_BITS + FRAC_BITS
) (
    input  logic                     clk,
    input  logic                     rst_n,
    input  logic                     valid_in,

    input  logic signed [DATA_WIDTH-1:0] x_t      [D-1:0],
    input  logic signed [DATA_WIDTH-1:0] h_t_prev [H-1:0],
    input  logic signed [DATA_WIDTH-1:0] W_ir_row [D-1:0],
    input  logic signed [DATA_WIDTH-1:0] W_hr_row [H-1:0],
    input  logic signed [DATA_WIDTH-1:0] b_ir_n,
    input  logic signed [DATA_WIDTH-1:0] b_hr_n,

    output logic signed [DATA_WIDTH-1:0] r_t_n,
    output logic                          valid_out
);

    localparam int ACC_EXTRA_BITS = $clog2(D > H ? D : H) + 3;
    localparam int ACC_WIDTH      = DATA_WIDTH + ACC_EXTRA_BITS;

    localparam signed [DATA_WIDTH-1:0] MAX_VAL = {1'b0, {(DATA_WIDTH-1){1'b1}}};
    localparam signed [DATA_WIDTH-1:0] MIN_VAL = {1'b1, {(DATA_WIDTH-1){1'b0}}};

    typedef enum logic [2:0] {
        S_IDLE   = 3'd0,
        S_SEL_X  = 3'd1,
        S_ACC_X  = 3'd2,
        S_SEL_H  = 3'd3,
        S_ACC_H  = 3'd4,
        S_WAIT   = 3'd5,   // register pre_act, let sigmoid pipeline fill
        S_DONE   = 3'd6
    } state_t;

    state_t                            state;
    logic [$clog2(D > H ? D : H)-1:0] idx;

    logic signed [DATA_WIDTH-1:0] op_a, op_b, product;

    mult #(.INT_WIDTH(INT_BITS), .FRAC_WIDTH(FRAC_BITS))
        mult_inst (.clk(clk), .rst_n(rst_n), .a(op_a), .b(op_b), .y(product));

    logic signed [ACC_WIDTH-1:0] acc_x, acc_h;

    function automatic logic signed [DATA_WIDTH-1:0] saturate(
        input logic signed [ACC_WIDTH-1:0] val
    );
        if (val > $signed({{ACC_EXTRA_BITS{1'b0}}, MAX_VAL})) return MAX_VAL;
        else if (val < $signed({{ACC_EXTRA_BITS{1'b1}}, MIN_VAL})) return MIN_VAL;
        else return val[DATA_WIDTH-1:0];
    endfunction

    // pre_act_comb is the combinational saturate+add result
    // pre_act_reg is registered before sigmoid to break the long path
    logic signed [DATA_WIDTH-1:0] pre_act_comb;
    logic signed [DATA_WIDTH-1:0] pre_act_reg;
    assign pre_act_comb = saturate(acc_x) + saturate(acc_h);

    // sigmoid receives the registered pre_act - clean single-cycle paths
    // into sigmoid's comparator tree
    logic signed [DATA_WIDTH-1:0] sigmoid_out;
    sigmoid #(.INT_WIDTH(INT_BITS), .FRAC_WIDTH(FRAC_BITS))
        sigmoid_inst (.clk(clk), .rst_n(rst_n), .reset(~rst_n),
                      .x(pre_act_reg), .y(sigmoid_out));

    // Sigmoid has 3 cycles of latency from x to y.
    // We need to count 3 cycles in S_WAIT before sampling sigmoid_out.
    logic [1:0] wait_cnt;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state       <= S_IDLE;
            idx         <= '0;
            op_a        <= '0;
            op_b        <= '0;
            acc_x       <= '0;
            acc_h       <= '0;
            pre_act_reg <= '0;
            wait_cnt    <= '0;
            r_t_n       <= '0;
            valid_out   <= 1'b0;
        end else begin
            valid_out <= 1'b0;

            case (state)

                S_IDLE: begin
                    if (valid_in) begin
                        acc_x <= {{ACC_EXTRA_BITS{b_ir_n[DATA_WIDTH-1]}}, b_ir_n};
                        idx   <= '0;
                        state <= S_SEL_X;
                    end
                end

                S_SEL_X: begin
                    op_a  <= W_ir_row[idx];
                    op_b  <= x_t[idx];
                    state <= S_ACC_X;
                end

                S_ACC_X: begin
                    acc_x <= acc_x + {{ACC_EXTRA_BITS{product[DATA_WIDTH-1]}}, product};
                    if (idx == D - 1) begin
                        acc_h <= {{ACC_EXTRA_BITS{b_hr_n[DATA_WIDTH-1]}}, b_hr_n};
                        idx   <= '0;
                        state <= S_SEL_H;
                    end else begin
                        idx   <= idx + 1;
                        state <= S_SEL_X;
                    end
                end

                S_SEL_H: begin
                    op_a  <= W_hr_row[idx];
                    op_b  <= h_t_prev[idx];
                    state <= S_ACC_H;
                end

                S_ACC_H: begin
                    acc_h <= acc_h + {{ACC_EXTRA_BITS{product[DATA_WIDTH-1]}}, product};
                    if (idx == H - 1) begin
                        // Register pre_act now - sigmoid starts pipeline
                        pre_act_reg <= pre_act_comb;
                        wait_cnt    <= '0;
                        state       <= S_WAIT;
                    end else begin
                        idx   <= idx + 1;
                        state <= S_SEL_H;
                    end
                end

                // Wait 3 cycles for sigmoid's 3-stage pipeline to produce y
                S_WAIT: begin
                    wait_cnt <= wait_cnt + 1;
                    if (wait_cnt == 2'd2)
                        state <= S_DONE;
                end

                S_DONE: begin
                    r_t_n     <= sigmoid_out;
                    valid_out <= 1'b1;
                    state     <= S_IDLE;
                end

            endcase
        end
    end

endmodule