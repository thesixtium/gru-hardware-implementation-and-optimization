`timescale 1ns / 1ps


module sigmoid #(
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
    localparam signed [WIDTH-1:0] CONST_0        = $rtoi( 0.0       * (1 << FRAC_WIDTH));
    localparam signed [WIDTH-1:0] CONST_1        = $rtoi( 1.0       * (1 << FRAC_WIDTH));
    localparam signed [WIDTH-1:0] CONST_015625   = $rtoi( 0.15625   * (1 << FRAC_WIDTH));
    localparam signed [WIDTH-1:0] CONST_0375     = $rtoi( 0.375     * (1 << FRAC_WIDTH));
    localparam signed [WIDTH-1:0] CONST_05       = $rtoi( 0.5       * (1 << FRAC_WIDTH));
    localparam signed [WIDTH-1:0] CONST_0625     = $rtoi( 0.625     * (1 << FRAC_WIDTH));
    localparam signed [WIDTH-1:0] CONST_084375   = $rtoi( 0.84375   * (1 << FRAC_WIDTH));

    // Slopes
    localparam signed [WIDTH-1:0] SLOPE_003125   = $rtoi( 0.03125   * (1 << FRAC_WIDTH));
    localparam signed [WIDTH-1:0] SLOPE_0125     = $rtoi( 0.125     * (1 << FRAC_WIDTH));
    localparam signed [WIDTH-1:0] SLOPE_025      = $rtoi( 0.25      * (1 << FRAC_WIDTH));

    // Breakpoints in input space (fixed point)
    localparam signed [WIDTH-1:0] BP_M5     = $rtoi(-5.0    * (1 << FRAC_WIDTH));
    localparam signed [WIDTH-1:0] BP_M2375  = $rtoi(-2.375  * (1 << FRAC_WIDTH));
    localparam signed [WIDTH-1:0] BP_M1     = $rtoi(-1.0    * (1 << FRAC_WIDTH));
    localparam signed [WIDTH-1:0] BP_P1     = $rtoi( 1.0    * (1 << FRAC_WIDTH));
    localparam signed [WIDTH-1:0] BP_P2375  = $rtoi( 2.375  * (1 << FRAC_WIDTH));
    localparam signed [WIDTH-1:0] BP_P5     = $rtoi( 5.0    * (1 << FRAC_WIDTH));

    // Internal combinational output
    logic signed [2*WIDTH-1:0] mult;  // product before truncation

    // Piecewise-linear combinational logic
    always_comb begin
        if (reset)
            y = '0;
        else if (x <= BP_M5) begin
            y = CONST_0;
        end
        else if (x <= BP_M2375) begin
            // y = 0.15625 + 0.03125*x
            mult   = $signed(x) * $signed(SLOPE_003125);
            y = CONST_015625 + (mult >>> FRAC_WIDTH);
        end
        else if (x <= BP_M1) begin
            // y = 0.375 + 0.125*x
            mult   = $signed(x) * $signed(SLOPE_0125);
            y = CONST_0375 + (mult >>> FRAC_WIDTH);
        end
        else if (x <= BP_P1) begin
            // y = 0.5 + 0.25*x
            mult   = $signed(x) * $signed(SLOPE_025);
            y = CONST_05 + (mult >>> FRAC_WIDTH);
        end
        else if (x <= BP_P2375) begin
            // y = 0.625 + 0.125*x
            mult   = $signed(x) * $signed(SLOPE_0125);
            y = CONST_0625 + (mult >>> FRAC_WIDTH);
        end
        else if (x <= BP_P5) begin
            // y = 0.84375 + 0.03125*x
            mult   = $signed(x) * $signed(SLOPE_003125);
            y = CONST_084375 + (mult >>> FRAC_WIDTH);
        end
        else begin
            y = CONST_1;
        end
    end

endmodule