`timescale 1ns / 1ps

// Fixed-Point Multiplier Module - 1-cycle registered output
// 
// Adding a pipeline register on the output breaks the mult→add critical
// path that was causing -3ns WNS. All callers already register their
// operand inputs (op_a_r / op_b_r) before driving this module, so the
// full pipeline is now:
//
//   [operand regs] → mult combinational → [product reg] → adder → [acc reg]
//
// Each stage is now a simple fast path. Total added latency: 1 cycle.
// Update FSM callers: product is valid the cycle AFTER op_a/op_b are
// presented, not the same cycle.

module mult #(
    parameter INT_WIDTH  = 8,
    parameter FRAC_WIDTH = 8
)(
    input  logic                                    clk,
    input  logic                                    rst_n,
    input  logic signed [INT_WIDTH+FRAC_WIDTH-1:0]  a,
    input  logic signed [INT_WIDTH+FRAC_WIDTH-1:0]  b,
    output logic signed [INT_WIDTH+FRAC_WIDTH-1:0]  y
);
    localparam TOTAL_WIDTH = INT_WIDTH + FRAC_WIDTH;
    localparam PROD_WIDTH  = 2 * TOTAL_WIDTH;

    logic signed [PROD_WIDTH-1:0] full_product;
    assign full_product = a * b;

    // Register the output to break the combinational mult→add path
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            y <= '0;
        else
            y <= full_product[FRAC_WIDTH +: TOTAL_WIDTH];
    end

endmodule