`timescale 1ns / 1ps
// d = 4
// h = 2
// auto-generated GRU module
module gru #(
    parameter int INT_WIDTH  = 8,
    parameter int FRAC_WIDTH = 8,
    parameter int WIDTH      = INT_WIDTH + FRAC_WIDTH + 1
)(
    input  logic                     clk,
    input  logic                     reset,
    input  logic signed [WIDTH-1:0]  x_0_0,
    input  logic signed [WIDTH-1:0]  x_0_1,
    input  logic signed [WIDTH-1:0]  x_0_2,
    input  logic signed [WIDTH-1:0]  x_0_3,
    input  logic signed [WIDTH-1:0]  h_0_0,
    input  logic signed [WIDTH-1:0]  h_0_1,
    // --- Weights for input gates ---
    input  logic signed [WIDTH-1:0]  w_ir_0_0,
    input  logic signed [WIDTH-1:0]  w_ir_0_1,
    input  logic signed [WIDTH-1:0]  w_ir_1_0,
    input  logic signed [WIDTH-1:0]  w_ir_1_1,
    input  logic signed [WIDTH-1:0]  w_ir_2_0,
    input  logic signed [WIDTH-1:0]  w_ir_2_1,
    input  logic signed [WIDTH-1:0]  w_ir_3_0,
    input  logic signed [WIDTH-1:0]  w_ir_3_1,
    input  logic signed [WIDTH-1:0]  w_iz_0_0,
    input  logic signed [WIDTH-1:0]  w_iz_0_1,
    input  logic signed [WIDTH-1:0]  w_iz_1_0,
    input  logic signed [WIDTH-1:0]  w_iz_1_1,
    input  logic signed [WIDTH-1:0]  w_iz_2_0,
    input  logic signed [WIDTH-1:0]  w_iz_2_1,
    input  logic signed [WIDTH-1:0]  w_iz_3_0,
    input  logic signed [WIDTH-1:0]  w_iz_3_1,
    input  logic signed [WIDTH-1:0]  w_in_0_0,
    input  logic signed [WIDTH-1:0]  w_in_0_1,
    input  logic signed [WIDTH-1:0]  w_in_1_0,
    input  logic signed [WIDTH-1:0]  w_in_1_1,
    input  logic signed [WIDTH-1:0]  w_in_2_0,
    input  logic signed [WIDTH-1:0]  w_in_2_1,
    input  logic signed [WIDTH-1:0]  w_in_3_0,
    input  logic signed [WIDTH-1:0]  w_in_3_1,
    // --- Recurrent weights ---
    input  logic signed [WIDTH-1:0]  w_hr_0_0,
    input  logic signed [WIDTH-1:0]  w_hr_0_1,
    input  logic signed [WIDTH-1:0]  w_hr_1_0,
    input  logic signed [WIDTH-1:0]  w_hr_1_1,
    input  logic signed [WIDTH-1:0]  w_hz_0_0,
    input  logic signed [WIDTH-1:0]  w_hz_0_1,
    input  logic signed [WIDTH-1:0]  w_hz_1_0,
    input  logic signed [WIDTH-1:0]  w_hz_1_1,
    input  logic signed [WIDTH-1:0]  w_hn_0_0,
    input  logic signed [WIDTH-1:0]  w_hn_0_1,
    input  logic signed [WIDTH-1:0]  w_hn_1_0,
    input  logic signed [WIDTH-1:0]  w_hn_1_1,
    // --- Biases ---
    input  logic signed [WIDTH-1:0]  b_ir_0_0,
    input  logic signed [WIDTH-1:0]  b_ir_0_1,
    input  logic signed [WIDTH-1:0]  b_iz_0_0,
    input  logic signed [WIDTH-1:0]  b_iz_0_1,
    input  logic signed [WIDTH-1:0]  b_in_0_0,
    input  logic signed [WIDTH-1:0]  b_in_0_1,
    input  logic signed [WIDTH-1:0]  b_hr_0_0,
    input  logic signed [WIDTH-1:0]  b_hr_0_1,
    input  logic signed [WIDTH-1:0]  b_hz_0_0,
    input  logic signed [WIDTH-1:0]  b_hz_0_1,
    input  logic signed [WIDTH-1:0]  b_hn_0_0,
    input  logic signed [WIDTH-1:0]  b_hn_0_1,
    // --- Outputs ---
    output logic signed [WIDTH-1:0]  y_0_0,    output logic signed [WIDTH-1:0]  y_0_1
);

    // ---- Fixed-point multiply helper ----
    function automatic logic signed [WIDTH-1:0] fixed_mul(
        input logic signed [WIDTH-1:0] a,
        input logic signed [WIDTH-1:0] b
    );
        logic signed [2*WIDTH-1:0] tmp;
        begin
            tmp = a * b;
            fixed_mul = tmp >>> FRAC_WIDTH;
        end
    endfunction

    // =========================================================
    // r = σ(W_w_ir*x + b_b_ir + W_w_hr*h_prev + b_b_ir)
    // =========================================================

    logic signed [WIDTH-1:0] r_0[1:0];
    logic signed [WIDTH-1:0] r_in_0[1:0];

    assign r_in_0[0] =
        fixed_mul(w_ir_0_0, x_0_0) + fixed_mul(w_ir_1_0, x_0_1) + fixed_mul(w_ir_2_0, x_0_2) + fixed_mul(w_ir_3_0, x_0_3) + fixed_mul(w_hr_0_0, h_0_0) + fixed_mul(w_hr_1_0, h_0_1) + b_ir_0_0;

    // instantiate sigmoid for r[0]
    sigmoid r_sig0(.clk(clk), .reset(reset), .x(r_in_0[0]), .y(r_0[0]));

    assign r_in_0[1] =
        fixed_mul(w_ir_0_1, x_0_0) + fixed_mul(w_ir_1_1, x_0_1) + fixed_mul(w_ir_2_1, x_0_2) + fixed_mul(w_ir_3_1, x_0_3) + fixed_mul(w_hr_0_1, h_0_0) + fixed_mul(w_hr_1_1, h_0_1) + b_ir_0_1;

    // instantiate sigmoid for r[1]
    sigmoid r_sig1(.clk(clk), .reset(reset), .x(r_in_0[1]), .y(r_0[1]));

    // =========================================================
    // z = σ(W_w_iz*x + b_b_iz + W_w_hz*h_prev + b_b_iz)
    // =========================================================

    logic signed [WIDTH-1:0] z_0[1:0];
    logic signed [WIDTH-1:0] z_in_0[1:0];

    assign z_in_0[0] =
        fixed_mul(w_iz_0_0, x_0_0) + fixed_mul(w_iz_1_0, x_0_1) + fixed_mul(w_iz_2_0, x_0_2) + fixed_mul(w_iz_3_0, x_0_3) + fixed_mul(w_hz_0_0, h_0_0) + fixed_mul(w_hz_1_0, h_0_1) + b_iz_0_0;

    // instantiate sigmoid for z[0]
    sigmoid z_sig0(.clk(clk), .reset(reset), .x(z_in_0[0]), .y(z_0[0]));

    assign z_in_0[1] =
        fixed_mul(w_iz_0_1, x_0_0) + fixed_mul(w_iz_1_1, x_0_1) + fixed_mul(w_iz_2_1, x_0_2) + fixed_mul(w_iz_3_1, x_0_3) + fixed_mul(w_hz_0_1, h_0_0) + fixed_mul(w_hz_1_1, h_0_1) + b_iz_0_1;

    // instantiate sigmoid for z[1]
    sigmoid z_sig1(.clk(clk), .reset(reset), .x(z_in_0[1]), .y(z_0[1]));

    // =========================================================
    // Candidate n_t = tanh(W_in*x + b_in + r_t ⊙ (W_hn*h_prev + b_hn))
    // =========================================================

    logic signed [WIDTH-1:0] n_0[1:0];
    logic signed [WIDTH-1:0] win_x[1:0];
    logic signed [WIDTH-1:0] whn_h[1:0];
    logic signed [WIDTH-1:0] r_whn[1:0];
    logic signed [WIDTH-1:0] n_in_0[1:0];

    assign win_x[0] = fixed_mul(w_in_0_0, x_0_0) + fixed_mul(w_in_1_0, x_0_1) + fixed_mul(w_in_2_0, x_0_2) + fixed_mul(w_in_3_0, x_0_3) + b_in_0_0;
    assign win_x[1] = fixed_mul(w_in_0_1, x_0_0) + fixed_mul(w_in_1_1, x_0_1) + fixed_mul(w_in_2_1, x_0_2) + fixed_mul(w_in_3_1, x_0_3) + b_in_0_1;

    assign whn_h[0] = fixed_mul(w_hn_0_0, h_0_0) + fixed_mul(w_hn_1_0, h_0_1) + b_hn_0_0;
    assign whn_h[1] = fixed_mul(w_hn_0_1, h_0_0) + fixed_mul(w_hn_1_1, h_0_1) + b_hn_0_1;

    assign r_whn[0] = fixed_mul(r_0[0], whn_h[0]);
    assign r_whn[1] = fixed_mul(r_0[1], whn_h[1]);

    assign n_in_0[0] = win_x[0] + r_whn[0];
    tanh n_tanh0(.clk(clk), .reset(reset), .x(n_in_0[0]), .y(n_0[0]));

    assign n_in_0[1] = win_x[1] + r_whn[1];
    tanh n_tanh1(.clk(clk), .reset(reset), .x(n_in_0[1]), .y(n_0[1]));

    // =========================================================
    // Final hidden state h_t = (1 - z_t)⊙n_t + z_t⊙h_prev
    // =========================================================

    localparam logic signed [WIDTH-1:0] ONE_CONST = (1 <<< FRAC_WIDTH);

    logic signed [WIDTH-1:0] one_minus_z[1:0];
    logic signed [WIDTH-1:0] part0[1:0];
    logic signed [WIDTH-1:0] part1[1:0];
    logic signed [WIDTH-1:0] hnext[1:0];

    assign one_minus_z[0] = ONE_CONST - z_0[0];
    assign one_minus_z[1] = ONE_CONST - z_0[1];

    assign part0[0] = fixed_mul(one_minus_z[0], n_0[0]);
    assign part1[0] = fixed_mul(z_0[0], h_0_0);
    assign hnext[0] = part0[0] + part1[0];

    assign part0[1] = fixed_mul(one_minus_z[1], n_0[1]);
    assign part1[1] = fixed_mul(z_0[1], h_0_1);
    assign hnext[1] = part0[1] + part1[1];

    // --- Registered outputs ---
    always_ff @(posedge clk) begin
        if (reset) begin
            y_0_0 <= '0;
            y_0_1 <= '0;
        end else begin
            y_0_0 <= hnext[0];
            y_0_1 <= hnext[1];
        end
    end

endmodule
