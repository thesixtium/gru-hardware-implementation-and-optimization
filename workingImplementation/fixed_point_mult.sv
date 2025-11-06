`timescale 1ns / 1ps


module fixed_point_mult #(
    parameter int INT_WIDTH  = 8,
    parameter int FRAC_WIDTH = 8,
    parameter int WIDTH      = INT_WIDTH + FRAC_WIDTH + 1
)(
    input  logic signed [WIDTH-1:0] a,
    input  logic signed [WIDTH-1:0] b,
    output logic signed [WIDTH-1:0] result
);

    // Full precision product (2*WIDTH bits)
    logic signed [(2*WIDTH)-1:0] product_full;

    // Multiply inputs
    assign product_full = a * b;

    // Correct fractional scaling with sign-preserving shift
    // (arithmetic shift right by FRAC_WIDTH)
    assign result = product_full >>> FRAC_WIDTH;

endmodule