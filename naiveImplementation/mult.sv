`timescale 1ns / 1ps

// Fixed-Point Multiplier Module
module mult #(
    parameter INT_WIDTH = 8,   // Integer bits (including sign bit)
    parameter FRAC_WIDTH = 8   // Fractional bits
)(
    input  logic signed [INT_WIDTH+FRAC_WIDTH-1:0] a,
    input  logic signed [INT_WIDTH+FRAC_WIDTH-1:0] b,
    output logic signed [INT_WIDTH+FRAC_WIDTH-1:0] y
);
    localparam TOTAL_WIDTH = INT_WIDTH + FRAC_WIDTH;
    localparam PROD_WIDTH = 2 * TOTAL_WIDTH;
    
    logic signed [PROD_WIDTH-1:0] full_product;
    
    // Multiply the two signed numbers
    assign full_product = a * b;
    
    // Extract the properly aligned result
    // After multiplication, we have 2*FRAC_WIDTH fractional bits
    // We need to shift right by FRAC_WIDTH to get back to FRAC_WIDTH fractional bits
    assign y = full_product[FRAC_WIDTH +: TOTAL_WIDTH];
    
endmodule
