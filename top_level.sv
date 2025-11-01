`timescale 1ns / 1ps

module top_level(
    input  logic clk,
    input  logic reset
    );

    // Parameters must match the generated GRU module parameters
    localparam int INT_WIDTH  = 8;
    localparam int FRAC_WIDTH = 8;
    localparam int WIDTH      = INT_WIDTH + FRAC_WIDTH + 1;

    // --- Declare every input the GRU expects as internal signals ---
    // Inputs: x_0_0 .. x_0_3, h_0_0 .. h_0_1, weights, biases...
    // Instead of listing dozens manually in comments, we declare them programmatically
    // style here - but for clarity we also show explicit ones used in the sample GRU.
    // (Make sure the names exactly match your generated module.)

    // Example primary inputs
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] x_0_0 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] x_0_1 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] x_0_2 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] x_0_3 = '0;

    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] y_0_0 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] y_0_1 = '0;

    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] h_0_0 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] h_0_1 = '0;

    // --- Weights (example naming from your module). Initialize to small constants
    // You must include every named signal your GRU definition requires.
    // I include the full set used in your module above.

    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_0_0 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_0_1 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_1_0 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_1_1 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_2_0 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_2_1 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_3_0 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_ir_3_1 = 16'sd1;

    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_0_0 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_0_1 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_1_0 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_1_1 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_2_0 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_2_1 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_3_0 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_iz_3_1 = 16'sd1;

    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_0_0 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_0_1 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_1_0 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_1_1 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_2_0 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_2_1 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_3_0 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_in_3_1 = 16'sd1;

    // Recurrent weights
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hr_0_0 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hr_0_1 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hr_1_0 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hr_1_1 = 16'sd1;

    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hz_0_0 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hz_0_1 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hz_1_0 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hz_1_1 = 16'sd1;

    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hn_0_0 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hn_0_1 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hn_1_0 = 16'sd1;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] w_hn_1_1 = 16'sd1;

    // Biases
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] b_ir_0_0 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] b_ir_0_1 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] b_iz_0_0 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] b_iz_0_1 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] b_in_0_0 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] b_in_0_1 = '0;

    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] b_hr_0_0 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] b_hr_0_1 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] b_hz_0_0 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] b_hz_0_1 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] b_hn_0_0 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] b_hn_0_1 = '0;

    // Final registers to capture and preserve the outputs (marked dont_touch)
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] preserved_y_0_0 = '0;
    (* keep = "true", dont_touch = "true" *) logic signed [WIDTH-1:0] preserved_y_0_1 = '0;

    // --- Instantiate the generated GRU module ---
    // Mark the instance so Vivado won't optimize it away.
    (* keep = "true", dont_touch = "true" *) gru #(
        .INT_WIDTH(INT_WIDTH),
        .FRAC_WIDTH(FRAC_WIDTH)
    ) gru_inst (
        .clk(clk),
        .reset(reset),
        .x_0_0(x_0_0),
        .x_0_1(x_0_1),
        .x_0_2(x_0_2),
        .x_0_3(x_0_3),
        .h_0_0(h_0_0),
        .h_0_1(h_0_1),

        .w_ir_0_0(w_ir_0_0), .w_ir_0_1(w_ir_0_1),
        .w_ir_1_0(w_ir_1_0), .w_ir_1_1(w_ir_1_1),
        .w_ir_2_0(w_ir_2_0), .w_ir_2_1(w_ir_2_1),
        .w_ir_3_0(w_ir_3_0), .w_ir_3_1(w_ir_3_1),

        .w_iz_0_0(w_iz_0_0), .w_iz_0_1(w_iz_0_1),
        .w_iz_1_0(w_iz_1_0), .w_iz_1_1(w_iz_1_1),
        .w_iz_2_0(w_iz_2_0), .w_iz_2_1(w_iz_2_1),
        .w_iz_3_0(w_iz_3_0), .w_iz_3_1(w_iz_3_1),

        .w_in_0_0(w_in_0_0), .w_in_0_1(w_in_0_1),
        .w_in_1_0(w_in_1_0), .w_in_1_1(w_in_1_1),
        .w_in_2_0(w_in_2_0), .w_in_2_1(w_in_2_1),
        .w_in_3_0(w_in_3_0), .w_in_3_1(w_in_3_1),

        .w_hr_0_0(w_hr_0_0), .w_hr_0_1(w_hr_0_1),
        .w_hr_1_0(w_hr_1_0), .w_hr_1_1(w_hr_1_1),

        .w_hz_0_0(w_hz_0_0), .w_hz_0_1(w_hz_0_1),
        .w_hz_1_0(w_hz_1_0), .w_hz_1_1(w_hz_1_1),

        .w_hn_0_0(w_hn_0_0), .w_hn_0_1(w_hn_0_1),
        .w_hn_1_0(w_hn_1_0), .w_hn_1_1(w_hn_1_1),

        .b_ir_0_0(b_ir_0_0), .b_ir_0_1(b_ir_0_1),
        .b_iz_0_0(b_iz_0_0), .b_iz_0_1(b_iz_0_1),
        .b_in_0_0(b_in_0_0), .b_in_0_1(b_in_0_1),

        .b_hr_0_0(b_hr_0_0), .b_hr_0_1(b_hr_0_1),
        .b_hz_0_0(b_hz_0_0), .b_hz_0_1(b_hz_0_1),
        .b_hn_0_0(b_hn_0_0), .b_hn_0_1(b_hn_0_1),

        .y_0_0(y_0_0),
        .y_0_1(y_0_1)
    );

    // Capture outputs into preserved registers so synthesis sees them used.
    always_ff @(posedge clk) begin
        if (reset) begin
            preserved_y_0_0 <= '0;
            preserved_y_0_1 <= '0;
        end else begin
            preserved_y_0_0 <= y_0_0;
            preserved_y_0_1 <= y_0_1;
        end
    end
endmodule
