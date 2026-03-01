// ============================================================================
// New/Candidate Gate Element Module (n_t)
// Computes: n_t[n] = tanh(W_in[n,:] @ x_t + W_hn[n,:] @ (r_t[n] * h_t_prev) + b_in[n] + b_hn[n])
//
// pre_act registered before tanh - breaks acc→saturate→tanh path.
// tanh has 6 cycles of pipeline latency, so S_WAIT counts 6 cycles.
// ============================================================================
module gru_new_gate_element #(
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
    input  logic signed [DATA_WIDTH-1:0] r_t_n,
    input  logic signed [DATA_WIDTH-1:0] W_in_row [D-1:0],
    input  logic signed [DATA_WIDTH-1:0] W_hn_row [H-1:0],
    input  logic signed [DATA_WIDTH-1:0] b_in_n,
    input  logic signed [DATA_WIDTH-1:0] b_hn_n,

    output logic signed [DATA_WIDTH-1:0] n_t_n,
    output logic                          valid_out
);

    localparam int ACC_EXTRA_BITS = $clog2(D > H ? D : H) + 3;
    localparam int ACC_WIDTH      = DATA_WIDTH + ACC_EXTRA_BITS;

    localparam signed [DATA_WIDTH-1:0] MAX_VAL = {1'b0, {(DATA_WIDTH-1){1'b1}}};
    localparam signed [DATA_WIDTH-1:0] MIN_VAL = {1'b1, {(DATA_WIDTH-1){1'b0}}};

    // tanh pipeline depth: mult(1) + sigmoid(3) + mult(1) + output_reg(1) = 6
    localparam int TANH_LATENCY = 6;

    typedef enum logic [2:0] {
        S_IDLE   = 3'd0,
        S_SEL_X  = 3'd1,
        S_ACC_X  = 3'd2,
        S_SEL_H  = 3'd3,
        S_GATE_H = 3'd4,
        S_ACC_H  = 3'd5,
        S_WAIT   = 3'd6,
        S_DONE   = 3'd7
    } state_t;

    state_t                            state;
    logic [$clog2(D > H ? D : H)-1:0] idx;

    logic signed [DATA_WIDTH-1:0] main_a, main_b, main_product;
    mult #(.INT_WIDTH(INT_BITS), .FRAC_WIDTH(FRAC_BITS))
        mult_main (.clk(clk), .rst_n(rst_n), .a(main_a), .b(main_b), .y(main_product));

    logic signed [DATA_WIDTH-1:0] gate_a, gate_b, gate_product;
    mult #(.INT_WIDTH(INT_BITS), .FRAC_WIDTH(FRAC_BITS))
        mult_gate (.clk(clk), .rst_n(rst_n), .a(gate_a), .b(gate_b), .y(gate_product));

    logic signed [ACC_WIDTH-1:0] acc_x, acc_h;

    function automatic logic signed [DATA_WIDTH-1:0] saturate(
        input logic signed [ACC_WIDTH-1:0] val
    );
        if (val > $signed({{ACC_EXTRA_BITS{1'b0}}, MAX_VAL})) return MAX_VAL;
        else if (val < $signed({{ACC_EXTRA_BITS{1'b1}}, MIN_VAL})) return MIN_VAL;
        else return val[DATA_WIDTH-1:0];
    endfunction

    logic signed [DATA_WIDTH-1:0] pre_act_comb;
    logic signed [DATA_WIDTH-1:0] pre_act_reg;
    assign pre_act_comb = saturate(acc_x) + saturate(acc_h);

    logic signed [DATA_WIDTH-1:0] tanh_out;
    tanh #(.INT_WIDTH(INT_BITS), .FRAC_WIDTH(FRAC_BITS))
        tanh_inst (.clk(clk), .rst_n(rst_n), .reset(~rst_n),
                   .x(pre_act_reg), .y(tanh_out));

    logic [$clog2(TANH_LATENCY+1)-1:0] wait_cnt;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state       <= S_IDLE;
            idx         <= '0;
            main_a      <= '0;
            main_b      <= '0;
            gate_a      <= '0;
            gate_b      <= '0;
            acc_x       <= '0;
            acc_h       <= '0;
            pre_act_reg <= '0;
            wait_cnt    <= '0;
            n_t_n       <= '0;
            valid_out   <= 1'b0;
        end else begin
            valid_out <= 1'b0;

            case (state)

                S_IDLE: begin
                    if (valid_in) begin
                        acc_x <= {{ACC_EXTRA_BITS{b_in_n[DATA_WIDTH-1]}}, b_in_n};
                        idx   <= '0;
                        state <= S_SEL_X;
                    end
                end

                S_SEL_X: begin
                    main_a <= W_in_row[idx];
                    main_b <= x_t[idx];
                    state  <= S_ACC_X;
                end

                S_ACC_X: begin
                    acc_x <= acc_x + {{ACC_EXTRA_BITS{main_product[DATA_WIDTH-1]}}, main_product};
                    if (idx == D - 1) begin
                        acc_h  <= {{ACC_EXTRA_BITS{b_hn_n[DATA_WIDTH-1]}}, b_hn_n};
                        gate_a <= r_t_n;
                        gate_b <= h_t_prev[0];
                        idx    <= '0;
                        state  <= S_GATE_H;
                    end else begin
                        idx   <= idx + 1;
                        state <= S_SEL_X;
                    end
                end

                S_SEL_H: begin
                    gate_a <= r_t_n;
                    gate_b <= h_t_prev[idx];
                    state  <= S_GATE_H;
                end

                S_GATE_H: begin
                    main_a <= W_hn_row[idx];
                    main_b <= gate_product;
                    state  <= S_ACC_H;
                end

                S_ACC_H: begin
                    acc_h <= acc_h + {{ACC_EXTRA_BITS{main_product[DATA_WIDTH-1]}}, main_product};
                    if (idx == H - 1) begin
                        // Register pre_act and let tanh pipeline fill
                        pre_act_reg <= pre_act_comb;
                        wait_cnt    <= '0;
                        state       <= S_WAIT;
                    end else begin
                        idx   <= idx + 1;
                        state <= S_SEL_H;
                    end
                end

                // Wait TANH_LATENCY cycles for tanh output to be valid
                S_WAIT: begin
                    wait_cnt <= wait_cnt + 1;
                    if (wait_cnt == TANH_LATENCY - 1)
                        state <= S_DONE;
                end

                S_DONE: begin
                    n_t_n     <= tanh_out;
                    valid_out <= 1'b1;
                    state     <= S_IDLE;
                end

            endcase
        end
    end

endmodule