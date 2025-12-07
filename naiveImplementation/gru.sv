
`timescale 1ns / 1ps
// GRU Cell Implementation (Fixed-Point Qm.f)
// d = 16 (input features), h = 8 (hidden units)
// WIDTH = INT_WIDTH + FRAC_WIDTH

module gru #(
    parameter int INT_WIDTH  = 6,
    parameter int FRAC_WIDTH = 14,
    parameter int WIDTH      = INT_WIDTH + FRAC_WIDTH
)(
    input  logic                     clk,
    input  logic                     reset,

    // Inputs (d=16)
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

    // Previous hidden state (h=8)
        input  logic signed [WIDTH-1:0]  h_0,
    input  logic signed [WIDTH-1:0]  h_1,
    input  logic signed [WIDTH-1:0]  h_2,
    input  logic signed [WIDTH-1:0]  h_3,
    input  logic signed [WIDTH-1:0]  h_4,
    input  logic signed [WIDTH-1:0]  h_5,
    input  logic signed [WIDTH-1:0]  h_6,
    input  logic signed [WIDTH-1:0]  h_7,

    // Input weights (h×d for each gate)
    input  logic signed [WIDTH-1:0]  w_ir_0_0, w_ir_0_1, w_ir_0_2, w_ir_0_3, w_ir_0_4, w_ir_0_5, w_ir_0_6, w_ir_0_7, w_ir_0_8, w_ir_0_9, w_ir_0_10, w_ir_0_11, w_ir_0_12, w_ir_0_13, w_ir_0_14, w_ir_0_15, w_ir_1_0, w_ir_1_1, w_ir_1_2, w_ir_1_3, w_ir_1_4, w_ir_1_5, w_ir_1_6, w_ir_1_7, w_ir_1_8, w_ir_1_9, w_ir_1_10, w_ir_1_11, w_ir_1_12, w_ir_1_13, w_ir_1_14, w_ir_1_15, w_ir_2_0, w_ir_2_1, w_ir_2_2, w_ir_2_3, w_ir_2_4, w_ir_2_5, w_ir_2_6, w_ir_2_7, w_ir_2_8, w_ir_2_9, w_ir_2_10, w_ir_2_11, w_ir_2_12, w_ir_2_13, w_ir_2_14, w_ir_2_15, w_ir_3_0, w_ir_3_1, w_ir_3_2, w_ir_3_3, w_ir_3_4, w_ir_3_5, w_ir_3_6, w_ir_3_7, w_ir_3_8, w_ir_3_9, w_ir_3_10, w_ir_3_11, w_ir_3_12, w_ir_3_13, w_ir_3_14, w_ir_3_15, w_ir_4_0, w_ir_4_1, w_ir_4_2, w_ir_4_3, w_ir_4_4, w_ir_4_5, w_ir_4_6, w_ir_4_7, w_ir_4_8, w_ir_4_9, w_ir_4_10, w_ir_4_11, w_ir_4_12, w_ir_4_13, w_ir_4_14, w_ir_4_15, w_ir_5_0, w_ir_5_1, w_ir_5_2, w_ir_5_3, w_ir_5_4, w_ir_5_5, w_ir_5_6, w_ir_5_7, w_ir_5_8, w_ir_5_9, w_ir_5_10, w_ir_5_11, w_ir_5_12, w_ir_5_13, w_ir_5_14, w_ir_5_15, w_ir_6_0, w_ir_6_1, w_ir_6_2, w_ir_6_3, w_ir_6_4, w_ir_6_5, w_ir_6_6, w_ir_6_7, w_ir_6_8, w_ir_6_9, w_ir_6_10, w_ir_6_11, w_ir_6_12, w_ir_6_13, w_ir_6_14, w_ir_6_15, w_ir_7_0, w_ir_7_1, w_ir_7_2, w_ir_7_3, w_ir_7_4, w_ir_7_5, w_ir_7_6, w_ir_7_7, w_ir_7_8, w_ir_7_9, w_ir_7_10, w_ir_7_11, w_ir_7_12, w_ir_7_13, w_ir_7_14, w_ir_7_15,
    input  logic signed [WIDTH-1:0]  w_iz_0_0, w_iz_0_1, w_iz_0_2, w_iz_0_3, w_iz_0_4, w_iz_0_5, w_iz_0_6, w_iz_0_7, w_iz_0_8, w_iz_0_9, w_iz_0_10, w_iz_0_11, w_iz_0_12, w_iz_0_13, w_iz_0_14, w_iz_0_15, w_iz_1_0, w_iz_1_1, w_iz_1_2, w_iz_1_3, w_iz_1_4, w_iz_1_5, w_iz_1_6, w_iz_1_7, w_iz_1_8, w_iz_1_9, w_iz_1_10, w_iz_1_11, w_iz_1_12, w_iz_1_13, w_iz_1_14, w_iz_1_15, w_iz_2_0, w_iz_2_1, w_iz_2_2, w_iz_2_3, w_iz_2_4, w_iz_2_5, w_iz_2_6, w_iz_2_7, w_iz_2_8, w_iz_2_9, w_iz_2_10, w_iz_2_11, w_iz_2_12, w_iz_2_13, w_iz_2_14, w_iz_2_15, w_iz_3_0, w_iz_3_1, w_iz_3_2, w_iz_3_3, w_iz_3_4, w_iz_3_5, w_iz_3_6, w_iz_3_7, w_iz_3_8, w_iz_3_9, w_iz_3_10, w_iz_3_11, w_iz_3_12, w_iz_3_13, w_iz_3_14, w_iz_3_15, w_iz_4_0, w_iz_4_1, w_iz_4_2, w_iz_4_3, w_iz_4_4, w_iz_4_5, w_iz_4_6, w_iz_4_7, w_iz_4_8, w_iz_4_9, w_iz_4_10, w_iz_4_11, w_iz_4_12, w_iz_4_13, w_iz_4_14, w_iz_4_15, w_iz_5_0, w_iz_5_1, w_iz_5_2, w_iz_5_3, w_iz_5_4, w_iz_5_5, w_iz_5_6, w_iz_5_7, w_iz_5_8, w_iz_5_9, w_iz_5_10, w_iz_5_11, w_iz_5_12, w_iz_5_13, w_iz_5_14, w_iz_5_15, w_iz_6_0, w_iz_6_1, w_iz_6_2, w_iz_6_3, w_iz_6_4, w_iz_6_5, w_iz_6_6, w_iz_6_7, w_iz_6_8, w_iz_6_9, w_iz_6_10, w_iz_6_11, w_iz_6_12, w_iz_6_13, w_iz_6_14, w_iz_6_15, w_iz_7_0, w_iz_7_1, w_iz_7_2, w_iz_7_3, w_iz_7_4, w_iz_7_5, w_iz_7_6, w_iz_7_7, w_iz_7_8, w_iz_7_9, w_iz_7_10, w_iz_7_11, w_iz_7_12, w_iz_7_13, w_iz_7_14, w_iz_7_15,
    input  logic signed [WIDTH-1:0]  w_in_0_0, w_in_0_1, w_in_0_2, w_in_0_3, w_in_0_4, w_in_0_5, w_in_0_6, w_in_0_7, w_in_0_8, w_in_0_9, w_in_0_10, w_in_0_11, w_in_0_12, w_in_0_13, w_in_0_14, w_in_0_15, w_in_1_0, w_in_1_1, w_in_1_2, w_in_1_3, w_in_1_4, w_in_1_5, w_in_1_6, w_in_1_7, w_in_1_8, w_in_1_9, w_in_1_10, w_in_1_11, w_in_1_12, w_in_1_13, w_in_1_14, w_in_1_15, w_in_2_0, w_in_2_1, w_in_2_2, w_in_2_3, w_in_2_4, w_in_2_5, w_in_2_6, w_in_2_7, w_in_2_8, w_in_2_9, w_in_2_10, w_in_2_11, w_in_2_12, w_in_2_13, w_in_2_14, w_in_2_15, w_in_3_0, w_in_3_1, w_in_3_2, w_in_3_3, w_in_3_4, w_in_3_5, w_in_3_6, w_in_3_7, w_in_3_8, w_in_3_9, w_in_3_10, w_in_3_11, w_in_3_12, w_in_3_13, w_in_3_14, w_in_3_15, w_in_4_0, w_in_4_1, w_in_4_2, w_in_4_3, w_in_4_4, w_in_4_5, w_in_4_6, w_in_4_7, w_in_4_8, w_in_4_9, w_in_4_10, w_in_4_11, w_in_4_12, w_in_4_13, w_in_4_14, w_in_4_15, w_in_5_0, w_in_5_1, w_in_5_2, w_in_5_3, w_in_5_4, w_in_5_5, w_in_5_6, w_in_5_7, w_in_5_8, w_in_5_9, w_in_5_10, w_in_5_11, w_in_5_12, w_in_5_13, w_in_5_14, w_in_5_15, w_in_6_0, w_in_6_1, w_in_6_2, w_in_6_3, w_in_6_4, w_in_6_5, w_in_6_6, w_in_6_7, w_in_6_8, w_in_6_9, w_in_6_10, w_in_6_11, w_in_6_12, w_in_6_13, w_in_6_14, w_in_6_15, w_in_7_0, w_in_7_1, w_in_7_2, w_in_7_3, w_in_7_4, w_in_7_5, w_in_7_6, w_in_7_7, w_in_7_8, w_in_7_9, w_in_7_10, w_in_7_11, w_in_7_12, w_in_7_13, w_in_7_14, w_in_7_15,

    // Recurrent weights (h×h for each gate)
    input  logic signed [WIDTH-1:0]  w_hr_0_0, w_hr_0_1, w_hr_0_2, w_hr_0_3, w_hr_0_4, w_hr_0_5, w_hr_0_6, w_hr_0_7, w_hr_1_0, w_hr_1_1, w_hr_1_2, w_hr_1_3, w_hr_1_4, w_hr_1_5, w_hr_1_6, w_hr_1_7, w_hr_2_0, w_hr_2_1, w_hr_2_2, w_hr_2_3, w_hr_2_4, w_hr_2_5, w_hr_2_6, w_hr_2_7, w_hr_3_0, w_hr_3_1, w_hr_3_2, w_hr_3_3, w_hr_3_4, w_hr_3_5, w_hr_3_6, w_hr_3_7, w_hr_4_0, w_hr_4_1, w_hr_4_2, w_hr_4_3, w_hr_4_4, w_hr_4_5, w_hr_4_6, w_hr_4_7, w_hr_5_0, w_hr_5_1, w_hr_5_2, w_hr_5_3, w_hr_5_4, w_hr_5_5, w_hr_5_6, w_hr_5_7, w_hr_6_0, w_hr_6_1, w_hr_6_2, w_hr_6_3, w_hr_6_4, w_hr_6_5, w_hr_6_6, w_hr_6_7, w_hr_7_0, w_hr_7_1, w_hr_7_2, w_hr_7_3, w_hr_7_4, w_hr_7_5, w_hr_7_6, w_hr_7_7,
    input  logic signed [WIDTH-1:0]  w_hz_0_0, w_hz_0_1, w_hz_0_2, w_hz_0_3, w_hz_0_4, w_hz_0_5, w_hz_0_6, w_hz_0_7, w_hz_1_0, w_hz_1_1, w_hz_1_2, w_hz_1_3, w_hz_1_4, w_hz_1_5, w_hz_1_6, w_hz_1_7, w_hz_2_0, w_hz_2_1, w_hz_2_2, w_hz_2_3, w_hz_2_4, w_hz_2_5, w_hz_2_6, w_hz_2_7, w_hz_3_0, w_hz_3_1, w_hz_3_2, w_hz_3_3, w_hz_3_4, w_hz_3_5, w_hz_3_6, w_hz_3_7, w_hz_4_0, w_hz_4_1, w_hz_4_2, w_hz_4_3, w_hz_4_4, w_hz_4_5, w_hz_4_6, w_hz_4_7, w_hz_5_0, w_hz_5_1, w_hz_5_2, w_hz_5_3, w_hz_5_4, w_hz_5_5, w_hz_5_6, w_hz_5_7, w_hz_6_0, w_hz_6_1, w_hz_6_2, w_hz_6_3, w_hz_6_4, w_hz_6_5, w_hz_6_6, w_hz_6_7, w_hz_7_0, w_hz_7_1, w_hz_7_2, w_hz_7_3, w_hz_7_4, w_hz_7_5, w_hz_7_6, w_hz_7_7,
    input  logic signed [WIDTH-1:0]  w_hn_0_0, w_hn_0_1, w_hn_0_2, w_hn_0_3, w_hn_0_4, w_hn_0_5, w_hn_0_6, w_hn_0_7, w_hn_1_0, w_hn_1_1, w_hn_1_2, w_hn_1_3, w_hn_1_4, w_hn_1_5, w_hn_1_6, w_hn_1_7, w_hn_2_0, w_hn_2_1, w_hn_2_2, w_hn_2_3, w_hn_2_4, w_hn_2_5, w_hn_2_6, w_hn_2_7, w_hn_3_0, w_hn_3_1, w_hn_3_2, w_hn_3_3, w_hn_3_4, w_hn_3_5, w_hn_3_6, w_hn_3_7, w_hn_4_0, w_hn_4_1, w_hn_4_2, w_hn_4_3, w_hn_4_4, w_hn_4_5, w_hn_4_6, w_hn_4_7, w_hn_5_0, w_hn_5_1, w_hn_5_2, w_hn_5_3, w_hn_5_4, w_hn_5_5, w_hn_5_6, w_hn_5_7, w_hn_6_0, w_hn_6_1, w_hn_6_2, w_hn_6_3, w_hn_6_4, w_hn_6_5, w_hn_6_6, w_hn_6_7, w_hn_7_0, w_hn_7_1, w_hn_7_2, w_hn_7_3, w_hn_7_4, w_hn_7_5, w_hn_7_6, w_hn_7_7,

    // Biases (h for each gate type)
    input  logic signed [WIDTH-1:0]  b_ir_0, b_ir_1, b_ir_2, b_ir_3, b_ir_4, b_ir_5, b_ir_6, b_ir_7, b_iz_0, b_iz_1, b_iz_2, b_iz_3, b_iz_4, b_iz_5, b_iz_6, b_iz_7, b_in_0, b_in_1, b_in_2, b_in_3, b_in_4, b_in_5, b_in_6, b_in_7, b_hr_0, b_hr_1, b_hr_2, b_hr_3, b_hr_4, b_hr_5, b_hr_6, b_hr_7, b_hz_0, b_hz_1, b_hz_2, b_hz_3, b_hz_4, b_hz_5, b_hz_6, b_hz_7, b_hn_0, b_hn_1, b_hn_2, b_hn_3, b_hn_4, b_hn_5, b_hn_6, b_hn_7,

    // Outputs (h=8)
        output logic signed [WIDTH-1:0]  y_0,
    output logic signed [WIDTH-1:0]  y_1,
    output logic signed [WIDTH-1:0]  y_2,
    output logic signed [WIDTH-1:0]  y_3,
    output logic signed [WIDTH-1:0]  y_4,
    output logic signed [WIDTH-1:0]  y_5,
    output logic signed [WIDTH-1:0]  y_6,
    output logic signed [WIDTH-1:0]  y_7
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
    logic signed [WIDTH-1:0] r_sum[8];
    logic signed [WIDTH-1:0] r_act[8];

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
        r_sum[0] = sat_add(r_sum[0], b_hr_0);
        r_sum[0] = sat_add(r_sum[0], fx_mult_round(w_hr_0_0, h_0));
        r_sum[0] = sat_add(r_sum[0], fx_mult_round(w_hr_0_1, h_1));
        r_sum[0] = sat_add(r_sum[0], fx_mult_round(w_hr_0_2, h_2));
        r_sum[0] = sat_add(r_sum[0], fx_mult_round(w_hr_0_3, h_3));
        r_sum[0] = sat_add(r_sum[0], fx_mult_round(w_hr_0_4, h_4));
        r_sum[0] = sat_add(r_sum[0], fx_mult_round(w_hr_0_5, h_5));
        r_sum[0] = sat_add(r_sum[0], fx_mult_round(w_hr_0_6, h_6));
        r_sum[0] = sat_add(r_sum[0], fx_mult_round(w_hr_0_7, h_7));

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
        r_sum[1] = sat_add(r_sum[1], b_hr_1);
        r_sum[1] = sat_add(r_sum[1], fx_mult_round(w_hr_1_0, h_0));
        r_sum[1] = sat_add(r_sum[1], fx_mult_round(w_hr_1_1, h_1));
        r_sum[1] = sat_add(r_sum[1], fx_mult_round(w_hr_1_2, h_2));
        r_sum[1] = sat_add(r_sum[1], fx_mult_round(w_hr_1_3, h_3));
        r_sum[1] = sat_add(r_sum[1], fx_mult_round(w_hr_1_4, h_4));
        r_sum[1] = sat_add(r_sum[1], fx_mult_round(w_hr_1_5, h_5));
        r_sum[1] = sat_add(r_sum[1], fx_mult_round(w_hr_1_6, h_6));
        r_sum[1] = sat_add(r_sum[1], fx_mult_round(w_hr_1_7, h_7));

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
        r_sum[2] = sat_add(r_sum[2], b_hr_2);
        r_sum[2] = sat_add(r_sum[2], fx_mult_round(w_hr_2_0, h_0));
        r_sum[2] = sat_add(r_sum[2], fx_mult_round(w_hr_2_1, h_1));
        r_sum[2] = sat_add(r_sum[2], fx_mult_round(w_hr_2_2, h_2));
        r_sum[2] = sat_add(r_sum[2], fx_mult_round(w_hr_2_3, h_3));
        r_sum[2] = sat_add(r_sum[2], fx_mult_round(w_hr_2_4, h_4));
        r_sum[2] = sat_add(r_sum[2], fx_mult_round(w_hr_2_5, h_5));
        r_sum[2] = sat_add(r_sum[2], fx_mult_round(w_hr_2_6, h_6));
        r_sum[2] = sat_add(r_sum[2], fx_mult_round(w_hr_2_7, h_7));

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
        r_sum[3] = sat_add(r_sum[3], b_hr_3);
        r_sum[3] = sat_add(r_sum[3], fx_mult_round(w_hr_3_0, h_0));
        r_sum[3] = sat_add(r_sum[3], fx_mult_round(w_hr_3_1, h_1));
        r_sum[3] = sat_add(r_sum[3], fx_mult_round(w_hr_3_2, h_2));
        r_sum[3] = sat_add(r_sum[3], fx_mult_round(w_hr_3_3, h_3));
        r_sum[3] = sat_add(r_sum[3], fx_mult_round(w_hr_3_4, h_4));
        r_sum[3] = sat_add(r_sum[3], fx_mult_round(w_hr_3_5, h_5));
        r_sum[3] = sat_add(r_sum[3], fx_mult_round(w_hr_3_6, h_6));
        r_sum[3] = sat_add(r_sum[3], fx_mult_round(w_hr_3_7, h_7));

        // r_sum[4]
        r_sum[4] = b_ir_4;
        r_sum[4] = sat_add(r_sum[4], fx_mult_round(w_ir_4_0, x_0));
        r_sum[4] = sat_add(r_sum[4], fx_mult_round(w_ir_4_1, x_1));
        r_sum[4] = sat_add(r_sum[4], fx_mult_round(w_ir_4_2, x_2));
        r_sum[4] = sat_add(r_sum[4], fx_mult_round(w_ir_4_3, x_3));
        r_sum[4] = sat_add(r_sum[4], fx_mult_round(w_ir_4_4, x_4));
        r_sum[4] = sat_add(r_sum[4], fx_mult_round(w_ir_4_5, x_5));
        r_sum[4] = sat_add(r_sum[4], fx_mult_round(w_ir_4_6, x_6));
        r_sum[4] = sat_add(r_sum[4], fx_mult_round(w_ir_4_7, x_7));
        r_sum[4] = sat_add(r_sum[4], fx_mult_round(w_ir_4_8, x_8));
        r_sum[4] = sat_add(r_sum[4], fx_mult_round(w_ir_4_9, x_9));
        r_sum[4] = sat_add(r_sum[4], fx_mult_round(w_ir_4_10, x_10));
        r_sum[4] = sat_add(r_sum[4], fx_mult_round(w_ir_4_11, x_11));
        r_sum[4] = sat_add(r_sum[4], fx_mult_round(w_ir_4_12, x_12));
        r_sum[4] = sat_add(r_sum[4], fx_mult_round(w_ir_4_13, x_13));
        r_sum[4] = sat_add(r_sum[4], fx_mult_round(w_ir_4_14, x_14));
        r_sum[4] = sat_add(r_sum[4], fx_mult_round(w_ir_4_15, x_15));
        r_sum[4] = sat_add(r_sum[4], b_hr_4);
        r_sum[4] = sat_add(r_sum[4], fx_mult_round(w_hr_4_0, h_0));
        r_sum[4] = sat_add(r_sum[4], fx_mult_round(w_hr_4_1, h_1));
        r_sum[4] = sat_add(r_sum[4], fx_mult_round(w_hr_4_2, h_2));
        r_sum[4] = sat_add(r_sum[4], fx_mult_round(w_hr_4_3, h_3));
        r_sum[4] = sat_add(r_sum[4], fx_mult_round(w_hr_4_4, h_4));
        r_sum[4] = sat_add(r_sum[4], fx_mult_round(w_hr_4_5, h_5));
        r_sum[4] = sat_add(r_sum[4], fx_mult_round(w_hr_4_6, h_6));
        r_sum[4] = sat_add(r_sum[4], fx_mult_round(w_hr_4_7, h_7));

        // r_sum[5]
        r_sum[5] = b_ir_5;
        r_sum[5] = sat_add(r_sum[5], fx_mult_round(w_ir_5_0, x_0));
        r_sum[5] = sat_add(r_sum[5], fx_mult_round(w_ir_5_1, x_1));
        r_sum[5] = sat_add(r_sum[5], fx_mult_round(w_ir_5_2, x_2));
        r_sum[5] = sat_add(r_sum[5], fx_mult_round(w_ir_5_3, x_3));
        r_sum[5] = sat_add(r_sum[5], fx_mult_round(w_ir_5_4, x_4));
        r_sum[5] = sat_add(r_sum[5], fx_mult_round(w_ir_5_5, x_5));
        r_sum[5] = sat_add(r_sum[5], fx_mult_round(w_ir_5_6, x_6));
        r_sum[5] = sat_add(r_sum[5], fx_mult_round(w_ir_5_7, x_7));
        r_sum[5] = sat_add(r_sum[5], fx_mult_round(w_ir_5_8, x_8));
        r_sum[5] = sat_add(r_sum[5], fx_mult_round(w_ir_5_9, x_9));
        r_sum[5] = sat_add(r_sum[5], fx_mult_round(w_ir_5_10, x_10));
        r_sum[5] = sat_add(r_sum[5], fx_mult_round(w_ir_5_11, x_11));
        r_sum[5] = sat_add(r_sum[5], fx_mult_round(w_ir_5_12, x_12));
        r_sum[5] = sat_add(r_sum[5], fx_mult_round(w_ir_5_13, x_13));
        r_sum[5] = sat_add(r_sum[5], fx_mult_round(w_ir_5_14, x_14));
        r_sum[5] = sat_add(r_sum[5], fx_mult_round(w_ir_5_15, x_15));
        r_sum[5] = sat_add(r_sum[5], b_hr_5);
        r_sum[5] = sat_add(r_sum[5], fx_mult_round(w_hr_5_0, h_0));
        r_sum[5] = sat_add(r_sum[5], fx_mult_round(w_hr_5_1, h_1));
        r_sum[5] = sat_add(r_sum[5], fx_mult_round(w_hr_5_2, h_2));
        r_sum[5] = sat_add(r_sum[5], fx_mult_round(w_hr_5_3, h_3));
        r_sum[5] = sat_add(r_sum[5], fx_mult_round(w_hr_5_4, h_4));
        r_sum[5] = sat_add(r_sum[5], fx_mult_round(w_hr_5_5, h_5));
        r_sum[5] = sat_add(r_sum[5], fx_mult_round(w_hr_5_6, h_6));
        r_sum[5] = sat_add(r_sum[5], fx_mult_round(w_hr_5_7, h_7));

        // r_sum[6]
        r_sum[6] = b_ir_6;
        r_sum[6] = sat_add(r_sum[6], fx_mult_round(w_ir_6_0, x_0));
        r_sum[6] = sat_add(r_sum[6], fx_mult_round(w_ir_6_1, x_1));
        r_sum[6] = sat_add(r_sum[6], fx_mult_round(w_ir_6_2, x_2));
        r_sum[6] = sat_add(r_sum[6], fx_mult_round(w_ir_6_3, x_3));
        r_sum[6] = sat_add(r_sum[6], fx_mult_round(w_ir_6_4, x_4));
        r_sum[6] = sat_add(r_sum[6], fx_mult_round(w_ir_6_5, x_5));
        r_sum[6] = sat_add(r_sum[6], fx_mult_round(w_ir_6_6, x_6));
        r_sum[6] = sat_add(r_sum[6], fx_mult_round(w_ir_6_7, x_7));
        r_sum[6] = sat_add(r_sum[6], fx_mult_round(w_ir_6_8, x_8));
        r_sum[6] = sat_add(r_sum[6], fx_mult_round(w_ir_6_9, x_9));
        r_sum[6] = sat_add(r_sum[6], fx_mult_round(w_ir_6_10, x_10));
        r_sum[6] = sat_add(r_sum[6], fx_mult_round(w_ir_6_11, x_11));
        r_sum[6] = sat_add(r_sum[6], fx_mult_round(w_ir_6_12, x_12));
        r_sum[6] = sat_add(r_sum[6], fx_mult_round(w_ir_6_13, x_13));
        r_sum[6] = sat_add(r_sum[6], fx_mult_round(w_ir_6_14, x_14));
        r_sum[6] = sat_add(r_sum[6], fx_mult_round(w_ir_6_15, x_15));
        r_sum[6] = sat_add(r_sum[6], b_hr_6);
        r_sum[6] = sat_add(r_sum[6], fx_mult_round(w_hr_6_0, h_0));
        r_sum[6] = sat_add(r_sum[6], fx_mult_round(w_hr_6_1, h_1));
        r_sum[6] = sat_add(r_sum[6], fx_mult_round(w_hr_6_2, h_2));
        r_sum[6] = sat_add(r_sum[6], fx_mult_round(w_hr_6_3, h_3));
        r_sum[6] = sat_add(r_sum[6], fx_mult_round(w_hr_6_4, h_4));
        r_sum[6] = sat_add(r_sum[6], fx_mult_round(w_hr_6_5, h_5));
        r_sum[6] = sat_add(r_sum[6], fx_mult_round(w_hr_6_6, h_6));
        r_sum[6] = sat_add(r_sum[6], fx_mult_round(w_hr_6_7, h_7));

        // r_sum[7]
        r_sum[7] = b_ir_7;
        r_sum[7] = sat_add(r_sum[7], fx_mult_round(w_ir_7_0, x_0));
        r_sum[7] = sat_add(r_sum[7], fx_mult_round(w_ir_7_1, x_1));
        r_sum[7] = sat_add(r_sum[7], fx_mult_round(w_ir_7_2, x_2));
        r_sum[7] = sat_add(r_sum[7], fx_mult_round(w_ir_7_3, x_3));
        r_sum[7] = sat_add(r_sum[7], fx_mult_round(w_ir_7_4, x_4));
        r_sum[7] = sat_add(r_sum[7], fx_mult_round(w_ir_7_5, x_5));
        r_sum[7] = sat_add(r_sum[7], fx_mult_round(w_ir_7_6, x_6));
        r_sum[7] = sat_add(r_sum[7], fx_mult_round(w_ir_7_7, x_7));
        r_sum[7] = sat_add(r_sum[7], fx_mult_round(w_ir_7_8, x_8));
        r_sum[7] = sat_add(r_sum[7], fx_mult_round(w_ir_7_9, x_9));
        r_sum[7] = sat_add(r_sum[7], fx_mult_round(w_ir_7_10, x_10));
        r_sum[7] = sat_add(r_sum[7], fx_mult_round(w_ir_7_11, x_11));
        r_sum[7] = sat_add(r_sum[7], fx_mult_round(w_ir_7_12, x_12));
        r_sum[7] = sat_add(r_sum[7], fx_mult_round(w_ir_7_13, x_13));
        r_sum[7] = sat_add(r_sum[7], fx_mult_round(w_ir_7_14, x_14));
        r_sum[7] = sat_add(r_sum[7], fx_mult_round(w_ir_7_15, x_15));
        r_sum[7] = sat_add(r_sum[7], b_hr_7);
        r_sum[7] = sat_add(r_sum[7], fx_mult_round(w_hr_7_0, h_0));
        r_sum[7] = sat_add(r_sum[7], fx_mult_round(w_hr_7_1, h_1));
        r_sum[7] = sat_add(r_sum[7], fx_mult_round(w_hr_7_2, h_2));
        r_sum[7] = sat_add(r_sum[7], fx_mult_round(w_hr_7_3, h_3));
        r_sum[7] = sat_add(r_sum[7], fx_mult_round(w_hr_7_4, h_4));
        r_sum[7] = sat_add(r_sum[7], fx_mult_round(w_hr_7_5, h_5));
        r_sum[7] = sat_add(r_sum[7], fx_mult_round(w_hr_7_6, h_6));
        r_sum[7] = sat_add(r_sum[7], fx_mult_round(w_hr_7_7, h_7));

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
    sigmoid #(.INT_WIDTH(INT_WIDTH), .FRAC_WIDTH(FRAC_WIDTH)) sigmoid_r4 (
        .reset(reset), .x(r_sum[4]), .y(r_act[4])
    );
    sigmoid #(.INT_WIDTH(INT_WIDTH), .FRAC_WIDTH(FRAC_WIDTH)) sigmoid_r5 (
        .reset(reset), .x(r_sum[5]), .y(r_act[5])
    );
    sigmoid #(.INT_WIDTH(INT_WIDTH), .FRAC_WIDTH(FRAC_WIDTH)) sigmoid_r6 (
        .reset(reset), .x(r_sum[6]), .y(r_act[6])
    );
    sigmoid #(.INT_WIDTH(INT_WIDTH), .FRAC_WIDTH(FRAC_WIDTH)) sigmoid_r7 (
        .reset(reset), .x(r_sum[7]), .y(r_act[7])
    );

    // Update gate: z_t = σ(W_iz*x + b_iz + W_hz*h + b_hz)
    // z gate computation
    logic signed [WIDTH-1:0] z_sum[8];
    logic signed [WIDTH-1:0] z_act[8];

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
        z_sum[0] = sat_add(z_sum[0], b_hz_0);
        z_sum[0] = sat_add(z_sum[0], fx_mult_round(w_hz_0_0, h_0));
        z_sum[0] = sat_add(z_sum[0], fx_mult_round(w_hz_0_1, h_1));
        z_sum[0] = sat_add(z_sum[0], fx_mult_round(w_hz_0_2, h_2));
        z_sum[0] = sat_add(z_sum[0], fx_mult_round(w_hz_0_3, h_3));
        z_sum[0] = sat_add(z_sum[0], fx_mult_round(w_hz_0_4, h_4));
        z_sum[0] = sat_add(z_sum[0], fx_mult_round(w_hz_0_5, h_5));
        z_sum[0] = sat_add(z_sum[0], fx_mult_round(w_hz_0_6, h_6));
        z_sum[0] = sat_add(z_sum[0], fx_mult_round(w_hz_0_7, h_7));

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
        z_sum[1] = sat_add(z_sum[1], b_hz_1);
        z_sum[1] = sat_add(z_sum[1], fx_mult_round(w_hz_1_0, h_0));
        z_sum[1] = sat_add(z_sum[1], fx_mult_round(w_hz_1_1, h_1));
        z_sum[1] = sat_add(z_sum[1], fx_mult_round(w_hz_1_2, h_2));
        z_sum[1] = sat_add(z_sum[1], fx_mult_round(w_hz_1_3, h_3));
        z_sum[1] = sat_add(z_sum[1], fx_mult_round(w_hz_1_4, h_4));
        z_sum[1] = sat_add(z_sum[1], fx_mult_round(w_hz_1_5, h_5));
        z_sum[1] = sat_add(z_sum[1], fx_mult_round(w_hz_1_6, h_6));
        z_sum[1] = sat_add(z_sum[1], fx_mult_round(w_hz_1_7, h_7));

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
        z_sum[2] = sat_add(z_sum[2], b_hz_2);
        z_sum[2] = sat_add(z_sum[2], fx_mult_round(w_hz_2_0, h_0));
        z_sum[2] = sat_add(z_sum[2], fx_mult_round(w_hz_2_1, h_1));
        z_sum[2] = sat_add(z_sum[2], fx_mult_round(w_hz_2_2, h_2));
        z_sum[2] = sat_add(z_sum[2], fx_mult_round(w_hz_2_3, h_3));
        z_sum[2] = sat_add(z_sum[2], fx_mult_round(w_hz_2_4, h_4));
        z_sum[2] = sat_add(z_sum[2], fx_mult_round(w_hz_2_5, h_5));
        z_sum[2] = sat_add(z_sum[2], fx_mult_round(w_hz_2_6, h_6));
        z_sum[2] = sat_add(z_sum[2], fx_mult_round(w_hz_2_7, h_7));

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
        z_sum[3] = sat_add(z_sum[3], b_hz_3);
        z_sum[3] = sat_add(z_sum[3], fx_mult_round(w_hz_3_0, h_0));
        z_sum[3] = sat_add(z_sum[3], fx_mult_round(w_hz_3_1, h_1));
        z_sum[3] = sat_add(z_sum[3], fx_mult_round(w_hz_3_2, h_2));
        z_sum[3] = sat_add(z_sum[3], fx_mult_round(w_hz_3_3, h_3));
        z_sum[3] = sat_add(z_sum[3], fx_mult_round(w_hz_3_4, h_4));
        z_sum[3] = sat_add(z_sum[3], fx_mult_round(w_hz_3_5, h_5));
        z_sum[3] = sat_add(z_sum[3], fx_mult_round(w_hz_3_6, h_6));
        z_sum[3] = sat_add(z_sum[3], fx_mult_round(w_hz_3_7, h_7));

        // z_sum[4]
        z_sum[4] = b_iz_4;
        z_sum[4] = sat_add(z_sum[4], fx_mult_round(w_iz_4_0, x_0));
        z_sum[4] = sat_add(z_sum[4], fx_mult_round(w_iz_4_1, x_1));
        z_sum[4] = sat_add(z_sum[4], fx_mult_round(w_iz_4_2, x_2));
        z_sum[4] = sat_add(z_sum[4], fx_mult_round(w_iz_4_3, x_3));
        z_sum[4] = sat_add(z_sum[4], fx_mult_round(w_iz_4_4, x_4));
        z_sum[4] = sat_add(z_sum[4], fx_mult_round(w_iz_4_5, x_5));
        z_sum[4] = sat_add(z_sum[4], fx_mult_round(w_iz_4_6, x_6));
        z_sum[4] = sat_add(z_sum[4], fx_mult_round(w_iz_4_7, x_7));
        z_sum[4] = sat_add(z_sum[4], fx_mult_round(w_iz_4_8, x_8));
        z_sum[4] = sat_add(z_sum[4], fx_mult_round(w_iz_4_9, x_9));
        z_sum[4] = sat_add(z_sum[4], fx_mult_round(w_iz_4_10, x_10));
        z_sum[4] = sat_add(z_sum[4], fx_mult_round(w_iz_4_11, x_11));
        z_sum[4] = sat_add(z_sum[4], fx_mult_round(w_iz_4_12, x_12));
        z_sum[4] = sat_add(z_sum[4], fx_mult_round(w_iz_4_13, x_13));
        z_sum[4] = sat_add(z_sum[4], fx_mult_round(w_iz_4_14, x_14));
        z_sum[4] = sat_add(z_sum[4], fx_mult_round(w_iz_4_15, x_15));
        z_sum[4] = sat_add(z_sum[4], b_hz_4);
        z_sum[4] = sat_add(z_sum[4], fx_mult_round(w_hz_4_0, h_0));
        z_sum[4] = sat_add(z_sum[4], fx_mult_round(w_hz_4_1, h_1));
        z_sum[4] = sat_add(z_sum[4], fx_mult_round(w_hz_4_2, h_2));
        z_sum[4] = sat_add(z_sum[4], fx_mult_round(w_hz_4_3, h_3));
        z_sum[4] = sat_add(z_sum[4], fx_mult_round(w_hz_4_4, h_4));
        z_sum[4] = sat_add(z_sum[4], fx_mult_round(w_hz_4_5, h_5));
        z_sum[4] = sat_add(z_sum[4], fx_mult_round(w_hz_4_6, h_6));
        z_sum[4] = sat_add(z_sum[4], fx_mult_round(w_hz_4_7, h_7));

        // z_sum[5]
        z_sum[5] = b_iz_5;
        z_sum[5] = sat_add(z_sum[5], fx_mult_round(w_iz_5_0, x_0));
        z_sum[5] = sat_add(z_sum[5], fx_mult_round(w_iz_5_1, x_1));
        z_sum[5] = sat_add(z_sum[5], fx_mult_round(w_iz_5_2, x_2));
        z_sum[5] = sat_add(z_sum[5], fx_mult_round(w_iz_5_3, x_3));
        z_sum[5] = sat_add(z_sum[5], fx_mult_round(w_iz_5_4, x_4));
        z_sum[5] = sat_add(z_sum[5], fx_mult_round(w_iz_5_5, x_5));
        z_sum[5] = sat_add(z_sum[5], fx_mult_round(w_iz_5_6, x_6));
        z_sum[5] = sat_add(z_sum[5], fx_mult_round(w_iz_5_7, x_7));
        z_sum[5] = sat_add(z_sum[5], fx_mult_round(w_iz_5_8, x_8));
        z_sum[5] = sat_add(z_sum[5], fx_mult_round(w_iz_5_9, x_9));
        z_sum[5] = sat_add(z_sum[5], fx_mult_round(w_iz_5_10, x_10));
        z_sum[5] = sat_add(z_sum[5], fx_mult_round(w_iz_5_11, x_11));
        z_sum[5] = sat_add(z_sum[5], fx_mult_round(w_iz_5_12, x_12));
        z_sum[5] = sat_add(z_sum[5], fx_mult_round(w_iz_5_13, x_13));
        z_sum[5] = sat_add(z_sum[5], fx_mult_round(w_iz_5_14, x_14));
        z_sum[5] = sat_add(z_sum[5], fx_mult_round(w_iz_5_15, x_15));
        z_sum[5] = sat_add(z_sum[5], b_hz_5);
        z_sum[5] = sat_add(z_sum[5], fx_mult_round(w_hz_5_0, h_0));
        z_sum[5] = sat_add(z_sum[5], fx_mult_round(w_hz_5_1, h_1));
        z_sum[5] = sat_add(z_sum[5], fx_mult_round(w_hz_5_2, h_2));
        z_sum[5] = sat_add(z_sum[5], fx_mult_round(w_hz_5_3, h_3));
        z_sum[5] = sat_add(z_sum[5], fx_mult_round(w_hz_5_4, h_4));
        z_sum[5] = sat_add(z_sum[5], fx_mult_round(w_hz_5_5, h_5));
        z_sum[5] = sat_add(z_sum[5], fx_mult_round(w_hz_5_6, h_6));
        z_sum[5] = sat_add(z_sum[5], fx_mult_round(w_hz_5_7, h_7));

        // z_sum[6]
        z_sum[6] = b_iz_6;
        z_sum[6] = sat_add(z_sum[6], fx_mult_round(w_iz_6_0, x_0));
        z_sum[6] = sat_add(z_sum[6], fx_mult_round(w_iz_6_1, x_1));
        z_sum[6] = sat_add(z_sum[6], fx_mult_round(w_iz_6_2, x_2));
        z_sum[6] = sat_add(z_sum[6], fx_mult_round(w_iz_6_3, x_3));
        z_sum[6] = sat_add(z_sum[6], fx_mult_round(w_iz_6_4, x_4));
        z_sum[6] = sat_add(z_sum[6], fx_mult_round(w_iz_6_5, x_5));
        z_sum[6] = sat_add(z_sum[6], fx_mult_round(w_iz_6_6, x_6));
        z_sum[6] = sat_add(z_sum[6], fx_mult_round(w_iz_6_7, x_7));
        z_sum[6] = sat_add(z_sum[6], fx_mult_round(w_iz_6_8, x_8));
        z_sum[6] = sat_add(z_sum[6], fx_mult_round(w_iz_6_9, x_9));
        z_sum[6] = sat_add(z_sum[6], fx_mult_round(w_iz_6_10, x_10));
        z_sum[6] = sat_add(z_sum[6], fx_mult_round(w_iz_6_11, x_11));
        z_sum[6] = sat_add(z_sum[6], fx_mult_round(w_iz_6_12, x_12));
        z_sum[6] = sat_add(z_sum[6], fx_mult_round(w_iz_6_13, x_13));
        z_sum[6] = sat_add(z_sum[6], fx_mult_round(w_iz_6_14, x_14));
        z_sum[6] = sat_add(z_sum[6], fx_mult_round(w_iz_6_15, x_15));
        z_sum[6] = sat_add(z_sum[6], b_hz_6);
        z_sum[6] = sat_add(z_sum[6], fx_mult_round(w_hz_6_0, h_0));
        z_sum[6] = sat_add(z_sum[6], fx_mult_round(w_hz_6_1, h_1));
        z_sum[6] = sat_add(z_sum[6], fx_mult_round(w_hz_6_2, h_2));
        z_sum[6] = sat_add(z_sum[6], fx_mult_round(w_hz_6_3, h_3));
        z_sum[6] = sat_add(z_sum[6], fx_mult_round(w_hz_6_4, h_4));
        z_sum[6] = sat_add(z_sum[6], fx_mult_round(w_hz_6_5, h_5));
        z_sum[6] = sat_add(z_sum[6], fx_mult_round(w_hz_6_6, h_6));
        z_sum[6] = sat_add(z_sum[6], fx_mult_round(w_hz_6_7, h_7));

        // z_sum[7]
        z_sum[7] = b_iz_7;
        z_sum[7] = sat_add(z_sum[7], fx_mult_round(w_iz_7_0, x_0));
        z_sum[7] = sat_add(z_sum[7], fx_mult_round(w_iz_7_1, x_1));
        z_sum[7] = sat_add(z_sum[7], fx_mult_round(w_iz_7_2, x_2));
        z_sum[7] = sat_add(z_sum[7], fx_mult_round(w_iz_7_3, x_3));
        z_sum[7] = sat_add(z_sum[7], fx_mult_round(w_iz_7_4, x_4));
        z_sum[7] = sat_add(z_sum[7], fx_mult_round(w_iz_7_5, x_5));
        z_sum[7] = sat_add(z_sum[7], fx_mult_round(w_iz_7_6, x_6));
        z_sum[7] = sat_add(z_sum[7], fx_mult_round(w_iz_7_7, x_7));
        z_sum[7] = sat_add(z_sum[7], fx_mult_round(w_iz_7_8, x_8));
        z_sum[7] = sat_add(z_sum[7], fx_mult_round(w_iz_7_9, x_9));
        z_sum[7] = sat_add(z_sum[7], fx_mult_round(w_iz_7_10, x_10));
        z_sum[7] = sat_add(z_sum[7], fx_mult_round(w_iz_7_11, x_11));
        z_sum[7] = sat_add(z_sum[7], fx_mult_round(w_iz_7_12, x_12));
        z_sum[7] = sat_add(z_sum[7], fx_mult_round(w_iz_7_13, x_13));
        z_sum[7] = sat_add(z_sum[7], fx_mult_round(w_iz_7_14, x_14));
        z_sum[7] = sat_add(z_sum[7], fx_mult_round(w_iz_7_15, x_15));
        z_sum[7] = sat_add(z_sum[7], b_hz_7);
        z_sum[7] = sat_add(z_sum[7], fx_mult_round(w_hz_7_0, h_0));
        z_sum[7] = sat_add(z_sum[7], fx_mult_round(w_hz_7_1, h_1));
        z_sum[7] = sat_add(z_sum[7], fx_mult_round(w_hz_7_2, h_2));
        z_sum[7] = sat_add(z_sum[7], fx_mult_round(w_hz_7_3, h_3));
        z_sum[7] = sat_add(z_sum[7], fx_mult_round(w_hz_7_4, h_4));
        z_sum[7] = sat_add(z_sum[7], fx_mult_round(w_hz_7_5, h_5));
        z_sum[7] = sat_add(z_sum[7], fx_mult_round(w_hz_7_6, h_6));
        z_sum[7] = sat_add(z_sum[7], fx_mult_round(w_hz_7_7, h_7));

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
    sigmoid #(.INT_WIDTH(INT_WIDTH), .FRAC_WIDTH(FRAC_WIDTH)) sigmoid_z4 (
        .reset(reset), .x(z_sum[4]), .y(z_act[4])
    );
    sigmoid #(.INT_WIDTH(INT_WIDTH), .FRAC_WIDTH(FRAC_WIDTH)) sigmoid_z5 (
        .reset(reset), .x(z_sum[5]), .y(z_act[5])
    );
    sigmoid #(.INT_WIDTH(INT_WIDTH), .FRAC_WIDTH(FRAC_WIDTH)) sigmoid_z6 (
        .reset(reset), .x(z_sum[6]), .y(z_act[6])
    );
    sigmoid #(.INT_WIDTH(INT_WIDTH), .FRAC_WIDTH(FRAC_WIDTH)) sigmoid_z7 (
        .reset(reset), .x(z_sum[7]), .y(z_act[7])
    );

    // Candidate hidden state: n_t = tanh(W_in*x + b_in + r_t ⊙ (W_hn*h + b_hn))
    // Candidate hidden state computation
    logic signed [WIDTH-1:0] wn_h[8];
    logic signed [WIDTH-1:0] gated_h[8];
    logic signed [WIDTH-1:0] n_sum[8];
    logic signed [WIDTH-1:0] n_act[8];

    always_comb begin
        // wn_h[0] = W_hn*h + b_hn
        wn_h[0] = b_hn_0;
        wn_h[0] = sat_add(wn_h[0], fx_mult_round(w_hn_0_0, h_0));
        wn_h[0] = sat_add(wn_h[0], fx_mult_round(w_hn_0_1, h_1));
        wn_h[0] = sat_add(wn_h[0], fx_mult_round(w_hn_0_2, h_2));
        wn_h[0] = sat_add(wn_h[0], fx_mult_round(w_hn_0_3, h_3));
        wn_h[0] = sat_add(wn_h[0], fx_mult_round(w_hn_0_4, h_4));
        wn_h[0] = sat_add(wn_h[0], fx_mult_round(w_hn_0_5, h_5));
        wn_h[0] = sat_add(wn_h[0], fx_mult_round(w_hn_0_6, h_6));
        wn_h[0] = sat_add(wn_h[0], fx_mult_round(w_hn_0_7, h_7));

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
        n_sum[0] = sat_add(n_sum[0], gated_h[0]);

        // wn_h[1] = W_hn*h + b_hn
        wn_h[1] = b_hn_1;
        wn_h[1] = sat_add(wn_h[1], fx_mult_round(w_hn_1_0, h_0));
        wn_h[1] = sat_add(wn_h[1], fx_mult_round(w_hn_1_1, h_1));
        wn_h[1] = sat_add(wn_h[1], fx_mult_round(w_hn_1_2, h_2));
        wn_h[1] = sat_add(wn_h[1], fx_mult_round(w_hn_1_3, h_3));
        wn_h[1] = sat_add(wn_h[1], fx_mult_round(w_hn_1_4, h_4));
        wn_h[1] = sat_add(wn_h[1], fx_mult_round(w_hn_1_5, h_5));
        wn_h[1] = sat_add(wn_h[1], fx_mult_round(w_hn_1_6, h_6));
        wn_h[1] = sat_add(wn_h[1], fx_mult_round(w_hn_1_7, h_7));

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
        n_sum[1] = sat_add(n_sum[1], gated_h[1]);

        // wn_h[2] = W_hn*h + b_hn
        wn_h[2] = b_hn_2;
        wn_h[2] = sat_add(wn_h[2], fx_mult_round(w_hn_2_0, h_0));
        wn_h[2] = sat_add(wn_h[2], fx_mult_round(w_hn_2_1, h_1));
        wn_h[2] = sat_add(wn_h[2], fx_mult_round(w_hn_2_2, h_2));
        wn_h[2] = sat_add(wn_h[2], fx_mult_round(w_hn_2_3, h_3));
        wn_h[2] = sat_add(wn_h[2], fx_mult_round(w_hn_2_4, h_4));
        wn_h[2] = sat_add(wn_h[2], fx_mult_round(w_hn_2_5, h_5));
        wn_h[2] = sat_add(wn_h[2], fx_mult_round(w_hn_2_6, h_6));
        wn_h[2] = sat_add(wn_h[2], fx_mult_round(w_hn_2_7, h_7));

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
        n_sum[2] = sat_add(n_sum[2], gated_h[2]);

        // wn_h[3] = W_hn*h + b_hn
        wn_h[3] = b_hn_3;
        wn_h[3] = sat_add(wn_h[3], fx_mult_round(w_hn_3_0, h_0));
        wn_h[3] = sat_add(wn_h[3], fx_mult_round(w_hn_3_1, h_1));
        wn_h[3] = sat_add(wn_h[3], fx_mult_round(w_hn_3_2, h_2));
        wn_h[3] = sat_add(wn_h[3], fx_mult_round(w_hn_3_3, h_3));
        wn_h[3] = sat_add(wn_h[3], fx_mult_round(w_hn_3_4, h_4));
        wn_h[3] = sat_add(wn_h[3], fx_mult_round(w_hn_3_5, h_5));
        wn_h[3] = sat_add(wn_h[3], fx_mult_round(w_hn_3_6, h_6));
        wn_h[3] = sat_add(wn_h[3], fx_mult_round(w_hn_3_7, h_7));

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
        n_sum[3] = sat_add(n_sum[3], gated_h[3]);

        // wn_h[4] = W_hn*h + b_hn
        wn_h[4] = b_hn_4;
        wn_h[4] = sat_add(wn_h[4], fx_mult_round(w_hn_4_0, h_0));
        wn_h[4] = sat_add(wn_h[4], fx_mult_round(w_hn_4_1, h_1));
        wn_h[4] = sat_add(wn_h[4], fx_mult_round(w_hn_4_2, h_2));
        wn_h[4] = sat_add(wn_h[4], fx_mult_round(w_hn_4_3, h_3));
        wn_h[4] = sat_add(wn_h[4], fx_mult_round(w_hn_4_4, h_4));
        wn_h[4] = sat_add(wn_h[4], fx_mult_round(w_hn_4_5, h_5));
        wn_h[4] = sat_add(wn_h[4], fx_mult_round(w_hn_4_6, h_6));
        wn_h[4] = sat_add(wn_h[4], fx_mult_round(w_hn_4_7, h_7));

        // gated_h[4] = r_t ⊙ wn_h
        gated_h[4] = fx_mult_round(r_act[4], wn_h[4]);

        // n_sum[4] = W_in*x + b_in + gated_h
        n_sum[4] = b_in_4;
        n_sum[4] = sat_add(n_sum[4], fx_mult_round(w_in_4_0, x_0));
        n_sum[4] = sat_add(n_sum[4], fx_mult_round(w_in_4_1, x_1));
        n_sum[4] = sat_add(n_sum[4], fx_mult_round(w_in_4_2, x_2));
        n_sum[4] = sat_add(n_sum[4], fx_mult_round(w_in_4_3, x_3));
        n_sum[4] = sat_add(n_sum[4], fx_mult_round(w_in_4_4, x_4));
        n_sum[4] = sat_add(n_sum[4], fx_mult_round(w_in_4_5, x_5));
        n_sum[4] = sat_add(n_sum[4], fx_mult_round(w_in_4_6, x_6));
        n_sum[4] = sat_add(n_sum[4], fx_mult_round(w_in_4_7, x_7));
        n_sum[4] = sat_add(n_sum[4], fx_mult_round(w_in_4_8, x_8));
        n_sum[4] = sat_add(n_sum[4], fx_mult_round(w_in_4_9, x_9));
        n_sum[4] = sat_add(n_sum[4], fx_mult_round(w_in_4_10, x_10));
        n_sum[4] = sat_add(n_sum[4], fx_mult_round(w_in_4_11, x_11));
        n_sum[4] = sat_add(n_sum[4], fx_mult_round(w_in_4_12, x_12));
        n_sum[4] = sat_add(n_sum[4], fx_mult_round(w_in_4_13, x_13));
        n_sum[4] = sat_add(n_sum[4], fx_mult_round(w_in_4_14, x_14));
        n_sum[4] = sat_add(n_sum[4], fx_mult_round(w_in_4_15, x_15));
        n_sum[4] = sat_add(n_sum[4], gated_h[4]);

        // wn_h[5] = W_hn*h + b_hn
        wn_h[5] = b_hn_5;
        wn_h[5] = sat_add(wn_h[5], fx_mult_round(w_hn_5_0, h_0));
        wn_h[5] = sat_add(wn_h[5], fx_mult_round(w_hn_5_1, h_1));
        wn_h[5] = sat_add(wn_h[5], fx_mult_round(w_hn_5_2, h_2));
        wn_h[5] = sat_add(wn_h[5], fx_mult_round(w_hn_5_3, h_3));
        wn_h[5] = sat_add(wn_h[5], fx_mult_round(w_hn_5_4, h_4));
        wn_h[5] = sat_add(wn_h[5], fx_mult_round(w_hn_5_5, h_5));
        wn_h[5] = sat_add(wn_h[5], fx_mult_round(w_hn_5_6, h_6));
        wn_h[5] = sat_add(wn_h[5], fx_mult_round(w_hn_5_7, h_7));

        // gated_h[5] = r_t ⊙ wn_h
        gated_h[5] = fx_mult_round(r_act[5], wn_h[5]);

        // n_sum[5] = W_in*x + b_in + gated_h
        n_sum[5] = b_in_5;
        n_sum[5] = sat_add(n_sum[5], fx_mult_round(w_in_5_0, x_0));
        n_sum[5] = sat_add(n_sum[5], fx_mult_round(w_in_5_1, x_1));
        n_sum[5] = sat_add(n_sum[5], fx_mult_round(w_in_5_2, x_2));
        n_sum[5] = sat_add(n_sum[5], fx_mult_round(w_in_5_3, x_3));
        n_sum[5] = sat_add(n_sum[5], fx_mult_round(w_in_5_4, x_4));
        n_sum[5] = sat_add(n_sum[5], fx_mult_round(w_in_5_5, x_5));
        n_sum[5] = sat_add(n_sum[5], fx_mult_round(w_in_5_6, x_6));
        n_sum[5] = sat_add(n_sum[5], fx_mult_round(w_in_5_7, x_7));
        n_sum[5] = sat_add(n_sum[5], fx_mult_round(w_in_5_8, x_8));
        n_sum[5] = sat_add(n_sum[5], fx_mult_round(w_in_5_9, x_9));
        n_sum[5] = sat_add(n_sum[5], fx_mult_round(w_in_5_10, x_10));
        n_sum[5] = sat_add(n_sum[5], fx_mult_round(w_in_5_11, x_11));
        n_sum[5] = sat_add(n_sum[5], fx_mult_round(w_in_5_12, x_12));
        n_sum[5] = sat_add(n_sum[5], fx_mult_round(w_in_5_13, x_13));
        n_sum[5] = sat_add(n_sum[5], fx_mult_round(w_in_5_14, x_14));
        n_sum[5] = sat_add(n_sum[5], fx_mult_round(w_in_5_15, x_15));
        n_sum[5] = sat_add(n_sum[5], gated_h[5]);

        // wn_h[6] = W_hn*h + b_hn
        wn_h[6] = b_hn_6;
        wn_h[6] = sat_add(wn_h[6], fx_mult_round(w_hn_6_0, h_0));
        wn_h[6] = sat_add(wn_h[6], fx_mult_round(w_hn_6_1, h_1));
        wn_h[6] = sat_add(wn_h[6], fx_mult_round(w_hn_6_2, h_2));
        wn_h[6] = sat_add(wn_h[6], fx_mult_round(w_hn_6_3, h_3));
        wn_h[6] = sat_add(wn_h[6], fx_mult_round(w_hn_6_4, h_4));
        wn_h[6] = sat_add(wn_h[6], fx_mult_round(w_hn_6_5, h_5));
        wn_h[6] = sat_add(wn_h[6], fx_mult_round(w_hn_6_6, h_6));
        wn_h[6] = sat_add(wn_h[6], fx_mult_round(w_hn_6_7, h_7));

        // gated_h[6] = r_t ⊙ wn_h
        gated_h[6] = fx_mult_round(r_act[6], wn_h[6]);

        // n_sum[6] = W_in*x + b_in + gated_h
        n_sum[6] = b_in_6;
        n_sum[6] = sat_add(n_sum[6], fx_mult_round(w_in_6_0, x_0));
        n_sum[6] = sat_add(n_sum[6], fx_mult_round(w_in_6_1, x_1));
        n_sum[6] = sat_add(n_sum[6], fx_mult_round(w_in_6_2, x_2));
        n_sum[6] = sat_add(n_sum[6], fx_mult_round(w_in_6_3, x_3));
        n_sum[6] = sat_add(n_sum[6], fx_mult_round(w_in_6_4, x_4));
        n_sum[6] = sat_add(n_sum[6], fx_mult_round(w_in_6_5, x_5));
        n_sum[6] = sat_add(n_sum[6], fx_mult_round(w_in_6_6, x_6));
        n_sum[6] = sat_add(n_sum[6], fx_mult_round(w_in_6_7, x_7));
        n_sum[6] = sat_add(n_sum[6], fx_mult_round(w_in_6_8, x_8));
        n_sum[6] = sat_add(n_sum[6], fx_mult_round(w_in_6_9, x_9));
        n_sum[6] = sat_add(n_sum[6], fx_mult_round(w_in_6_10, x_10));
        n_sum[6] = sat_add(n_sum[6], fx_mult_round(w_in_6_11, x_11));
        n_sum[6] = sat_add(n_sum[6], fx_mult_round(w_in_6_12, x_12));
        n_sum[6] = sat_add(n_sum[6], fx_mult_round(w_in_6_13, x_13));
        n_sum[6] = sat_add(n_sum[6], fx_mult_round(w_in_6_14, x_14));
        n_sum[6] = sat_add(n_sum[6], fx_mult_round(w_in_6_15, x_15));
        n_sum[6] = sat_add(n_sum[6], gated_h[6]);

        // wn_h[7] = W_hn*h + b_hn
        wn_h[7] = b_hn_7;
        wn_h[7] = sat_add(wn_h[7], fx_mult_round(w_hn_7_0, h_0));
        wn_h[7] = sat_add(wn_h[7], fx_mult_round(w_hn_7_1, h_1));
        wn_h[7] = sat_add(wn_h[7], fx_mult_round(w_hn_7_2, h_2));
        wn_h[7] = sat_add(wn_h[7], fx_mult_round(w_hn_7_3, h_3));
        wn_h[7] = sat_add(wn_h[7], fx_mult_round(w_hn_7_4, h_4));
        wn_h[7] = sat_add(wn_h[7], fx_mult_round(w_hn_7_5, h_5));
        wn_h[7] = sat_add(wn_h[7], fx_mult_round(w_hn_7_6, h_6));
        wn_h[7] = sat_add(wn_h[7], fx_mult_round(w_hn_7_7, h_7));

        // gated_h[7] = r_t ⊙ wn_h
        gated_h[7] = fx_mult_round(r_act[7], wn_h[7]);

        // n_sum[7] = W_in*x + b_in + gated_h
        n_sum[7] = b_in_7;
        n_sum[7] = sat_add(n_sum[7], fx_mult_round(w_in_7_0, x_0));
        n_sum[7] = sat_add(n_sum[7], fx_mult_round(w_in_7_1, x_1));
        n_sum[7] = sat_add(n_sum[7], fx_mult_round(w_in_7_2, x_2));
        n_sum[7] = sat_add(n_sum[7], fx_mult_round(w_in_7_3, x_3));
        n_sum[7] = sat_add(n_sum[7], fx_mult_round(w_in_7_4, x_4));
        n_sum[7] = sat_add(n_sum[7], fx_mult_round(w_in_7_5, x_5));
        n_sum[7] = sat_add(n_sum[7], fx_mult_round(w_in_7_6, x_6));
        n_sum[7] = sat_add(n_sum[7], fx_mult_round(w_in_7_7, x_7));
        n_sum[7] = sat_add(n_sum[7], fx_mult_round(w_in_7_8, x_8));
        n_sum[7] = sat_add(n_sum[7], fx_mult_round(w_in_7_9, x_9));
        n_sum[7] = sat_add(n_sum[7], fx_mult_round(w_in_7_10, x_10));
        n_sum[7] = sat_add(n_sum[7], fx_mult_round(w_in_7_11, x_11));
        n_sum[7] = sat_add(n_sum[7], fx_mult_round(w_in_7_12, x_12));
        n_sum[7] = sat_add(n_sum[7], fx_mult_round(w_in_7_13, x_13));
        n_sum[7] = sat_add(n_sum[7], fx_mult_round(w_in_7_14, x_14));
        n_sum[7] = sat_add(n_sum[7], fx_mult_round(w_in_7_15, x_15));
        n_sum[7] = sat_add(n_sum[7], gated_h[7]);

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
    tanh #(.INT_WIDTH(INT_WIDTH), .FRAC_WIDTH(FRAC_WIDTH)) tanh_n4 (
         .reset(reset), .x(n_sum[4]), .y(n_act[4])
    );
    tanh #(.INT_WIDTH(INT_WIDTH), .FRAC_WIDTH(FRAC_WIDTH)) tanh_n5 (
         .reset(reset), .x(n_sum[5]), .y(n_act[5])
    );
    tanh #(.INT_WIDTH(INT_WIDTH), .FRAC_WIDTH(FRAC_WIDTH)) tanh_n6 (
         .reset(reset), .x(n_sum[6]), .y(n_act[6])
    );
    tanh #(.INT_WIDTH(INT_WIDTH), .FRAC_WIDTH(FRAC_WIDTH)) tanh_n7 (
         .reset(reset), .x(n_sum[7]), .y(n_act[7])
    );

    // Final hidden state update
    // Hidden state update: h_t = (1 - z_t) ⊙ n_t + z_t ⊙ h_{t-1}
    logic signed [WIDTH-1:0] one_minus_z[8];
    logic signed [WIDTH-1:0] part1[8], part2[8];
    logic signed [WIDTH-1:0] h_new[8];

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
        one_minus_z[4] = sat_add(ONE, -z_act[4]);
        part1[4] = fx_mult_round(one_minus_z[4], n_act[4]);
        part2[4] = fx_mult_round(z_act[4], h_4);
        h_new[4] = sat_add(part1[4], part2[4]);
        one_minus_z[5] = sat_add(ONE, -z_act[5]);
        part1[5] = fx_mult_round(one_minus_z[5], n_act[5]);
        part2[5] = fx_mult_round(z_act[5], h_5);
        h_new[5] = sat_add(part1[5], part2[5]);
        one_minus_z[6] = sat_add(ONE, -z_act[6]);
        part1[6] = fx_mult_round(one_minus_z[6], n_act[6]);
        part2[6] = fx_mult_round(z_act[6], h_6);
        h_new[6] = sat_add(part1[6], part2[6]);
        one_minus_z[7] = sat_add(ONE, -z_act[7]);
        part1[7] = fx_mult_round(one_minus_z[7], n_act[7]);
        part2[7] = fx_mult_round(z_act[7], h_7);
        h_new[7] = sat_add(part1[7], part2[7]);
    end

    // Register outputs
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            y_0 <= '0;
            y_1 <= '0;
            y_2 <= '0;
            y_3 <= '0;
            y_4 <= '0;
            y_5 <= '0;
            y_6 <= '0;
            y_7 <= '0;
        end else begin
            y_0 <= h_new[0];
            y_1 <= h_new[1];
            y_2 <= h_new[2];
            y_3 <= h_new[3];
            y_4 <= h_new[4];
            y_5 <= h_new[5];
            y_6 <= h_new[6];
            y_7 <= h_new[7];
        end
    end

endmodule
