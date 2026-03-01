`timescale 1ns / 1ps

// Piecewise-linear sigmoid - 3-stage pipeline
//
// Stage 1 (cycle 0): combinational breakpoint mux selects slope/offset/x
// Stage 1→2 reg:     x_r, slope_r, offset_r, use_slope_r captured
// Stage 2 (cycle 1): combinational multiply  slope_r * x_r
// Stage 2→3 reg:     mult_r, offset_r2, use_slope_r2 captured
// Stage 3 (cycle 2): combinational add  offset_r2 + mult_r
// Stage 3 reg:       y captured
//
// Critical paths:
//   mux  → reg          (fast: just comparators and muxes)
//   reg  → mult → reg   (one 16x16 multiply between registers)
//   reg  → add  → reg   (one adder between registers)
//
// Total latency: 2 cycles from x presented to y valid.

module sigmoid #(
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

    localparam signed [WIDTH-1:0] CONST_0       = $rtoi( 0.0      * (1 << FRAC_WIDTH));
    localparam signed [WIDTH-1:0] CONST_1       = $rtoi( 1.0      * (1 << FRAC_WIDTH));
    localparam signed [WIDTH-1:0] CONST_015625  = $rtoi( 0.15625  * (1 << FRAC_WIDTH));
    localparam signed [WIDTH-1:0] CONST_0375    = $rtoi( 0.375    * (1 << FRAC_WIDTH));
    localparam signed [WIDTH-1:0] CONST_05      = $rtoi( 0.5      * (1 << FRAC_WIDTH));
    localparam signed [WIDTH-1:0] CONST_0625    = $rtoi( 0.625    * (1 << FRAC_WIDTH));
    localparam signed [WIDTH-1:0] CONST_084375  = $rtoi( 0.84375  * (1 << FRAC_WIDTH));

    localparam signed [WIDTH-1:0] SLOPE_003125  = $rtoi( 0.03125  * (1 << FRAC_WIDTH));
    localparam signed [WIDTH-1:0] SLOPE_0125    = $rtoi( 0.125    * (1 << FRAC_WIDTH));
    localparam signed [WIDTH-1:0] SLOPE_025     = $rtoi( 0.25     * (1 << FRAC_WIDTH));

    localparam signed [WIDTH-1:0] BP_M5    = $rtoi(-5.0   * (1 << FRAC_WIDTH));
    localparam signed [WIDTH-1:0] BP_M2375 = $rtoi(-2.375 * (1 << FRAC_WIDTH));
    localparam signed [WIDTH-1:0] BP_M1    = $rtoi(-1.0   * (1 << FRAC_WIDTH));
    localparam signed [WIDTH-1:0] BP_P1    = $rtoi( 1.0   * (1 << FRAC_WIDTH));
    localparam signed [WIDTH-1:0] BP_P2375 = $rtoi( 2.375 * (1 << FRAC_WIDTH));
    localparam signed [WIDTH-1:0] BP_P5    = $rtoi( 5.0   * (1 << FRAC_WIDTH));

    // -------------------------------------------------------------------------
    // Stage 1: combinational breakpoint mux
    // -------------------------------------------------------------------------
    logic signed [WIDTH-1:0] slope_sel, offset_sel;
    logic                    use_slope;

    always_comb begin
        slope_sel  = '0;
        offset_sel = '0;
        use_slope  = 1'b1;

        if (reset || x <= BP_M5) begin
            offset_sel = CONST_0;
            use_slope  = 1'b0;
        end else if (x <= BP_M2375) begin
            slope_sel  = SLOPE_003125;
            offset_sel = CONST_015625;
        end else if (x <= BP_M1) begin
            slope_sel  = SLOPE_0125;
            offset_sel = CONST_0375;
        end else if (x <= BP_P1) begin
            slope_sel  = SLOPE_025;
            offset_sel = CONST_05;
        end else if (x <= BP_P2375) begin
            slope_sel  = SLOPE_0125;
            offset_sel = CONST_0625;
        end else if (x <= BP_P5) begin
            slope_sel  = SLOPE_003125;
            offset_sel = CONST_084375;
        end else begin
            offset_sel = CONST_1;
            use_slope  = 1'b0;
        end
    end

    // -------------------------------------------------------------------------
    // Stage 1→2 register
    // -------------------------------------------------------------------------
    logic signed [WIDTH-1:0] x_r, slope_r, offset_r;
    logic                    use_slope_r;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            x_r         <= '0;
            slope_r     <= '0;
            offset_r    <= '0;
            use_slope_r <= 1'b0;
        end else begin
            x_r         <= x;
            slope_r     <= slope_sel;
            offset_r    <= offset_sel;
            use_slope_r <= use_slope;
        end
    end

    // -------------------------------------------------------------------------
    // Stage 2: combinational multiply (inputs are registered - fast path)
    // -------------------------------------------------------------------------
    logic signed [2*WIDTH-1:0] mult_full;
    logic signed   [WIDTH-1:0] mult_trunc;
    assign mult_full  = x_r * slope_r;
    assign mult_trunc = mult_full >>> FRAC_WIDTH;

    // -------------------------------------------------------------------------
    // Stage 2→3 register  ← this is the register that was missing before
    // -------------------------------------------------------------------------
    logic signed [WIDTH-1:0] mult_r, offset_r2;
    logic                    use_slope_r2;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mult_r       <= '0;
            offset_r2    <= '0;
            use_slope_r2 <= 1'b0;
        end else begin
            mult_r       <= mult_trunc;
            offset_r2    <= offset_r;
            use_slope_r2 <= use_slope_r;
        end
    end

    // -------------------------------------------------------------------------
    // Stage 3: combinational add + output register
    // -------------------------------------------------------------------------
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            y <= '0;
        else if (!use_slope_r2)
            y <= offset_r2;
        else
            y <= offset_r2 + mult_r;   // just an adder - no multiply here
    end

endmodule