`timescale 1ns / 1ps

module gru_tb();

    // Parameters
    parameter CLK_PERIOD = 10; // 10ns for 100MHz clock
    parameter int INT_WIDTH  = 8;
    parameter int FRAC_WIDTH = 8;
    parameter int WIDTH      = INT_WIDTH + FRAC_WIDTH + 1;

    // Signals
    logic clk = 0;
    logic reset = 0;

	logic signed [WIDTH-1:0] x_0_0 = 'b0000_0000_0000_1101_0;
	logic signed [WIDTH-1:0] x_0_1 = 'b0000_0000_0001_1001_1;
	logic signed [WIDTH-1:0] x_0_2 = 'b0000_0000_0010_0110_1;
	logic signed [WIDTH-1:0] x_0_3 = 'b0000_0000_0011_0011_0;

	logic signed [WIDTH-1:0] h_0_0 = 'b0000_0000_0000_1101_0;
	logic signed [WIDTH-1:0] h_0_1 = 'b0000_0000_0001_1001_1;

	logic signed [WIDTH-1:0] w_ir_0_0 = 'b0000_0000_0000_1101_0;
	logic signed [WIDTH-1:0] w_ir_0_1 = 'b0000_0000_0001_1001_1;
	logic signed [WIDTH-1:0] w_ir_1_0 = 'b0000_0000_0010_0110_1;
	logic signed [WIDTH-1:0] w_ir_1_1 = 'b0000_0000_0011_0011_0;
	logic signed [WIDTH-1:0] w_ir_2_0 = 'b0000_0000_0100_0000_0;
	logic signed [WIDTH-1:0] w_ir_2_1 = 'b0000_0000_0100_1101_0;
	logic signed [WIDTH-1:0] w_ir_3_0 = 'b0000_0000_0100_0000_0;
	logic signed [WIDTH-1:0] w_ir_3_1 = 'b0000_0000_0100_1101_0;

	logic signed [WIDTH-1:0] w_in_0_0 = 'b0000_0000_0000_1101_0;
	logic signed [WIDTH-1:0] w_in_0_1 = 'b0000_0000_0001_1001_1;
	logic signed [WIDTH-1:0] w_in_1_0 = 'b0000_0000_0010_0110_1;
	logic signed [WIDTH-1:0] w_in_1_1 = 'b0000_0000_0011_0011_0;
	logic signed [WIDTH-1:0] w_in_2_0 = 'b0000_0000_0100_0000_0;
	logic signed [WIDTH-1:0] w_in_2_1 = 'b0000_0000_0100_1101_0;
	logic signed [WIDTH-1:0] w_in_3_0 = 'b0000_0000_0100_0000_0;
	logic signed [WIDTH-1:0] w_in_3_1 = 'b0000_0000_0100_1101_0;

	logic signed [WIDTH-1:0] w_iz_0_0 = 'b0000_0000_0000_1101_0;
	logic signed [WIDTH-1:0] w_iz_0_1 = 'b0000_0000_0001_1001_1;
	logic signed [WIDTH-1:0] w_iz_1_0 = 'b0000_0000_0010_0110_1;
	logic signed [WIDTH-1:0] w_iz_1_1 = 'b0000_0000_0011_0011_0;
	logic signed [WIDTH-1:0] w_iz_2_0 = 'b0000_0000_0100_0000_0;
	logic signed [WIDTH-1:0] w_iz_2_1 = 'b0000_0000_0100_1101_0;
	logic signed [WIDTH-1:0] w_iz_3_0 = 'b0000_0000_0100_0000_0;
	logic signed [WIDTH-1:0] w_iz_3_1 = 'b0000_0000_0100_1101_0;

	logic signed [WIDTH-1:0] w_hr_0_0 = 'b0000_0000_0000_1101_0;
	logic signed [WIDTH-1:0] w_hr_0_1 = 'b0000_0000_0001_1001_1;
	logic signed [WIDTH-1:0] w_hr_1_0 = 'b0000_0000_0010_0110_1;
	logic signed [WIDTH-1:0] w_hr_1_1 = 'b0000_0000_0011_0011_0;

	logic signed [WIDTH-1:0] w_hn_0_0 = 'b0000_0000_0000_1101_0;
	logic signed [WIDTH-1:0] w_hn_0_1 = 'b0000_0000_0001_1001_1;
	logic signed [WIDTH-1:0] w_hn_1_0 = 'b0000_0000_0010_0110_1;
	logic signed [WIDTH-1:0] w_hn_1_1 = 'b0000_0000_0011_0011_0;

	logic signed [WIDTH-1:0] w_hz_0_0 = 'b0000_0000_0000_1101_0;
	logic signed [WIDTH-1:0] w_hz_0_1 = 'b0000_0000_0001_1001_1;
	logic signed [WIDTH-1:0] w_hz_1_0 = 'b0000_0000_0010_0110_1;
	logic signed [WIDTH-1:0] w_hz_1_1 = 'b0000_0000_0011_0011_0;

	logic signed [WIDTH-1:0] b_ir_0_0 = 'b0000_0000_0000_1101_0;
	logic signed [WIDTH-1:0] b_ir_0_1 = 'b0000_0000_0001_1001_1;

	logic signed [WIDTH-1:0] b_in_0_0 = 'b0000_0000_0000_1101_0;
	logic signed [WIDTH-1:0] b_in_0_1 = 'b0000_0000_0001_1001_1;

	logic signed [WIDTH-1:0] b_iz_0_0 = 'b0000_0000_0000_1101_0;
	logic signed [WIDTH-1:0] b_iz_0_1 = 'b0000_0000_0001_1001_1;

	logic signed [WIDTH-1:0] b_hr_0_0 = 'b0000_0000_0000_1101_0;
	logic signed [WIDTH-1:0] b_hr_0_1 = 'b0000_0000_0001_1001_1;

	logic signed [WIDTH-1:0] b_hn_0_0 = 'b0000_0000_0000_1101_0;
	logic signed [WIDTH-1:0] b_hn_0_1 = 'b0000_0000_0001_1001_1;

	logic signed [WIDTH-1:0] b_hz_0_0 = 'b0000_0000_0000_1101_0;
	logic signed [WIDTH-1:0] b_hz_0_1 = 'b0000_0000_0001_1001_1;

	logic signed [WIDTH-1:0] y_0_0 = 'b0000_0000_0010_0000_1;
	logic signed [WIDTH-1:0] y_0_1 = 'b0000_0000_0010_1100_0;

    gru uut (
        .clk(clk),
        .reset(reset),
        .x_0_0(x_0_0),
        .x_0_1(x_0_1),
        .x_0_2(x_0_2),
        .x_0_3(x_0_3),
        .h_0_0(h_0_0),
        .h_0_1(h_0_1),
        .w_ir_0_0(w_ir_0_0),
        .w_ir_0_1(w_ir_0_1),
        .w_ir_1_0(w_ir_1_0),
        .w_ir_1_1(w_ir_1_1),
        .w_ir_2_0(w_ir_2_0),
        .w_ir_2_1(w_ir_2_1),
        .w_ir_3_0(w_ir_3_0),
        .w_ir_3_1(w_ir_3_1),
        .w_in_0_0(w_in_0_0),
        .w_in_0_1(w_in_0_1),
        .w_in_1_0(w_in_1_0),
        .w_in_1_1(w_in_1_1),
        .w_in_2_0(w_in_2_0),
        .w_in_2_1(w_in_2_1),
        .w_in_3_0(w_in_3_0),
        .w_in_3_1(w_in_3_1),
        .w_iz_0_0(w_iz_0_0),
        .w_iz_0_1(w_iz_0_1),
        .w_iz_1_0(w_iz_1_0),
        .w_iz_1_1(w_iz_1_1),
        .w_iz_2_0(w_iz_2_0),
        .w_iz_2_1(w_iz_2_1),
        .w_iz_3_0(w_iz_3_0),
        .w_iz_3_1(w_iz_3_1),
        .w_hr_0_0(w_hr_0_0),
        .w_hr_0_1(w_hr_0_1),
        .w_hr_1_0(w_hr_1_0),
        .w_hr_1_1(w_hr_1_1),
        .w_hn_0_0(w_hn_0_0),
        .w_hn_0_1(w_hn_0_1),
        .w_hn_1_0(w_hn_1_0),
        .w_hn_1_1(w_hn_1_1),
        .w_hz_0_0(w_hz_0_0),
        .w_hz_0_1(w_hz_0_1),
        .w_hz_1_0(w_hz_1_0),
        .w_hz_1_1(w_hz_1_1),
        .b_ir_0_0(b_ir_0_0),
        .b_ir_0_1(b_ir_0_1),
        .b_in_0_0(b_in_0_0),
        .b_in_0_1(b_in_0_1),
        .b_iz_0_0(b_iz_0_0),
        .b_iz_0_1(b_iz_0_1),
        .b_hr_0_0(b_hr_0_0),
        .b_hr_0_1(b_hr_0_1),
        .b_hn_0_0(b_hn_0_0),
        .b_hn_0_1(b_hn_0_1),
        .b_hz_0_0(b_hz_0_0),
        .b_hz_0_1(b_hz_0_1),
        .y_0_0(y_0_0),
        .y_0_1(y_0_1)
    );

    always #(CLK_PERIOD / 2) clk = ~clk;

    // Test stimulus
    initial begin
        reset = 0;
        #(10 * CLK_PERIOD);
        reset = 1;
        #(10 * CLK_PERIOD);
        reset = 0;
        #(100 * CLK_PERIOD);
        $stop;
    end
endmodule
