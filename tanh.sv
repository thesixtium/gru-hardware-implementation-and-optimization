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
    localparam signed [WIDTH-1:0] CONST_N1 = -(1 <<< FRAC_WIDTH);
    localparam signed [WIDTH-1:0] CONST_1  =  (1 <<< FRAC_WIDTH);
    localparam signed [WIDTH-1:0] TWO      =  (2 <<< FRAC_WIDTH);

    localparam signed [WIDTH-1:0] BP_M2 = -(2 <<< FRAC_WIDTH);
    localparam signed [WIDTH-1:0] BP_P2 =  (2 <<< FRAC_WIDTH);

    logic signed [WIDTH-1:0] x_times_2;
    logic signed [WIDTH-1:0] sigmoid_out;
    logic signed [WIDTH-1:0] scaled_result;
    logic signed [WIDTH-1:0] tanh_result;

    // CORRECTED: Proper fixed-point multiplication for 2*x
    function automatic logic signed [WIDTH-1:0] fx_mult(
        input logic signed [WIDTH-1:0] a,
        input logic signed [WIDTH-1:0] b
    );
        logic signed [(2*WIDTH)-1:0] product;
        logic signed [WIDTH:0] rounded;

        product = a * b;
        // Correct extraction: take bits [2*FRAC_WIDTH + WIDTH - 1 : FRAC_WIDTH]
        // and add rounding bit
        rounded = product[(2*WIDTH)-1:FRAC_WIDTH] + product[FRAC_WIDTH-1];

        // Saturation check
        if (rounded[WIDTH] != rounded[WIDTH-1]) begin
            fx_mult = rounded[WIDTH] ? {1'b1, {(WIDTH-1){1'b0}}} : {1'b0, {(WIDTH-1){1'b1}}};
        end else begin
            fx_mult = rounded[WIDTH-1:0];
        end
    endfunction

    // Saturating addition
    function automatic logic signed [WIDTH-1:0] sat_add(
        input logic signed [WIDTH-1:0] a,
        input logic signed [WIDTH-1:0] b
    );
        logic signed [WIDTH:0] sum_ext;
        sum_ext = {a[WIDTH-1], a} + {b[WIDTH-1], b};

        if (sum_ext[WIDTH] != sum_ext[WIDTH-1]) begin
            sat_add = sum_ext[WIDTH] ? {1'b1, {(WIDTH-1){1'b0}}} : {1'b0, {(WIDTH-1){1'b1}}};
        end else begin
            sat_add = sum_ext[WIDTH-1:0];
        end
    endfunction

    // Calculate 2*x with saturation
    assign x_times_2 = fx_mult(TWO, x);

    sigmoid #(.INT_WIDTH(INT_WIDTH), .FRAC_WIDTH(FRAC_WIDTH)) sig_inst (
        .clk(clk), .reset(reset), .x(x_times_2), .y(sigmoid_out)
    );

    // tanh(x) = 2*sigmoid(2x) - 1
    assign scaled_result = fx_mult(TWO, sigmoid_out);
    assign tanh_result = sat_add(scaled_result, -CONST_1);

    always_comb begin
        if (reset)
            y = '0;
        else if (x <= BP_M2)
            y = CONST_N1;
        else if (x >= BP_P2)
            y = CONST_1;
        else
            y = tanh_result;
    end
endmodule