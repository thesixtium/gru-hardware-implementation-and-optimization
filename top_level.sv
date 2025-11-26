
`timescale 1ns / 1ps
// d = 64 (input features)
// h = 4 (hidden units)
// auto-generated top-level wrapper for GRU
module top_level(
    input  logic clk,
    input  logic reset
);

    // Parameters must match the generated GRU module parameters
    localparam int INT_WIDTH  = 4;
    localparam int FRAC_WIDTH = 5;
    localparam int WIDTH      = INT_WIDTH + FRAC_WIDTH;

    // --- Input signals (d=64) ---
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
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] x_16 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] x_17 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] x_18 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] x_19 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] x_20 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] x_21 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] x_22 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] x_23 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] x_24 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] x_25 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] x_26 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] x_27 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] x_28 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] x_29 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] x_30 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] x_31 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] x_32 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] x_33 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] x_34 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] x_35 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] x_36 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] x_37 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] x_38 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] x_39 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] x_40 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] x_41 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] x_42 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] x_43 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] x_44 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] x_45 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] x_46 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] x_47 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] x_48 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] x_49 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] x_50 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] x_51 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] x_52 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] x_53 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] x_54 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] x_55 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] x_56 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] x_57 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] x_58 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] x_59 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] x_60 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] x_61 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] x_62 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] x_63 = '0;

    // --- Previous hidden state (h=4) ---
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] h_0 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] h_1 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] h_2 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] h_3 = '0;

    // --- Output signals (h=4) ---
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] y_0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] y_1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] y_2;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] y_3;

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
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_0_16 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_0_17 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_0_18 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_0_19 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_0_20 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_0_21 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_0_22 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_0_23 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_0_24 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_0_25 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_0_26 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_0_27 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_0_28 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_0_29 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_0_30 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_0_31 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_0_32 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_0_33 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_0_34 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_0_35 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_0_36 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_0_37 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_0_38 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_0_39 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_0_40 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_0_41 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_0_42 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_0_43 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_0_44 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_0_45 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_0_46 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_0_47 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_0_48 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_0_49 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_0_50 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_0_51 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_0_52 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_0_53 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_0_54 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_0_55 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_0_56 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_0_57 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_0_58 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_0_59 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_0_60 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_0_61 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_0_62 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_0_63 = 16'sd1;
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
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_1_16 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_1_17 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_1_18 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_1_19 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_1_20 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_1_21 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_1_22 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_1_23 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_1_24 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_1_25 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_1_26 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_1_27 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_1_28 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_1_29 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_1_30 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_1_31 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_1_32 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_1_33 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_1_34 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_1_35 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_1_36 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_1_37 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_1_38 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_1_39 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_1_40 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_1_41 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_1_42 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_1_43 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_1_44 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_1_45 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_1_46 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_1_47 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_1_48 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_1_49 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_1_50 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_1_51 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_1_52 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_1_53 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_1_54 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_1_55 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_1_56 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_1_57 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_1_58 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_1_59 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_1_60 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_1_61 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_1_62 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_1_63 = 16'sd1;
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
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_2_16 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_2_17 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_2_18 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_2_19 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_2_20 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_2_21 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_2_22 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_2_23 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_2_24 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_2_25 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_2_26 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_2_27 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_2_28 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_2_29 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_2_30 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_2_31 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_2_32 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_2_33 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_2_34 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_2_35 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_2_36 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_2_37 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_2_38 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_2_39 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_2_40 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_2_41 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_2_42 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_2_43 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_2_44 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_2_45 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_2_46 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_2_47 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_2_48 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_2_49 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_2_50 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_2_51 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_2_52 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_2_53 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_2_54 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_2_55 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_2_56 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_2_57 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_2_58 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_2_59 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_2_60 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_2_61 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_2_62 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_2_63 = 16'sd1;
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
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_3_16 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_3_17 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_3_18 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_3_19 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_3_20 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_3_21 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_3_22 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_3_23 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_3_24 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_3_25 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_3_26 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_3_27 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_3_28 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_3_29 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_3_30 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_3_31 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_3_32 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_3_33 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_3_34 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_3_35 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_3_36 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_3_37 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_3_38 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_3_39 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_3_40 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_3_41 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_3_42 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_3_43 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_3_44 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_3_45 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_3_46 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_3_47 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_3_48 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_3_49 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_3_50 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_3_51 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_3_52 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_3_53 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_3_54 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_3_55 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_3_56 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_3_57 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_3_58 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_3_59 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_3_60 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_3_61 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_3_62 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_3_63 = 16'sd1;

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
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_0_16 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_0_17 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_0_18 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_0_19 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_0_20 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_0_21 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_0_22 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_0_23 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_0_24 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_0_25 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_0_26 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_0_27 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_0_28 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_0_29 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_0_30 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_0_31 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_0_32 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_0_33 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_0_34 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_0_35 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_0_36 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_0_37 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_0_38 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_0_39 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_0_40 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_0_41 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_0_42 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_0_43 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_0_44 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_0_45 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_0_46 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_0_47 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_0_48 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_0_49 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_0_50 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_0_51 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_0_52 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_0_53 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_0_54 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_0_55 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_0_56 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_0_57 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_0_58 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_0_59 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_0_60 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_0_61 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_0_62 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_0_63 = 16'sd1;
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
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_1_16 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_1_17 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_1_18 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_1_19 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_1_20 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_1_21 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_1_22 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_1_23 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_1_24 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_1_25 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_1_26 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_1_27 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_1_28 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_1_29 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_1_30 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_1_31 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_1_32 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_1_33 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_1_34 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_1_35 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_1_36 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_1_37 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_1_38 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_1_39 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_1_40 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_1_41 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_1_42 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_1_43 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_1_44 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_1_45 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_1_46 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_1_47 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_1_48 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_1_49 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_1_50 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_1_51 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_1_52 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_1_53 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_1_54 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_1_55 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_1_56 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_1_57 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_1_58 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_1_59 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_1_60 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_1_61 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_1_62 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_1_63 = 16'sd1;
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
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_2_16 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_2_17 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_2_18 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_2_19 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_2_20 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_2_21 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_2_22 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_2_23 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_2_24 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_2_25 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_2_26 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_2_27 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_2_28 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_2_29 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_2_30 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_2_31 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_2_32 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_2_33 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_2_34 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_2_35 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_2_36 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_2_37 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_2_38 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_2_39 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_2_40 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_2_41 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_2_42 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_2_43 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_2_44 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_2_45 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_2_46 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_2_47 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_2_48 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_2_49 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_2_50 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_2_51 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_2_52 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_2_53 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_2_54 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_2_55 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_2_56 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_2_57 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_2_58 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_2_59 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_2_60 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_2_61 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_2_62 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_2_63 = 16'sd1;
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
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_3_16 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_3_17 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_3_18 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_3_19 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_3_20 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_3_21 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_3_22 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_3_23 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_3_24 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_3_25 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_3_26 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_3_27 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_3_28 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_3_29 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_3_30 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_3_31 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_3_32 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_3_33 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_3_34 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_3_35 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_3_36 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_3_37 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_3_38 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_3_39 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_3_40 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_3_41 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_3_42 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_3_43 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_3_44 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_3_45 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_3_46 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_3_47 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_3_48 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_3_49 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_3_50 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_3_51 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_3_52 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_3_53 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_3_54 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_3_55 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_3_56 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_3_57 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_3_58 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_3_59 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_3_60 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_3_61 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_3_62 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_3_63 = 16'sd1;

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
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_0_16 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_0_17 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_0_18 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_0_19 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_0_20 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_0_21 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_0_22 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_0_23 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_0_24 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_0_25 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_0_26 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_0_27 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_0_28 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_0_29 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_0_30 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_0_31 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_0_32 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_0_33 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_0_34 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_0_35 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_0_36 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_0_37 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_0_38 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_0_39 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_0_40 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_0_41 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_0_42 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_0_43 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_0_44 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_0_45 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_0_46 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_0_47 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_0_48 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_0_49 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_0_50 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_0_51 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_0_52 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_0_53 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_0_54 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_0_55 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_0_56 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_0_57 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_0_58 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_0_59 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_0_60 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_0_61 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_0_62 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_0_63 = 16'sd1;
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
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_1_16 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_1_17 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_1_18 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_1_19 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_1_20 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_1_21 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_1_22 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_1_23 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_1_24 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_1_25 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_1_26 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_1_27 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_1_28 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_1_29 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_1_30 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_1_31 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_1_32 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_1_33 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_1_34 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_1_35 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_1_36 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_1_37 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_1_38 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_1_39 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_1_40 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_1_41 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_1_42 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_1_43 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_1_44 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_1_45 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_1_46 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_1_47 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_1_48 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_1_49 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_1_50 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_1_51 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_1_52 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_1_53 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_1_54 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_1_55 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_1_56 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_1_57 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_1_58 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_1_59 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_1_60 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_1_61 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_1_62 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_1_63 = 16'sd1;
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
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_2_16 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_2_17 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_2_18 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_2_19 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_2_20 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_2_21 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_2_22 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_2_23 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_2_24 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_2_25 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_2_26 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_2_27 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_2_28 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_2_29 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_2_30 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_2_31 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_2_32 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_2_33 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_2_34 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_2_35 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_2_36 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_2_37 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_2_38 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_2_39 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_2_40 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_2_41 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_2_42 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_2_43 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_2_44 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_2_45 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_2_46 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_2_47 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_2_48 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_2_49 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_2_50 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_2_51 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_2_52 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_2_53 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_2_54 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_2_55 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_2_56 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_2_57 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_2_58 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_2_59 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_2_60 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_2_61 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_2_62 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_2_63 = 16'sd1;
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
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_3_16 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_3_17 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_3_18 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_3_19 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_3_20 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_3_21 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_3_22 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_3_23 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_3_24 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_3_25 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_3_26 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_3_27 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_3_28 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_3_29 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_3_30 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_3_31 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_3_32 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_3_33 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_3_34 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_3_35 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_3_36 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_3_37 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_3_38 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_3_39 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_3_40 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_3_41 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_3_42 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_3_43 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_3_44 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_3_45 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_3_46 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_3_47 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_3_48 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_3_49 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_3_50 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_3_51 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_3_52 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_3_53 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_3_54 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_3_55 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_3_56 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_3_57 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_3_58 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_3_59 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_3_60 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_3_61 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_3_62 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_3_63 = 16'sd1;

    // --- Recurrent weights (h×h for each gate) ---
    // w_hr: reset gate recurrent weights
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hr_0_0 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hr_0_1 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hr_0_2 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hr_0_3 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hr_1_0 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hr_1_1 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hr_1_2 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hr_1_3 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hr_2_0 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hr_2_1 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hr_2_2 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hr_2_3 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hr_3_0 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hr_3_1 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hr_3_2 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hr_3_3 = 16'sd1;

    // w_hz: update gate recurrent weights
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hz_0_0 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hz_0_1 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hz_0_2 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hz_0_3 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hz_1_0 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hz_1_1 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hz_1_2 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hz_1_3 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hz_2_0 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hz_2_1 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hz_2_2 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hz_2_3 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hz_3_0 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hz_3_1 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hz_3_2 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hz_3_3 = 16'sd1;

    // w_hn: new gate recurrent weights
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hn_0_0 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hn_0_1 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hn_0_2 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hn_0_3 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hn_1_0 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hn_1_1 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hn_1_2 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hn_1_3 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hn_2_0 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hn_2_1 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hn_2_2 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hn_2_3 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hn_3_0 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hn_3_1 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hn_3_2 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hn_3_3 = 16'sd1;

    // --- Biases (h for each gate type) ---
    // Input-to-hidden biases
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] b_ir_0 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] b_ir_1 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] b_ir_2 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] b_ir_3 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] b_iz_0 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] b_iz_1 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] b_iz_2 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] b_iz_3 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] b_in_0 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] b_in_1 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] b_in_2 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] b_in_3 = '0;

    // Hidden-to-hidden biases
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] b_hr_0 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] b_hr_1 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] b_hr_2 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] b_hr_3 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] b_hz_0 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] b_hz_1 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] b_hz_2 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] b_hz_3 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] b_hn_0 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] b_hn_1 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] b_hn_2 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] b_hn_3 = '0;

    // --- Final registers to capture and preserve the outputs ---
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] preserved_y_0 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] preserved_y_1 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] preserved_y_2 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] preserved_y_3 = '0;

    // --- Instantiate the generated GRU module ---
    (* keep = "true", dont_touch = "true" *) gru #(
        .INT_WIDTH(INT_WIDTH),
        .FRAC_WIDTH(FRAC_WIDTH)
    ) gru_inst (
        .clk(clk),
        .reset(reset),
        // Input features (d=64)

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
        .x_16(x_16),
        .x_17(x_17),
        .x_18(x_18),
        .x_19(x_19),
        .x_20(x_20),
        .x_21(x_21),
        .x_22(x_22),
        .x_23(x_23),
        .x_24(x_24),
        .x_25(x_25),
        .x_26(x_26),
        .x_27(x_27),
        .x_28(x_28),
        .x_29(x_29),
        .x_30(x_30),
        .x_31(x_31),
        .x_32(x_32),
        .x_33(x_33),
        .x_34(x_34),
        .x_35(x_35),
        .x_36(x_36),
        .x_37(x_37),
        .x_38(x_38),
        .x_39(x_39),
        .x_40(x_40),
        .x_41(x_41),
        .x_42(x_42),
        .x_43(x_43),
        .x_44(x_44),
        .x_45(x_45),
        .x_46(x_46),
        .x_47(x_47),
        .x_48(x_48),
        .x_49(x_49),
        .x_50(x_50),
        .x_51(x_51),
        .x_52(x_52),
        .x_53(x_53),
        .x_54(x_54),
        .x_55(x_55),
        .x_56(x_56),
        .x_57(x_57),
        .x_58(x_58),
        .x_59(x_59),
        .x_60(x_60),
        .x_61(x_61),
        .x_62(x_62),
        .x_63(x_63),
        // Hidden states (h=4)

        .h_0(h_0),
        .h_1(h_1),
        .h_2(h_2),
        .h_3(h_3),
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
        .w_ir_0_16(w_ir_0_16),
        .w_ir_0_17(w_ir_0_17),
        .w_ir_0_18(w_ir_0_18),
        .w_ir_0_19(w_ir_0_19),
        .w_ir_0_20(w_ir_0_20),
        .w_ir_0_21(w_ir_0_21),
        .w_ir_0_22(w_ir_0_22),
        .w_ir_0_23(w_ir_0_23),
        .w_ir_0_24(w_ir_0_24),
        .w_ir_0_25(w_ir_0_25),
        .w_ir_0_26(w_ir_0_26),
        .w_ir_0_27(w_ir_0_27),
        .w_ir_0_28(w_ir_0_28),
        .w_ir_0_29(w_ir_0_29),
        .w_ir_0_30(w_ir_0_30),
        .w_ir_0_31(w_ir_0_31),
        .w_ir_0_32(w_ir_0_32),
        .w_ir_0_33(w_ir_0_33),
        .w_ir_0_34(w_ir_0_34),
        .w_ir_0_35(w_ir_0_35),
        .w_ir_0_36(w_ir_0_36),
        .w_ir_0_37(w_ir_0_37),
        .w_ir_0_38(w_ir_0_38),
        .w_ir_0_39(w_ir_0_39),
        .w_ir_0_40(w_ir_0_40),
        .w_ir_0_41(w_ir_0_41),
        .w_ir_0_42(w_ir_0_42),
        .w_ir_0_43(w_ir_0_43),
        .w_ir_0_44(w_ir_0_44),
        .w_ir_0_45(w_ir_0_45),
        .w_ir_0_46(w_ir_0_46),
        .w_ir_0_47(w_ir_0_47),
        .w_ir_0_48(w_ir_0_48),
        .w_ir_0_49(w_ir_0_49),
        .w_ir_0_50(w_ir_0_50),
        .w_ir_0_51(w_ir_0_51),
        .w_ir_0_52(w_ir_0_52),
        .w_ir_0_53(w_ir_0_53),
        .w_ir_0_54(w_ir_0_54),
        .w_ir_0_55(w_ir_0_55),
        .w_ir_0_56(w_ir_0_56),
        .w_ir_0_57(w_ir_0_57),
        .w_ir_0_58(w_ir_0_58),
        .w_ir_0_59(w_ir_0_59),
        .w_ir_0_60(w_ir_0_60),
        .w_ir_0_61(w_ir_0_61),
        .w_ir_0_62(w_ir_0_62),
        .w_ir_0_63(w_ir_0_63),
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
        .w_ir_1_16(w_ir_1_16),
        .w_ir_1_17(w_ir_1_17),
        .w_ir_1_18(w_ir_1_18),
        .w_ir_1_19(w_ir_1_19),
        .w_ir_1_20(w_ir_1_20),
        .w_ir_1_21(w_ir_1_21),
        .w_ir_1_22(w_ir_1_22),
        .w_ir_1_23(w_ir_1_23),
        .w_ir_1_24(w_ir_1_24),
        .w_ir_1_25(w_ir_1_25),
        .w_ir_1_26(w_ir_1_26),
        .w_ir_1_27(w_ir_1_27),
        .w_ir_1_28(w_ir_1_28),
        .w_ir_1_29(w_ir_1_29),
        .w_ir_1_30(w_ir_1_30),
        .w_ir_1_31(w_ir_1_31),
        .w_ir_1_32(w_ir_1_32),
        .w_ir_1_33(w_ir_1_33),
        .w_ir_1_34(w_ir_1_34),
        .w_ir_1_35(w_ir_1_35),
        .w_ir_1_36(w_ir_1_36),
        .w_ir_1_37(w_ir_1_37),
        .w_ir_1_38(w_ir_1_38),
        .w_ir_1_39(w_ir_1_39),
        .w_ir_1_40(w_ir_1_40),
        .w_ir_1_41(w_ir_1_41),
        .w_ir_1_42(w_ir_1_42),
        .w_ir_1_43(w_ir_1_43),
        .w_ir_1_44(w_ir_1_44),
        .w_ir_1_45(w_ir_1_45),
        .w_ir_1_46(w_ir_1_46),
        .w_ir_1_47(w_ir_1_47),
        .w_ir_1_48(w_ir_1_48),
        .w_ir_1_49(w_ir_1_49),
        .w_ir_1_50(w_ir_1_50),
        .w_ir_1_51(w_ir_1_51),
        .w_ir_1_52(w_ir_1_52),
        .w_ir_1_53(w_ir_1_53),
        .w_ir_1_54(w_ir_1_54),
        .w_ir_1_55(w_ir_1_55),
        .w_ir_1_56(w_ir_1_56),
        .w_ir_1_57(w_ir_1_57),
        .w_ir_1_58(w_ir_1_58),
        .w_ir_1_59(w_ir_1_59),
        .w_ir_1_60(w_ir_1_60),
        .w_ir_1_61(w_ir_1_61),
        .w_ir_1_62(w_ir_1_62),
        .w_ir_1_63(w_ir_1_63),
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
        .w_ir_2_16(w_ir_2_16),
        .w_ir_2_17(w_ir_2_17),
        .w_ir_2_18(w_ir_2_18),
        .w_ir_2_19(w_ir_2_19),
        .w_ir_2_20(w_ir_2_20),
        .w_ir_2_21(w_ir_2_21),
        .w_ir_2_22(w_ir_2_22),
        .w_ir_2_23(w_ir_2_23),
        .w_ir_2_24(w_ir_2_24),
        .w_ir_2_25(w_ir_2_25),
        .w_ir_2_26(w_ir_2_26),
        .w_ir_2_27(w_ir_2_27),
        .w_ir_2_28(w_ir_2_28),
        .w_ir_2_29(w_ir_2_29),
        .w_ir_2_30(w_ir_2_30),
        .w_ir_2_31(w_ir_2_31),
        .w_ir_2_32(w_ir_2_32),
        .w_ir_2_33(w_ir_2_33),
        .w_ir_2_34(w_ir_2_34),
        .w_ir_2_35(w_ir_2_35),
        .w_ir_2_36(w_ir_2_36),
        .w_ir_2_37(w_ir_2_37),
        .w_ir_2_38(w_ir_2_38),
        .w_ir_2_39(w_ir_2_39),
        .w_ir_2_40(w_ir_2_40),
        .w_ir_2_41(w_ir_2_41),
        .w_ir_2_42(w_ir_2_42),
        .w_ir_2_43(w_ir_2_43),
        .w_ir_2_44(w_ir_2_44),
        .w_ir_2_45(w_ir_2_45),
        .w_ir_2_46(w_ir_2_46),
        .w_ir_2_47(w_ir_2_47),
        .w_ir_2_48(w_ir_2_48),
        .w_ir_2_49(w_ir_2_49),
        .w_ir_2_50(w_ir_2_50),
        .w_ir_2_51(w_ir_2_51),
        .w_ir_2_52(w_ir_2_52),
        .w_ir_2_53(w_ir_2_53),
        .w_ir_2_54(w_ir_2_54),
        .w_ir_2_55(w_ir_2_55),
        .w_ir_2_56(w_ir_2_56),
        .w_ir_2_57(w_ir_2_57),
        .w_ir_2_58(w_ir_2_58),
        .w_ir_2_59(w_ir_2_59),
        .w_ir_2_60(w_ir_2_60),
        .w_ir_2_61(w_ir_2_61),
        .w_ir_2_62(w_ir_2_62),
        .w_ir_2_63(w_ir_2_63),
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
        .w_ir_3_16(w_ir_3_16),
        .w_ir_3_17(w_ir_3_17),
        .w_ir_3_18(w_ir_3_18),
        .w_ir_3_19(w_ir_3_19),
        .w_ir_3_20(w_ir_3_20),
        .w_ir_3_21(w_ir_3_21),
        .w_ir_3_22(w_ir_3_22),
        .w_ir_3_23(w_ir_3_23),
        .w_ir_3_24(w_ir_3_24),
        .w_ir_3_25(w_ir_3_25),
        .w_ir_3_26(w_ir_3_26),
        .w_ir_3_27(w_ir_3_27),
        .w_ir_3_28(w_ir_3_28),
        .w_ir_3_29(w_ir_3_29),
        .w_ir_3_30(w_ir_3_30),
        .w_ir_3_31(w_ir_3_31),
        .w_ir_3_32(w_ir_3_32),
        .w_ir_3_33(w_ir_3_33),
        .w_ir_3_34(w_ir_3_34),
        .w_ir_3_35(w_ir_3_35),
        .w_ir_3_36(w_ir_3_36),
        .w_ir_3_37(w_ir_3_37),
        .w_ir_3_38(w_ir_3_38),
        .w_ir_3_39(w_ir_3_39),
        .w_ir_3_40(w_ir_3_40),
        .w_ir_3_41(w_ir_3_41),
        .w_ir_3_42(w_ir_3_42),
        .w_ir_3_43(w_ir_3_43),
        .w_ir_3_44(w_ir_3_44),
        .w_ir_3_45(w_ir_3_45),
        .w_ir_3_46(w_ir_3_46),
        .w_ir_3_47(w_ir_3_47),
        .w_ir_3_48(w_ir_3_48),
        .w_ir_3_49(w_ir_3_49),
        .w_ir_3_50(w_ir_3_50),
        .w_ir_3_51(w_ir_3_51),
        .w_ir_3_52(w_ir_3_52),
        .w_ir_3_53(w_ir_3_53),
        .w_ir_3_54(w_ir_3_54),
        .w_ir_3_55(w_ir_3_55),
        .w_ir_3_56(w_ir_3_56),
        .w_ir_3_57(w_ir_3_57),
        .w_ir_3_58(w_ir_3_58),
        .w_ir_3_59(w_ir_3_59),
        .w_ir_3_60(w_ir_3_60),
        .w_ir_3_61(w_ir_3_61),
        .w_ir_3_62(w_ir_3_62),
        .w_ir_3_63(w_ir_3_63),
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
        .w_iz_0_16(w_iz_0_16),
        .w_iz_0_17(w_iz_0_17),
        .w_iz_0_18(w_iz_0_18),
        .w_iz_0_19(w_iz_0_19),
        .w_iz_0_20(w_iz_0_20),
        .w_iz_0_21(w_iz_0_21),
        .w_iz_0_22(w_iz_0_22),
        .w_iz_0_23(w_iz_0_23),
        .w_iz_0_24(w_iz_0_24),
        .w_iz_0_25(w_iz_0_25),
        .w_iz_0_26(w_iz_0_26),
        .w_iz_0_27(w_iz_0_27),
        .w_iz_0_28(w_iz_0_28),
        .w_iz_0_29(w_iz_0_29),
        .w_iz_0_30(w_iz_0_30),
        .w_iz_0_31(w_iz_0_31),
        .w_iz_0_32(w_iz_0_32),
        .w_iz_0_33(w_iz_0_33),
        .w_iz_0_34(w_iz_0_34),
        .w_iz_0_35(w_iz_0_35),
        .w_iz_0_36(w_iz_0_36),
        .w_iz_0_37(w_iz_0_37),
        .w_iz_0_38(w_iz_0_38),
        .w_iz_0_39(w_iz_0_39),
        .w_iz_0_40(w_iz_0_40),
        .w_iz_0_41(w_iz_0_41),
        .w_iz_0_42(w_iz_0_42),
        .w_iz_0_43(w_iz_0_43),
        .w_iz_0_44(w_iz_0_44),
        .w_iz_0_45(w_iz_0_45),
        .w_iz_0_46(w_iz_0_46),
        .w_iz_0_47(w_iz_0_47),
        .w_iz_0_48(w_iz_0_48),
        .w_iz_0_49(w_iz_0_49),
        .w_iz_0_50(w_iz_0_50),
        .w_iz_0_51(w_iz_0_51),
        .w_iz_0_52(w_iz_0_52),
        .w_iz_0_53(w_iz_0_53),
        .w_iz_0_54(w_iz_0_54),
        .w_iz_0_55(w_iz_0_55),
        .w_iz_0_56(w_iz_0_56),
        .w_iz_0_57(w_iz_0_57),
        .w_iz_0_58(w_iz_0_58),
        .w_iz_0_59(w_iz_0_59),
        .w_iz_0_60(w_iz_0_60),
        .w_iz_0_61(w_iz_0_61),
        .w_iz_0_62(w_iz_0_62),
        .w_iz_0_63(w_iz_0_63),
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
        .w_iz_1_16(w_iz_1_16),
        .w_iz_1_17(w_iz_1_17),
        .w_iz_1_18(w_iz_1_18),
        .w_iz_1_19(w_iz_1_19),
        .w_iz_1_20(w_iz_1_20),
        .w_iz_1_21(w_iz_1_21),
        .w_iz_1_22(w_iz_1_22),
        .w_iz_1_23(w_iz_1_23),
        .w_iz_1_24(w_iz_1_24),
        .w_iz_1_25(w_iz_1_25),
        .w_iz_1_26(w_iz_1_26),
        .w_iz_1_27(w_iz_1_27),
        .w_iz_1_28(w_iz_1_28),
        .w_iz_1_29(w_iz_1_29),
        .w_iz_1_30(w_iz_1_30),
        .w_iz_1_31(w_iz_1_31),
        .w_iz_1_32(w_iz_1_32),
        .w_iz_1_33(w_iz_1_33),
        .w_iz_1_34(w_iz_1_34),
        .w_iz_1_35(w_iz_1_35),
        .w_iz_1_36(w_iz_1_36),
        .w_iz_1_37(w_iz_1_37),
        .w_iz_1_38(w_iz_1_38),
        .w_iz_1_39(w_iz_1_39),
        .w_iz_1_40(w_iz_1_40),
        .w_iz_1_41(w_iz_1_41),
        .w_iz_1_42(w_iz_1_42),
        .w_iz_1_43(w_iz_1_43),
        .w_iz_1_44(w_iz_1_44),
        .w_iz_1_45(w_iz_1_45),
        .w_iz_1_46(w_iz_1_46),
        .w_iz_1_47(w_iz_1_47),
        .w_iz_1_48(w_iz_1_48),
        .w_iz_1_49(w_iz_1_49),
        .w_iz_1_50(w_iz_1_50),
        .w_iz_1_51(w_iz_1_51),
        .w_iz_1_52(w_iz_1_52),
        .w_iz_1_53(w_iz_1_53),
        .w_iz_1_54(w_iz_1_54),
        .w_iz_1_55(w_iz_1_55),
        .w_iz_1_56(w_iz_1_56),
        .w_iz_1_57(w_iz_1_57),
        .w_iz_1_58(w_iz_1_58),
        .w_iz_1_59(w_iz_1_59),
        .w_iz_1_60(w_iz_1_60),
        .w_iz_1_61(w_iz_1_61),
        .w_iz_1_62(w_iz_1_62),
        .w_iz_1_63(w_iz_1_63),
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
        .w_iz_2_16(w_iz_2_16),
        .w_iz_2_17(w_iz_2_17),
        .w_iz_2_18(w_iz_2_18),
        .w_iz_2_19(w_iz_2_19),
        .w_iz_2_20(w_iz_2_20),
        .w_iz_2_21(w_iz_2_21),
        .w_iz_2_22(w_iz_2_22),
        .w_iz_2_23(w_iz_2_23),
        .w_iz_2_24(w_iz_2_24),
        .w_iz_2_25(w_iz_2_25),
        .w_iz_2_26(w_iz_2_26),
        .w_iz_2_27(w_iz_2_27),
        .w_iz_2_28(w_iz_2_28),
        .w_iz_2_29(w_iz_2_29),
        .w_iz_2_30(w_iz_2_30),
        .w_iz_2_31(w_iz_2_31),
        .w_iz_2_32(w_iz_2_32),
        .w_iz_2_33(w_iz_2_33),
        .w_iz_2_34(w_iz_2_34),
        .w_iz_2_35(w_iz_2_35),
        .w_iz_2_36(w_iz_2_36),
        .w_iz_2_37(w_iz_2_37),
        .w_iz_2_38(w_iz_2_38),
        .w_iz_2_39(w_iz_2_39),
        .w_iz_2_40(w_iz_2_40),
        .w_iz_2_41(w_iz_2_41),
        .w_iz_2_42(w_iz_2_42),
        .w_iz_2_43(w_iz_2_43),
        .w_iz_2_44(w_iz_2_44),
        .w_iz_2_45(w_iz_2_45),
        .w_iz_2_46(w_iz_2_46),
        .w_iz_2_47(w_iz_2_47),
        .w_iz_2_48(w_iz_2_48),
        .w_iz_2_49(w_iz_2_49),
        .w_iz_2_50(w_iz_2_50),
        .w_iz_2_51(w_iz_2_51),
        .w_iz_2_52(w_iz_2_52),
        .w_iz_2_53(w_iz_2_53),
        .w_iz_2_54(w_iz_2_54),
        .w_iz_2_55(w_iz_2_55),
        .w_iz_2_56(w_iz_2_56),
        .w_iz_2_57(w_iz_2_57),
        .w_iz_2_58(w_iz_2_58),
        .w_iz_2_59(w_iz_2_59),
        .w_iz_2_60(w_iz_2_60),
        .w_iz_2_61(w_iz_2_61),
        .w_iz_2_62(w_iz_2_62),
        .w_iz_2_63(w_iz_2_63),
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
        .w_iz_3_16(w_iz_3_16),
        .w_iz_3_17(w_iz_3_17),
        .w_iz_3_18(w_iz_3_18),
        .w_iz_3_19(w_iz_3_19),
        .w_iz_3_20(w_iz_3_20),
        .w_iz_3_21(w_iz_3_21),
        .w_iz_3_22(w_iz_3_22),
        .w_iz_3_23(w_iz_3_23),
        .w_iz_3_24(w_iz_3_24),
        .w_iz_3_25(w_iz_3_25),
        .w_iz_3_26(w_iz_3_26),
        .w_iz_3_27(w_iz_3_27),
        .w_iz_3_28(w_iz_3_28),
        .w_iz_3_29(w_iz_3_29),
        .w_iz_3_30(w_iz_3_30),
        .w_iz_3_31(w_iz_3_31),
        .w_iz_3_32(w_iz_3_32),
        .w_iz_3_33(w_iz_3_33),
        .w_iz_3_34(w_iz_3_34),
        .w_iz_3_35(w_iz_3_35),
        .w_iz_3_36(w_iz_3_36),
        .w_iz_3_37(w_iz_3_37),
        .w_iz_3_38(w_iz_3_38),
        .w_iz_3_39(w_iz_3_39),
        .w_iz_3_40(w_iz_3_40),
        .w_iz_3_41(w_iz_3_41),
        .w_iz_3_42(w_iz_3_42),
        .w_iz_3_43(w_iz_3_43),
        .w_iz_3_44(w_iz_3_44),
        .w_iz_3_45(w_iz_3_45),
        .w_iz_3_46(w_iz_3_46),
        .w_iz_3_47(w_iz_3_47),
        .w_iz_3_48(w_iz_3_48),
        .w_iz_3_49(w_iz_3_49),
        .w_iz_3_50(w_iz_3_50),
        .w_iz_3_51(w_iz_3_51),
        .w_iz_3_52(w_iz_3_52),
        .w_iz_3_53(w_iz_3_53),
        .w_iz_3_54(w_iz_3_54),
        .w_iz_3_55(w_iz_3_55),
        .w_iz_3_56(w_iz_3_56),
        .w_iz_3_57(w_iz_3_57),
        .w_iz_3_58(w_iz_3_58),
        .w_iz_3_59(w_iz_3_59),
        .w_iz_3_60(w_iz_3_60),
        .w_iz_3_61(w_iz_3_61),
        .w_iz_3_62(w_iz_3_62),
        .w_iz_3_63(w_iz_3_63),
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
        .w_in_0_16(w_in_0_16),
        .w_in_0_17(w_in_0_17),
        .w_in_0_18(w_in_0_18),
        .w_in_0_19(w_in_0_19),
        .w_in_0_20(w_in_0_20),
        .w_in_0_21(w_in_0_21),
        .w_in_0_22(w_in_0_22),
        .w_in_0_23(w_in_0_23),
        .w_in_0_24(w_in_0_24),
        .w_in_0_25(w_in_0_25),
        .w_in_0_26(w_in_0_26),
        .w_in_0_27(w_in_0_27),
        .w_in_0_28(w_in_0_28),
        .w_in_0_29(w_in_0_29),
        .w_in_0_30(w_in_0_30),
        .w_in_0_31(w_in_0_31),
        .w_in_0_32(w_in_0_32),
        .w_in_0_33(w_in_0_33),
        .w_in_0_34(w_in_0_34),
        .w_in_0_35(w_in_0_35),
        .w_in_0_36(w_in_0_36),
        .w_in_0_37(w_in_0_37),
        .w_in_0_38(w_in_0_38),
        .w_in_0_39(w_in_0_39),
        .w_in_0_40(w_in_0_40),
        .w_in_0_41(w_in_0_41),
        .w_in_0_42(w_in_0_42),
        .w_in_0_43(w_in_0_43),
        .w_in_0_44(w_in_0_44),
        .w_in_0_45(w_in_0_45),
        .w_in_0_46(w_in_0_46),
        .w_in_0_47(w_in_0_47),
        .w_in_0_48(w_in_0_48),
        .w_in_0_49(w_in_0_49),
        .w_in_0_50(w_in_0_50),
        .w_in_0_51(w_in_0_51),
        .w_in_0_52(w_in_0_52),
        .w_in_0_53(w_in_0_53),
        .w_in_0_54(w_in_0_54),
        .w_in_0_55(w_in_0_55),
        .w_in_0_56(w_in_0_56),
        .w_in_0_57(w_in_0_57),
        .w_in_0_58(w_in_0_58),
        .w_in_0_59(w_in_0_59),
        .w_in_0_60(w_in_0_60),
        .w_in_0_61(w_in_0_61),
        .w_in_0_62(w_in_0_62),
        .w_in_0_63(w_in_0_63),
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
        .w_in_1_16(w_in_1_16),
        .w_in_1_17(w_in_1_17),
        .w_in_1_18(w_in_1_18),
        .w_in_1_19(w_in_1_19),
        .w_in_1_20(w_in_1_20),
        .w_in_1_21(w_in_1_21),
        .w_in_1_22(w_in_1_22),
        .w_in_1_23(w_in_1_23),
        .w_in_1_24(w_in_1_24),
        .w_in_1_25(w_in_1_25),
        .w_in_1_26(w_in_1_26),
        .w_in_1_27(w_in_1_27),
        .w_in_1_28(w_in_1_28),
        .w_in_1_29(w_in_1_29),
        .w_in_1_30(w_in_1_30),
        .w_in_1_31(w_in_1_31),
        .w_in_1_32(w_in_1_32),
        .w_in_1_33(w_in_1_33),
        .w_in_1_34(w_in_1_34),
        .w_in_1_35(w_in_1_35),
        .w_in_1_36(w_in_1_36),
        .w_in_1_37(w_in_1_37),
        .w_in_1_38(w_in_1_38),
        .w_in_1_39(w_in_1_39),
        .w_in_1_40(w_in_1_40),
        .w_in_1_41(w_in_1_41),
        .w_in_1_42(w_in_1_42),
        .w_in_1_43(w_in_1_43),
        .w_in_1_44(w_in_1_44),
        .w_in_1_45(w_in_1_45),
        .w_in_1_46(w_in_1_46),
        .w_in_1_47(w_in_1_47),
        .w_in_1_48(w_in_1_48),
        .w_in_1_49(w_in_1_49),
        .w_in_1_50(w_in_1_50),
        .w_in_1_51(w_in_1_51),
        .w_in_1_52(w_in_1_52),
        .w_in_1_53(w_in_1_53),
        .w_in_1_54(w_in_1_54),
        .w_in_1_55(w_in_1_55),
        .w_in_1_56(w_in_1_56),
        .w_in_1_57(w_in_1_57),
        .w_in_1_58(w_in_1_58),
        .w_in_1_59(w_in_1_59),
        .w_in_1_60(w_in_1_60),
        .w_in_1_61(w_in_1_61),
        .w_in_1_62(w_in_1_62),
        .w_in_1_63(w_in_1_63),
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
        .w_in_2_16(w_in_2_16),
        .w_in_2_17(w_in_2_17),
        .w_in_2_18(w_in_2_18),
        .w_in_2_19(w_in_2_19),
        .w_in_2_20(w_in_2_20),
        .w_in_2_21(w_in_2_21),
        .w_in_2_22(w_in_2_22),
        .w_in_2_23(w_in_2_23),
        .w_in_2_24(w_in_2_24),
        .w_in_2_25(w_in_2_25),
        .w_in_2_26(w_in_2_26),
        .w_in_2_27(w_in_2_27),
        .w_in_2_28(w_in_2_28),
        .w_in_2_29(w_in_2_29),
        .w_in_2_30(w_in_2_30),
        .w_in_2_31(w_in_2_31),
        .w_in_2_32(w_in_2_32),
        .w_in_2_33(w_in_2_33),
        .w_in_2_34(w_in_2_34),
        .w_in_2_35(w_in_2_35),
        .w_in_2_36(w_in_2_36),
        .w_in_2_37(w_in_2_37),
        .w_in_2_38(w_in_2_38),
        .w_in_2_39(w_in_2_39),
        .w_in_2_40(w_in_2_40),
        .w_in_2_41(w_in_2_41),
        .w_in_2_42(w_in_2_42),
        .w_in_2_43(w_in_2_43),
        .w_in_2_44(w_in_2_44),
        .w_in_2_45(w_in_2_45),
        .w_in_2_46(w_in_2_46),
        .w_in_2_47(w_in_2_47),
        .w_in_2_48(w_in_2_48),
        .w_in_2_49(w_in_2_49),
        .w_in_2_50(w_in_2_50),
        .w_in_2_51(w_in_2_51),
        .w_in_2_52(w_in_2_52),
        .w_in_2_53(w_in_2_53),
        .w_in_2_54(w_in_2_54),
        .w_in_2_55(w_in_2_55),
        .w_in_2_56(w_in_2_56),
        .w_in_2_57(w_in_2_57),
        .w_in_2_58(w_in_2_58),
        .w_in_2_59(w_in_2_59),
        .w_in_2_60(w_in_2_60),
        .w_in_2_61(w_in_2_61),
        .w_in_2_62(w_in_2_62),
        .w_in_2_63(w_in_2_63),
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
        .w_in_3_16(w_in_3_16),
        .w_in_3_17(w_in_3_17),
        .w_in_3_18(w_in_3_18),
        .w_in_3_19(w_in_3_19),
        .w_in_3_20(w_in_3_20),
        .w_in_3_21(w_in_3_21),
        .w_in_3_22(w_in_3_22),
        .w_in_3_23(w_in_3_23),
        .w_in_3_24(w_in_3_24),
        .w_in_3_25(w_in_3_25),
        .w_in_3_26(w_in_3_26),
        .w_in_3_27(w_in_3_27),
        .w_in_3_28(w_in_3_28),
        .w_in_3_29(w_in_3_29),
        .w_in_3_30(w_in_3_30),
        .w_in_3_31(w_in_3_31),
        .w_in_3_32(w_in_3_32),
        .w_in_3_33(w_in_3_33),
        .w_in_3_34(w_in_3_34),
        .w_in_3_35(w_in_3_35),
        .w_in_3_36(w_in_3_36),
        .w_in_3_37(w_in_3_37),
        .w_in_3_38(w_in_3_38),
        .w_in_3_39(w_in_3_39),
        .w_in_3_40(w_in_3_40),
        .w_in_3_41(w_in_3_41),
        .w_in_3_42(w_in_3_42),
        .w_in_3_43(w_in_3_43),
        .w_in_3_44(w_in_3_44),
        .w_in_3_45(w_in_3_45),
        .w_in_3_46(w_in_3_46),
        .w_in_3_47(w_in_3_47),
        .w_in_3_48(w_in_3_48),
        .w_in_3_49(w_in_3_49),
        .w_in_3_50(w_in_3_50),
        .w_in_3_51(w_in_3_51),
        .w_in_3_52(w_in_3_52),
        .w_in_3_53(w_in_3_53),
        .w_in_3_54(w_in_3_54),
        .w_in_3_55(w_in_3_55),
        .w_in_3_56(w_in_3_56),
        .w_in_3_57(w_in_3_57),
        .w_in_3_58(w_in_3_58),
        .w_in_3_59(w_in_3_59),
        .w_in_3_60(w_in_3_60),
        .w_in_3_61(w_in_3_61),
        .w_in_3_62(w_in_3_62),
        .w_in_3_63(w_in_3_63),
        // Recurrent weights for reset gate

        .w_hr_0_0(w_hr_0_0),
        .w_hr_0_1(w_hr_0_1),
        .w_hr_0_2(w_hr_0_2),
        .w_hr_0_3(w_hr_0_3),
        .w_hr_1_0(w_hr_1_0),
        .w_hr_1_1(w_hr_1_1),
        .w_hr_1_2(w_hr_1_2),
        .w_hr_1_3(w_hr_1_3),
        .w_hr_2_0(w_hr_2_0),
        .w_hr_2_1(w_hr_2_1),
        .w_hr_2_2(w_hr_2_2),
        .w_hr_2_3(w_hr_2_3),
        .w_hr_3_0(w_hr_3_0),
        .w_hr_3_1(w_hr_3_1),
        .w_hr_3_2(w_hr_3_2),
        .w_hr_3_3(w_hr_3_3),
        // Recurrent weights for update gate

        .w_hz_0_0(w_hz_0_0),
        .w_hz_0_1(w_hz_0_1),
        .w_hz_0_2(w_hz_0_2),
        .w_hz_0_3(w_hz_0_3),
        .w_hz_1_0(w_hz_1_0),
        .w_hz_1_1(w_hz_1_1),
        .w_hz_1_2(w_hz_1_2),
        .w_hz_1_3(w_hz_1_3),
        .w_hz_2_0(w_hz_2_0),
        .w_hz_2_1(w_hz_2_1),
        .w_hz_2_2(w_hz_2_2),
        .w_hz_2_3(w_hz_2_3),
        .w_hz_3_0(w_hz_3_0),
        .w_hz_3_1(w_hz_3_1),
        .w_hz_3_2(w_hz_3_2),
        .w_hz_3_3(w_hz_3_3),
        // Recurrent weights for new gate

        .w_hn_0_0(w_hn_0_0),
        .w_hn_0_1(w_hn_0_1),
        .w_hn_0_2(w_hn_0_2),
        .w_hn_0_3(w_hn_0_3),
        .w_hn_1_0(w_hn_1_0),
        .w_hn_1_1(w_hn_1_1),
        .w_hn_1_2(w_hn_1_2),
        .w_hn_1_3(w_hn_1_3),
        .w_hn_2_0(w_hn_2_0),
        .w_hn_2_1(w_hn_2_1),
        .w_hn_2_2(w_hn_2_2),
        .w_hn_2_3(w_hn_2_3),
        .w_hn_3_0(w_hn_3_0),
        .w_hn_3_1(w_hn_3_1),
        .w_hn_3_2(w_hn_3_2),
        .w_hn_3_3(w_hn_3_3),
        // Biases

        .b_ir_0(b_ir_0),
        .b_ir_1(b_ir_1),
        .b_ir_2(b_ir_2),
        .b_ir_3(b_ir_3),
        .b_iz_0(b_iz_0),
        .b_iz_1(b_iz_1),
        .b_iz_2(b_iz_2),
        .b_iz_3(b_iz_3),
        .b_in_0(b_in_0),
        .b_in_1(b_in_1),
        .b_in_2(b_in_2),
        .b_in_3(b_in_3),
        .b_hr_0(b_hr_0),
        .b_hr_1(b_hr_1),
        .b_hr_2(b_hr_2),
        .b_hr_3(b_hr_3),
        .b_hz_0(b_hz_0),
        .b_hz_1(b_hz_1),
        .b_hz_2(b_hz_2),
        .b_hz_3(b_hz_3),
        .b_hn_0(b_hn_0),
        .b_hn_1(b_hn_1),
        .b_hn_2(b_hn_2),
        .b_hn_3(b_hn_3),
        // Outputs (h=4)

        .y_0(y_0),
        .y_1(y_1),
        .y_2(y_2),
        .y_3(y_3)
    );

    // --- Capture outputs into preserved registers ---
    always_ff @(posedge clk) begin
        if (reset) begin
            preserved_y_0 <= '0;
            preserved_y_1 <= '0;
            preserved_y_2 <= '0;
            preserved_y_3 <= '0;
        end else begin
            preserved_y_0 <= y_0;
            preserved_y_1 <= y_1;
            preserved_y_2 <= y_2;
            preserved_y_3 <= y_3;
        end
    end

endmodule
