
`timescale 1ns / 1ps
// d = 16 (input features)
// h = 8 (hidden units)
// auto-generated top-level wrapper for GRU
module top_level(
    input  logic clk,
    input  logic reset
);

    // Parameters must match the generated GRU module parameters
    localparam int INT_WIDTH  = 6;
    localparam int FRAC_WIDTH = 14;
    localparam int WIDTH      = INT_WIDTH + FRAC_WIDTH;

    // --- Input signals (d=16) ---
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] x_0 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] x_1 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] x_2 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] x_3 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] x_4 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] x_5 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] x_6 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] x_7 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] x_8 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] x_9 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] x_10 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] x_11 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] x_12 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] x_13 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] x_14 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] x_15 = '0;

    // --- Previous hidden state (h=8) ---
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] h_0 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] h_1 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] h_2 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] h_3 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] h_4 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] h_5 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] h_6 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] h_7 = '0;

    // --- Output signals (h=8) ---
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] y_0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] y_1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] y_2;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] y_3;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] y_4;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] y_5;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] y_6;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] y_7;

    // --- Weights for input gates (h×d for each gate) ---
    // w_ir: reset gate input weights
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_0_0 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_0_1 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_0_2 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_0_3 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_0_4 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_0_5 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_0_6 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_0_7 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_0_8 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_0_9 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_0_10 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_0_11 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_0_12 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_0_13 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_0_14 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_0_15 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_1_0 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_1_1 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_1_2 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_1_3 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_1_4 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_1_5 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_1_6 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_1_7 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_1_8 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_1_9 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_1_10 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_1_11 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_1_12 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_1_13 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_1_14 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_1_15 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_2_0 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_2_1 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_2_2 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_2_3 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_2_4 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_2_5 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_2_6 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_2_7 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_2_8 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_2_9 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_2_10 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_2_11 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_2_12 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_2_13 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_2_14 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_2_15 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_3_0 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_3_1 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_3_2 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_3_3 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_3_4 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_3_5 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_3_6 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_3_7 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_3_8 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_3_9 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_3_10 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_3_11 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_3_12 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_3_13 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_3_14 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_3_15 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_4_0 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_4_1 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_4_2 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_4_3 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_4_4 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_4_5 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_4_6 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_4_7 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_4_8 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_4_9 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_4_10 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_4_11 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_4_12 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_4_13 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_4_14 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_4_15 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_5_0 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_5_1 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_5_2 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_5_3 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_5_4 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_5_5 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_5_6 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_5_7 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_5_8 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_5_9 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_5_10 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_5_11 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_5_12 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_5_13 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_5_14 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_5_15 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_6_0 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_6_1 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_6_2 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_6_3 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_6_4 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_6_5 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_6_6 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_6_7 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_6_8 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_6_9 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_6_10 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_6_11 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_6_12 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_6_13 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_6_14 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_6_15 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_7_0 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_7_1 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_7_2 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_7_3 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_7_4 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_7_5 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_7_6 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_7_7 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_7_8 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_7_9 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_7_10 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_7_11 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_7_12 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_7_13 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_7_14 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_7_15 = 16'sd1;

    // w_iz: update gate input weights
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_0_0 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_0_1 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_0_2 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_0_3 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_0_4 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_0_5 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_0_6 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_0_7 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_0_8 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_0_9 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_0_10 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_0_11 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_0_12 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_0_13 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_0_14 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_0_15 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_1_0 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_1_1 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_1_2 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_1_3 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_1_4 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_1_5 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_1_6 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_1_7 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_1_8 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_1_9 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_1_10 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_1_11 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_1_12 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_1_13 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_1_14 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_1_15 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_2_0 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_2_1 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_2_2 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_2_3 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_2_4 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_2_5 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_2_6 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_2_7 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_2_8 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_2_9 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_2_10 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_2_11 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_2_12 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_2_13 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_2_14 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_2_15 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_3_0 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_3_1 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_3_2 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_3_3 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_3_4 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_3_5 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_3_6 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_3_7 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_3_8 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_3_9 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_3_10 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_3_11 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_3_12 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_3_13 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_3_14 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_3_15 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_4_0 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_4_1 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_4_2 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_4_3 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_4_4 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_4_5 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_4_6 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_4_7 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_4_8 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_4_9 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_4_10 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_4_11 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_4_12 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_4_13 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_4_14 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_4_15 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_5_0 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_5_1 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_5_2 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_5_3 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_5_4 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_5_5 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_5_6 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_5_7 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_5_8 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_5_9 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_5_10 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_5_11 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_5_12 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_5_13 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_5_14 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_5_15 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_6_0 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_6_1 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_6_2 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_6_3 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_6_4 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_6_5 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_6_6 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_6_7 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_6_8 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_6_9 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_6_10 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_6_11 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_6_12 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_6_13 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_6_14 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_6_15 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_7_0 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_7_1 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_7_2 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_7_3 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_7_4 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_7_5 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_7_6 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_7_7 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_7_8 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_7_9 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_7_10 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_7_11 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_7_12 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_7_13 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_7_14 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_7_15 = 16'sd1;

    // w_in: new gate input weights
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_0_0 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_0_1 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_0_2 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_0_3 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_0_4 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_0_5 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_0_6 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_0_7 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_0_8 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_0_9 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_0_10 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_0_11 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_0_12 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_0_13 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_0_14 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_0_15 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_1_0 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_1_1 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_1_2 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_1_3 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_1_4 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_1_5 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_1_6 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_1_7 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_1_8 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_1_9 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_1_10 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_1_11 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_1_12 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_1_13 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_1_14 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_1_15 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_2_0 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_2_1 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_2_2 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_2_3 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_2_4 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_2_5 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_2_6 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_2_7 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_2_8 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_2_9 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_2_10 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_2_11 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_2_12 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_2_13 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_2_14 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_2_15 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_3_0 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_3_1 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_3_2 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_3_3 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_3_4 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_3_5 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_3_6 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_3_7 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_3_8 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_3_9 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_3_10 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_3_11 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_3_12 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_3_13 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_3_14 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_3_15 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_4_0 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_4_1 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_4_2 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_4_3 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_4_4 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_4_5 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_4_6 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_4_7 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_4_8 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_4_9 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_4_10 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_4_11 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_4_12 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_4_13 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_4_14 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_4_15 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_5_0 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_5_1 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_5_2 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_5_3 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_5_4 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_5_5 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_5_6 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_5_7 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_5_8 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_5_9 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_5_10 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_5_11 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_5_12 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_5_13 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_5_14 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_5_15 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_6_0 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_6_1 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_6_2 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_6_3 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_6_4 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_6_5 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_6_6 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_6_7 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_6_8 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_6_9 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_6_10 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_6_11 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_6_12 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_6_13 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_6_14 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_6_15 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_7_0 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_7_1 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_7_2 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_7_3 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_7_4 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_7_5 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_7_6 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_7_7 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_7_8 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_7_9 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_7_10 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_7_11 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_7_12 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_7_13 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_7_14 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_7_15 = 16'sd1;

    // --- Recurrent weights (h×h for each gate) ---
    // w_hr: reset gate recurrent weights
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hr_0_0 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hr_0_1 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hr_0_2 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hr_0_3 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hr_0_4 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hr_0_5 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hr_0_6 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hr_0_7 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hr_1_0 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hr_1_1 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hr_1_2 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hr_1_3 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hr_1_4 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hr_1_5 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hr_1_6 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hr_1_7 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hr_2_0 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hr_2_1 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hr_2_2 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hr_2_3 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hr_2_4 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hr_2_5 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hr_2_6 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hr_2_7 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hr_3_0 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hr_3_1 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hr_3_2 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hr_3_3 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hr_3_4 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hr_3_5 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hr_3_6 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hr_3_7 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hr_4_0 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hr_4_1 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hr_4_2 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hr_4_3 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hr_4_4 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hr_4_5 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hr_4_6 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hr_4_7 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hr_5_0 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hr_5_1 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hr_5_2 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hr_5_3 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hr_5_4 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hr_5_5 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hr_5_6 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hr_5_7 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hr_6_0 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hr_6_1 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hr_6_2 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hr_6_3 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hr_6_4 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hr_6_5 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hr_6_6 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hr_6_7 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hr_7_0 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hr_7_1 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hr_7_2 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hr_7_3 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hr_7_4 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hr_7_5 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hr_7_6 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hr_7_7 = 16'sd1;

    // w_hz: update gate recurrent weights
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hz_0_0 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hz_0_1 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hz_0_2 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hz_0_3 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hz_0_4 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hz_0_5 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hz_0_6 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hz_0_7 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hz_1_0 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hz_1_1 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hz_1_2 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hz_1_3 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hz_1_4 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hz_1_5 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hz_1_6 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hz_1_7 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hz_2_0 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hz_2_1 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hz_2_2 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hz_2_3 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hz_2_4 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hz_2_5 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hz_2_6 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hz_2_7 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hz_3_0 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hz_3_1 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hz_3_2 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hz_3_3 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hz_3_4 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hz_3_5 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hz_3_6 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hz_3_7 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hz_4_0 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hz_4_1 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hz_4_2 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hz_4_3 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hz_4_4 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hz_4_5 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hz_4_6 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hz_4_7 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hz_5_0 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hz_5_1 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hz_5_2 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hz_5_3 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hz_5_4 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hz_5_5 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hz_5_6 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hz_5_7 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hz_6_0 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hz_6_1 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hz_6_2 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hz_6_3 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hz_6_4 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hz_6_5 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hz_6_6 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hz_6_7 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hz_7_0 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hz_7_1 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hz_7_2 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hz_7_3 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hz_7_4 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hz_7_5 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hz_7_6 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hz_7_7 = 16'sd1;

    // w_hn: new gate recurrent weights
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hn_0_0 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hn_0_1 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hn_0_2 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hn_0_3 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hn_0_4 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hn_0_5 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hn_0_6 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hn_0_7 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hn_1_0 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hn_1_1 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hn_1_2 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hn_1_3 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hn_1_4 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hn_1_5 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hn_1_6 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hn_1_7 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hn_2_0 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hn_2_1 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hn_2_2 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hn_2_3 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hn_2_4 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hn_2_5 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hn_2_6 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hn_2_7 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hn_3_0 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hn_3_1 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hn_3_2 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hn_3_3 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hn_3_4 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hn_3_5 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hn_3_6 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hn_3_7 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hn_4_0 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hn_4_1 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hn_4_2 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hn_4_3 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hn_4_4 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hn_4_5 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hn_4_6 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hn_4_7 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hn_5_0 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hn_5_1 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hn_5_2 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hn_5_3 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hn_5_4 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hn_5_5 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hn_5_6 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hn_5_7 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hn_6_0 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hn_6_1 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hn_6_2 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hn_6_3 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hn_6_4 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hn_6_5 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hn_6_6 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hn_6_7 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hn_7_0 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hn_7_1 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hn_7_2 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hn_7_3 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hn_7_4 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hn_7_5 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hn_7_6 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hn_7_7 = 16'sd1;

    // --- Biases (h for each gate type) ---
    // Input-to-hidden biases
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] b_ir_0 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] b_ir_1 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] b_ir_2 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] b_ir_3 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] b_ir_4 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] b_ir_5 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] b_ir_6 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] b_ir_7 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] b_iz_0 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] b_iz_1 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] b_iz_2 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] b_iz_3 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] b_iz_4 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] b_iz_5 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] b_iz_6 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] b_iz_7 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] b_in_0 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] b_in_1 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] b_in_2 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] b_in_3 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] b_in_4 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] b_in_5 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] b_in_6 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] b_in_7 = '0;

    // Hidden-to-hidden biases
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] b_hr_0 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] b_hr_1 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] b_hr_2 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] b_hr_3 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] b_hr_4 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] b_hr_5 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] b_hr_6 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] b_hr_7 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] b_hz_0 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] b_hz_1 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] b_hz_2 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] b_hz_3 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] b_hz_4 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] b_hz_5 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] b_hz_6 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] b_hz_7 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] b_hn_0 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] b_hn_1 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] b_hn_2 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] b_hn_3 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] b_hn_4 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] b_hn_5 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] b_hn_6 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] b_hn_7 = '0;

    // --- Final registers to capture and preserve the outputs ---
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] preserved_y_0 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] preserved_y_1 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] preserved_y_2 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] preserved_y_3 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] preserved_y_4 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] preserved_y_5 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] preserved_y_6 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] preserved_y_7 = '0;

    // --- Instantiate the generated GRU module ---
    (* keep = "true", dont_touch = "true" *) gru #(
        .INT_WIDTH(INT_WIDTH),
        .FRAC_WIDTH(FRAC_WIDTH)
    ) gru_inst (
        .clk(clk),
        .reset(reset),
        // Input features (d=16)

        .x_0(x_0),
        .x_1(x_1),
        .x_2(x_2),
        .x_3(x_3),
        .x_4(x_4),
        .x_5(x_5),
        .x_6(x_6),
        .x_7(x_7),
        .x_8(x_8),
        .x_9(x_9),
        .x_10(x_10),
        .x_11(x_11),
        .x_12(x_12),
        .x_13(x_13),
        .x_14(x_14),
        .x_15(x_15),
        // Hidden states (h=8)

        .h_0(h_0),
        .h_1(h_1),
        .h_2(h_2),
        .h_3(h_3),
        .h_4(h_4),
        .h_5(h_5),
        .h_6(h_6),
        .h_7(h_7),
        // Input weights for reset gate

        .w_ir_0_0(w_ir_0_0),
        .w_ir_0_1(w_ir_0_1),
        .w_ir_0_2(w_ir_0_2),
        .w_ir_0_3(w_ir_0_3),
        .w_ir_0_4(w_ir_0_4),
        .w_ir_0_5(w_ir_0_5),
        .w_ir_0_6(w_ir_0_6),
        .w_ir_0_7(w_ir_0_7),
        .w_ir_0_8(w_ir_0_8),
        .w_ir_0_9(w_ir_0_9),
        .w_ir_0_10(w_ir_0_10),
        .w_ir_0_11(w_ir_0_11),
        .w_ir_0_12(w_ir_0_12),
        .w_ir_0_13(w_ir_0_13),
        .w_ir_0_14(w_ir_0_14),
        .w_ir_0_15(w_ir_0_15),
        .w_ir_1_0(w_ir_1_0),
        .w_ir_1_1(w_ir_1_1),
        .w_ir_1_2(w_ir_1_2),
        .w_ir_1_3(w_ir_1_3),
        .w_ir_1_4(w_ir_1_4),
        .w_ir_1_5(w_ir_1_5),
        .w_ir_1_6(w_ir_1_6),
        .w_ir_1_7(w_ir_1_7),
        .w_ir_1_8(w_ir_1_8),
        .w_ir_1_9(w_ir_1_9),
        .w_ir_1_10(w_ir_1_10),
        .w_ir_1_11(w_ir_1_11),
        .w_ir_1_12(w_ir_1_12),
        .w_ir_1_13(w_ir_1_13),
        .w_ir_1_14(w_ir_1_14),
        .w_ir_1_15(w_ir_1_15),
        .w_ir_2_0(w_ir_2_0),
        .w_ir_2_1(w_ir_2_1),
        .w_ir_2_2(w_ir_2_2),
        .w_ir_2_3(w_ir_2_3),
        .w_ir_2_4(w_ir_2_4),
        .w_ir_2_5(w_ir_2_5),
        .w_ir_2_6(w_ir_2_6),
        .w_ir_2_7(w_ir_2_7),
        .w_ir_2_8(w_ir_2_8),
        .w_ir_2_9(w_ir_2_9),
        .w_ir_2_10(w_ir_2_10),
        .w_ir_2_11(w_ir_2_11),
        .w_ir_2_12(w_ir_2_12),
        .w_ir_2_13(w_ir_2_13),
        .w_ir_2_14(w_ir_2_14),
        .w_ir_2_15(w_ir_2_15),
        .w_ir_3_0(w_ir_3_0),
        .w_ir_3_1(w_ir_3_1),
        .w_ir_3_2(w_ir_3_2),
        .w_ir_3_3(w_ir_3_3),
        .w_ir_3_4(w_ir_3_4),
        .w_ir_3_5(w_ir_3_5),
        .w_ir_3_6(w_ir_3_6),
        .w_ir_3_7(w_ir_3_7),
        .w_ir_3_8(w_ir_3_8),
        .w_ir_3_9(w_ir_3_9),
        .w_ir_3_10(w_ir_3_10),
        .w_ir_3_11(w_ir_3_11),
        .w_ir_3_12(w_ir_3_12),
        .w_ir_3_13(w_ir_3_13),
        .w_ir_3_14(w_ir_3_14),
        .w_ir_3_15(w_ir_3_15),
        .w_ir_4_0(w_ir_4_0),
        .w_ir_4_1(w_ir_4_1),
        .w_ir_4_2(w_ir_4_2),
        .w_ir_4_3(w_ir_4_3),
        .w_ir_4_4(w_ir_4_4),
        .w_ir_4_5(w_ir_4_5),
        .w_ir_4_6(w_ir_4_6),
        .w_ir_4_7(w_ir_4_7),
        .w_ir_4_8(w_ir_4_8),
        .w_ir_4_9(w_ir_4_9),
        .w_ir_4_10(w_ir_4_10),
        .w_ir_4_11(w_ir_4_11),
        .w_ir_4_12(w_ir_4_12),
        .w_ir_4_13(w_ir_4_13),
        .w_ir_4_14(w_ir_4_14),
        .w_ir_4_15(w_ir_4_15),
        .w_ir_5_0(w_ir_5_0),
        .w_ir_5_1(w_ir_5_1),
        .w_ir_5_2(w_ir_5_2),
        .w_ir_5_3(w_ir_5_3),
        .w_ir_5_4(w_ir_5_4),
        .w_ir_5_5(w_ir_5_5),
        .w_ir_5_6(w_ir_5_6),
        .w_ir_5_7(w_ir_5_7),
        .w_ir_5_8(w_ir_5_8),
        .w_ir_5_9(w_ir_5_9),
        .w_ir_5_10(w_ir_5_10),
        .w_ir_5_11(w_ir_5_11),
        .w_ir_5_12(w_ir_5_12),
        .w_ir_5_13(w_ir_5_13),
        .w_ir_5_14(w_ir_5_14),
        .w_ir_5_15(w_ir_5_15),
        .w_ir_6_0(w_ir_6_0),
        .w_ir_6_1(w_ir_6_1),
        .w_ir_6_2(w_ir_6_2),
        .w_ir_6_3(w_ir_6_3),
        .w_ir_6_4(w_ir_6_4),
        .w_ir_6_5(w_ir_6_5),
        .w_ir_6_6(w_ir_6_6),
        .w_ir_6_7(w_ir_6_7),
        .w_ir_6_8(w_ir_6_8),
        .w_ir_6_9(w_ir_6_9),
        .w_ir_6_10(w_ir_6_10),
        .w_ir_6_11(w_ir_6_11),
        .w_ir_6_12(w_ir_6_12),
        .w_ir_6_13(w_ir_6_13),
        .w_ir_6_14(w_ir_6_14),
        .w_ir_6_15(w_ir_6_15),
        .w_ir_7_0(w_ir_7_0),
        .w_ir_7_1(w_ir_7_1),
        .w_ir_7_2(w_ir_7_2),
        .w_ir_7_3(w_ir_7_3),
        .w_ir_7_4(w_ir_7_4),
        .w_ir_7_5(w_ir_7_5),
        .w_ir_7_6(w_ir_7_6),
        .w_ir_7_7(w_ir_7_7),
        .w_ir_7_8(w_ir_7_8),
        .w_ir_7_9(w_ir_7_9),
        .w_ir_7_10(w_ir_7_10),
        .w_ir_7_11(w_ir_7_11),
        .w_ir_7_12(w_ir_7_12),
        .w_ir_7_13(w_ir_7_13),
        .w_ir_7_14(w_ir_7_14),
        .w_ir_7_15(w_ir_7_15),
        // Input weights for update gate

        .w_iz_0_0(w_iz_0_0),
        .w_iz_0_1(w_iz_0_1),
        .w_iz_0_2(w_iz_0_2),
        .w_iz_0_3(w_iz_0_3),
        .w_iz_0_4(w_iz_0_4),
        .w_iz_0_5(w_iz_0_5),
        .w_iz_0_6(w_iz_0_6),
        .w_iz_0_7(w_iz_0_7),
        .w_iz_0_8(w_iz_0_8),
        .w_iz_0_9(w_iz_0_9),
        .w_iz_0_10(w_iz_0_10),
        .w_iz_0_11(w_iz_0_11),
        .w_iz_0_12(w_iz_0_12),
        .w_iz_0_13(w_iz_0_13),
        .w_iz_0_14(w_iz_0_14),
        .w_iz_0_15(w_iz_0_15),
        .w_iz_1_0(w_iz_1_0),
        .w_iz_1_1(w_iz_1_1),
        .w_iz_1_2(w_iz_1_2),
        .w_iz_1_3(w_iz_1_3),
        .w_iz_1_4(w_iz_1_4),
        .w_iz_1_5(w_iz_1_5),
        .w_iz_1_6(w_iz_1_6),
        .w_iz_1_7(w_iz_1_7),
        .w_iz_1_8(w_iz_1_8),
        .w_iz_1_9(w_iz_1_9),
        .w_iz_1_10(w_iz_1_10),
        .w_iz_1_11(w_iz_1_11),
        .w_iz_1_12(w_iz_1_12),
        .w_iz_1_13(w_iz_1_13),
        .w_iz_1_14(w_iz_1_14),
        .w_iz_1_15(w_iz_1_15),
        .w_iz_2_0(w_iz_2_0),
        .w_iz_2_1(w_iz_2_1),
        .w_iz_2_2(w_iz_2_2),
        .w_iz_2_3(w_iz_2_3),
        .w_iz_2_4(w_iz_2_4),
        .w_iz_2_5(w_iz_2_5),
        .w_iz_2_6(w_iz_2_6),
        .w_iz_2_7(w_iz_2_7),
        .w_iz_2_8(w_iz_2_8),
        .w_iz_2_9(w_iz_2_9),
        .w_iz_2_10(w_iz_2_10),
        .w_iz_2_11(w_iz_2_11),
        .w_iz_2_12(w_iz_2_12),
        .w_iz_2_13(w_iz_2_13),
        .w_iz_2_14(w_iz_2_14),
        .w_iz_2_15(w_iz_2_15),
        .w_iz_3_0(w_iz_3_0),
        .w_iz_3_1(w_iz_3_1),
        .w_iz_3_2(w_iz_3_2),
        .w_iz_3_3(w_iz_3_3),
        .w_iz_3_4(w_iz_3_4),
        .w_iz_3_5(w_iz_3_5),
        .w_iz_3_6(w_iz_3_6),
        .w_iz_3_7(w_iz_3_7),
        .w_iz_3_8(w_iz_3_8),
        .w_iz_3_9(w_iz_3_9),
        .w_iz_3_10(w_iz_3_10),
        .w_iz_3_11(w_iz_3_11),
        .w_iz_3_12(w_iz_3_12),
        .w_iz_3_13(w_iz_3_13),
        .w_iz_3_14(w_iz_3_14),
        .w_iz_3_15(w_iz_3_15),
        .w_iz_4_0(w_iz_4_0),
        .w_iz_4_1(w_iz_4_1),
        .w_iz_4_2(w_iz_4_2),
        .w_iz_4_3(w_iz_4_3),
        .w_iz_4_4(w_iz_4_4),
        .w_iz_4_5(w_iz_4_5),
        .w_iz_4_6(w_iz_4_6),
        .w_iz_4_7(w_iz_4_7),
        .w_iz_4_8(w_iz_4_8),
        .w_iz_4_9(w_iz_4_9),
        .w_iz_4_10(w_iz_4_10),
        .w_iz_4_11(w_iz_4_11),
        .w_iz_4_12(w_iz_4_12),
        .w_iz_4_13(w_iz_4_13),
        .w_iz_4_14(w_iz_4_14),
        .w_iz_4_15(w_iz_4_15),
        .w_iz_5_0(w_iz_5_0),
        .w_iz_5_1(w_iz_5_1),
        .w_iz_5_2(w_iz_5_2),
        .w_iz_5_3(w_iz_5_3),
        .w_iz_5_4(w_iz_5_4),
        .w_iz_5_5(w_iz_5_5),
        .w_iz_5_6(w_iz_5_6),
        .w_iz_5_7(w_iz_5_7),
        .w_iz_5_8(w_iz_5_8),
        .w_iz_5_9(w_iz_5_9),
        .w_iz_5_10(w_iz_5_10),
        .w_iz_5_11(w_iz_5_11),
        .w_iz_5_12(w_iz_5_12),
        .w_iz_5_13(w_iz_5_13),
        .w_iz_5_14(w_iz_5_14),
        .w_iz_5_15(w_iz_5_15),
        .w_iz_6_0(w_iz_6_0),
        .w_iz_6_1(w_iz_6_1),
        .w_iz_6_2(w_iz_6_2),
        .w_iz_6_3(w_iz_6_3),
        .w_iz_6_4(w_iz_6_4),
        .w_iz_6_5(w_iz_6_5),
        .w_iz_6_6(w_iz_6_6),
        .w_iz_6_7(w_iz_6_7),
        .w_iz_6_8(w_iz_6_8),
        .w_iz_6_9(w_iz_6_9),
        .w_iz_6_10(w_iz_6_10),
        .w_iz_6_11(w_iz_6_11),
        .w_iz_6_12(w_iz_6_12),
        .w_iz_6_13(w_iz_6_13),
        .w_iz_6_14(w_iz_6_14),
        .w_iz_6_15(w_iz_6_15),
        .w_iz_7_0(w_iz_7_0),
        .w_iz_7_1(w_iz_7_1),
        .w_iz_7_2(w_iz_7_2),
        .w_iz_7_3(w_iz_7_3),
        .w_iz_7_4(w_iz_7_4),
        .w_iz_7_5(w_iz_7_5),
        .w_iz_7_6(w_iz_7_6),
        .w_iz_7_7(w_iz_7_7),
        .w_iz_7_8(w_iz_7_8),
        .w_iz_7_9(w_iz_7_9),
        .w_iz_7_10(w_iz_7_10),
        .w_iz_7_11(w_iz_7_11),
        .w_iz_7_12(w_iz_7_12),
        .w_iz_7_13(w_iz_7_13),
        .w_iz_7_14(w_iz_7_14),
        .w_iz_7_15(w_iz_7_15),
        // Input weights for new gate

        .w_in_0_0(w_in_0_0),
        .w_in_0_1(w_in_0_1),
        .w_in_0_2(w_in_0_2),
        .w_in_0_3(w_in_0_3),
        .w_in_0_4(w_in_0_4),
        .w_in_0_5(w_in_0_5),
        .w_in_0_6(w_in_0_6),
        .w_in_0_7(w_in_0_7),
        .w_in_0_8(w_in_0_8),
        .w_in_0_9(w_in_0_9),
        .w_in_0_10(w_in_0_10),
        .w_in_0_11(w_in_0_11),
        .w_in_0_12(w_in_0_12),
        .w_in_0_13(w_in_0_13),
        .w_in_0_14(w_in_0_14),
        .w_in_0_15(w_in_0_15),
        .w_in_1_0(w_in_1_0),
        .w_in_1_1(w_in_1_1),
        .w_in_1_2(w_in_1_2),
        .w_in_1_3(w_in_1_3),
        .w_in_1_4(w_in_1_4),
        .w_in_1_5(w_in_1_5),
        .w_in_1_6(w_in_1_6),
        .w_in_1_7(w_in_1_7),
        .w_in_1_8(w_in_1_8),
        .w_in_1_9(w_in_1_9),
        .w_in_1_10(w_in_1_10),
        .w_in_1_11(w_in_1_11),
        .w_in_1_12(w_in_1_12),
        .w_in_1_13(w_in_1_13),
        .w_in_1_14(w_in_1_14),
        .w_in_1_15(w_in_1_15),
        .w_in_2_0(w_in_2_0),
        .w_in_2_1(w_in_2_1),
        .w_in_2_2(w_in_2_2),
        .w_in_2_3(w_in_2_3),
        .w_in_2_4(w_in_2_4),
        .w_in_2_5(w_in_2_5),
        .w_in_2_6(w_in_2_6),
        .w_in_2_7(w_in_2_7),
        .w_in_2_8(w_in_2_8),
        .w_in_2_9(w_in_2_9),
        .w_in_2_10(w_in_2_10),
        .w_in_2_11(w_in_2_11),
        .w_in_2_12(w_in_2_12),
        .w_in_2_13(w_in_2_13),
        .w_in_2_14(w_in_2_14),
        .w_in_2_15(w_in_2_15),
        .w_in_3_0(w_in_3_0),
        .w_in_3_1(w_in_3_1),
        .w_in_3_2(w_in_3_2),
        .w_in_3_3(w_in_3_3),
        .w_in_3_4(w_in_3_4),
        .w_in_3_5(w_in_3_5),
        .w_in_3_6(w_in_3_6),
        .w_in_3_7(w_in_3_7),
        .w_in_3_8(w_in_3_8),
        .w_in_3_9(w_in_3_9),
        .w_in_3_10(w_in_3_10),
        .w_in_3_11(w_in_3_11),
        .w_in_3_12(w_in_3_12),
        .w_in_3_13(w_in_3_13),
        .w_in_3_14(w_in_3_14),
        .w_in_3_15(w_in_3_15),
        .w_in_4_0(w_in_4_0),
        .w_in_4_1(w_in_4_1),
        .w_in_4_2(w_in_4_2),
        .w_in_4_3(w_in_4_3),
        .w_in_4_4(w_in_4_4),
        .w_in_4_5(w_in_4_5),
        .w_in_4_6(w_in_4_6),
        .w_in_4_7(w_in_4_7),
        .w_in_4_8(w_in_4_8),
        .w_in_4_9(w_in_4_9),
        .w_in_4_10(w_in_4_10),
        .w_in_4_11(w_in_4_11),
        .w_in_4_12(w_in_4_12),
        .w_in_4_13(w_in_4_13),
        .w_in_4_14(w_in_4_14),
        .w_in_4_15(w_in_4_15),
        .w_in_5_0(w_in_5_0),
        .w_in_5_1(w_in_5_1),
        .w_in_5_2(w_in_5_2),
        .w_in_5_3(w_in_5_3),
        .w_in_5_4(w_in_5_4),
        .w_in_5_5(w_in_5_5),
        .w_in_5_6(w_in_5_6),
        .w_in_5_7(w_in_5_7),
        .w_in_5_8(w_in_5_8),
        .w_in_5_9(w_in_5_9),
        .w_in_5_10(w_in_5_10),
        .w_in_5_11(w_in_5_11),
        .w_in_5_12(w_in_5_12),
        .w_in_5_13(w_in_5_13),
        .w_in_5_14(w_in_5_14),
        .w_in_5_15(w_in_5_15),
        .w_in_6_0(w_in_6_0),
        .w_in_6_1(w_in_6_1),
        .w_in_6_2(w_in_6_2),
        .w_in_6_3(w_in_6_3),
        .w_in_6_4(w_in_6_4),
        .w_in_6_5(w_in_6_5),
        .w_in_6_6(w_in_6_6),
        .w_in_6_7(w_in_6_7),
        .w_in_6_8(w_in_6_8),
        .w_in_6_9(w_in_6_9),
        .w_in_6_10(w_in_6_10),
        .w_in_6_11(w_in_6_11),
        .w_in_6_12(w_in_6_12),
        .w_in_6_13(w_in_6_13),
        .w_in_6_14(w_in_6_14),
        .w_in_6_15(w_in_6_15),
        .w_in_7_0(w_in_7_0),
        .w_in_7_1(w_in_7_1),
        .w_in_7_2(w_in_7_2),
        .w_in_7_3(w_in_7_3),
        .w_in_7_4(w_in_7_4),
        .w_in_7_5(w_in_7_5),
        .w_in_7_6(w_in_7_6),
        .w_in_7_7(w_in_7_7),
        .w_in_7_8(w_in_7_8),
        .w_in_7_9(w_in_7_9),
        .w_in_7_10(w_in_7_10),
        .w_in_7_11(w_in_7_11),
        .w_in_7_12(w_in_7_12),
        .w_in_7_13(w_in_7_13),
        .w_in_7_14(w_in_7_14),
        .w_in_7_15(w_in_7_15),
        // Recurrent weights for reset gate

        .w_hr_0_0(w_hr_0_0),
        .w_hr_0_1(w_hr_0_1),
        .w_hr_0_2(w_hr_0_2),
        .w_hr_0_3(w_hr_0_3),
        .w_hr_0_4(w_hr_0_4),
        .w_hr_0_5(w_hr_0_5),
        .w_hr_0_6(w_hr_0_6),
        .w_hr_0_7(w_hr_0_7),
        .w_hr_1_0(w_hr_1_0),
        .w_hr_1_1(w_hr_1_1),
        .w_hr_1_2(w_hr_1_2),
        .w_hr_1_3(w_hr_1_3),
        .w_hr_1_4(w_hr_1_4),
        .w_hr_1_5(w_hr_1_5),
        .w_hr_1_6(w_hr_1_6),
        .w_hr_1_7(w_hr_1_7),
        .w_hr_2_0(w_hr_2_0),
        .w_hr_2_1(w_hr_2_1),
        .w_hr_2_2(w_hr_2_2),
        .w_hr_2_3(w_hr_2_3),
        .w_hr_2_4(w_hr_2_4),
        .w_hr_2_5(w_hr_2_5),
        .w_hr_2_6(w_hr_2_6),
        .w_hr_2_7(w_hr_2_7),
        .w_hr_3_0(w_hr_3_0),
        .w_hr_3_1(w_hr_3_1),
        .w_hr_3_2(w_hr_3_2),
        .w_hr_3_3(w_hr_3_3),
        .w_hr_3_4(w_hr_3_4),
        .w_hr_3_5(w_hr_3_5),
        .w_hr_3_6(w_hr_3_6),
        .w_hr_3_7(w_hr_3_7),
        .w_hr_4_0(w_hr_4_0),
        .w_hr_4_1(w_hr_4_1),
        .w_hr_4_2(w_hr_4_2),
        .w_hr_4_3(w_hr_4_3),
        .w_hr_4_4(w_hr_4_4),
        .w_hr_4_5(w_hr_4_5),
        .w_hr_4_6(w_hr_4_6),
        .w_hr_4_7(w_hr_4_7),
        .w_hr_5_0(w_hr_5_0),
        .w_hr_5_1(w_hr_5_1),
        .w_hr_5_2(w_hr_5_2),
        .w_hr_5_3(w_hr_5_3),
        .w_hr_5_4(w_hr_5_4),
        .w_hr_5_5(w_hr_5_5),
        .w_hr_5_6(w_hr_5_6),
        .w_hr_5_7(w_hr_5_7),
        .w_hr_6_0(w_hr_6_0),
        .w_hr_6_1(w_hr_6_1),
        .w_hr_6_2(w_hr_6_2),
        .w_hr_6_3(w_hr_6_3),
        .w_hr_6_4(w_hr_6_4),
        .w_hr_6_5(w_hr_6_5),
        .w_hr_6_6(w_hr_6_6),
        .w_hr_6_7(w_hr_6_7),
        .w_hr_7_0(w_hr_7_0),
        .w_hr_7_1(w_hr_7_1),
        .w_hr_7_2(w_hr_7_2),
        .w_hr_7_3(w_hr_7_3),
        .w_hr_7_4(w_hr_7_4),
        .w_hr_7_5(w_hr_7_5),
        .w_hr_7_6(w_hr_7_6),
        .w_hr_7_7(w_hr_7_7),
        // Recurrent weights for update gate

        .w_hz_0_0(w_hz_0_0),
        .w_hz_0_1(w_hz_0_1),
        .w_hz_0_2(w_hz_0_2),
        .w_hz_0_3(w_hz_0_3),
        .w_hz_0_4(w_hz_0_4),
        .w_hz_0_5(w_hz_0_5),
        .w_hz_0_6(w_hz_0_6),
        .w_hz_0_7(w_hz_0_7),
        .w_hz_1_0(w_hz_1_0),
        .w_hz_1_1(w_hz_1_1),
        .w_hz_1_2(w_hz_1_2),
        .w_hz_1_3(w_hz_1_3),
        .w_hz_1_4(w_hz_1_4),
        .w_hz_1_5(w_hz_1_5),
        .w_hz_1_6(w_hz_1_6),
        .w_hz_1_7(w_hz_1_7),
        .w_hz_2_0(w_hz_2_0),
        .w_hz_2_1(w_hz_2_1),
        .w_hz_2_2(w_hz_2_2),
        .w_hz_2_3(w_hz_2_3),
        .w_hz_2_4(w_hz_2_4),
        .w_hz_2_5(w_hz_2_5),
        .w_hz_2_6(w_hz_2_6),
        .w_hz_2_7(w_hz_2_7),
        .w_hz_3_0(w_hz_3_0),
        .w_hz_3_1(w_hz_3_1),
        .w_hz_3_2(w_hz_3_2),
        .w_hz_3_3(w_hz_3_3),
        .w_hz_3_4(w_hz_3_4),
        .w_hz_3_5(w_hz_3_5),
        .w_hz_3_6(w_hz_3_6),
        .w_hz_3_7(w_hz_3_7),
        .w_hz_4_0(w_hz_4_0),
        .w_hz_4_1(w_hz_4_1),
        .w_hz_4_2(w_hz_4_2),
        .w_hz_4_3(w_hz_4_3),
        .w_hz_4_4(w_hz_4_4),
        .w_hz_4_5(w_hz_4_5),
        .w_hz_4_6(w_hz_4_6),
        .w_hz_4_7(w_hz_4_7),
        .w_hz_5_0(w_hz_5_0),
        .w_hz_5_1(w_hz_5_1),
        .w_hz_5_2(w_hz_5_2),
        .w_hz_5_3(w_hz_5_3),
        .w_hz_5_4(w_hz_5_4),
        .w_hz_5_5(w_hz_5_5),
        .w_hz_5_6(w_hz_5_6),
        .w_hz_5_7(w_hz_5_7),
        .w_hz_6_0(w_hz_6_0),
        .w_hz_6_1(w_hz_6_1),
        .w_hz_6_2(w_hz_6_2),
        .w_hz_6_3(w_hz_6_3),
        .w_hz_6_4(w_hz_6_4),
        .w_hz_6_5(w_hz_6_5),
        .w_hz_6_6(w_hz_6_6),
        .w_hz_6_7(w_hz_6_7),
        .w_hz_7_0(w_hz_7_0),
        .w_hz_7_1(w_hz_7_1),
        .w_hz_7_2(w_hz_7_2),
        .w_hz_7_3(w_hz_7_3),
        .w_hz_7_4(w_hz_7_4),
        .w_hz_7_5(w_hz_7_5),
        .w_hz_7_6(w_hz_7_6),
        .w_hz_7_7(w_hz_7_7),
        // Recurrent weights for new gate

        .w_hn_0_0(w_hn_0_0),
        .w_hn_0_1(w_hn_0_1),
        .w_hn_0_2(w_hn_0_2),
        .w_hn_0_3(w_hn_0_3),
        .w_hn_0_4(w_hn_0_4),
        .w_hn_0_5(w_hn_0_5),
        .w_hn_0_6(w_hn_0_6),
        .w_hn_0_7(w_hn_0_7),
        .w_hn_1_0(w_hn_1_0),
        .w_hn_1_1(w_hn_1_1),
        .w_hn_1_2(w_hn_1_2),
        .w_hn_1_3(w_hn_1_3),
        .w_hn_1_4(w_hn_1_4),
        .w_hn_1_5(w_hn_1_5),
        .w_hn_1_6(w_hn_1_6),
        .w_hn_1_7(w_hn_1_7),
        .w_hn_2_0(w_hn_2_0),
        .w_hn_2_1(w_hn_2_1),
        .w_hn_2_2(w_hn_2_2),
        .w_hn_2_3(w_hn_2_3),
        .w_hn_2_4(w_hn_2_4),
        .w_hn_2_5(w_hn_2_5),
        .w_hn_2_6(w_hn_2_6),
        .w_hn_2_7(w_hn_2_7),
        .w_hn_3_0(w_hn_3_0),
        .w_hn_3_1(w_hn_3_1),
        .w_hn_3_2(w_hn_3_2),
        .w_hn_3_3(w_hn_3_3),
        .w_hn_3_4(w_hn_3_4),
        .w_hn_3_5(w_hn_3_5),
        .w_hn_3_6(w_hn_3_6),
        .w_hn_3_7(w_hn_3_7),
        .w_hn_4_0(w_hn_4_0),
        .w_hn_4_1(w_hn_4_1),
        .w_hn_4_2(w_hn_4_2),
        .w_hn_4_3(w_hn_4_3),
        .w_hn_4_4(w_hn_4_4),
        .w_hn_4_5(w_hn_4_5),
        .w_hn_4_6(w_hn_4_6),
        .w_hn_4_7(w_hn_4_7),
        .w_hn_5_0(w_hn_5_0),
        .w_hn_5_1(w_hn_5_1),
        .w_hn_5_2(w_hn_5_2),
        .w_hn_5_3(w_hn_5_3),
        .w_hn_5_4(w_hn_5_4),
        .w_hn_5_5(w_hn_5_5),
        .w_hn_5_6(w_hn_5_6),
        .w_hn_5_7(w_hn_5_7),
        .w_hn_6_0(w_hn_6_0),
        .w_hn_6_1(w_hn_6_1),
        .w_hn_6_2(w_hn_6_2),
        .w_hn_6_3(w_hn_6_3),
        .w_hn_6_4(w_hn_6_4),
        .w_hn_6_5(w_hn_6_5),
        .w_hn_6_6(w_hn_6_6),
        .w_hn_6_7(w_hn_6_7),
        .w_hn_7_0(w_hn_7_0),
        .w_hn_7_1(w_hn_7_1),
        .w_hn_7_2(w_hn_7_2),
        .w_hn_7_3(w_hn_7_3),
        .w_hn_7_4(w_hn_7_4),
        .w_hn_7_5(w_hn_7_5),
        .w_hn_7_6(w_hn_7_6),
        .w_hn_7_7(w_hn_7_7),
        // Biases

        .b_ir_0(b_ir_0),
        .b_ir_1(b_ir_1),
        .b_ir_2(b_ir_2),
        .b_ir_3(b_ir_3),
        .b_ir_4(b_ir_4),
        .b_ir_5(b_ir_5),
        .b_ir_6(b_ir_6),
        .b_ir_7(b_ir_7),
        .b_iz_0(b_iz_0),
        .b_iz_1(b_iz_1),
        .b_iz_2(b_iz_2),
        .b_iz_3(b_iz_3),
        .b_iz_4(b_iz_4),
        .b_iz_5(b_iz_5),
        .b_iz_6(b_iz_6),
        .b_iz_7(b_iz_7),
        .b_in_0(b_in_0),
        .b_in_1(b_in_1),
        .b_in_2(b_in_2),
        .b_in_3(b_in_3),
        .b_in_4(b_in_4),
        .b_in_5(b_in_5),
        .b_in_6(b_in_6),
        .b_in_7(b_in_7),
        .b_hr_0(b_hr_0),
        .b_hr_1(b_hr_1),
        .b_hr_2(b_hr_2),
        .b_hr_3(b_hr_3),
        .b_hr_4(b_hr_4),
        .b_hr_5(b_hr_5),
        .b_hr_6(b_hr_6),
        .b_hr_7(b_hr_7),
        .b_hz_0(b_hz_0),
        .b_hz_1(b_hz_1),
        .b_hz_2(b_hz_2),
        .b_hz_3(b_hz_3),
        .b_hz_4(b_hz_4),
        .b_hz_5(b_hz_5),
        .b_hz_6(b_hz_6),
        .b_hz_7(b_hz_7),
        .b_hn_0(b_hn_0),
        .b_hn_1(b_hn_1),
        .b_hn_2(b_hn_2),
        .b_hn_3(b_hn_3),
        .b_hn_4(b_hn_4),
        .b_hn_5(b_hn_5),
        .b_hn_6(b_hn_6),
        .b_hn_7(b_hn_7),
        // Outputs (h=8)

        .y_0(y_0),
        .y_1(y_1),
        .y_2(y_2),
        .y_3(y_3),
        .y_4(y_4),
        .y_5(y_5),
        .y_6(y_6),
        .y_7(y_7)
    );

    // --- Capture outputs into preserved registers ---
    always_ff @(posedge clk) begin
        if (reset) begin
            preserved_y_0 <= '0;
            preserved_y_1 <= '0;
            preserved_y_2 <= '0;
            preserved_y_3 <= '0;
            preserved_y_4 <= '0;
            preserved_y_5 <= '0;
            preserved_y_6 <= '0;
            preserved_y_7 <= '0;
        end else begin
            preserved_y_0 <= y_0;
            preserved_y_1 <= y_1;
            preserved_y_2 <= y_2;
            preserved_y_3 <= y_3;
            preserved_y_4 <= y_4;
            preserved_y_5 <= y_5;
            preserved_y_6 <= y_6;
            preserved_y_7 <= y_7;
        end
    end

endmodule
