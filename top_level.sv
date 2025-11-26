
`timescale 1ns / 1ps
// d = 5 (input features)
// h = 3 (hidden units)
// auto-generated top-level wrapper for GRU
module top_level(
    input  logic clk,
    input  logic reset
);

    // Parameters must match the generated GRU module parameters
    localparam int INT_WIDTH  = 4;
    localparam int FRAC_WIDTH = 5;
    localparam int WIDTH      = INT_WIDTH + FRAC_WIDTH + 1;

    // --- Input signals (d=5) ---
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] x_0 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] x_1 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] x_2 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] x_3 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] x_4 = '0;

    // --- Previous hidden state (h=3) ---
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] h_0 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] h_1 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] h_2 = '0;

    // --- Output signals (h=3) ---
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] y_0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] y_1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] y_2;

    // --- Weights for input gates (h×d for each gate) ---
    // w_ir: reset gate input weights
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_0_0 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_0_1 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_0_2 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_0_3 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_0_4 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_1_0 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_1_1 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_1_2 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_1_3 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_1_4 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_2_0 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_2_1 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_2_2 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_2_3 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_2_4 = 16'sd1;

    // w_iz: update gate input weights
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_0_0 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_0_1 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_0_2 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_0_3 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_0_4 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_1_0 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_1_1 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_1_2 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_1_3 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_1_4 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_2_0 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_2_1 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_2_2 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_2_3 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_2_4 = 16'sd1;

    // w_in: new gate input weights
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_0_0 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_0_1 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_0_2 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_0_3 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_0_4 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_1_0 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_1_1 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_1_2 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_1_3 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_1_4 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_2_0 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_2_1 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_2_2 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_2_3 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_2_4 = 16'sd1;

    // --- Recurrent weights (h×h for each gate) ---
    // w_hr: reset gate recurrent weights
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hr_0_0 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hr_0_1 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hr_0_2 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hr_1_0 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hr_1_1 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hr_1_2 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hr_2_0 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hr_2_1 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hr_2_2 = 16'sd1;

    // w_hz: update gate recurrent weights
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hz_0_0 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hz_0_1 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hz_0_2 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hz_1_0 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hz_1_1 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hz_1_2 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hz_2_0 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hz_2_1 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hz_2_2 = 16'sd1;

    // w_hn: new gate recurrent weights
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hn_0_0 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hn_0_1 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hn_0_2 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hn_1_0 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hn_1_1 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hn_1_2 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hn_2_0 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hn_2_1 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hn_2_2 = 16'sd1;

    // --- Biases (h for each gate type) ---
    // Input-to-hidden biases
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] b_ir_0 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] b_ir_1 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] b_ir_2 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] b_iz_0 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] b_iz_1 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] b_iz_2 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] b_in_0 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] b_in_1 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] b_in_2 = '0;

    // Hidden-to-hidden biases
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] b_hr_0 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] b_hr_1 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] b_hr_2 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] b_hz_0 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] b_hz_1 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] b_hz_2 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] b_hn_0 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] b_hn_1 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] b_hn_2 = '0;

    // --- Final registers to capture and preserve the outputs ---
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] preserved_y_0 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] preserved_y_1 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] preserved_y_2 = '0;

    // --- Instantiate the generated GRU module ---
    (* keep = "true", dont_touch = "true" *) gru #(
        .INT_WIDTH(INT_WIDTH),
        .FRAC_WIDTH(FRAC_WIDTH)
    ) gru_inst (
        .clk(clk),
        .reset(reset),
        // Input features (d=5)

        .x_0(x_0),
        .x_1(x_1),
        .x_2(x_2),
        .x_3(x_3),
        .x_4(x_4),
        // Hidden states (h=3)

        .h_0(h_0),
        .h_1(h_1),
        .h_2(h_2),
        // Input weights for reset gate

        .w_ir_0_0(w_ir_0_0),
        .w_ir_0_1(w_ir_0_1),
        .w_ir_0_2(w_ir_0_2),
        .w_ir_0_3(w_ir_0_3),
        .w_ir_0_4(w_ir_0_4),
        .w_ir_1_0(w_ir_1_0),
        .w_ir_1_1(w_ir_1_1),
        .w_ir_1_2(w_ir_1_2),
        .w_ir_1_3(w_ir_1_3),
        .w_ir_1_4(w_ir_1_4),
        .w_ir_2_0(w_ir_2_0),
        .w_ir_2_1(w_ir_2_1),
        .w_ir_2_2(w_ir_2_2),
        .w_ir_2_3(w_ir_2_3),
        .w_ir_2_4(w_ir_2_4),
        // Input weights for update gate

        .w_iz_0_0(w_iz_0_0),
        .w_iz_0_1(w_iz_0_1),
        .w_iz_0_2(w_iz_0_2),
        .w_iz_0_3(w_iz_0_3),
        .w_iz_0_4(w_iz_0_4),
        .w_iz_1_0(w_iz_1_0),
        .w_iz_1_1(w_iz_1_1),
        .w_iz_1_2(w_iz_1_2),
        .w_iz_1_3(w_iz_1_3),
        .w_iz_1_4(w_iz_1_4),
        .w_iz_2_0(w_iz_2_0),
        .w_iz_2_1(w_iz_2_1),
        .w_iz_2_2(w_iz_2_2),
        .w_iz_2_3(w_iz_2_3),
        .w_iz_2_4(w_iz_2_4),
        // Input weights for new gate

        .w_in_0_0(w_in_0_0),
        .w_in_0_1(w_in_0_1),
        .w_in_0_2(w_in_0_2),
        .w_in_0_3(w_in_0_3),
        .w_in_0_4(w_in_0_4),
        .w_in_1_0(w_in_1_0),
        .w_in_1_1(w_in_1_1),
        .w_in_1_2(w_in_1_2),
        .w_in_1_3(w_in_1_3),
        .w_in_1_4(w_in_1_4),
        .w_in_2_0(w_in_2_0),
        .w_in_2_1(w_in_2_1),
        .w_in_2_2(w_in_2_2),
        .w_in_2_3(w_in_2_3),
        .w_in_2_4(w_in_2_4),
        // Recurrent weights for reset gate

        .w_hr_0_0(w_hr_0_0),
        .w_hr_0_1(w_hr_0_1),
        .w_hr_0_2(w_hr_0_2),
        .w_hr_1_0(w_hr_1_0),
        .w_hr_1_1(w_hr_1_1),
        .w_hr_1_2(w_hr_1_2),
        .w_hr_2_0(w_hr_2_0),
        .w_hr_2_1(w_hr_2_1),
        .w_hr_2_2(w_hr_2_2),
        // Recurrent weights for update gate

        .w_hz_0_0(w_hz_0_0),
        .w_hz_0_1(w_hz_0_1),
        .w_hz_0_2(w_hz_0_2),
        .w_hz_1_0(w_hz_1_0),
        .w_hz_1_1(w_hz_1_1),
        .w_hz_1_2(w_hz_1_2),
        .w_hz_2_0(w_hz_2_0),
        .w_hz_2_1(w_hz_2_1),
        .w_hz_2_2(w_hz_2_2),
        // Recurrent weights for new gate

        .w_hn_0_0(w_hn_0_0),
        .w_hn_0_1(w_hn_0_1),
        .w_hn_0_2(w_hn_0_2),
        .w_hn_1_0(w_hn_1_0),
        .w_hn_1_1(w_hn_1_1),
        .w_hn_1_2(w_hn_1_2),
        .w_hn_2_0(w_hn_2_0),
        .w_hn_2_1(w_hn_2_1),
        .w_hn_2_2(w_hn_2_2),
        // Biases

        .b_ir_0(b_ir_0),
        .b_ir_1(b_ir_1),
        .b_ir_2(b_ir_2),
        .b_iz_0(b_iz_0),
        .b_iz_1(b_iz_1),
        .b_iz_2(b_iz_2),
        .b_in_0(b_in_0),
        .b_in_1(b_in_1),
        .b_in_2(b_in_2),
        .b_hr_0(b_hr_0),
        .b_hr_1(b_hr_1),
        .b_hr_2(b_hr_2),
        .b_hz_0(b_hz_0),
        .b_hz_1(b_hz_1),
        .b_hz_2(b_hz_2),
        .b_hn_0(b_hn_0),
        .b_hn_1(b_hn_1),
        .b_hn_2(b_hn_2),
        // Outputs (h=3)

        .y_0(y_0),
        .y_1(y_1),
        .y_2(y_2)
    );

    // --- Capture outputs into preserved registers ---
    always_ff @(posedge clk) begin
        if (reset) begin
            preserved_y_0 <= '0;
            preserved_y_1 <= '0;
            preserved_y_2 <= '0;
        end else begin
            preserved_y_0 <= y_0;
            preserved_y_1 <= y_1;
            preserved_y_2 <= y_2;
        end
    end

endmodule
