`timescale 1ns / 1ps
// Corrected tanh module
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

    // Fixed-point constants
    localparam signed [WIDTH-1:0] CONST_N1 = $rtoi(-1.0 * (1 << FRAC_WIDTH));
    localparam signed [WIDTH-1:0] CONST_0  = $rtoi( 0.0 * (1 << FRAC_WIDTH));
    localparam signed [WIDTH-1:0] CONST_1  = $rtoi( 1.0 * (1 << FRAC_WIDTH));
    localparam signed [WIDTH-1:0] CONST_2  = $rtoi( 2.0 * (1 << FRAC_WIDTH));

    // Breakpoints
    localparam signed [WIDTH-1:0] BP_M3 = $rtoi(-3.0 * (1 << FRAC_WIDTH));
    localparam signed [WIDTH-1:0] BP_P3 = $rtoi( 3.0 * (1 << FRAC_WIDTH));

    // Compute 2*x with saturation
    logic signed [WIDTH:0] x_doubled_ext;
    logic signed [WIDTH-1:0] x_doubled;
    
    always_comb begin
        x_doubled_ext = {x[WIDTH-1], x} <<< 1;  // Sign-extend and shift
        
        // Saturation check
        if (x_doubled_ext[WIDTH] != x_doubled_ext[WIDTH-1]) begin
            x_doubled = x_doubled_ext[WIDTH] ? {1'b1, {(WIDTH-1){1'b0}}} : {1'b0, {(WIDTH-1){1'b1}}};
        end else begin
            x_doubled = x_doubled_ext[WIDTH-1:0];
        end
    end

    // Sigmoid of 2*x
    logic signed [WIDTH-1:0] sigmoid_out;
    
    sigmoid #(
        .INT_WIDTH(INT_WIDTH),
        .FRAC_WIDTH(FRAC_WIDTH)
    ) sig_inst (
        .clk(clk),
        .reset(reset),
        .x(x_doubled),
        .y(sigmoid_out)
    );

    // Helper function for fixed-point multiply
    function automatic logic signed [WIDTH-1:0] fx_mult(
        input logic signed [WIDTH-1:0] a,
        input logic signed [WIDTH-1:0] b
    );
        logic signed [(2*WIDTH)-1:0] product;
        product = a * b;
        fx_mult = (product + (1 <<< (FRAC_WIDTH-1))) >>> FRAC_WIDTH;
    endfunction

    // Apply tanh(x) = 2*sigmoid(2*x) - 1
    logic signed [WIDTH-1:0] tanh_result;
    logic signed [WIDTH:0] temp;
    
    always_comb begin
        if (reset) begin
            y = CONST_0;
        end else if (x <= BP_M3) begin
            y = CONST_N1;
        end else if (x >= BP_P3) begin
            y = CONST_1;
        end else begin
            // tanh(x) = 2*sigmoid(2*x) - 1
            tanh_result = fx_mult(CONST_2, sigmoid_out);
            temp = {tanh_result[WIDTH-1], tanh_result} - {CONST_1[WIDTH-1], CONST_1};
            
            // Saturation
            if (temp[WIDTH] != temp[WIDTH-1]) begin
                y = temp[WIDTH] ? {1'b1, {(WIDTH-1){1'b0}}} : {1'b0, {(WIDTH-1){1'b1}}};
            end else begin
                y = temp[WIDTH-1:0];
            end
        end
    end

endmodule