
`timescale 1ns / 1ps
// d = 4 (input features)
// h = 4 (hidden units)
// auto-generated top-level wrapper for GRU
module top_level(
    input  logic clk,
    input  logic reset
);

    // Parameters must match the generated GRU module parameters
    localparam int INT_WIDTH  = 4;
    localparam int FRAC_WIDTH = 10;
    localparam int WIDTH      = INT_WIDTH + FRAC_WIDTH + 1;

    // --- Input signals (d=4) ---
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] x_0 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] x_1 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] x_2 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] x_3 = '0;

    // --- Previous hidden state (h=4) ---
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] h_0 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] h_1 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] h_2 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] h_3 = '0;

    // --- Output signals (h=4) ---
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] y_0 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] y_1 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] y_2 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] y_3 = '0;

    // --- Weights for input gates (h×d for each gate) ---
    // w_ir: reset gate input weights
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_0_0 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_0_1 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_0_2 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_0_3 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_1_0 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_1_1 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_1_2 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_1_3 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_2_0 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_2_1 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_2_2 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_2_3 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_3_0 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_3_1 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_3_2 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_3_3 = 16'sd1;

    // w_iz: update gate input weights
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_0_0 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_0_1 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_0_2 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_0_3 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_1_0 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_1_1 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_1_2 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_1_3 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_2_0 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_2_1 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_2_2 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_2_3 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_3_0 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_3_1 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_3_2 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_3_3 = 16'sd1;

    // w_in: new gate input weights
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_0_0 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_0_1 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_0_2 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_0_3 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_1_0 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_1_1 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_1_2 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_1_3 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_2_0 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_2_1 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_2_2 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_2_3 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_3_0 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_3_1 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_3_2 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_3_3 = 16'sd1;

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
        // Input features (d=4)

        .x_0(x_0),
        .x_1(x_1),
        .x_2(x_2),
        .x_3(x_3),
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
        .w_ir_1_0(w_ir_1_0),
        .w_ir_1_1(w_ir_1_1),
        .w_ir_1_2(w_ir_1_2),
        .w_ir_1_3(w_ir_1_3),
        .w_ir_2_0(w_ir_2_0),
        .w_ir_2_1(w_ir_2_1),
        .w_ir_2_2(w_ir_2_2),
        .w_ir_2_3(w_ir_2_3),
        .w_ir_3_0(w_ir_3_0),
        .w_ir_3_1(w_ir_3_1),
        .w_ir_3_2(w_ir_3_2),
        .w_ir_3_3(w_ir_3_3),
        // Input weights for update gate

        .w_iz_0_0(w_iz_0_0),
        .w_iz_0_1(w_iz_0_1),
        .w_iz_0_2(w_iz_0_2),
        .w_iz_0_3(w_iz_0_3),
        .w_iz_1_0(w_iz_1_0),
        .w_iz_1_1(w_iz_1_1),
        .w_iz_1_2(w_iz_1_2),
        .w_iz_1_3(w_iz_1_3),
        .w_iz_2_0(w_iz_2_0),
        .w_iz_2_1(w_iz_2_1),
        .w_iz_2_2(w_iz_2_2),
        .w_iz_2_3(w_iz_2_3),
        .w_iz_3_0(w_iz_3_0),
        .w_iz_3_1(w_iz_3_1),
        .w_iz_3_2(w_iz_3_2),
        .w_iz_3_3(w_iz_3_3),
        // Input weights for new gate

        .w_in_0_0(w_in_0_0),
        .w_in_0_1(w_in_0_1),
        .w_in_0_2(w_in_0_2),
        .w_in_0_3(w_in_0_3),
        .w_in_1_0(w_in_1_0),
        .w_in_1_1(w_in_1_1),
        .w_in_1_2(w_in_1_2),
        .w_in_1_3(w_in_1_3),
        .w_in_2_0(w_in_2_0),
        .w_in_2_1(w_in_2_1),
        .w_in_2_2(w_in_2_2),
        .w_in_2_3(w_in_2_3),
        .w_in_3_0(w_in_3_0),
        .w_in_3_1(w_in_3_1),
        .w_in_3_2(w_in_3_2),
        .w_in_3_3(w_in_3_3),
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
