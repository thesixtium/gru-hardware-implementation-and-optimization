module tanh #(
    parameter int INT_WIDTH  = 8,
    parameter int FRAC_WIDTH = 8,
    parameter int WIDTH      = INT_WIDTH + FRAC_WIDTH + 1
)(
    input  logic                     clk,
    input  logic                     reset,
    input  logic signed [WIDTH-1:0]  x,
    output logic signed [WIDTH-1:0]  y
);

    // Fixed-point constants in Q(INT_WIDTH.FRAC_WIDTH) format
    localparam signed [WIDTH-1:0] CONST_N1       = $rtoi(-1.0       * (1 << FRAC_WIDTH));
    localparam signed [WIDTH-1:0] CONST_1        = $rtoi( 1.0       * (1 << FRAC_WIDTH));

    // Breakpoints in input space (fixed point)
    localparam signed [WIDTH-1:0] BP_M2     = $rtoi(-2.0    * (1 << FRAC_WIDTH));
    localparam signed [WIDTH-1:0] BP_P2     = $rtoi( 2.0    * (1 << FRAC_WIDTH));

    // Internal combinational output
    logic signed [2*WIDTH-1:0] mult;  // product before truncation
    logic signed [WIDTH-1:0] sigmoid_result;
    
    sigmoid unit ( .clk(clk), .reset(reset), .x(2*x), .y(sigmoid_result) );
    
    // Piecewise-linear combinational logic
    always_comb begin
        if (reset)
            y = '0;
        else if (x <= BP_M2) begin
            y = CONST_N1;
        end
        else if (x <= BP_P2) begin
            y = sigmoid_result;
        end
        else begin
            y = CONST_1;
        end
    end

endmodule
