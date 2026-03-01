// ============================================================================
// Reset Gate Element Module (r_t)
// Computes: r_t[n] = sigmoid(W_ir[n,:] @ x_t + W_hr[n,:] @ h_t_prev + b_ir[n] + b_hr[n])
//
// Pipeline stages per multiply-accumulate:
//   S_SEL:  register operands into mult inputs         (cycle 0)
//           mult combinational logic runs
//   S_WAIT: mult output register captures result       (cycle 1)
//   S_ACC:  accumulate registered product              (cycle 2)
//
// Critical paths are now all single-stage:
//   reg → mult_comb → reg   (SEL→WAIT)
//   reg → adder    → reg   (WAIT→ACC, product already registered)
//
// Latency: 3*(D+H) + 2 cycles from valid_in to valid_out.
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
        S_SEL_X  = 3'd1,   // present operands to mult
        S_ACC_X  = 3'd2,   // mult output reg is valid; accumulate
        S_SEL_H  = 3'd3,
        S_ACC_H  = 3'd4,
        S_DONE   = 3'd5
    } state_t;

    state_t                            state;
    logic [$clog2(D > H ? D : H)-1:0] idx;

    // Mult inputs (registered before driving mult)
    logic signed [DATA_WIDTH-1:0] op_a, op_b;

    // Mult output - now registered inside mult module (1 cycle latency)
    logic signed [DATA_WIDTH-1:0] product;

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

    logic signed [DATA_WIDTH-1:0] pre_act, sigmoid_out;
    assign pre_act = saturate(acc_x) + saturate(acc_h);

    sigmoid #(.INT_WIDTH(INT_BITS), .FRAC_WIDTH(FRAC_BITS))
        sigmoid_inst (.clk(clk), .rst_n(rst_n), .reset(~rst_n), .x(pre_act), .y(sigmoid_out));

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state     <= S_IDLE;
            idx       <= '0;
            op_a      <= '0;
            op_b      <= '0;
            acc_x     <= '0;
            acc_h     <= '0;
            r_t_n     <= '0;
            valid_out <= 1'b0;
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

                // Present operands - mult combinational runs this cycle,
                // product register captures on next rising edge
                S_SEL_X: begin
                    op_a  <= W_ir_row[idx];
                    op_b  <= x_t[idx];
                    state <= S_ACC_X;
                end

                // product register now holds W_ir[idx] * x_t[idx]
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
                        state <= S_DONE;
                    end else begin
                        idx   <= idx + 1;
                        state <= S_SEL_H;
                    end
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