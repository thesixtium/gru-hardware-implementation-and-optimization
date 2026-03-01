// tanh(x) = 2*sigmoid(2x) - 1
//
// Pipeline depth accounting:
//   mult(2x):    1 cycle  (registered mult)
//   sigmoid:     3 cycles (new 3-stage sigmoid)
//   mult(*2):    1 cycle  (registered mult)
//   output reg:  1 cycle
//   Total:       6 cycles from x to y
//
// x_delay must be 5 cycles deep so the clamp comparison on original x
// aligns with the final output register.

module tanh #(
    parameter int INT_WIDTH  = 8,
    parameter int FRAC_WIDTH = 8,
    parameter int WIDTH      = INT_WIDTH + FRAC_WIDTH
)(
    input  logic                     clk,
    input  logic                     rst_n,
    input  logic                     reset,
    input  logic signed [WIDTH-1:0]  x,
    output logic signed [WIDTH-1:0]  y
);
    localparam signed [WIDTH-1:0] CONST_N1 = -(1 <<< FRAC_WIDTH);
    localparam signed [WIDTH-1:0] CONST_1  =  (1 <<< FRAC_WIDTH);
    localparam signed [WIDTH-1:0] TWO      =  (2 <<< FRAC_WIDTH);
    localparam signed [WIDTH-1:0] ONE      =  (1 <<< FRAC_WIDTH);

    localparam signed [WIDTH-1:0] BP_M2 = -(2 <<< FRAC_WIDTH);
    localparam signed [WIDTH-1:0] BP_P2 =  (2 <<< FRAC_WIDTH);

    // Stage 1: x * 2  (1-cycle registered mult)
    logic signed [WIDTH-1:0] x_times_2;
    mult #(.INT_WIDTH(INT_WIDTH), .FRAC_WIDTH(FRAC_WIDTH))
        mul_2x (.clk(clk), .rst_n(rst_n), .a(x), .b(TWO), .y(x_times_2));

    // Stages 2-4: sigmoid(2x)  (3-cycle pipeline)
    logic signed [WIDTH-1:0] sigmoid_out;
    sigmoid #(.INT_WIDTH(INT_WIDTH), .FRAC_WIDTH(FRAC_WIDTH))
        sig_inst (.clk(clk), .rst_n(rst_n), .reset(reset),
                  .x(x_times_2), .y(sigmoid_out));

    // Stage 5: sigmoid_out * 2  (1-cycle registered mult)
    logic signed [WIDTH-1:0] sigmoid_times_2;
    mult #(.INT_WIDTH(INT_WIDTH), .FRAC_WIDTH(FRAC_WIDTH))
        mul_2s (.clk(clk), .rst_n(rst_n), .a(sigmoid_out), .b(TWO), .y(sigmoid_times_2));

    // Delay x by 5 cycles to align clamp comparison with stage-5 output
    // (mult:1 + sigmoid:3 + mult:1 = 5 cycles before output register)
    localparam int PIPE_DEPTH = 5;
    logic signed [WIDTH-1:0] x_delay [PIPE_DEPTH-1:0];

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i = 0; i < PIPE_DEPTH; i++) x_delay[i] <= '0;
        end else begin
            x_delay[0] <= x;
            for (int i = 1; i < PIPE_DEPTH; i++) x_delay[i] <= x_delay[i-1];
        end
    end

    // Stage 6: output register - clamp or compute
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            y <= '0;
        else if (reset)
            y <= '0;
        else if (x_delay[PIPE_DEPTH-1] <= BP_M2)
            y <= CONST_N1;
        else if (x_delay[PIPE_DEPTH-1] >= BP_P2)
            y <= CONST_1;
        else
            y <= sigmoid_times_2 - ONE;  // just a subtract - no multiply
    end

endmodule