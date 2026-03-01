// ============================================================================
// Reset Gate Element Module (r_t)
// Computes: r_t[n] = sigmoid(W_ir[n,:] @ x_t + W_hr[n,:] @ h_t_prev + b_ir[n] + b_hr[n])
//
// Accumulation is now registered (one addition per clock) to break the
// combinational adder chain that was causing the large negative WNS.
// valid_out pulses one cycle after accumulation + sigmoid complete.
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

    input  logic signed [DATA_WIDTH-1:0] x_t [D-1:0],
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
    localparam int TOTAL_ITERS    = D > H ? D : H;  // run longest loop

    // Saturation limits
    localparam signed [DATA_WIDTH-1:0] MAX_VAL = {1'b0, {(DATA_WIDTH-1){1'b1}}};
    localparam signed [DATA_WIDTH-1:0] MIN_VAL = {1'b1, {(DATA_WIDTH-1){1'b0}}};

    // Combinational products (registered inputs keep these fast)
    logic signed [DATA_WIDTH-1:0] prod_x [D-1:0];
    logic signed [DATA_WIDTH-1:0] prod_h [H-1:0];

    genvar i;
    generate
        for (i = 0; i < D; i++) begin : gen_mult_x
            mult #(.INT_WIDTH(INT_BITS), .FRAC_WIDTH(FRAC_BITS))
                mult_x_inst (.a(W_ir_row[i]), .b(x_t[i]), .y(prod_x[i]));
        end
        for (i = 0; i < H; i++) begin : gen_mult_h
            mult #(.INT_WIDTH(INT_BITS), .FRAC_WIDTH(FRAC_BITS))
                mult_h_inst (.a(W_hr_row[i]), .b(h_t_prev[i]), .y(prod_h[i]));
        end
    endgenerate

    // -----------------------------------------------------------------------
    // Registered accumulator FSM
    // Phase 0: accumulate prod_x[0..D-1] starting from b_ir_n
    // Phase 1: accumulate prod_h[0..H-1] starting from b_hr_n
    // -----------------------------------------------------------------------
    typedef enum logic [1:0] {
        ACC_IDLE  = 2'd0,
        ACC_X     = 2'd1,
        ACC_H     = 2'd2,
        ACC_DONE  = 2'd3
    } acc_state_t;

    acc_state_t                       acc_state;
    logic [$clog2(TOTAL_ITERS+1)-1:0] acc_idx;
    logic signed [ACC_WIDTH-1:0]      acc_x;
    logic signed [ACC_WIDTH-1:0]      acc_h;

    // Saturate helper (function avoids repeated code)
    function automatic logic signed [DATA_WIDTH-1:0] saturate(
        input logic signed [ACC_WIDTH-1:0] val
    );
        if (val > $signed({{ACC_EXTRA_BITS{1'b0}}, MAX_VAL}))
            return MAX_VAL;
        else if (val < $signed({{ACC_EXTRA_BITS{1'b1}}, MIN_VAL}))
            return MIN_VAL;
        else
            return val[DATA_WIDTH-1:0];
    endfunction

    logic signed [DATA_WIDTH-1:0] acc_x_sat;
    logic signed [DATA_WIDTH-1:0] acc_h_sat;
    logic signed [DATA_WIDTH-1:0] pre_act;
    logic signed [DATA_WIDTH-1:0] sigmoid_out;

    assign acc_x_sat = saturate(acc_x);
    assign acc_h_sat = saturate(acc_h);
    assign pre_act   = acc_x_sat + acc_h_sat;

    sigmoid #(.INT_WIDTH(INT_BITS), .FRAC_WIDTH(FRAC_BITS))
        sigmoid_inst (.reset(~rst_n), .x(pre_act), .y(sigmoid_out));

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            acc_state <= ACC_IDLE;
            acc_idx   <= '0;
            acc_x     <= '0;
            acc_h     <= '0;
            r_t_n     <= '0;
            valid_out <= 1'b0;
        end else begin
            valid_out <= 1'b0;  // default

            case (acc_state)

                ACC_IDLE: begin
                    if (valid_in) begin
                        acc_x     <= {{ACC_EXTRA_BITS{b_ir_n[DATA_WIDTH-1]}}, b_ir_n};
                        acc_idx   <= '0;
                        acc_state <= ACC_X;
                    end
                end

                ACC_X: begin
                    acc_x   <= acc_x + {{ACC_EXTRA_BITS{prod_x[acc_idx][DATA_WIDTH-1]}}, prod_x[acc_idx]};
                    acc_idx <= acc_idx + 1;
                    if (acc_idx == D - 1) begin
                        acc_h     <= {{ACC_EXTRA_BITS{b_hr_n[DATA_WIDTH-1]}}, b_hr_n};
                        acc_idx   <= '0;
                        acc_state <= ACC_H;
                    end
                end

                ACC_H: begin
                    acc_h   <= acc_h + {{ACC_EXTRA_BITS{prod_h[acc_idx][DATA_WIDTH-1]}}, prod_h[acc_idx]};
                    acc_idx <= acc_idx + 1;
                    if (acc_idx == H - 1) begin
                        acc_state <= ACC_DONE;
                    end
                end

                ACC_DONE: begin
                    // pre_act and sigmoid_out are combinational from acc_x/acc_h
                    r_t_n     <= sigmoid_out;
                    valid_out <= 1'b1;
                    acc_state <= ACC_IDLE;
                end

            endcase
        end
    end

endmodule