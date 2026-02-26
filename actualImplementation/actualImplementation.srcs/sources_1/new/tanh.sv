module tanh #(
    parameter int INT_WIDTH  = 8,
    parameter int FRAC_WIDTH = 8,
    parameter int WIDTH      = INT_WIDTH + FRAC_WIDTH
)(
    input  logic                     reset,
    input  logic signed [WIDTH-1:0]  x,
    output logic signed [WIDTH-1:0]  y
);
    localparam signed [WIDTH-1:0] CONST_N1 = -(1 <<< FRAC_WIDTH);
    localparam signed [WIDTH-1:0] CONST_1  =  (1 <<< FRAC_WIDTH);
    localparam signed [WIDTH-1:0] TWO      =  (2 <<< FRAC_WIDTH);
    localparam signed [WIDTH-1:0] ONE      = (1 <<< FRAC_WIDTH);

    localparam signed [WIDTH-1:0] BP_M2 = -(2 <<< FRAC_WIDTH);
    localparam signed [WIDTH-1:0] BP_P2 =  (2 <<< FRAC_WIDTH);

    logic signed [WIDTH-1:0] x_times_2;
    logic signed [WIDTH-1:0] sigmoid_out;
    logic signed [WIDTH-1:0] sigmoid_out_times_2;
    logic signed [WIDTH-1:0] tanh_result;

    mult #(.INT_WIDTH(INT_WIDTH), .FRAC_WIDTH(FRAC_WIDTH)) mul_inst_1 (
        .a(x), .b( TWO ), .y(x_times_2)
    );

    sigmoid #(.INT_WIDTH(INT_WIDTH), .FRAC_WIDTH(FRAC_WIDTH)) sig_inst (
        .reset(reset), .x(x_times_2), .y(sigmoid_out)
    );

    mult #(.INT_WIDTH(INT_WIDTH), .FRAC_WIDTH(FRAC_WIDTH)) mul_inst_2 (
        .a(sigmoid_out), .b( TWO ), .y(sigmoid_out_times_2)
    );

    assign tanh_result = sigmoid_out_times_2 - ONE;

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