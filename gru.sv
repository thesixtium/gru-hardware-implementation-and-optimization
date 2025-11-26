
`timescale 1ns / 1ps
// GRU Cell Implementation (Fixed-Point Qm.f)
// d = 64 (input features), h = 4 (hidden units)
// WIDTH = INT_WIDTH + FRAC_WIDTH

module gru #(
    parameter int INT_WIDTH  = 4,
    parameter int FRAC_WIDTH = 5,
    parameter int WIDTH      = INT_WIDTH + FRAC_WIDTH
)(
    input  logic                     clk,
    input  logic                     reset,

    // Inputs (d=64)
        input  logic signed [WIDTH-1:0]  x_0,
    input  logic signed [WIDTH-1:0]  x_1,
    input  logic signed [WIDTH-1:0]  x_2,
    input  logic signed [WIDTH-1:0]  x_3,
    input  logic signed [WIDTH-1:0]  x_4,
    input  logic signed [WIDTH-1:0]  x_5,
    input  logic signed [WIDTH-1:0]  x_6,
    input  logic signed [WIDTH-1:0]  x_7,
    input  logic signed [WIDTH-1:0]  x_8,
    input  logic signed [WIDTH-1:0]  x_9,
    input  logic signed [WIDTH-1:0]  x_10,
    input  logic signed [WIDTH-1:0]  x_11,
    input  logic signed [WIDTH-1:0]  x_12,
    input  logic signed [WIDTH-1:0]  x_13,
    input  logic signed [WIDTH-1:0]  x_14,
    input  logic signed [WIDTH-1:0]  x_15,
    input  logic signed [WIDTH-1:0]  x_16,
    input  logic signed [WIDTH-1:0]  x_17,
    input  logic signed [WIDTH-1:0]  x_18,
    input  logic signed [WIDTH-1:0]  x_19,
    input  logic signed [WIDTH-1:0]  x_20,
    input  logic signed [WIDTH-1:0]  x_21,
    input  logic signed [WIDTH-1:0]  x_22,
    input  logic signed [WIDTH-1:0]  x_23,
    input  logic signed [WIDTH-1:0]  x_24,
    input  logic signed [WIDTH-1:0]  x_25,
    input  logic signed [WIDTH-1:0]  x_26,
    input  logic signed [WIDTH-1:0]  x_27,
    input  logic signed [WIDTH-1:0]  x_28,
    input  logic signed [WIDTH-1:0]  x_29,
    input  logic signed [WIDTH-1:0]  x_30,
    input  logic signed [WIDTH-1:0]  x_31,
    input  logic signed [WIDTH-1:0]  x_32,
    input  logic signed [WIDTH-1:0]  x_33,
    input  logic signed [WIDTH-1:0]  x_34,
    input  logic signed [WIDTH-1:0]  x_35,
    input  logic signed [WIDTH-1:0]  x_36,
    input  logic signed [WIDTH-1:0]  x_37,
    input  logic signed [WIDTH-1:0]  x_38,
    input  logic signed [WIDTH-1:0]  x_39,
    input  logic signed [WIDTH-1:0]  x_40,
    input  logic signed [WIDTH-1:0]  x_41,
    input  logic signed [WIDTH-1:0]  x_42,
    input  logic signed [WIDTH-1:0]  x_43,
    input  logic signed [WIDTH-1:0]  x_44,
    input  logic signed [WIDTH-1:0]  x_45,
    input  logic signed [WIDTH-1:0]  x_46,
    input  logic signed [WIDTH-1:0]  x_47,
    input  logic signed [WIDTH-1:0]  x_48,
    input  logic signed [WIDTH-1:0]  x_49,
    input  logic signed [WIDTH-1:0]  x_50,
    input  logic signed [WIDTH-1:0]  x_51,
    input  logic signed [WIDTH-1:0]  x_52,
    input  logic signed [WIDTH-1:0]  x_53,
    input  logic signed [WIDTH-1:0]  x_54,
    input  logic signed [WIDTH-1:0]  x_55,
    input  logic signed [WIDTH-1:0]  x_56,
    input  logic signed [WIDTH-1:0]  x_57,
    input  logic signed [WIDTH-1:0]  x_58,
    input  logic signed [WIDTH-1:0]  x_59,
    input  logic signed [WIDTH-1:0]  x_60,
    input  logic signed [WIDTH-1:0]  x_61,
    input  logic signed [WIDTH-1:0]  x_62,
    input  logic signed [WIDTH-1:0]  x_63,

    // Previous hidden state (h=4)
        input  logic signed [WIDTH-1:0]  h_0,
    input  logic signed [WIDTH-1:0]  h_1,
    input  logic signed [WIDTH-1:0]  h_2,
    input  logic signed [WIDTH-1:0]  h_3,

    // Input weights (h×d for each gate)
    input  logic signed [WIDTH-1:0]  w_ir_0_0, w_ir_0_1, w_ir_0_2, w_ir_0_3, w_ir_0_4, w_ir_0_5, w_ir_0_6, w_ir_0_7, w_ir_0_8, w_ir_0_9, w_ir_0_10, w_ir_0_11, w_ir_0_12, w_ir_0_13, w_ir_0_14, w_ir_0_15, w_ir_0_16, w_ir_0_17, w_ir_0_18, w_ir_0_19, w_ir_0_20, w_ir_0_21, w_ir_0_22, w_ir_0_23, w_ir_0_24, w_ir_0_25, w_ir_0_26, w_ir_0_27, w_ir_0_28, w_ir_0_29, w_ir_0_30, w_ir_0_31, w_ir_0_32, w_ir_0_33, w_ir_0_34, w_ir_0_35, w_ir_0_36, w_ir_0_37, w_ir_0_38, w_ir_0_39, w_ir_0_40, w_ir_0_41, w_ir_0_42, w_ir_0_43, w_ir_0_44, w_ir_0_45, w_ir_0_46, w_ir_0_47, w_ir_0_48, w_ir_0_49, w_ir_0_50, w_ir_0_51, w_ir_0_52, w_ir_0_53, w_ir_0_54, w_ir_0_55, w_ir_0_56, w_ir_0_57, w_ir_0_58, w_ir_0_59, w_ir_0_60, w_ir_0_61, w_ir_0_62, w_ir_0_63, w_ir_1_0, w_ir_1_1, w_ir_1_2, w_ir_1_3, w_ir_1_4, w_ir_1_5, w_ir_1_6, w_ir_1_7, w_ir_1_8, w_ir_1_9, w_ir_1_10, w_ir_1_11, w_ir_1_12, w_ir_1_13, w_ir_1_14, w_ir_1_15, w_ir_1_16, w_ir_1_17, w_ir_1_18, w_ir_1_19, w_ir_1_20, w_ir_1_21, w_ir_1_22, w_ir_1_23, w_ir_1_24, w_ir_1_25, w_ir_1_26, w_ir_1_27, w_ir_1_28, w_ir_1_29, w_ir_1_30, w_ir_1_31, w_ir_1_32, w_ir_1_33, w_ir_1_34, w_ir_1_35, w_ir_1_36, w_ir_1_37, w_ir_1_38, w_ir_1_39, w_ir_1_40, w_ir_1_41, w_ir_1_42, w_ir_1_43, w_ir_1_44, w_ir_1_45, w_ir_1_46, w_ir_1_47, w_ir_1_48, w_ir_1_49, w_ir_1_50, w_ir_1_51, w_ir_1_52, w_ir_1_53, w_ir_1_54, w_ir_1_55, w_ir_1_56, w_ir_1_57, w_ir_1_58, w_ir_1_59, w_ir_1_60, w_ir_1_61, w_ir_1_62, w_ir_1_63, w_ir_2_0, w_ir_2_1, w_ir_2_2, w_ir_2_3, w_ir_2_4, w_ir_2_5, w_ir_2_6, w_ir_2_7, w_ir_2_8, w_ir_2_9, w_ir_2_10, w_ir_2_11, w_ir_2_12, w_ir_2_13, w_ir_2_14, w_ir_2_15, w_ir_2_16, w_ir_2_17, w_ir_2_18, w_ir_2_19, w_ir_2_20, w_ir_2_21, w_ir_2_22, w_ir_2_23, w_ir_2_24, w_ir_2_25, w_ir_2_26, w_ir_2_27, w_ir_2_28, w_ir_2_29, w_ir_2_30, w_ir_2_31, w_ir_2_32, w_ir_2_33, w_ir_2_34, w_ir_2_35, w_ir_2_36, w_ir_2_37, w_ir_2_38, w_ir_2_39, w_ir_2_40, w_ir_2_41, w_ir_2_42, w_ir_2_43, w_ir_2_44, w_ir_2_45, w_ir_2_46, w_ir_2_47, w_ir_2_48, w_ir_2_49, w_ir_2_50, w_ir_2_51, w_ir_2_52, w_ir_2_53, w_ir_2_54, w_ir_2_55, w_ir_2_56, w_ir_2_57, w_ir_2_58, w_ir_2_59, w_ir_2_60, w_ir_2_61, w_ir_2_62, w_ir_2_63, w_ir_3_0, w_ir_3_1, w_ir_3_2, w_ir_3_3, w_ir_3_4, w_ir_3_5, w_ir_3_6, w_ir_3_7, w_ir_3_8, w_ir_3_9, w_ir_3_10, w_ir_3_11, w_ir_3_12, w_ir_3_13, w_ir_3_14, w_ir_3_15, w_ir_3_16, w_ir_3_17, w_ir_3_18, w_ir_3_19, w_ir_3_20, w_ir_3_21, w_ir_3_22, w_ir_3_23, w_ir_3_24, w_ir_3_25, w_ir_3_26, w_ir_3_27, w_ir_3_28, w_ir_3_29, w_ir_3_30, w_ir_3_31, w_ir_3_32, w_ir_3_33, w_ir_3_34, w_ir_3_35, w_ir_3_36, w_ir_3_37, w_ir_3_38, w_ir_3_39, w_ir_3_40, w_ir_3_41, w_ir_3_42, w_ir_3_43, w_ir_3_44, w_ir_3_45, w_ir_3_46, w_ir_3_47, w_ir_3_48, w_ir_3_49, w_ir_3_50, w_ir_3_51, w_ir_3_52, w_ir_3_53, w_ir_3_54, w_ir_3_55, w_ir_3_56, w_ir_3_57, w_ir_3_58, w_ir_3_59, w_ir_3_60, w_ir_3_61, w_ir_3_62, w_ir_3_63,
    input  logic signed [WIDTH-1:0]  w_iz_0_0, w_iz_0_1, w_iz_0_2, w_iz_0_3, w_iz_0_4, w_iz_0_5, w_iz_0_6, w_iz_0_7, w_iz_0_8, w_iz_0_9, w_iz_0_10, w_iz_0_11, w_iz_0_12, w_iz_0_13, w_iz_0_14, w_iz_0_15, w_iz_0_16, w_iz_0_17, w_iz_0_18, w_iz_0_19, w_iz_0_20, w_iz_0_21, w_iz_0_22, w_iz_0_23, w_iz_0_24, w_iz_0_25, w_iz_0_26, w_iz_0_27, w_iz_0_28, w_iz_0_29, w_iz_0_30, w_iz_0_31, w_iz_0_32, w_iz_0_33, w_iz_0_34, w_iz_0_35, w_iz_0_36, w_iz_0_37, w_iz_0_38, w_iz_0_39, w_iz_0_40, w_iz_0_41, w_iz_0_42, w_iz_0_43, w_iz_0_44, w_iz_0_45, w_iz_0_46, w_iz_0_47, w_iz_0_48, w_iz_0_49, w_iz_0_50, w_iz_0_51, w_iz_0_52, w_iz_0_53, w_iz_0_54, w_iz_0_55, w_iz_0_56, w_iz_0_57, w_iz_0_58, w_iz_0_59, w_iz_0_60, w_iz_0_61, w_iz_0_62, w_iz_0_63, w_iz_1_0, w_iz_1_1, w_iz_1_2, w_iz_1_3, w_iz_1_4, w_iz_1_5, w_iz_1_6, w_iz_1_7, w_iz_1_8, w_iz_1_9, w_iz_1_10, w_iz_1_11, w_iz_1_12, w_iz_1_13, w_iz_1_14, w_iz_1_15, w_iz_1_16, w_iz_1_17, w_iz_1_18, w_iz_1_19, w_iz_1_20, w_iz_1_21, w_iz_1_22, w_iz_1_23, w_iz_1_24, w_iz_1_25, w_iz_1_26, w_iz_1_27, w_iz_1_28, w_iz_1_29, w_iz_1_30, w_iz_1_31, w_iz_1_32, w_iz_1_33, w_iz_1_34, w_iz_1_35, w_iz_1_36, w_iz_1_37, w_iz_1_38, w_iz_1_39, w_iz_1_40, w_iz_1_41, w_iz_1_42, w_iz_1_43, w_iz_1_44, w_iz_1_45, w_iz_1_46, w_iz_1_47, w_iz_1_48, w_iz_1_49, w_iz_1_50, w_iz_1_51, w_iz_1_52, w_iz_1_53, w_iz_1_54, w_iz_1_55, w_iz_1_56, w_iz_1_57, w_iz_1_58, w_iz_1_59, w_iz_1_60, w_iz_1_61, w_iz_1_62, w_iz_1_63, w_iz_2_0, w_iz_2_1, w_iz_2_2, w_iz_2_3, w_iz_2_4, w_iz_2_5, w_iz_2_6, w_iz_2_7, w_iz_2_8, w_iz_2_9, w_iz_2_10, w_iz_2_11, w_iz_2_12, w_iz_2_13, w_iz_2_14, w_iz_2_15, w_iz_2_16, w_iz_2_17, w_iz_2_18, w_iz_2_19, w_iz_2_20, w_iz_2_21, w_iz_2_22, w_iz_2_23, w_iz_2_24, w_iz_2_25, w_iz_2_26, w_iz_2_27, w_iz_2_28, w_iz_2_29, w_iz_2_30, w_iz_2_31, w_iz_2_32, w_iz_2_33, w_iz_2_34, w_iz_2_35, w_iz_2_36, w_iz_2_37, w_iz_2_38, w_iz_2_39, w_iz_2_40, w_iz_2_41, w_iz_2_42, w_iz_2_43, w_iz_2_44, w_iz_2_45, w_iz_2_46, w_iz_2_47, w_iz_2_48, w_iz_2_49, w_iz_2_50, w_iz_2_51, w_iz_2_52, w_iz_2_53, w_iz_2_54, w_iz_2_55, w_iz_2_56, w_iz_2_57, w_iz_2_58, w_iz_2_59, w_iz_2_60, w_iz_2_61, w_iz_2_62, w_iz_2_63, w_iz_3_0, w_iz_3_1, w_iz_3_2, w_iz_3_3, w_iz_3_4, w_iz_3_5, w_iz_3_6, w_iz_3_7, w_iz_3_8, w_iz_3_9, w_iz_3_10, w_iz_3_11, w_iz_3_12, w_iz_3_13, w_iz_3_14, w_iz_3_15, w_iz_3_16, w_iz_3_17, w_iz_3_18, w_iz_3_19, w_iz_3_20, w_iz_3_21, w_iz_3_22, w_iz_3_23, w_iz_3_24, w_iz_3_25, w_iz_3_26, w_iz_3_27, w_iz_3_28, w_iz_3_29, w_iz_3_30, w_iz_3_31, w_iz_3_32, w_iz_3_33, w_iz_3_34, w_iz_3_35, w_iz_3_36, w_iz_3_37, w_iz_3_38, w_iz_3_39, w_iz_3_40, w_iz_3_41, w_iz_3_42, w_iz_3_43, w_iz_3_44, w_iz_3_45, w_iz_3_46, w_iz_3_47, w_iz_3_48, w_iz_3_49, w_iz_3_50, w_iz_3_51, w_iz_3_52, w_iz_3_53, w_iz_3_54, w_iz_3_55, w_iz_3_56, w_iz_3_57, w_iz_3_58, w_iz_3_59, w_iz_3_60, w_iz_3_61, w_iz_3_62, w_iz_3_63,
    input  logic signed [WIDTH-1:0]  w_in_0_0, w_in_0_1, w_in_0_2, w_in_0_3, w_in_0_4, w_in_0_5, w_in_0_6, w_in_0_7, w_in_0_8, w_in_0_9, w_in_0_10, w_in_0_11, w_in_0_12, w_in_0_13, w_in_0_14, w_in_0_15, w_in_0_16, w_in_0_17, w_in_0_18, w_in_0_19, w_in_0_20, w_in_0_21, w_in_0_22, w_in_0_23, w_in_0_24, w_in_0_25, w_in_0_26, w_in_0_27, w_in_0_28, w_in_0_29, w_in_0_30, w_in_0_31, w_in_0_32, w_in_0_33, w_in_0_34, w_in_0_35, w_in_0_36, w_in_0_37, w_in_0_38, w_in_0_39, w_in_0_40, w_in_0_41, w_in_0_42, w_in_0_43, w_in_0_44, w_in_0_45, w_in_0_46, w_in_0_47, w_in_0_48, w_in_0_49, w_in_0_50, w_in_0_51, w_in_0_52, w_in_0_53, w_in_0_54, w_in_0_55, w_in_0_56, w_in_0_57, w_in_0_58, w_in_0_59, w_in_0_60, w_in_0_61, w_in_0_62, w_in_0_63, w_in_1_0, w_in_1_1, w_in_1_2, w_in_1_3, w_in_1_4, w_in_1_5, w_in_1_6, w_in_1_7, w_in_1_8, w_in_1_9, w_in_1_10, w_in_1_11, w_in_1_12, w_in_1_13, w_in_1_14, w_in_1_15, w_in_1_16, w_in_1_17, w_in_1_18, w_in_1_19, w_in_1_20, w_in_1_21, w_in_1_22, w_in_1_23, w_in_1_24, w_in_1_25, w_in_1_26, w_in_1_27, w_in_1_28, w_in_1_29, w_in_1_30, w_in_1_31, w_in_1_32, w_in_1_33, w_in_1_34, w_in_1_35, w_in_1_36, w_in_1_37, w_in_1_38, w_in_1_39, w_in_1_40, w_in_1_41, w_in_1_42, w_in_1_43, w_in_1_44, w_in_1_45, w_in_1_46, w_in_1_47, w_in_1_48, w_in_1_49, w_in_1_50, w_in_1_51, w_in_1_52, w_in_1_53, w_in_1_54, w_in_1_55, w_in_1_56, w_in_1_57, w_in_1_58, w_in_1_59, w_in_1_60, w_in_1_61, w_in_1_62, w_in_1_63, w_in_2_0, w_in_2_1, w_in_2_2, w_in_2_3, w_in_2_4, w_in_2_5, w_in_2_6, w_in_2_7, w_in_2_8, w_in_2_9, w_in_2_10, w_in_2_11, w_in_2_12, w_in_2_13, w_in_2_14, w_in_2_15, w_in_2_16, w_in_2_17, w_in_2_18, w_in_2_19, w_in_2_20, w_in_2_21, w_in_2_22, w_in_2_23, w_in_2_24, w_in_2_25, w_in_2_26, w_in_2_27, w_in_2_28, w_in_2_29, w_in_2_30, w_in_2_31, w_in_2_32, w_in_2_33, w_in_2_34, w_in_2_35, w_in_2_36, w_in_2_37, w_in_2_38, w_in_2_39, w_in_2_40, w_in_2_41, w_in_2_42, w_in_2_43, w_in_2_44, w_in_2_45, w_in_2_46, w_in_2_47, w_in_2_48, w_in_2_49, w_in_2_50, w_in_2_51, w_in_2_52, w_in_2_53, w_in_2_54, w_in_2_55, w_in_2_56, w_in_2_57, w_in_2_58, w_in_2_59, w_in_2_60, w_in_2_61, w_in_2_62, w_in_2_63, w_in_3_0, w_in_3_1, w_in_3_2, w_in_3_3, w_in_3_4, w_in_3_5, w_in_3_6, w_in_3_7, w_in_3_8, w_in_3_9, w_in_3_10, w_in_3_11, w_in_3_12, w_in_3_13, w_in_3_14, w_in_3_15, w_in_3_16, w_in_3_17, w_in_3_18, w_in_3_19, w_in_3_20, w_in_3_21, w_in_3_22, w_in_3_23, w_in_3_24, w_in_3_25, w_in_3_26, w_in_3_27, w_in_3_28, w_in_3_29, w_in_3_30, w_in_3_31, w_in_3_32, w_in_3_33, w_in_3_34, w_in_3_35, w_in_3_36, w_in_3_37, w_in_3_38, w_in_3_39, w_in_3_40, w_in_3_41, w_in_3_42, w_in_3_43, w_in_3_44, w_in_3_45, w_in_3_46, w_in_3_47, w_in_3_48, w_in_3_49, w_in_3_50, w_in_3_51, w_in_3_52, w_in_3_53, w_in_3_54, w_in_3_55, w_in_3_56, w_in_3_57, w_in_3_58, w_in_3_59, w_in_3_60, w_in_3_61, w_in_3_62, w_in_3_63,

    // Recurrent weights (h×h for each gate)
    input  logic signed [WIDTH-1:0]  w_hr_0_0, w_hr_0_1, w_hr_0_2, w_hr_0_3, w_hr_1_0, w_hr_1_1, w_hr_1_2, w_hr_1_3, w_hr_2_0, w_hr_2_1, w_hr_2_2, w_hr_2_3, w_hr_3_0, w_hr_3_1, w_hr_3_2, w_hr_3_3,
    input  logic signed [WIDTH-1:0]  w_hz_0_0, w_hz_0_1, w_hz_0_2, w_hz_0_3, w_hz_1_0, w_hz_1_1, w_hz_1_2, w_hz_1_3, w_hz_2_0, w_hz_2_1, w_hz_2_2, w_hz_2_3, w_hz_3_0, w_hz_3_1, w_hz_3_2, w_hz_3_3,
    input  logic signed [WIDTH-1:0]  w_hn_0_0, w_hn_0_1, w_hn_0_2, w_hn_0_3, w_hn_1_0, w_hn_1_1, w_hn_1_2, w_hn_1_3, w_hn_2_0, w_hn_2_1, w_hn_2_2, w_hn_2_3, w_hn_3_0, w_hn_3_1, w_hn_3_2, w_hn_3_3,

    // Biases (h for each gate type)
    input  logic signed [WIDTH-1:0]  b_ir_0, b_ir_1, b_ir_2, b_ir_3, b_iz_0, b_iz_1, b_iz_2, b_iz_3, b_in_0, b_in_1, b_in_2, b_in_3, b_hr_0, b_hr_1, b_hr_2, b_hr_3, b_hz_0, b_hz_1, b_hz_2, b_hz_3, b_hn_0, b_hn_1, b_hn_2, b_hn_3,

    // Outputs (h=4)
        output logic signed [WIDTH-1:0]  y_0,
    output logic signed [WIDTH-1:0]  y_1,
    output logic signed [WIDTH-1:0]  y_2,
    output logic signed [WIDTH-1:0]  y_3
);

    // Helper functions
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

    function automatic logic signed [WIDTH-1:0] fx_mult_round(
        input logic signed [WIDTH-1:0] a,
        input logic signed [WIDTH-1:0] b
    );
        logic signed [(2*WIDTH)-1:0] product;
        logic signed [WIDTH:0] rounded;

        product = a * b;
        rounded = (product[(2*WIDTH)-1:FRAC_WIDTH] + product[FRAC_WIDTH-1]);

        if (rounded[WIDTH] != rounded[WIDTH-1]) begin
            fx_mult_round = rounded[WIDTH] ? {1'b1, {(WIDTH-1){1'b0}}} : {1'b0, {(WIDTH-1){1'b1}}};
        end else begin
            fx_mult_round = rounded[WIDTH-1:0];
        end
    endfunction

    localparam logic signed [WIDTH-1:0] ONE = (1 <<< FRAC_WIDTH);

    // Reset gate: r_t = σ(W_ir*x + b_ir + W_hr*h + b_hr)
    // r gate computation
    logic signed [WIDTH-1:0] r_sum[4];
    logic signed [WIDTH-1:0] r_act[4];

    always_comb begin
        // r_sum[0]
        r_sum[0] = b_ir_0;
        r_sum[0] = sat_add(r_sum[0], fx_mult_round(w_ir_0_0, x_0));
        r_sum[0] = sat_add(r_sum[0], fx_mult_round(w_ir_0_1, x_1));
        r_sum[0] = sat_add(r_sum[0], fx_mult_round(w_ir_0_2, x_2));
        r_sum[0] = sat_add(r_sum[0], fx_mult_round(w_ir_0_3, x_3));
        r_sum[0] = sat_add(r_sum[0], fx_mult_round(w_ir_0_4, x_4));
        r_sum[0] = sat_add(r_sum[0], fx_mult_round(w_ir_0_5, x_5));
        r_sum[0] = sat_add(r_sum[0], fx_mult_round(w_ir_0_6, x_6));
        r_sum[0] = sat_add(r_sum[0], fx_mult_round(w_ir_0_7, x_7));
        r_sum[0] = sat_add(r_sum[0], fx_mult_round(w_ir_0_8, x_8));
        r_sum[0] = sat_add(r_sum[0], fx_mult_round(w_ir_0_9, x_9));
        r_sum[0] = sat_add(r_sum[0], fx_mult_round(w_ir_0_10, x_10));
        r_sum[0] = sat_add(r_sum[0], fx_mult_round(w_ir_0_11, x_11));
        r_sum[0] = sat_add(r_sum[0], fx_mult_round(w_ir_0_12, x_12));
        r_sum[0] = sat_add(r_sum[0], fx_mult_round(w_ir_0_13, x_13));
        r_sum[0] = sat_add(r_sum[0], fx_mult_round(w_ir_0_14, x_14));
        r_sum[0] = sat_add(r_sum[0], fx_mult_round(w_ir_0_15, x_15));
        r_sum[0] = sat_add(r_sum[0], fx_mult_round(w_ir_0_16, x_16));
        r_sum[0] = sat_add(r_sum[0], fx_mult_round(w_ir_0_17, x_17));
        r_sum[0] = sat_add(r_sum[0], fx_mult_round(w_ir_0_18, x_18));
        r_sum[0] = sat_add(r_sum[0], fx_mult_round(w_ir_0_19, x_19));
        r_sum[0] = sat_add(r_sum[0], fx_mult_round(w_ir_0_20, x_20));
        r_sum[0] = sat_add(r_sum[0], fx_mult_round(w_ir_0_21, x_21));
        r_sum[0] = sat_add(r_sum[0], fx_mult_round(w_ir_0_22, x_22));
        r_sum[0] = sat_add(r_sum[0], fx_mult_round(w_ir_0_23, x_23));
        r_sum[0] = sat_add(r_sum[0], fx_mult_round(w_ir_0_24, x_24));
        r_sum[0] = sat_add(r_sum[0], fx_mult_round(w_ir_0_25, x_25));
        r_sum[0] = sat_add(r_sum[0], fx_mult_round(w_ir_0_26, x_26));
        r_sum[0] = sat_add(r_sum[0], fx_mult_round(w_ir_0_27, x_27));
        r_sum[0] = sat_add(r_sum[0], fx_mult_round(w_ir_0_28, x_28));
        r_sum[0] = sat_add(r_sum[0], fx_mult_round(w_ir_0_29, x_29));
        r_sum[0] = sat_add(r_sum[0], fx_mult_round(w_ir_0_30, x_30));
        r_sum[0] = sat_add(r_sum[0], fx_mult_round(w_ir_0_31, x_31));
        r_sum[0] = sat_add(r_sum[0], fx_mult_round(w_ir_0_32, x_32));
        r_sum[0] = sat_add(r_sum[0], fx_mult_round(w_ir_0_33, x_33));
        r_sum[0] = sat_add(r_sum[0], fx_mult_round(w_ir_0_34, x_34));
        r_sum[0] = sat_add(r_sum[0], fx_mult_round(w_ir_0_35, x_35));
        r_sum[0] = sat_add(r_sum[0], fx_mult_round(w_ir_0_36, x_36));
        r_sum[0] = sat_add(r_sum[0], fx_mult_round(w_ir_0_37, x_37));
        r_sum[0] = sat_add(r_sum[0], fx_mult_round(w_ir_0_38, x_38));
        r_sum[0] = sat_add(r_sum[0], fx_mult_round(w_ir_0_39, x_39));
        r_sum[0] = sat_add(r_sum[0], fx_mult_round(w_ir_0_40, x_40));
        r_sum[0] = sat_add(r_sum[0], fx_mult_round(w_ir_0_41, x_41));
        r_sum[0] = sat_add(r_sum[0], fx_mult_round(w_ir_0_42, x_42));
        r_sum[0] = sat_add(r_sum[0], fx_mult_round(w_ir_0_43, x_43));
        r_sum[0] = sat_add(r_sum[0], fx_mult_round(w_ir_0_44, x_44));
        r_sum[0] = sat_add(r_sum[0], fx_mult_round(w_ir_0_45, x_45));
        r_sum[0] = sat_add(r_sum[0], fx_mult_round(w_ir_0_46, x_46));
        r_sum[0] = sat_add(r_sum[0], fx_mult_round(w_ir_0_47, x_47));
        r_sum[0] = sat_add(r_sum[0], fx_mult_round(w_ir_0_48, x_48));
        r_sum[0] = sat_add(r_sum[0], fx_mult_round(w_ir_0_49, x_49));
        r_sum[0] = sat_add(r_sum[0], fx_mult_round(w_ir_0_50, x_50));
        r_sum[0] = sat_add(r_sum[0], fx_mult_round(w_ir_0_51, x_51));
        r_sum[0] = sat_add(r_sum[0], fx_mult_round(w_ir_0_52, x_52));
        r_sum[0] = sat_add(r_sum[0], fx_mult_round(w_ir_0_53, x_53));
        r_sum[0] = sat_add(r_sum[0], fx_mult_round(w_ir_0_54, x_54));
        r_sum[0] = sat_add(r_sum[0], fx_mult_round(w_ir_0_55, x_55));
        r_sum[0] = sat_add(r_sum[0], fx_mult_round(w_ir_0_56, x_56));
        r_sum[0] = sat_add(r_sum[0], fx_mult_round(w_ir_0_57, x_57));
        r_sum[0] = sat_add(r_sum[0], fx_mult_round(w_ir_0_58, x_58));
        r_sum[0] = sat_add(r_sum[0], fx_mult_round(w_ir_0_59, x_59));
        r_sum[0] = sat_add(r_sum[0], fx_mult_round(w_ir_0_60, x_60));
        r_sum[0] = sat_add(r_sum[0], fx_mult_round(w_ir_0_61, x_61));
        r_sum[0] = sat_add(r_sum[0], fx_mult_round(w_ir_0_62, x_62));
        r_sum[0] = sat_add(r_sum[0], fx_mult_round(w_ir_0_63, x_63));
        r_sum[0] = sat_add(r_sum[0], b_hr_0);
        r_sum[0] = sat_add(r_sum[0], fx_mult_round(w_hr_0_0, h_0));
        r_sum[0] = sat_add(r_sum[0], fx_mult_round(w_hr_0_1, h_1));
        r_sum[0] = sat_add(r_sum[0], fx_mult_round(w_hr_0_2, h_2));
        r_sum[0] = sat_add(r_sum[0], fx_mult_round(w_hr_0_3, h_3));

        // r_sum[1]
        r_sum[1] = b_ir_1;
        r_sum[1] = sat_add(r_sum[1], fx_mult_round(w_ir_1_0, x_0));
        r_sum[1] = sat_add(r_sum[1], fx_mult_round(w_ir_1_1, x_1));
        r_sum[1] = sat_add(r_sum[1], fx_mult_round(w_ir_1_2, x_2));
        r_sum[1] = sat_add(r_sum[1], fx_mult_round(w_ir_1_3, x_3));
        r_sum[1] = sat_add(r_sum[1], fx_mult_round(w_ir_1_4, x_4));
        r_sum[1] = sat_add(r_sum[1], fx_mult_round(w_ir_1_5, x_5));
        r_sum[1] = sat_add(r_sum[1], fx_mult_round(w_ir_1_6, x_6));
        r_sum[1] = sat_add(r_sum[1], fx_mult_round(w_ir_1_7, x_7));
        r_sum[1] = sat_add(r_sum[1], fx_mult_round(w_ir_1_8, x_8));
        r_sum[1] = sat_add(r_sum[1], fx_mult_round(w_ir_1_9, x_9));
        r_sum[1] = sat_add(r_sum[1], fx_mult_round(w_ir_1_10, x_10));
        r_sum[1] = sat_add(r_sum[1], fx_mult_round(w_ir_1_11, x_11));
        r_sum[1] = sat_add(r_sum[1], fx_mult_round(w_ir_1_12, x_12));
        r_sum[1] = sat_add(r_sum[1], fx_mult_round(w_ir_1_13, x_13));
        r_sum[1] = sat_add(r_sum[1], fx_mult_round(w_ir_1_14, x_14));
        r_sum[1] = sat_add(r_sum[1], fx_mult_round(w_ir_1_15, x_15));
        r_sum[1] = sat_add(r_sum[1], fx_mult_round(w_ir_1_16, x_16));
        r_sum[1] = sat_add(r_sum[1], fx_mult_round(w_ir_1_17, x_17));
        r_sum[1] = sat_add(r_sum[1], fx_mult_round(w_ir_1_18, x_18));
        r_sum[1] = sat_add(r_sum[1], fx_mult_round(w_ir_1_19, x_19));
        r_sum[1] = sat_add(r_sum[1], fx_mult_round(w_ir_1_20, x_20));
        r_sum[1] = sat_add(r_sum[1], fx_mult_round(w_ir_1_21, x_21));
        r_sum[1] = sat_add(r_sum[1], fx_mult_round(w_ir_1_22, x_22));
        r_sum[1] = sat_add(r_sum[1], fx_mult_round(w_ir_1_23, x_23));
        r_sum[1] = sat_add(r_sum[1], fx_mult_round(w_ir_1_24, x_24));
        r_sum[1] = sat_add(r_sum[1], fx_mult_round(w_ir_1_25, x_25));
        r_sum[1] = sat_add(r_sum[1], fx_mult_round(w_ir_1_26, x_26));
        r_sum[1] = sat_add(r_sum[1], fx_mult_round(w_ir_1_27, x_27));
        r_sum[1] = sat_add(r_sum[1], fx_mult_round(w_ir_1_28, x_28));
        r_sum[1] = sat_add(r_sum[1], fx_mult_round(w_ir_1_29, x_29));
        r_sum[1] = sat_add(r_sum[1], fx_mult_round(w_ir_1_30, x_30));
        r_sum[1] = sat_add(r_sum[1], fx_mult_round(w_ir_1_31, x_31));
        r_sum[1] = sat_add(r_sum[1], fx_mult_round(w_ir_1_32, x_32));
        r_sum[1] = sat_add(r_sum[1], fx_mult_round(w_ir_1_33, x_33));
        r_sum[1] = sat_add(r_sum[1], fx_mult_round(w_ir_1_34, x_34));
        r_sum[1] = sat_add(r_sum[1], fx_mult_round(w_ir_1_35, x_35));
        r_sum[1] = sat_add(r_sum[1], fx_mult_round(w_ir_1_36, x_36));
        r_sum[1] = sat_add(r_sum[1], fx_mult_round(w_ir_1_37, x_37));
        r_sum[1] = sat_add(r_sum[1], fx_mult_round(w_ir_1_38, x_38));
        r_sum[1] = sat_add(r_sum[1], fx_mult_round(w_ir_1_39, x_39));
        r_sum[1] = sat_add(r_sum[1], fx_mult_round(w_ir_1_40, x_40));
        r_sum[1] = sat_add(r_sum[1], fx_mult_round(w_ir_1_41, x_41));
        r_sum[1] = sat_add(r_sum[1], fx_mult_round(w_ir_1_42, x_42));
        r_sum[1] = sat_add(r_sum[1], fx_mult_round(w_ir_1_43, x_43));
        r_sum[1] = sat_add(r_sum[1], fx_mult_round(w_ir_1_44, x_44));
        r_sum[1] = sat_add(r_sum[1], fx_mult_round(w_ir_1_45, x_45));
        r_sum[1] = sat_add(r_sum[1], fx_mult_round(w_ir_1_46, x_46));
        r_sum[1] = sat_add(r_sum[1], fx_mult_round(w_ir_1_47, x_47));
        r_sum[1] = sat_add(r_sum[1], fx_mult_round(w_ir_1_48, x_48));
        r_sum[1] = sat_add(r_sum[1], fx_mult_round(w_ir_1_49, x_49));
        r_sum[1] = sat_add(r_sum[1], fx_mult_round(w_ir_1_50, x_50));
        r_sum[1] = sat_add(r_sum[1], fx_mult_round(w_ir_1_51, x_51));
        r_sum[1] = sat_add(r_sum[1], fx_mult_round(w_ir_1_52, x_52));
        r_sum[1] = sat_add(r_sum[1], fx_mult_round(w_ir_1_53, x_53));
        r_sum[1] = sat_add(r_sum[1], fx_mult_round(w_ir_1_54, x_54));
        r_sum[1] = sat_add(r_sum[1], fx_mult_round(w_ir_1_55, x_55));
        r_sum[1] = sat_add(r_sum[1], fx_mult_round(w_ir_1_56, x_56));
        r_sum[1] = sat_add(r_sum[1], fx_mult_round(w_ir_1_57, x_57));
        r_sum[1] = sat_add(r_sum[1], fx_mult_round(w_ir_1_58, x_58));
        r_sum[1] = sat_add(r_sum[1], fx_mult_round(w_ir_1_59, x_59));
        r_sum[1] = sat_add(r_sum[1], fx_mult_round(w_ir_1_60, x_60));
        r_sum[1] = sat_add(r_sum[1], fx_mult_round(w_ir_1_61, x_61));
        r_sum[1] = sat_add(r_sum[1], fx_mult_round(w_ir_1_62, x_62));
        r_sum[1] = sat_add(r_sum[1], fx_mult_round(w_ir_1_63, x_63));
        r_sum[1] = sat_add(r_sum[1], b_hr_1);
        r_sum[1] = sat_add(r_sum[1], fx_mult_round(w_hr_1_0, h_0));
        r_sum[1] = sat_add(r_sum[1], fx_mult_round(w_hr_1_1, h_1));
        r_sum[1] = sat_add(r_sum[1], fx_mult_round(w_hr_1_2, h_2));
        r_sum[1] = sat_add(r_sum[1], fx_mult_round(w_hr_1_3, h_3));

        // r_sum[2]
        r_sum[2] = b_ir_2;
        r_sum[2] = sat_add(r_sum[2], fx_mult_round(w_ir_2_0, x_0));
        r_sum[2] = sat_add(r_sum[2], fx_mult_round(w_ir_2_1, x_1));
        r_sum[2] = sat_add(r_sum[2], fx_mult_round(w_ir_2_2, x_2));
        r_sum[2] = sat_add(r_sum[2], fx_mult_round(w_ir_2_3, x_3));
        r_sum[2] = sat_add(r_sum[2], fx_mult_round(w_ir_2_4, x_4));
        r_sum[2] = sat_add(r_sum[2], fx_mult_round(w_ir_2_5, x_5));
        r_sum[2] = sat_add(r_sum[2], fx_mult_round(w_ir_2_6, x_6));
        r_sum[2] = sat_add(r_sum[2], fx_mult_round(w_ir_2_7, x_7));
        r_sum[2] = sat_add(r_sum[2], fx_mult_round(w_ir_2_8, x_8));
        r_sum[2] = sat_add(r_sum[2], fx_mult_round(w_ir_2_9, x_9));
        r_sum[2] = sat_add(r_sum[2], fx_mult_round(w_ir_2_10, x_10));
        r_sum[2] = sat_add(r_sum[2], fx_mult_round(w_ir_2_11, x_11));
        r_sum[2] = sat_add(r_sum[2], fx_mult_round(w_ir_2_12, x_12));
        r_sum[2] = sat_add(r_sum[2], fx_mult_round(w_ir_2_13, x_13));
        r_sum[2] = sat_add(r_sum[2], fx_mult_round(w_ir_2_14, x_14));
        r_sum[2] = sat_add(r_sum[2], fx_mult_round(w_ir_2_15, x_15));
        r_sum[2] = sat_add(r_sum[2], fx_mult_round(w_ir_2_16, x_16));
        r_sum[2] = sat_add(r_sum[2], fx_mult_round(w_ir_2_17, x_17));
        r_sum[2] = sat_add(r_sum[2], fx_mult_round(w_ir_2_18, x_18));
        r_sum[2] = sat_add(r_sum[2], fx_mult_round(w_ir_2_19, x_19));
        r_sum[2] = sat_add(r_sum[2], fx_mult_round(w_ir_2_20, x_20));
        r_sum[2] = sat_add(r_sum[2], fx_mult_round(w_ir_2_21, x_21));
        r_sum[2] = sat_add(r_sum[2], fx_mult_round(w_ir_2_22, x_22));
        r_sum[2] = sat_add(r_sum[2], fx_mult_round(w_ir_2_23, x_23));
        r_sum[2] = sat_add(r_sum[2], fx_mult_round(w_ir_2_24, x_24));
        r_sum[2] = sat_add(r_sum[2], fx_mult_round(w_ir_2_25, x_25));
        r_sum[2] = sat_add(r_sum[2], fx_mult_round(w_ir_2_26, x_26));
        r_sum[2] = sat_add(r_sum[2], fx_mult_round(w_ir_2_27, x_27));
        r_sum[2] = sat_add(r_sum[2], fx_mult_round(w_ir_2_28, x_28));
        r_sum[2] = sat_add(r_sum[2], fx_mult_round(w_ir_2_29, x_29));
        r_sum[2] = sat_add(r_sum[2], fx_mult_round(w_ir_2_30, x_30));
        r_sum[2] = sat_add(r_sum[2], fx_mult_round(w_ir_2_31, x_31));
        r_sum[2] = sat_add(r_sum[2], fx_mult_round(w_ir_2_32, x_32));
        r_sum[2] = sat_add(r_sum[2], fx_mult_round(w_ir_2_33, x_33));
        r_sum[2] = sat_add(r_sum[2], fx_mult_round(w_ir_2_34, x_34));
        r_sum[2] = sat_add(r_sum[2], fx_mult_round(w_ir_2_35, x_35));
        r_sum[2] = sat_add(r_sum[2], fx_mult_round(w_ir_2_36, x_36));
        r_sum[2] = sat_add(r_sum[2], fx_mult_round(w_ir_2_37, x_37));
        r_sum[2] = sat_add(r_sum[2], fx_mult_round(w_ir_2_38, x_38));
        r_sum[2] = sat_add(r_sum[2], fx_mult_round(w_ir_2_39, x_39));
        r_sum[2] = sat_add(r_sum[2], fx_mult_round(w_ir_2_40, x_40));
        r_sum[2] = sat_add(r_sum[2], fx_mult_round(w_ir_2_41, x_41));
        r_sum[2] = sat_add(r_sum[2], fx_mult_round(w_ir_2_42, x_42));
        r_sum[2] = sat_add(r_sum[2], fx_mult_round(w_ir_2_43, x_43));
        r_sum[2] = sat_add(r_sum[2], fx_mult_round(w_ir_2_44, x_44));
        r_sum[2] = sat_add(r_sum[2], fx_mult_round(w_ir_2_45, x_45));
        r_sum[2] = sat_add(r_sum[2], fx_mult_round(w_ir_2_46, x_46));
        r_sum[2] = sat_add(r_sum[2], fx_mult_round(w_ir_2_47, x_47));
        r_sum[2] = sat_add(r_sum[2], fx_mult_round(w_ir_2_48, x_48));
        r_sum[2] = sat_add(r_sum[2], fx_mult_round(w_ir_2_49, x_49));
        r_sum[2] = sat_add(r_sum[2], fx_mult_round(w_ir_2_50, x_50));
        r_sum[2] = sat_add(r_sum[2], fx_mult_round(w_ir_2_51, x_51));
        r_sum[2] = sat_add(r_sum[2], fx_mult_round(w_ir_2_52, x_52));
        r_sum[2] = sat_add(r_sum[2], fx_mult_round(w_ir_2_53, x_53));
        r_sum[2] = sat_add(r_sum[2], fx_mult_round(w_ir_2_54, x_54));
        r_sum[2] = sat_add(r_sum[2], fx_mult_round(w_ir_2_55, x_55));
        r_sum[2] = sat_add(r_sum[2], fx_mult_round(w_ir_2_56, x_56));
        r_sum[2] = sat_add(r_sum[2], fx_mult_round(w_ir_2_57, x_57));
        r_sum[2] = sat_add(r_sum[2], fx_mult_round(w_ir_2_58, x_58));
        r_sum[2] = sat_add(r_sum[2], fx_mult_round(w_ir_2_59, x_59));
        r_sum[2] = sat_add(r_sum[2], fx_mult_round(w_ir_2_60, x_60));
        r_sum[2] = sat_add(r_sum[2], fx_mult_round(w_ir_2_61, x_61));
        r_sum[2] = sat_add(r_sum[2], fx_mult_round(w_ir_2_62, x_62));
        r_sum[2] = sat_add(r_sum[2], fx_mult_round(w_ir_2_63, x_63));
        r_sum[2] = sat_add(r_sum[2], b_hr_2);
        r_sum[2] = sat_add(r_sum[2], fx_mult_round(w_hr_2_0, h_0));
        r_sum[2] = sat_add(r_sum[2], fx_mult_round(w_hr_2_1, h_1));
        r_sum[2] = sat_add(r_sum[2], fx_mult_round(w_hr_2_2, h_2));
        r_sum[2] = sat_add(r_sum[2], fx_mult_round(w_hr_2_3, h_3));

        // r_sum[3]
        r_sum[3] = b_ir_3;
        r_sum[3] = sat_add(r_sum[3], fx_mult_round(w_ir_3_0, x_0));
        r_sum[3] = sat_add(r_sum[3], fx_mult_round(w_ir_3_1, x_1));
        r_sum[3] = sat_add(r_sum[3], fx_mult_round(w_ir_3_2, x_2));
        r_sum[3] = sat_add(r_sum[3], fx_mult_round(w_ir_3_3, x_3));
        r_sum[3] = sat_add(r_sum[3], fx_mult_round(w_ir_3_4, x_4));
        r_sum[3] = sat_add(r_sum[3], fx_mult_round(w_ir_3_5, x_5));
        r_sum[3] = sat_add(r_sum[3], fx_mult_round(w_ir_3_6, x_6));
        r_sum[3] = sat_add(r_sum[3], fx_mult_round(w_ir_3_7, x_7));
        r_sum[3] = sat_add(r_sum[3], fx_mult_round(w_ir_3_8, x_8));
        r_sum[3] = sat_add(r_sum[3], fx_mult_round(w_ir_3_9, x_9));
        r_sum[3] = sat_add(r_sum[3], fx_mult_round(w_ir_3_10, x_10));
        r_sum[3] = sat_add(r_sum[3], fx_mult_round(w_ir_3_11, x_11));
        r_sum[3] = sat_add(r_sum[3], fx_mult_round(w_ir_3_12, x_12));
        r_sum[3] = sat_add(r_sum[3], fx_mult_round(w_ir_3_13, x_13));
        r_sum[3] = sat_add(r_sum[3], fx_mult_round(w_ir_3_14, x_14));
        r_sum[3] = sat_add(r_sum[3], fx_mult_round(w_ir_3_15, x_15));
        r_sum[3] = sat_add(r_sum[3], fx_mult_round(w_ir_3_16, x_16));
        r_sum[3] = sat_add(r_sum[3], fx_mult_round(w_ir_3_17, x_17));
        r_sum[3] = sat_add(r_sum[3], fx_mult_round(w_ir_3_18, x_18));
        r_sum[3] = sat_add(r_sum[3], fx_mult_round(w_ir_3_19, x_19));
        r_sum[3] = sat_add(r_sum[3], fx_mult_round(w_ir_3_20, x_20));
        r_sum[3] = sat_add(r_sum[3], fx_mult_round(w_ir_3_21, x_21));
        r_sum[3] = sat_add(r_sum[3], fx_mult_round(w_ir_3_22, x_22));
        r_sum[3] = sat_add(r_sum[3], fx_mult_round(w_ir_3_23, x_23));
        r_sum[3] = sat_add(r_sum[3], fx_mult_round(w_ir_3_24, x_24));
        r_sum[3] = sat_add(r_sum[3], fx_mult_round(w_ir_3_25, x_25));
        r_sum[3] = sat_add(r_sum[3], fx_mult_round(w_ir_3_26, x_26));
        r_sum[3] = sat_add(r_sum[3], fx_mult_round(w_ir_3_27, x_27));
        r_sum[3] = sat_add(r_sum[3], fx_mult_round(w_ir_3_28, x_28));
        r_sum[3] = sat_add(r_sum[3], fx_mult_round(w_ir_3_29, x_29));
        r_sum[3] = sat_add(r_sum[3], fx_mult_round(w_ir_3_30, x_30));
        r_sum[3] = sat_add(r_sum[3], fx_mult_round(w_ir_3_31, x_31));
        r_sum[3] = sat_add(r_sum[3], fx_mult_round(w_ir_3_32, x_32));
        r_sum[3] = sat_add(r_sum[3], fx_mult_round(w_ir_3_33, x_33));
        r_sum[3] = sat_add(r_sum[3], fx_mult_round(w_ir_3_34, x_34));
        r_sum[3] = sat_add(r_sum[3], fx_mult_round(w_ir_3_35, x_35));
        r_sum[3] = sat_add(r_sum[3], fx_mult_round(w_ir_3_36, x_36));
        r_sum[3] = sat_add(r_sum[3], fx_mult_round(w_ir_3_37, x_37));
        r_sum[3] = sat_add(r_sum[3], fx_mult_round(w_ir_3_38, x_38));
        r_sum[3] = sat_add(r_sum[3], fx_mult_round(w_ir_3_39, x_39));
        r_sum[3] = sat_add(r_sum[3], fx_mult_round(w_ir_3_40, x_40));
        r_sum[3] = sat_add(r_sum[3], fx_mult_round(w_ir_3_41, x_41));
        r_sum[3] = sat_add(r_sum[3], fx_mult_round(w_ir_3_42, x_42));
        r_sum[3] = sat_add(r_sum[3], fx_mult_round(w_ir_3_43, x_43));
        r_sum[3] = sat_add(r_sum[3], fx_mult_round(w_ir_3_44, x_44));
        r_sum[3] = sat_add(r_sum[3], fx_mult_round(w_ir_3_45, x_45));
        r_sum[3] = sat_add(r_sum[3], fx_mult_round(w_ir_3_46, x_46));
        r_sum[3] = sat_add(r_sum[3], fx_mult_round(w_ir_3_47, x_47));
        r_sum[3] = sat_add(r_sum[3], fx_mult_round(w_ir_3_48, x_48));
        r_sum[3] = sat_add(r_sum[3], fx_mult_round(w_ir_3_49, x_49));
        r_sum[3] = sat_add(r_sum[3], fx_mult_round(w_ir_3_50, x_50));
        r_sum[3] = sat_add(r_sum[3], fx_mult_round(w_ir_3_51, x_51));
        r_sum[3] = sat_add(r_sum[3], fx_mult_round(w_ir_3_52, x_52));
        r_sum[3] = sat_add(r_sum[3], fx_mult_round(w_ir_3_53, x_53));
        r_sum[3] = sat_add(r_sum[3], fx_mult_round(w_ir_3_54, x_54));
        r_sum[3] = sat_add(r_sum[3], fx_mult_round(w_ir_3_55, x_55));
        r_sum[3] = sat_add(r_sum[3], fx_mult_round(w_ir_3_56, x_56));
        r_sum[3] = sat_add(r_sum[3], fx_mult_round(w_ir_3_57, x_57));
        r_sum[3] = sat_add(r_sum[3], fx_mult_round(w_ir_3_58, x_58));
        r_sum[3] = sat_add(r_sum[3], fx_mult_round(w_ir_3_59, x_59));
        r_sum[3] = sat_add(r_sum[3], fx_mult_round(w_ir_3_60, x_60));
        r_sum[3] = sat_add(r_sum[3], fx_mult_round(w_ir_3_61, x_61));
        r_sum[3] = sat_add(r_sum[3], fx_mult_round(w_ir_3_62, x_62));
        r_sum[3] = sat_add(r_sum[3], fx_mult_round(w_ir_3_63, x_63));
        r_sum[3] = sat_add(r_sum[3], b_hr_3);
        r_sum[3] = sat_add(r_sum[3], fx_mult_round(w_hr_3_0, h_0));
        r_sum[3] = sat_add(r_sum[3], fx_mult_round(w_hr_3_1, h_1));
        r_sum[3] = sat_add(r_sum[3], fx_mult_round(w_hr_3_2, h_2));
        r_sum[3] = sat_add(r_sum[3], fx_mult_round(w_hr_3_3, h_3));

    end

    sigmoid #(.INT_WIDTH(INT_WIDTH), .FRAC_WIDTH(FRAC_WIDTH)) sigmoid_r0 (
        .reset(reset), .x(r_sum[0]), .y(r_act[0])
    );
    sigmoid #(.INT_WIDTH(INT_WIDTH), .FRAC_WIDTH(FRAC_WIDTH)) sigmoid_r1 (
        .reset(reset), .x(r_sum[1]), .y(r_act[1])
    );
    sigmoid #(.INT_WIDTH(INT_WIDTH), .FRAC_WIDTH(FRAC_WIDTH)) sigmoid_r2 (
        .reset(reset), .x(r_sum[2]), .y(r_act[2])
    );
    sigmoid #(.INT_WIDTH(INT_WIDTH), .FRAC_WIDTH(FRAC_WIDTH)) sigmoid_r3 (
        .reset(reset), .x(r_sum[3]), .y(r_act[3])
    );

    // Update gate: z_t = σ(W_iz*x + b_iz + W_hz*h + b_hz)
    // z gate computation
    logic signed [WIDTH-1:0] z_sum[4];
    logic signed [WIDTH-1:0] z_act[4];

    always_comb begin
        // z_sum[0]
        z_sum[0] = b_iz_0;
        z_sum[0] = sat_add(z_sum[0], fx_mult_round(w_iz_0_0, x_0));
        z_sum[0] = sat_add(z_sum[0], fx_mult_round(w_iz_0_1, x_1));
        z_sum[0] = sat_add(z_sum[0], fx_mult_round(w_iz_0_2, x_2));
        z_sum[0] = sat_add(z_sum[0], fx_mult_round(w_iz_0_3, x_3));
        z_sum[0] = sat_add(z_sum[0], fx_mult_round(w_iz_0_4, x_4));
        z_sum[0] = sat_add(z_sum[0], fx_mult_round(w_iz_0_5, x_5));
        z_sum[0] = sat_add(z_sum[0], fx_mult_round(w_iz_0_6, x_6));
        z_sum[0] = sat_add(z_sum[0], fx_mult_round(w_iz_0_7, x_7));
        z_sum[0] = sat_add(z_sum[0], fx_mult_round(w_iz_0_8, x_8));
        z_sum[0] = sat_add(z_sum[0], fx_mult_round(w_iz_0_9, x_9));
        z_sum[0] = sat_add(z_sum[0], fx_mult_round(w_iz_0_10, x_10));
        z_sum[0] = sat_add(z_sum[0], fx_mult_round(w_iz_0_11, x_11));
        z_sum[0] = sat_add(z_sum[0], fx_mult_round(w_iz_0_12, x_12));
        z_sum[0] = sat_add(z_sum[0], fx_mult_round(w_iz_0_13, x_13));
        z_sum[0] = sat_add(z_sum[0], fx_mult_round(w_iz_0_14, x_14));
        z_sum[0] = sat_add(z_sum[0], fx_mult_round(w_iz_0_15, x_15));
        z_sum[0] = sat_add(z_sum[0], fx_mult_round(w_iz_0_16, x_16));
        z_sum[0] = sat_add(z_sum[0], fx_mult_round(w_iz_0_17, x_17));
        z_sum[0] = sat_add(z_sum[0], fx_mult_round(w_iz_0_18, x_18));
        z_sum[0] = sat_add(z_sum[0], fx_mult_round(w_iz_0_19, x_19));
        z_sum[0] = sat_add(z_sum[0], fx_mult_round(w_iz_0_20, x_20));
        z_sum[0] = sat_add(z_sum[0], fx_mult_round(w_iz_0_21, x_21));
        z_sum[0] = sat_add(z_sum[0], fx_mult_round(w_iz_0_22, x_22));
        z_sum[0] = sat_add(z_sum[0], fx_mult_round(w_iz_0_23, x_23));
        z_sum[0] = sat_add(z_sum[0], fx_mult_round(w_iz_0_24, x_24));
        z_sum[0] = sat_add(z_sum[0], fx_mult_round(w_iz_0_25, x_25));
        z_sum[0] = sat_add(z_sum[0], fx_mult_round(w_iz_0_26, x_26));
        z_sum[0] = sat_add(z_sum[0], fx_mult_round(w_iz_0_27, x_27));
        z_sum[0] = sat_add(z_sum[0], fx_mult_round(w_iz_0_28, x_28));
        z_sum[0] = sat_add(z_sum[0], fx_mult_round(w_iz_0_29, x_29));
        z_sum[0] = sat_add(z_sum[0], fx_mult_round(w_iz_0_30, x_30));
        z_sum[0] = sat_add(z_sum[0], fx_mult_round(w_iz_0_31, x_31));
        z_sum[0] = sat_add(z_sum[0], fx_mult_round(w_iz_0_32, x_32));
        z_sum[0] = sat_add(z_sum[0], fx_mult_round(w_iz_0_33, x_33));
        z_sum[0] = sat_add(z_sum[0], fx_mult_round(w_iz_0_34, x_34));
        z_sum[0] = sat_add(z_sum[0], fx_mult_round(w_iz_0_35, x_35));
        z_sum[0] = sat_add(z_sum[0], fx_mult_round(w_iz_0_36, x_36));
        z_sum[0] = sat_add(z_sum[0], fx_mult_round(w_iz_0_37, x_37));
        z_sum[0] = sat_add(z_sum[0], fx_mult_round(w_iz_0_38, x_38));
        z_sum[0] = sat_add(z_sum[0], fx_mult_round(w_iz_0_39, x_39));
        z_sum[0] = sat_add(z_sum[0], fx_mult_round(w_iz_0_40, x_40));
        z_sum[0] = sat_add(z_sum[0], fx_mult_round(w_iz_0_41, x_41));
        z_sum[0] = sat_add(z_sum[0], fx_mult_round(w_iz_0_42, x_42));
        z_sum[0] = sat_add(z_sum[0], fx_mult_round(w_iz_0_43, x_43));
        z_sum[0] = sat_add(z_sum[0], fx_mult_round(w_iz_0_44, x_44));
        z_sum[0] = sat_add(z_sum[0], fx_mult_round(w_iz_0_45, x_45));
        z_sum[0] = sat_add(z_sum[0], fx_mult_round(w_iz_0_46, x_46));
        z_sum[0] = sat_add(z_sum[0], fx_mult_round(w_iz_0_47, x_47));
        z_sum[0] = sat_add(z_sum[0], fx_mult_round(w_iz_0_48, x_48));
        z_sum[0] = sat_add(z_sum[0], fx_mult_round(w_iz_0_49, x_49));
        z_sum[0] = sat_add(z_sum[0], fx_mult_round(w_iz_0_50, x_50));
        z_sum[0] = sat_add(z_sum[0], fx_mult_round(w_iz_0_51, x_51));
        z_sum[0] = sat_add(z_sum[0], fx_mult_round(w_iz_0_52, x_52));
        z_sum[0] = sat_add(z_sum[0], fx_mult_round(w_iz_0_53, x_53));
        z_sum[0] = sat_add(z_sum[0], fx_mult_round(w_iz_0_54, x_54));
        z_sum[0] = sat_add(z_sum[0], fx_mult_round(w_iz_0_55, x_55));
        z_sum[0] = sat_add(z_sum[0], fx_mult_round(w_iz_0_56, x_56));
        z_sum[0] = sat_add(z_sum[0], fx_mult_round(w_iz_0_57, x_57));
        z_sum[0] = sat_add(z_sum[0], fx_mult_round(w_iz_0_58, x_58));
        z_sum[0] = sat_add(z_sum[0], fx_mult_round(w_iz_0_59, x_59));
        z_sum[0] = sat_add(z_sum[0], fx_mult_round(w_iz_0_60, x_60));
        z_sum[0] = sat_add(z_sum[0], fx_mult_round(w_iz_0_61, x_61));
        z_sum[0] = sat_add(z_sum[0], fx_mult_round(w_iz_0_62, x_62));
        z_sum[0] = sat_add(z_sum[0], fx_mult_round(w_iz_0_63, x_63));
        z_sum[0] = sat_add(z_sum[0], b_hz_0);
        z_sum[0] = sat_add(z_sum[0], fx_mult_round(w_hz_0_0, h_0));
        z_sum[0] = sat_add(z_sum[0], fx_mult_round(w_hz_0_1, h_1));
        z_sum[0] = sat_add(z_sum[0], fx_mult_round(w_hz_0_2, h_2));
        z_sum[0] = sat_add(z_sum[0], fx_mult_round(w_hz_0_3, h_3));

        // z_sum[1]
        z_sum[1] = b_iz_1;
        z_sum[1] = sat_add(z_sum[1], fx_mult_round(w_iz_1_0, x_0));
        z_sum[1] = sat_add(z_sum[1], fx_mult_round(w_iz_1_1, x_1));
        z_sum[1] = sat_add(z_sum[1], fx_mult_round(w_iz_1_2, x_2));
        z_sum[1] = sat_add(z_sum[1], fx_mult_round(w_iz_1_3, x_3));
        z_sum[1] = sat_add(z_sum[1], fx_mult_round(w_iz_1_4, x_4));
        z_sum[1] = sat_add(z_sum[1], fx_mult_round(w_iz_1_5, x_5));
        z_sum[1] = sat_add(z_sum[1], fx_mult_round(w_iz_1_6, x_6));
        z_sum[1] = sat_add(z_sum[1], fx_mult_round(w_iz_1_7, x_7));
        z_sum[1] = sat_add(z_sum[1], fx_mult_round(w_iz_1_8, x_8));
        z_sum[1] = sat_add(z_sum[1], fx_mult_round(w_iz_1_9, x_9));
        z_sum[1] = sat_add(z_sum[1], fx_mult_round(w_iz_1_10, x_10));
        z_sum[1] = sat_add(z_sum[1], fx_mult_round(w_iz_1_11, x_11));
        z_sum[1] = sat_add(z_sum[1], fx_mult_round(w_iz_1_12, x_12));
        z_sum[1] = sat_add(z_sum[1], fx_mult_round(w_iz_1_13, x_13));
        z_sum[1] = sat_add(z_sum[1], fx_mult_round(w_iz_1_14, x_14));
        z_sum[1] = sat_add(z_sum[1], fx_mult_round(w_iz_1_15, x_15));
        z_sum[1] = sat_add(z_sum[1], fx_mult_round(w_iz_1_16, x_16));
        z_sum[1] = sat_add(z_sum[1], fx_mult_round(w_iz_1_17, x_17));
        z_sum[1] = sat_add(z_sum[1], fx_mult_round(w_iz_1_18, x_18));
        z_sum[1] = sat_add(z_sum[1], fx_mult_round(w_iz_1_19, x_19));
        z_sum[1] = sat_add(z_sum[1], fx_mult_round(w_iz_1_20, x_20));
        z_sum[1] = sat_add(z_sum[1], fx_mult_round(w_iz_1_21, x_21));
        z_sum[1] = sat_add(z_sum[1], fx_mult_round(w_iz_1_22, x_22));
        z_sum[1] = sat_add(z_sum[1], fx_mult_round(w_iz_1_23, x_23));
        z_sum[1] = sat_add(z_sum[1], fx_mult_round(w_iz_1_24, x_24));
        z_sum[1] = sat_add(z_sum[1], fx_mult_round(w_iz_1_25, x_25));
        z_sum[1] = sat_add(z_sum[1], fx_mult_round(w_iz_1_26, x_26));
        z_sum[1] = sat_add(z_sum[1], fx_mult_round(w_iz_1_27, x_27));
        z_sum[1] = sat_add(z_sum[1], fx_mult_round(w_iz_1_28, x_28));
        z_sum[1] = sat_add(z_sum[1], fx_mult_round(w_iz_1_29, x_29));
        z_sum[1] = sat_add(z_sum[1], fx_mult_round(w_iz_1_30, x_30));
        z_sum[1] = sat_add(z_sum[1], fx_mult_round(w_iz_1_31, x_31));
        z_sum[1] = sat_add(z_sum[1], fx_mult_round(w_iz_1_32, x_32));
        z_sum[1] = sat_add(z_sum[1], fx_mult_round(w_iz_1_33, x_33));
        z_sum[1] = sat_add(z_sum[1], fx_mult_round(w_iz_1_34, x_34));
        z_sum[1] = sat_add(z_sum[1], fx_mult_round(w_iz_1_35, x_35));
        z_sum[1] = sat_add(z_sum[1], fx_mult_round(w_iz_1_36, x_36));
        z_sum[1] = sat_add(z_sum[1], fx_mult_round(w_iz_1_37, x_37));
        z_sum[1] = sat_add(z_sum[1], fx_mult_round(w_iz_1_38, x_38));
        z_sum[1] = sat_add(z_sum[1], fx_mult_round(w_iz_1_39, x_39));
        z_sum[1] = sat_add(z_sum[1], fx_mult_round(w_iz_1_40, x_40));
        z_sum[1] = sat_add(z_sum[1], fx_mult_round(w_iz_1_41, x_41));
        z_sum[1] = sat_add(z_sum[1], fx_mult_round(w_iz_1_42, x_42));
        z_sum[1] = sat_add(z_sum[1], fx_mult_round(w_iz_1_43, x_43));
        z_sum[1] = sat_add(z_sum[1], fx_mult_round(w_iz_1_44, x_44));
        z_sum[1] = sat_add(z_sum[1], fx_mult_round(w_iz_1_45, x_45));
        z_sum[1] = sat_add(z_sum[1], fx_mult_round(w_iz_1_46, x_46));
        z_sum[1] = sat_add(z_sum[1], fx_mult_round(w_iz_1_47, x_47));
        z_sum[1] = sat_add(z_sum[1], fx_mult_round(w_iz_1_48, x_48));
        z_sum[1] = sat_add(z_sum[1], fx_mult_round(w_iz_1_49, x_49));
        z_sum[1] = sat_add(z_sum[1], fx_mult_round(w_iz_1_50, x_50));
        z_sum[1] = sat_add(z_sum[1], fx_mult_round(w_iz_1_51, x_51));
        z_sum[1] = sat_add(z_sum[1], fx_mult_round(w_iz_1_52, x_52));
        z_sum[1] = sat_add(z_sum[1], fx_mult_round(w_iz_1_53, x_53));
        z_sum[1] = sat_add(z_sum[1], fx_mult_round(w_iz_1_54, x_54));
        z_sum[1] = sat_add(z_sum[1], fx_mult_round(w_iz_1_55, x_55));
        z_sum[1] = sat_add(z_sum[1], fx_mult_round(w_iz_1_56, x_56));
        z_sum[1] = sat_add(z_sum[1], fx_mult_round(w_iz_1_57, x_57));
        z_sum[1] = sat_add(z_sum[1], fx_mult_round(w_iz_1_58, x_58));
        z_sum[1] = sat_add(z_sum[1], fx_mult_round(w_iz_1_59, x_59));
        z_sum[1] = sat_add(z_sum[1], fx_mult_round(w_iz_1_60, x_60));
        z_sum[1] = sat_add(z_sum[1], fx_mult_round(w_iz_1_61, x_61));
        z_sum[1] = sat_add(z_sum[1], fx_mult_round(w_iz_1_62, x_62));
        z_sum[1] = sat_add(z_sum[1], fx_mult_round(w_iz_1_63, x_63));
        z_sum[1] = sat_add(z_sum[1], b_hz_1);
        z_sum[1] = sat_add(z_sum[1], fx_mult_round(w_hz_1_0, h_0));
        z_sum[1] = sat_add(z_sum[1], fx_mult_round(w_hz_1_1, h_1));
        z_sum[1] = sat_add(z_sum[1], fx_mult_round(w_hz_1_2, h_2));
        z_sum[1] = sat_add(z_sum[1], fx_mult_round(w_hz_1_3, h_3));

        // z_sum[2]
        z_sum[2] = b_iz_2;
        z_sum[2] = sat_add(z_sum[2], fx_mult_round(w_iz_2_0, x_0));
        z_sum[2] = sat_add(z_sum[2], fx_mult_round(w_iz_2_1, x_1));
        z_sum[2] = sat_add(z_sum[2], fx_mult_round(w_iz_2_2, x_2));
        z_sum[2] = sat_add(z_sum[2], fx_mult_round(w_iz_2_3, x_3));
        z_sum[2] = sat_add(z_sum[2], fx_mult_round(w_iz_2_4, x_4));
        z_sum[2] = sat_add(z_sum[2], fx_mult_round(w_iz_2_5, x_5));
        z_sum[2] = sat_add(z_sum[2], fx_mult_round(w_iz_2_6, x_6));
        z_sum[2] = sat_add(z_sum[2], fx_mult_round(w_iz_2_7, x_7));
        z_sum[2] = sat_add(z_sum[2], fx_mult_round(w_iz_2_8, x_8));
        z_sum[2] = sat_add(z_sum[2], fx_mult_round(w_iz_2_9, x_9));
        z_sum[2] = sat_add(z_sum[2], fx_mult_round(w_iz_2_10, x_10));
        z_sum[2] = sat_add(z_sum[2], fx_mult_round(w_iz_2_11, x_11));
        z_sum[2] = sat_add(z_sum[2], fx_mult_round(w_iz_2_12, x_12));
        z_sum[2] = sat_add(z_sum[2], fx_mult_round(w_iz_2_13, x_13));
        z_sum[2] = sat_add(z_sum[2], fx_mult_round(w_iz_2_14, x_14));
        z_sum[2] = sat_add(z_sum[2], fx_mult_round(w_iz_2_15, x_15));
        z_sum[2] = sat_add(z_sum[2], fx_mult_round(w_iz_2_16, x_16));
        z_sum[2] = sat_add(z_sum[2], fx_mult_round(w_iz_2_17, x_17));
        z_sum[2] = sat_add(z_sum[2], fx_mult_round(w_iz_2_18, x_18));
        z_sum[2] = sat_add(z_sum[2], fx_mult_round(w_iz_2_19, x_19));
        z_sum[2] = sat_add(z_sum[2], fx_mult_round(w_iz_2_20, x_20));
        z_sum[2] = sat_add(z_sum[2], fx_mult_round(w_iz_2_21, x_21));
        z_sum[2] = sat_add(z_sum[2], fx_mult_round(w_iz_2_22, x_22));
        z_sum[2] = sat_add(z_sum[2], fx_mult_round(w_iz_2_23, x_23));
        z_sum[2] = sat_add(z_sum[2], fx_mult_round(w_iz_2_24, x_24));
        z_sum[2] = sat_add(z_sum[2], fx_mult_round(w_iz_2_25, x_25));
        z_sum[2] = sat_add(z_sum[2], fx_mult_round(w_iz_2_26, x_26));
        z_sum[2] = sat_add(z_sum[2], fx_mult_round(w_iz_2_27, x_27));
        z_sum[2] = sat_add(z_sum[2], fx_mult_round(w_iz_2_28, x_28));
        z_sum[2] = sat_add(z_sum[2], fx_mult_round(w_iz_2_29, x_29));
        z_sum[2] = sat_add(z_sum[2], fx_mult_round(w_iz_2_30, x_30));
        z_sum[2] = sat_add(z_sum[2], fx_mult_round(w_iz_2_31, x_31));
        z_sum[2] = sat_add(z_sum[2], fx_mult_round(w_iz_2_32, x_32));
        z_sum[2] = sat_add(z_sum[2], fx_mult_round(w_iz_2_33, x_33));
        z_sum[2] = sat_add(z_sum[2], fx_mult_round(w_iz_2_34, x_34));
        z_sum[2] = sat_add(z_sum[2], fx_mult_round(w_iz_2_35, x_35));
        z_sum[2] = sat_add(z_sum[2], fx_mult_round(w_iz_2_36, x_36));
        z_sum[2] = sat_add(z_sum[2], fx_mult_round(w_iz_2_37, x_37));
        z_sum[2] = sat_add(z_sum[2], fx_mult_round(w_iz_2_38, x_38));
        z_sum[2] = sat_add(z_sum[2], fx_mult_round(w_iz_2_39, x_39));
        z_sum[2] = sat_add(z_sum[2], fx_mult_round(w_iz_2_40, x_40));
        z_sum[2] = sat_add(z_sum[2], fx_mult_round(w_iz_2_41, x_41));
        z_sum[2] = sat_add(z_sum[2], fx_mult_round(w_iz_2_42, x_42));
        z_sum[2] = sat_add(z_sum[2], fx_mult_round(w_iz_2_43, x_43));
        z_sum[2] = sat_add(z_sum[2], fx_mult_round(w_iz_2_44, x_44));
        z_sum[2] = sat_add(z_sum[2], fx_mult_round(w_iz_2_45, x_45));
        z_sum[2] = sat_add(z_sum[2], fx_mult_round(w_iz_2_46, x_46));
        z_sum[2] = sat_add(z_sum[2], fx_mult_round(w_iz_2_47, x_47));
        z_sum[2] = sat_add(z_sum[2], fx_mult_round(w_iz_2_48, x_48));
        z_sum[2] = sat_add(z_sum[2], fx_mult_round(w_iz_2_49, x_49));
        z_sum[2] = sat_add(z_sum[2], fx_mult_round(w_iz_2_50, x_50));
        z_sum[2] = sat_add(z_sum[2], fx_mult_round(w_iz_2_51, x_51));
        z_sum[2] = sat_add(z_sum[2], fx_mult_round(w_iz_2_52, x_52));
        z_sum[2] = sat_add(z_sum[2], fx_mult_round(w_iz_2_53, x_53));
        z_sum[2] = sat_add(z_sum[2], fx_mult_round(w_iz_2_54, x_54));
        z_sum[2] = sat_add(z_sum[2], fx_mult_round(w_iz_2_55, x_55));
        z_sum[2] = sat_add(z_sum[2], fx_mult_round(w_iz_2_56, x_56));
        z_sum[2] = sat_add(z_sum[2], fx_mult_round(w_iz_2_57, x_57));
        z_sum[2] = sat_add(z_sum[2], fx_mult_round(w_iz_2_58, x_58));
        z_sum[2] = sat_add(z_sum[2], fx_mult_round(w_iz_2_59, x_59));
        z_sum[2] = sat_add(z_sum[2], fx_mult_round(w_iz_2_60, x_60));
        z_sum[2] = sat_add(z_sum[2], fx_mult_round(w_iz_2_61, x_61));
        z_sum[2] = sat_add(z_sum[2], fx_mult_round(w_iz_2_62, x_62));
        z_sum[2] = sat_add(z_sum[2], fx_mult_round(w_iz_2_63, x_63));
        z_sum[2] = sat_add(z_sum[2], b_hz_2);
        z_sum[2] = sat_add(z_sum[2], fx_mult_round(w_hz_2_0, h_0));
        z_sum[2] = sat_add(z_sum[2], fx_mult_round(w_hz_2_1, h_1));
        z_sum[2] = sat_add(z_sum[2], fx_mult_round(w_hz_2_2, h_2));
        z_sum[2] = sat_add(z_sum[2], fx_mult_round(w_hz_2_3, h_3));

        // z_sum[3]
        z_sum[3] = b_iz_3;
        z_sum[3] = sat_add(z_sum[3], fx_mult_round(w_iz_3_0, x_0));
        z_sum[3] = sat_add(z_sum[3], fx_mult_round(w_iz_3_1, x_1));
        z_sum[3] = sat_add(z_sum[3], fx_mult_round(w_iz_3_2, x_2));
        z_sum[3] = sat_add(z_sum[3], fx_mult_round(w_iz_3_3, x_3));
        z_sum[3] = sat_add(z_sum[3], fx_mult_round(w_iz_3_4, x_4));
        z_sum[3] = sat_add(z_sum[3], fx_mult_round(w_iz_3_5, x_5));
        z_sum[3] = sat_add(z_sum[3], fx_mult_round(w_iz_3_6, x_6));
        z_sum[3] = sat_add(z_sum[3], fx_mult_round(w_iz_3_7, x_7));
        z_sum[3] = sat_add(z_sum[3], fx_mult_round(w_iz_3_8, x_8));
        z_sum[3] = sat_add(z_sum[3], fx_mult_round(w_iz_3_9, x_9));
        z_sum[3] = sat_add(z_sum[3], fx_mult_round(w_iz_3_10, x_10));
        z_sum[3] = sat_add(z_sum[3], fx_mult_round(w_iz_3_11, x_11));
        z_sum[3] = sat_add(z_sum[3], fx_mult_round(w_iz_3_12, x_12));
        z_sum[3] = sat_add(z_sum[3], fx_mult_round(w_iz_3_13, x_13));
        z_sum[3] = sat_add(z_sum[3], fx_mult_round(w_iz_3_14, x_14));
        z_sum[3] = sat_add(z_sum[3], fx_mult_round(w_iz_3_15, x_15));
        z_sum[3] = sat_add(z_sum[3], fx_mult_round(w_iz_3_16, x_16));
        z_sum[3] = sat_add(z_sum[3], fx_mult_round(w_iz_3_17, x_17));
        z_sum[3] = sat_add(z_sum[3], fx_mult_round(w_iz_3_18, x_18));
        z_sum[3] = sat_add(z_sum[3], fx_mult_round(w_iz_3_19, x_19));
        z_sum[3] = sat_add(z_sum[3], fx_mult_round(w_iz_3_20, x_20));
        z_sum[3] = sat_add(z_sum[3], fx_mult_round(w_iz_3_21, x_21));
        z_sum[3] = sat_add(z_sum[3], fx_mult_round(w_iz_3_22, x_22));
        z_sum[3] = sat_add(z_sum[3], fx_mult_round(w_iz_3_23, x_23));
        z_sum[3] = sat_add(z_sum[3], fx_mult_round(w_iz_3_24, x_24));
        z_sum[3] = sat_add(z_sum[3], fx_mult_round(w_iz_3_25, x_25));
        z_sum[3] = sat_add(z_sum[3], fx_mult_round(w_iz_3_26, x_26));
        z_sum[3] = sat_add(z_sum[3], fx_mult_round(w_iz_3_27, x_27));
        z_sum[3] = sat_add(z_sum[3], fx_mult_round(w_iz_3_28, x_28));
        z_sum[3] = sat_add(z_sum[3], fx_mult_round(w_iz_3_29, x_29));
        z_sum[3] = sat_add(z_sum[3], fx_mult_round(w_iz_3_30, x_30));
        z_sum[3] = sat_add(z_sum[3], fx_mult_round(w_iz_3_31, x_31));
        z_sum[3] = sat_add(z_sum[3], fx_mult_round(w_iz_3_32, x_32));
        z_sum[3] = sat_add(z_sum[3], fx_mult_round(w_iz_3_33, x_33));
        z_sum[3] = sat_add(z_sum[3], fx_mult_round(w_iz_3_34, x_34));
        z_sum[3] = sat_add(z_sum[3], fx_mult_round(w_iz_3_35, x_35));
        z_sum[3] = sat_add(z_sum[3], fx_mult_round(w_iz_3_36, x_36));
        z_sum[3] = sat_add(z_sum[3], fx_mult_round(w_iz_3_37, x_37));
        z_sum[3] = sat_add(z_sum[3], fx_mult_round(w_iz_3_38, x_38));
        z_sum[3] = sat_add(z_sum[3], fx_mult_round(w_iz_3_39, x_39));
        z_sum[3] = sat_add(z_sum[3], fx_mult_round(w_iz_3_40, x_40));
        z_sum[3] = sat_add(z_sum[3], fx_mult_round(w_iz_3_41, x_41));
        z_sum[3] = sat_add(z_sum[3], fx_mult_round(w_iz_3_42, x_42));
        z_sum[3] = sat_add(z_sum[3], fx_mult_round(w_iz_3_43, x_43));
        z_sum[3] = sat_add(z_sum[3], fx_mult_round(w_iz_3_44, x_44));
        z_sum[3] = sat_add(z_sum[3], fx_mult_round(w_iz_3_45, x_45));
        z_sum[3] = sat_add(z_sum[3], fx_mult_round(w_iz_3_46, x_46));
        z_sum[3] = sat_add(z_sum[3], fx_mult_round(w_iz_3_47, x_47));
        z_sum[3] = sat_add(z_sum[3], fx_mult_round(w_iz_3_48, x_48));
        z_sum[3] = sat_add(z_sum[3], fx_mult_round(w_iz_3_49, x_49));
        z_sum[3] = sat_add(z_sum[3], fx_mult_round(w_iz_3_50, x_50));
        z_sum[3] = sat_add(z_sum[3], fx_mult_round(w_iz_3_51, x_51));
        z_sum[3] = sat_add(z_sum[3], fx_mult_round(w_iz_3_52, x_52));
        z_sum[3] = sat_add(z_sum[3], fx_mult_round(w_iz_3_53, x_53));
        z_sum[3] = sat_add(z_sum[3], fx_mult_round(w_iz_3_54, x_54));
        z_sum[3] = sat_add(z_sum[3], fx_mult_round(w_iz_3_55, x_55));
        z_sum[3] = sat_add(z_sum[3], fx_mult_round(w_iz_3_56, x_56));
        z_sum[3] = sat_add(z_sum[3], fx_mult_round(w_iz_3_57, x_57));
        z_sum[3] = sat_add(z_sum[3], fx_mult_round(w_iz_3_58, x_58));
        z_sum[3] = sat_add(z_sum[3], fx_mult_round(w_iz_3_59, x_59));
        z_sum[3] = sat_add(z_sum[3], fx_mult_round(w_iz_3_60, x_60));
        z_sum[3] = sat_add(z_sum[3], fx_mult_round(w_iz_3_61, x_61));
        z_sum[3] = sat_add(z_sum[3], fx_mult_round(w_iz_3_62, x_62));
        z_sum[3] = sat_add(z_sum[3], fx_mult_round(w_iz_3_63, x_63));
        z_sum[3] = sat_add(z_sum[3], b_hz_3);
        z_sum[3] = sat_add(z_sum[3], fx_mult_round(w_hz_3_0, h_0));
        z_sum[3] = sat_add(z_sum[3], fx_mult_round(w_hz_3_1, h_1));
        z_sum[3] = sat_add(z_sum[3], fx_mult_round(w_hz_3_2, h_2));
        z_sum[3] = sat_add(z_sum[3], fx_mult_round(w_hz_3_3, h_3));

    end

    sigmoid #(.INT_WIDTH(INT_WIDTH), .FRAC_WIDTH(FRAC_WIDTH)) sigmoid_z0 (
        .reset(reset), .x(z_sum[0]), .y(z_act[0])
    );
    sigmoid #(.INT_WIDTH(INT_WIDTH), .FRAC_WIDTH(FRAC_WIDTH)) sigmoid_z1 (
        .reset(reset), .x(z_sum[1]), .y(z_act[1])
    );
    sigmoid #(.INT_WIDTH(INT_WIDTH), .FRAC_WIDTH(FRAC_WIDTH)) sigmoid_z2 (
        .reset(reset), .x(z_sum[2]), .y(z_act[2])
    );
    sigmoid #(.INT_WIDTH(INT_WIDTH), .FRAC_WIDTH(FRAC_WIDTH)) sigmoid_z3 (
        .reset(reset), .x(z_sum[3]), .y(z_act[3])
    );

    // Candidate hidden state: n_t = tanh(W_in*x + b_in + r_t ⊙ (W_hn*h + b_hn))
    // Candidate hidden state computation
    logic signed [WIDTH-1:0] wn_h[4];
    logic signed [WIDTH-1:0] gated_h[4];
    logic signed [WIDTH-1:0] n_sum[4];
    logic signed [WIDTH-1:0] n_act[4];

    always_comb begin
        // wn_h[0] = W_hn*h + b_hn
        wn_h[0] = b_hn_0;
        wn_h[0] = sat_add(wn_h[0], fx_mult_round(w_hn_0_0, h_0));
        wn_h[0] = sat_add(wn_h[0], fx_mult_round(w_hn_0_1, h_1));
        wn_h[0] = sat_add(wn_h[0], fx_mult_round(w_hn_0_2, h_2));
        wn_h[0] = sat_add(wn_h[0], fx_mult_round(w_hn_0_3, h_3));

        // gated_h[0] = r_t ⊙ wn_h
        gated_h[0] = fx_mult_round(r_act[0], wn_h[0]);

        // n_sum[0] = W_in*x + b_in + gated_h
        n_sum[0] = b_in_0;
        n_sum[0] = sat_add(n_sum[0], fx_mult_round(w_in_0_0, x_0));
        n_sum[0] = sat_add(n_sum[0], fx_mult_round(w_in_0_1, x_1));
        n_sum[0] = sat_add(n_sum[0], fx_mult_round(w_in_0_2, x_2));
        n_sum[0] = sat_add(n_sum[0], fx_mult_round(w_in_0_3, x_3));
        n_sum[0] = sat_add(n_sum[0], fx_mult_round(w_in_0_4, x_4));
        n_sum[0] = sat_add(n_sum[0], fx_mult_round(w_in_0_5, x_5));
        n_sum[0] = sat_add(n_sum[0], fx_mult_round(w_in_0_6, x_6));
        n_sum[0] = sat_add(n_sum[0], fx_mult_round(w_in_0_7, x_7));
        n_sum[0] = sat_add(n_sum[0], fx_mult_round(w_in_0_8, x_8));
        n_sum[0] = sat_add(n_sum[0], fx_mult_round(w_in_0_9, x_9));
        n_sum[0] = sat_add(n_sum[0], fx_mult_round(w_in_0_10, x_10));
        n_sum[0] = sat_add(n_sum[0], fx_mult_round(w_in_0_11, x_11));
        n_sum[0] = sat_add(n_sum[0], fx_mult_round(w_in_0_12, x_12));
        n_sum[0] = sat_add(n_sum[0], fx_mult_round(w_in_0_13, x_13));
        n_sum[0] = sat_add(n_sum[0], fx_mult_round(w_in_0_14, x_14));
        n_sum[0] = sat_add(n_sum[0], fx_mult_round(w_in_0_15, x_15));
        n_sum[0] = sat_add(n_sum[0], fx_mult_round(w_in_0_16, x_16));
        n_sum[0] = sat_add(n_sum[0], fx_mult_round(w_in_0_17, x_17));
        n_sum[0] = sat_add(n_sum[0], fx_mult_round(w_in_0_18, x_18));
        n_sum[0] = sat_add(n_sum[0], fx_mult_round(w_in_0_19, x_19));
        n_sum[0] = sat_add(n_sum[0], fx_mult_round(w_in_0_20, x_20));
        n_sum[0] = sat_add(n_sum[0], fx_mult_round(w_in_0_21, x_21));
        n_sum[0] = sat_add(n_sum[0], fx_mult_round(w_in_0_22, x_22));
        n_sum[0] = sat_add(n_sum[0], fx_mult_round(w_in_0_23, x_23));
        n_sum[0] = sat_add(n_sum[0], fx_mult_round(w_in_0_24, x_24));
        n_sum[0] = sat_add(n_sum[0], fx_mult_round(w_in_0_25, x_25));
        n_sum[0] = sat_add(n_sum[0], fx_mult_round(w_in_0_26, x_26));
        n_sum[0] = sat_add(n_sum[0], fx_mult_round(w_in_0_27, x_27));
        n_sum[0] = sat_add(n_sum[0], fx_mult_round(w_in_0_28, x_28));
        n_sum[0] = sat_add(n_sum[0], fx_mult_round(w_in_0_29, x_29));
        n_sum[0] = sat_add(n_sum[0], fx_mult_round(w_in_0_30, x_30));
        n_sum[0] = sat_add(n_sum[0], fx_mult_round(w_in_0_31, x_31));
        n_sum[0] = sat_add(n_sum[0], fx_mult_round(w_in_0_32, x_32));
        n_sum[0] = sat_add(n_sum[0], fx_mult_round(w_in_0_33, x_33));
        n_sum[0] = sat_add(n_sum[0], fx_mult_round(w_in_0_34, x_34));
        n_sum[0] = sat_add(n_sum[0], fx_mult_round(w_in_0_35, x_35));
        n_sum[0] = sat_add(n_sum[0], fx_mult_round(w_in_0_36, x_36));
        n_sum[0] = sat_add(n_sum[0], fx_mult_round(w_in_0_37, x_37));
        n_sum[0] = sat_add(n_sum[0], fx_mult_round(w_in_0_38, x_38));
        n_sum[0] = sat_add(n_sum[0], fx_mult_round(w_in_0_39, x_39));
        n_sum[0] = sat_add(n_sum[0], fx_mult_round(w_in_0_40, x_40));
        n_sum[0] = sat_add(n_sum[0], fx_mult_round(w_in_0_41, x_41));
        n_sum[0] = sat_add(n_sum[0], fx_mult_round(w_in_0_42, x_42));
        n_sum[0] = sat_add(n_sum[0], fx_mult_round(w_in_0_43, x_43));
        n_sum[0] = sat_add(n_sum[0], fx_mult_round(w_in_0_44, x_44));
        n_sum[0] = sat_add(n_sum[0], fx_mult_round(w_in_0_45, x_45));
        n_sum[0] = sat_add(n_sum[0], fx_mult_round(w_in_0_46, x_46));
        n_sum[0] = sat_add(n_sum[0], fx_mult_round(w_in_0_47, x_47));
        n_sum[0] = sat_add(n_sum[0], fx_mult_round(w_in_0_48, x_48));
        n_sum[0] = sat_add(n_sum[0], fx_mult_round(w_in_0_49, x_49));
        n_sum[0] = sat_add(n_sum[0], fx_mult_round(w_in_0_50, x_50));
        n_sum[0] = sat_add(n_sum[0], fx_mult_round(w_in_0_51, x_51));
        n_sum[0] = sat_add(n_sum[0], fx_mult_round(w_in_0_52, x_52));
        n_sum[0] = sat_add(n_sum[0], fx_mult_round(w_in_0_53, x_53));
        n_sum[0] = sat_add(n_sum[0], fx_mult_round(w_in_0_54, x_54));
        n_sum[0] = sat_add(n_sum[0], fx_mult_round(w_in_0_55, x_55));
        n_sum[0] = sat_add(n_sum[0], fx_mult_round(w_in_0_56, x_56));
        n_sum[0] = sat_add(n_sum[0], fx_mult_round(w_in_0_57, x_57));
        n_sum[0] = sat_add(n_sum[0], fx_mult_round(w_in_0_58, x_58));
        n_sum[0] = sat_add(n_sum[0], fx_mult_round(w_in_0_59, x_59));
        n_sum[0] = sat_add(n_sum[0], fx_mult_round(w_in_0_60, x_60));
        n_sum[0] = sat_add(n_sum[0], fx_mult_round(w_in_0_61, x_61));
        n_sum[0] = sat_add(n_sum[0], fx_mult_round(w_in_0_62, x_62));
        n_sum[0] = sat_add(n_sum[0], fx_mult_round(w_in_0_63, x_63));
        n_sum[0] = sat_add(n_sum[0], gated_h[0]);

        // wn_h[1] = W_hn*h + b_hn
        wn_h[1] = b_hn_1;
        wn_h[1] = sat_add(wn_h[1], fx_mult_round(w_hn_1_0, h_0));
        wn_h[1] = sat_add(wn_h[1], fx_mult_round(w_hn_1_1, h_1));
        wn_h[1] = sat_add(wn_h[1], fx_mult_round(w_hn_1_2, h_2));
        wn_h[1] = sat_add(wn_h[1], fx_mult_round(w_hn_1_3, h_3));

        // gated_h[1] = r_t ⊙ wn_h
        gated_h[1] = fx_mult_round(r_act[1], wn_h[1]);

        // n_sum[1] = W_in*x + b_in + gated_h
        n_sum[1] = b_in_1;
        n_sum[1] = sat_add(n_sum[1], fx_mult_round(w_in_1_0, x_0));
        n_sum[1] = sat_add(n_sum[1], fx_mult_round(w_in_1_1, x_1));
        n_sum[1] = sat_add(n_sum[1], fx_mult_round(w_in_1_2, x_2));
        n_sum[1] = sat_add(n_sum[1], fx_mult_round(w_in_1_3, x_3));
        n_sum[1] = sat_add(n_sum[1], fx_mult_round(w_in_1_4, x_4));
        n_sum[1] = sat_add(n_sum[1], fx_mult_round(w_in_1_5, x_5));
        n_sum[1] = sat_add(n_sum[1], fx_mult_round(w_in_1_6, x_6));
        n_sum[1] = sat_add(n_sum[1], fx_mult_round(w_in_1_7, x_7));
        n_sum[1] = sat_add(n_sum[1], fx_mult_round(w_in_1_8, x_8));
        n_sum[1] = sat_add(n_sum[1], fx_mult_round(w_in_1_9, x_9));
        n_sum[1] = sat_add(n_sum[1], fx_mult_round(w_in_1_10, x_10));
        n_sum[1] = sat_add(n_sum[1], fx_mult_round(w_in_1_11, x_11));
        n_sum[1] = sat_add(n_sum[1], fx_mult_round(w_in_1_12, x_12));
        n_sum[1] = sat_add(n_sum[1], fx_mult_round(w_in_1_13, x_13));
        n_sum[1] = sat_add(n_sum[1], fx_mult_round(w_in_1_14, x_14));
        n_sum[1] = sat_add(n_sum[1], fx_mult_round(w_in_1_15, x_15));
        n_sum[1] = sat_add(n_sum[1], fx_mult_round(w_in_1_16, x_16));
        n_sum[1] = sat_add(n_sum[1], fx_mult_round(w_in_1_17, x_17));
        n_sum[1] = sat_add(n_sum[1], fx_mult_round(w_in_1_18, x_18));
        n_sum[1] = sat_add(n_sum[1], fx_mult_round(w_in_1_19, x_19));
        n_sum[1] = sat_add(n_sum[1], fx_mult_round(w_in_1_20, x_20));
        n_sum[1] = sat_add(n_sum[1], fx_mult_round(w_in_1_21, x_21));
        n_sum[1] = sat_add(n_sum[1], fx_mult_round(w_in_1_22, x_22));
        n_sum[1] = sat_add(n_sum[1], fx_mult_round(w_in_1_23, x_23));
        n_sum[1] = sat_add(n_sum[1], fx_mult_round(w_in_1_24, x_24));
        n_sum[1] = sat_add(n_sum[1], fx_mult_round(w_in_1_25, x_25));
        n_sum[1] = sat_add(n_sum[1], fx_mult_round(w_in_1_26, x_26));
        n_sum[1] = sat_add(n_sum[1], fx_mult_round(w_in_1_27, x_27));
        n_sum[1] = sat_add(n_sum[1], fx_mult_round(w_in_1_28, x_28));
        n_sum[1] = sat_add(n_sum[1], fx_mult_round(w_in_1_29, x_29));
        n_sum[1] = sat_add(n_sum[1], fx_mult_round(w_in_1_30, x_30));
        n_sum[1] = sat_add(n_sum[1], fx_mult_round(w_in_1_31, x_31));
        n_sum[1] = sat_add(n_sum[1], fx_mult_round(w_in_1_32, x_32));
        n_sum[1] = sat_add(n_sum[1], fx_mult_round(w_in_1_33, x_33));
        n_sum[1] = sat_add(n_sum[1], fx_mult_round(w_in_1_34, x_34));
        n_sum[1] = sat_add(n_sum[1], fx_mult_round(w_in_1_35, x_35));
        n_sum[1] = sat_add(n_sum[1], fx_mult_round(w_in_1_36, x_36));
        n_sum[1] = sat_add(n_sum[1], fx_mult_round(w_in_1_37, x_37));
        n_sum[1] = sat_add(n_sum[1], fx_mult_round(w_in_1_38, x_38));
        n_sum[1] = sat_add(n_sum[1], fx_mult_round(w_in_1_39, x_39));
        n_sum[1] = sat_add(n_sum[1], fx_mult_round(w_in_1_40, x_40));
        n_sum[1] = sat_add(n_sum[1], fx_mult_round(w_in_1_41, x_41));
        n_sum[1] = sat_add(n_sum[1], fx_mult_round(w_in_1_42, x_42));
        n_sum[1] = sat_add(n_sum[1], fx_mult_round(w_in_1_43, x_43));
        n_sum[1] = sat_add(n_sum[1], fx_mult_round(w_in_1_44, x_44));
        n_sum[1] = sat_add(n_sum[1], fx_mult_round(w_in_1_45, x_45));
        n_sum[1] = sat_add(n_sum[1], fx_mult_round(w_in_1_46, x_46));
        n_sum[1] = sat_add(n_sum[1], fx_mult_round(w_in_1_47, x_47));
        n_sum[1] = sat_add(n_sum[1], fx_mult_round(w_in_1_48, x_48));
        n_sum[1] = sat_add(n_sum[1], fx_mult_round(w_in_1_49, x_49));
        n_sum[1] = sat_add(n_sum[1], fx_mult_round(w_in_1_50, x_50));
        n_sum[1] = sat_add(n_sum[1], fx_mult_round(w_in_1_51, x_51));
        n_sum[1] = sat_add(n_sum[1], fx_mult_round(w_in_1_52, x_52));
        n_sum[1] = sat_add(n_sum[1], fx_mult_round(w_in_1_53, x_53));
        n_sum[1] = sat_add(n_sum[1], fx_mult_round(w_in_1_54, x_54));
        n_sum[1] = sat_add(n_sum[1], fx_mult_round(w_in_1_55, x_55));
        n_sum[1] = sat_add(n_sum[1], fx_mult_round(w_in_1_56, x_56));
        n_sum[1] = sat_add(n_sum[1], fx_mult_round(w_in_1_57, x_57));
        n_sum[1] = sat_add(n_sum[1], fx_mult_round(w_in_1_58, x_58));
        n_sum[1] = sat_add(n_sum[1], fx_mult_round(w_in_1_59, x_59));
        n_sum[1] = sat_add(n_sum[1], fx_mult_round(w_in_1_60, x_60));
        n_sum[1] = sat_add(n_sum[1], fx_mult_round(w_in_1_61, x_61));
        n_sum[1] = sat_add(n_sum[1], fx_mult_round(w_in_1_62, x_62));
        n_sum[1] = sat_add(n_sum[1], fx_mult_round(w_in_1_63, x_63));
        n_sum[1] = sat_add(n_sum[1], gated_h[1]);

        // wn_h[2] = W_hn*h + b_hn
        wn_h[2] = b_hn_2;
        wn_h[2] = sat_add(wn_h[2], fx_mult_round(w_hn_2_0, h_0));
        wn_h[2] = sat_add(wn_h[2], fx_mult_round(w_hn_2_1, h_1));
        wn_h[2] = sat_add(wn_h[2], fx_mult_round(w_hn_2_2, h_2));
        wn_h[2] = sat_add(wn_h[2], fx_mult_round(w_hn_2_3, h_3));

        // gated_h[2] = r_t ⊙ wn_h
        gated_h[2] = fx_mult_round(r_act[2], wn_h[2]);

        // n_sum[2] = W_in*x + b_in + gated_h
        n_sum[2] = b_in_2;
        n_sum[2] = sat_add(n_sum[2], fx_mult_round(w_in_2_0, x_0));
        n_sum[2] = sat_add(n_sum[2], fx_mult_round(w_in_2_1, x_1));
        n_sum[2] = sat_add(n_sum[2], fx_mult_round(w_in_2_2, x_2));
        n_sum[2] = sat_add(n_sum[2], fx_mult_round(w_in_2_3, x_3));
        n_sum[2] = sat_add(n_sum[2], fx_mult_round(w_in_2_4, x_4));
        n_sum[2] = sat_add(n_sum[2], fx_mult_round(w_in_2_5, x_5));
        n_sum[2] = sat_add(n_sum[2], fx_mult_round(w_in_2_6, x_6));
        n_sum[2] = sat_add(n_sum[2], fx_mult_round(w_in_2_7, x_7));
        n_sum[2] = sat_add(n_sum[2], fx_mult_round(w_in_2_8, x_8));
        n_sum[2] = sat_add(n_sum[2], fx_mult_round(w_in_2_9, x_9));
        n_sum[2] = sat_add(n_sum[2], fx_mult_round(w_in_2_10, x_10));
        n_sum[2] = sat_add(n_sum[2], fx_mult_round(w_in_2_11, x_11));
        n_sum[2] = sat_add(n_sum[2], fx_mult_round(w_in_2_12, x_12));
        n_sum[2] = sat_add(n_sum[2], fx_mult_round(w_in_2_13, x_13));
        n_sum[2] = sat_add(n_sum[2], fx_mult_round(w_in_2_14, x_14));
        n_sum[2] = sat_add(n_sum[2], fx_mult_round(w_in_2_15, x_15));
        n_sum[2] = sat_add(n_sum[2], fx_mult_round(w_in_2_16, x_16));
        n_sum[2] = sat_add(n_sum[2], fx_mult_round(w_in_2_17, x_17));
        n_sum[2] = sat_add(n_sum[2], fx_mult_round(w_in_2_18, x_18));
        n_sum[2] = sat_add(n_sum[2], fx_mult_round(w_in_2_19, x_19));
        n_sum[2] = sat_add(n_sum[2], fx_mult_round(w_in_2_20, x_20));
        n_sum[2] = sat_add(n_sum[2], fx_mult_round(w_in_2_21, x_21));
        n_sum[2] = sat_add(n_sum[2], fx_mult_round(w_in_2_22, x_22));
        n_sum[2] = sat_add(n_sum[2], fx_mult_round(w_in_2_23, x_23));
        n_sum[2] = sat_add(n_sum[2], fx_mult_round(w_in_2_24, x_24));
        n_sum[2] = sat_add(n_sum[2], fx_mult_round(w_in_2_25, x_25));
        n_sum[2] = sat_add(n_sum[2], fx_mult_round(w_in_2_26, x_26));
        n_sum[2] = sat_add(n_sum[2], fx_mult_round(w_in_2_27, x_27));
        n_sum[2] = sat_add(n_sum[2], fx_mult_round(w_in_2_28, x_28));
        n_sum[2] = sat_add(n_sum[2], fx_mult_round(w_in_2_29, x_29));
        n_sum[2] = sat_add(n_sum[2], fx_mult_round(w_in_2_30, x_30));
        n_sum[2] = sat_add(n_sum[2], fx_mult_round(w_in_2_31, x_31));
        n_sum[2] = sat_add(n_sum[2], fx_mult_round(w_in_2_32, x_32));
        n_sum[2] = sat_add(n_sum[2], fx_mult_round(w_in_2_33, x_33));
        n_sum[2] = sat_add(n_sum[2], fx_mult_round(w_in_2_34, x_34));
        n_sum[2] = sat_add(n_sum[2], fx_mult_round(w_in_2_35, x_35));
        n_sum[2] = sat_add(n_sum[2], fx_mult_round(w_in_2_36, x_36));
        n_sum[2] = sat_add(n_sum[2], fx_mult_round(w_in_2_37, x_37));
        n_sum[2] = sat_add(n_sum[2], fx_mult_round(w_in_2_38, x_38));
        n_sum[2] = sat_add(n_sum[2], fx_mult_round(w_in_2_39, x_39));
        n_sum[2] = sat_add(n_sum[2], fx_mult_round(w_in_2_40, x_40));
        n_sum[2] = sat_add(n_sum[2], fx_mult_round(w_in_2_41, x_41));
        n_sum[2] = sat_add(n_sum[2], fx_mult_round(w_in_2_42, x_42));
        n_sum[2] = sat_add(n_sum[2], fx_mult_round(w_in_2_43, x_43));
        n_sum[2] = sat_add(n_sum[2], fx_mult_round(w_in_2_44, x_44));
        n_sum[2] = sat_add(n_sum[2], fx_mult_round(w_in_2_45, x_45));
        n_sum[2] = sat_add(n_sum[2], fx_mult_round(w_in_2_46, x_46));
        n_sum[2] = sat_add(n_sum[2], fx_mult_round(w_in_2_47, x_47));
        n_sum[2] = sat_add(n_sum[2], fx_mult_round(w_in_2_48, x_48));
        n_sum[2] = sat_add(n_sum[2], fx_mult_round(w_in_2_49, x_49));
        n_sum[2] = sat_add(n_sum[2], fx_mult_round(w_in_2_50, x_50));
        n_sum[2] = sat_add(n_sum[2], fx_mult_round(w_in_2_51, x_51));
        n_sum[2] = sat_add(n_sum[2], fx_mult_round(w_in_2_52, x_52));
        n_sum[2] = sat_add(n_sum[2], fx_mult_round(w_in_2_53, x_53));
        n_sum[2] = sat_add(n_sum[2], fx_mult_round(w_in_2_54, x_54));
        n_sum[2] = sat_add(n_sum[2], fx_mult_round(w_in_2_55, x_55));
        n_sum[2] = sat_add(n_sum[2], fx_mult_round(w_in_2_56, x_56));
        n_sum[2] = sat_add(n_sum[2], fx_mult_round(w_in_2_57, x_57));
        n_sum[2] = sat_add(n_sum[2], fx_mult_round(w_in_2_58, x_58));
        n_sum[2] = sat_add(n_sum[2], fx_mult_round(w_in_2_59, x_59));
        n_sum[2] = sat_add(n_sum[2], fx_mult_round(w_in_2_60, x_60));
        n_sum[2] = sat_add(n_sum[2], fx_mult_round(w_in_2_61, x_61));
        n_sum[2] = sat_add(n_sum[2], fx_mult_round(w_in_2_62, x_62));
        n_sum[2] = sat_add(n_sum[2], fx_mult_round(w_in_2_63, x_63));
        n_sum[2] = sat_add(n_sum[2], gated_h[2]);

        // wn_h[3] = W_hn*h + b_hn
        wn_h[3] = b_hn_3;
        wn_h[3] = sat_add(wn_h[3], fx_mult_round(w_hn_3_0, h_0));
        wn_h[3] = sat_add(wn_h[3], fx_mult_round(w_hn_3_1, h_1));
        wn_h[3] = sat_add(wn_h[3], fx_mult_round(w_hn_3_2, h_2));
        wn_h[3] = sat_add(wn_h[3], fx_mult_round(w_hn_3_3, h_3));

        // gated_h[3] = r_t ⊙ wn_h
        gated_h[3] = fx_mult_round(r_act[3], wn_h[3]);

        // n_sum[3] = W_in*x + b_in + gated_h
        n_sum[3] = b_in_3;
        n_sum[3] = sat_add(n_sum[3], fx_mult_round(w_in_3_0, x_0));
        n_sum[3] = sat_add(n_sum[3], fx_mult_round(w_in_3_1, x_1));
        n_sum[3] = sat_add(n_sum[3], fx_mult_round(w_in_3_2, x_2));
        n_sum[3] = sat_add(n_sum[3], fx_mult_round(w_in_3_3, x_3));
        n_sum[3] = sat_add(n_sum[3], fx_mult_round(w_in_3_4, x_4));
        n_sum[3] = sat_add(n_sum[3], fx_mult_round(w_in_3_5, x_5));
        n_sum[3] = sat_add(n_sum[3], fx_mult_round(w_in_3_6, x_6));
        n_sum[3] = sat_add(n_sum[3], fx_mult_round(w_in_3_7, x_7));
        n_sum[3] = sat_add(n_sum[3], fx_mult_round(w_in_3_8, x_8));
        n_sum[3] = sat_add(n_sum[3], fx_mult_round(w_in_3_9, x_9));
        n_sum[3] = sat_add(n_sum[3], fx_mult_round(w_in_3_10, x_10));
        n_sum[3] = sat_add(n_sum[3], fx_mult_round(w_in_3_11, x_11));
        n_sum[3] = sat_add(n_sum[3], fx_mult_round(w_in_3_12, x_12));
        n_sum[3] = sat_add(n_sum[3], fx_mult_round(w_in_3_13, x_13));
        n_sum[3] = sat_add(n_sum[3], fx_mult_round(w_in_3_14, x_14));
        n_sum[3] = sat_add(n_sum[3], fx_mult_round(w_in_3_15, x_15));
        n_sum[3] = sat_add(n_sum[3], fx_mult_round(w_in_3_16, x_16));
        n_sum[3] = sat_add(n_sum[3], fx_mult_round(w_in_3_17, x_17));
        n_sum[3] = sat_add(n_sum[3], fx_mult_round(w_in_3_18, x_18));
        n_sum[3] = sat_add(n_sum[3], fx_mult_round(w_in_3_19, x_19));
        n_sum[3] = sat_add(n_sum[3], fx_mult_round(w_in_3_20, x_20));
        n_sum[3] = sat_add(n_sum[3], fx_mult_round(w_in_3_21, x_21));
        n_sum[3] = sat_add(n_sum[3], fx_mult_round(w_in_3_22, x_22));
        n_sum[3] = sat_add(n_sum[3], fx_mult_round(w_in_3_23, x_23));
        n_sum[3] = sat_add(n_sum[3], fx_mult_round(w_in_3_24, x_24));
        n_sum[3] = sat_add(n_sum[3], fx_mult_round(w_in_3_25, x_25));
        n_sum[3] = sat_add(n_sum[3], fx_mult_round(w_in_3_26, x_26));
        n_sum[3] = sat_add(n_sum[3], fx_mult_round(w_in_3_27, x_27));
        n_sum[3] = sat_add(n_sum[3], fx_mult_round(w_in_3_28, x_28));
        n_sum[3] = sat_add(n_sum[3], fx_mult_round(w_in_3_29, x_29));
        n_sum[3] = sat_add(n_sum[3], fx_mult_round(w_in_3_30, x_30));
        n_sum[3] = sat_add(n_sum[3], fx_mult_round(w_in_3_31, x_31));
        n_sum[3] = sat_add(n_sum[3], fx_mult_round(w_in_3_32, x_32));
        n_sum[3] = sat_add(n_sum[3], fx_mult_round(w_in_3_33, x_33));
        n_sum[3] = sat_add(n_sum[3], fx_mult_round(w_in_3_34, x_34));
        n_sum[3] = sat_add(n_sum[3], fx_mult_round(w_in_3_35, x_35));
        n_sum[3] = sat_add(n_sum[3], fx_mult_round(w_in_3_36, x_36));
        n_sum[3] = sat_add(n_sum[3], fx_mult_round(w_in_3_37, x_37));
        n_sum[3] = sat_add(n_sum[3], fx_mult_round(w_in_3_38, x_38));
        n_sum[3] = sat_add(n_sum[3], fx_mult_round(w_in_3_39, x_39));
        n_sum[3] = sat_add(n_sum[3], fx_mult_round(w_in_3_40, x_40));
        n_sum[3] = sat_add(n_sum[3], fx_mult_round(w_in_3_41, x_41));
        n_sum[3] = sat_add(n_sum[3], fx_mult_round(w_in_3_42, x_42));
        n_sum[3] = sat_add(n_sum[3], fx_mult_round(w_in_3_43, x_43));
        n_sum[3] = sat_add(n_sum[3], fx_mult_round(w_in_3_44, x_44));
        n_sum[3] = sat_add(n_sum[3], fx_mult_round(w_in_3_45, x_45));
        n_sum[3] = sat_add(n_sum[3], fx_mult_round(w_in_3_46, x_46));
        n_sum[3] = sat_add(n_sum[3], fx_mult_round(w_in_3_47, x_47));
        n_sum[3] = sat_add(n_sum[3], fx_mult_round(w_in_3_48, x_48));
        n_sum[3] = sat_add(n_sum[3], fx_mult_round(w_in_3_49, x_49));
        n_sum[3] = sat_add(n_sum[3], fx_mult_round(w_in_3_50, x_50));
        n_sum[3] = sat_add(n_sum[3], fx_mult_round(w_in_3_51, x_51));
        n_sum[3] = sat_add(n_sum[3], fx_mult_round(w_in_3_52, x_52));
        n_sum[3] = sat_add(n_sum[3], fx_mult_round(w_in_3_53, x_53));
        n_sum[3] = sat_add(n_sum[3], fx_mult_round(w_in_3_54, x_54));
        n_sum[3] = sat_add(n_sum[3], fx_mult_round(w_in_3_55, x_55));
        n_sum[3] = sat_add(n_sum[3], fx_mult_round(w_in_3_56, x_56));
        n_sum[3] = sat_add(n_sum[3], fx_mult_round(w_in_3_57, x_57));
        n_sum[3] = sat_add(n_sum[3], fx_mult_round(w_in_3_58, x_58));
        n_sum[3] = sat_add(n_sum[3], fx_mult_round(w_in_3_59, x_59));
        n_sum[3] = sat_add(n_sum[3], fx_mult_round(w_in_3_60, x_60));
        n_sum[3] = sat_add(n_sum[3], fx_mult_round(w_in_3_61, x_61));
        n_sum[3] = sat_add(n_sum[3], fx_mult_round(w_in_3_62, x_62));
        n_sum[3] = sat_add(n_sum[3], fx_mult_round(w_in_3_63, x_63));
        n_sum[3] = sat_add(n_sum[3], gated_h[3]);

    end

    tanh #(.INT_WIDTH(INT_WIDTH), .FRAC_WIDTH(FRAC_WIDTH)) tanh_n0 (
         .reset(reset), .x(n_sum[0]), .y(n_act[0])
    );
    tanh #(.INT_WIDTH(INT_WIDTH), .FRAC_WIDTH(FRAC_WIDTH)) tanh_n1 (
         .reset(reset), .x(n_sum[1]), .y(n_act[1])
    );
    tanh #(.INT_WIDTH(INT_WIDTH), .FRAC_WIDTH(FRAC_WIDTH)) tanh_n2 (
         .reset(reset), .x(n_sum[2]), .y(n_act[2])
    );
    tanh #(.INT_WIDTH(INT_WIDTH), .FRAC_WIDTH(FRAC_WIDTH)) tanh_n3 (
         .reset(reset), .x(n_sum[3]), .y(n_act[3])
    );

    // Final hidden state update
    // Hidden state update: h_t = (1 - z_t) ⊙ n_t + z_t ⊙ h_{t-1}
    logic signed [WIDTH-1:0] one_minus_z[4];
    logic signed [WIDTH-1:0] part1[4], part2[4];
    logic signed [WIDTH-1:0] h_new[4];

    always_comb begin
        one_minus_z[0] = sat_add(ONE, -z_act[0]);
        part1[0] = fx_mult_round(one_minus_z[0], n_act[0]);
        part2[0] = fx_mult_round(z_act[0], h_0);
        h_new[0] = sat_add(part1[0], part2[0]);
        one_minus_z[1] = sat_add(ONE, -z_act[1]);
        part1[1] = fx_mult_round(one_minus_z[1], n_act[1]);
        part2[1] = fx_mult_round(z_act[1], h_1);
        h_new[1] = sat_add(part1[1], part2[1]);
        one_minus_z[2] = sat_add(ONE, -z_act[2]);
        part1[2] = fx_mult_round(one_minus_z[2], n_act[2]);
        part2[2] = fx_mult_round(z_act[2], h_2);
        h_new[2] = sat_add(part1[2], part2[2]);
        one_minus_z[3] = sat_add(ONE, -z_act[3]);
        part1[3] = fx_mult_round(one_minus_z[3], n_act[3]);
        part2[3] = fx_mult_round(z_act[3], h_3);
        h_new[3] = sat_add(part1[3], part2[3]);
    end

    // Register outputs
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            y_0 <= '0;
            y_1 <= '0;
            y_2 <= '0;
            y_3 <= '0;
        end else begin
            y_0 <= h_new[0];
            y_1 <= h_new[1];
            y_2 <= h_new[2];
            y_3 <= h_new[3];
        end
    end

endmodule
