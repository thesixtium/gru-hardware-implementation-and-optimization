
`timescale 1ns / 1ps
// GRU Cell Implementation (Fixed-Point Qm.f)
// d = 5 (input features), h = 3 (hidden units)
// WIDTH = INT_WIDTH + FRAC_WIDTH

module gru #(
    parameter int INT_WIDTH  = 4,
    parameter int FRAC_WIDTH = 5,
    parameter int WIDTH      = INT_WIDTH + FRAC_WIDTH
)(
    input  logic                     clk,
    input  logic                     reset,

    // Inputs (d=5)
        input  logic signed [WIDTH-1:0]  x_0,
    input  logic signed [WIDTH-1:0]  x_1,
    input  logic signed [WIDTH-1:0]  x_2,
    input  logic signed [WIDTH-1:0]  x_3,
    input  logic signed [WIDTH-1:0]  x_4,

    // Previous hidden state (h=3)
        input  logic signed [WIDTH-1:0]  h_0,
    input  logic signed [WIDTH-1:0]  h_1,
    input  logic signed [WIDTH-1:0]  h_2,

    // Input weights (h×d for each gate)
    input  logic signed [WIDTH-1:0]  w_ir_0_0, w_ir_0_1, w_ir_0_2, w_ir_0_3, w_ir_0_4, w_ir_1_0, w_ir_1_1, w_ir_1_2, w_ir_1_3, w_ir_1_4, w_ir_2_0, w_ir_2_1, w_ir_2_2, w_ir_2_3, w_ir_2_4,
    input  logic signed [WIDTH-1:0]  w_iz_0_0, w_iz_0_1, w_iz_0_2, w_iz_0_3, w_iz_0_4, w_iz_1_0, w_iz_1_1, w_iz_1_2, w_iz_1_3, w_iz_1_4, w_iz_2_0, w_iz_2_1, w_iz_2_2, w_iz_2_3, w_iz_2_4,
    input  logic signed [WIDTH-1:0]  w_in_0_0, w_in_0_1, w_in_0_2, w_in_0_3, w_in_0_4, w_in_1_0, w_in_1_1, w_in_1_2, w_in_1_3, w_in_1_4, w_in_2_0, w_in_2_1, w_in_2_2, w_in_2_3, w_in_2_4,

    // Recurrent weights (h×h for each gate)
    input  logic signed [WIDTH-1:0]  w_hr_0_0, w_hr_0_1, w_hr_0_2, w_hr_1_0, w_hr_1_1, w_hr_1_2, w_hr_2_0, w_hr_2_1, w_hr_2_2,
    input  logic signed [WIDTH-1:0]  w_hz_0_0, w_hz_0_1, w_hz_0_2, w_hz_1_0, w_hz_1_1, w_hz_1_2, w_hz_2_0, w_hz_2_1, w_hz_2_2,
    input  logic signed [WIDTH-1:0]  w_hn_0_0, w_hn_0_1, w_hn_0_2, w_hn_1_0, w_hn_1_1, w_hn_1_2, w_hn_2_0, w_hn_2_1, w_hn_2_2,

    // Biases (h for each gate type)
    input  logic signed [WIDTH-1:0]  b_ir_0, b_ir_1, b_ir_2, b_iz_0, b_iz_1, b_iz_2, b_in_0, b_in_1, b_in_2, b_hr_0, b_hr_1, b_hr_2, b_hz_0, b_hz_1, b_hz_2, b_hn_0, b_hn_1, b_hn_2,

    // Outputs (h=3)
        output logic signed [WIDTH-1:0]  y_0,
    output logic signed [WIDTH-1:0]  y_1,
    output logic signed [WIDTH-1:0]  y_2
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
    logic signed [WIDTH-1:0] r_sum[3];
    logic signed [WIDTH-1:0] r_act[3];

    always_comb begin
        // r_sum[0]
        r_sum[0] = b_ir_0;
        r_sum[0] = sat_add(r_sum[0], fx_mult_round(w_ir_0_0, x_0));
        r_sum[0] = sat_add(r_sum[0], fx_mult_round(w_ir_0_1, x_1));
        r_sum[0] = sat_add(r_sum[0], fx_mult_round(w_ir_0_2, x_2));
        r_sum[0] = sat_add(r_sum[0], fx_mult_round(w_ir_0_3, x_3));
        r_sum[0] = sat_add(r_sum[0], fx_mult_round(w_ir_0_4, x_4));
        r_sum[0] = sat_add(r_sum[0], b_hr_0);
        r_sum[0] = sat_add(r_sum[0], fx_mult_round(w_hr_0_0, h_0));
        r_sum[0] = sat_add(r_sum[0], fx_mult_round(w_hr_0_1, h_1));
        r_sum[0] = sat_add(r_sum[0], fx_mult_round(w_hr_0_2, h_2));

        // r_sum[1]
        r_sum[1] = b_ir_1;
        r_sum[1] = sat_add(r_sum[1], fx_mult_round(w_ir_1_0, x_0));
        r_sum[1] = sat_add(r_sum[1], fx_mult_round(w_ir_1_1, x_1));
        r_sum[1] = sat_add(r_sum[1], fx_mult_round(w_ir_1_2, x_2));
        r_sum[1] = sat_add(r_sum[1], fx_mult_round(w_ir_1_3, x_3));
        r_sum[1] = sat_add(r_sum[1], fx_mult_round(w_ir_1_4, x_4));
        r_sum[1] = sat_add(r_sum[1], b_hr_1);
        r_sum[1] = sat_add(r_sum[1], fx_mult_round(w_hr_1_0, h_0));
        r_sum[1] = sat_add(r_sum[1], fx_mult_round(w_hr_1_1, h_1));
        r_sum[1] = sat_add(r_sum[1], fx_mult_round(w_hr_1_2, h_2));

        // r_sum[2]
        r_sum[2] = b_ir_2;
        r_sum[2] = sat_add(r_sum[2], fx_mult_round(w_ir_2_0, x_0));
        r_sum[2] = sat_add(r_sum[2], fx_mult_round(w_ir_2_1, x_1));
        r_sum[2] = sat_add(r_sum[2], fx_mult_round(w_ir_2_2, x_2));
        r_sum[2] = sat_add(r_sum[2], fx_mult_round(w_ir_2_3, x_3));
        r_sum[2] = sat_add(r_sum[2], fx_mult_round(w_ir_2_4, x_4));
        r_sum[2] = sat_add(r_sum[2], b_hr_2);
        r_sum[2] = sat_add(r_sum[2], fx_mult_round(w_hr_2_0, h_0));
        r_sum[2] = sat_add(r_sum[2], fx_mult_round(w_hr_2_1, h_1));
        r_sum[2] = sat_add(r_sum[2], fx_mult_round(w_hr_2_2, h_2));

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

    // Update gate: z_t = σ(W_iz*x + b_iz + W_hz*h + b_hz)
    // z gate computation
    logic signed [WIDTH-1:0] z_sum[3];
    logic signed [WIDTH-1:0] z_act[3];

    always_comb begin
        // z_sum[0]
        z_sum[0] = b_iz_0;
        z_sum[0] = sat_add(z_sum[0], fx_mult_round(w_iz_0_0, x_0));
        z_sum[0] = sat_add(z_sum[0], fx_mult_round(w_iz_0_1, x_1));
        z_sum[0] = sat_add(z_sum[0], fx_mult_round(w_iz_0_2, x_2));
        z_sum[0] = sat_add(z_sum[0], fx_mult_round(w_iz_0_3, x_3));
        z_sum[0] = sat_add(z_sum[0], fx_mult_round(w_iz_0_4, x_4));
        z_sum[0] = sat_add(z_sum[0], b_hz_0);
        z_sum[0] = sat_add(z_sum[0], fx_mult_round(w_hz_0_0, h_0));
        z_sum[0] = sat_add(z_sum[0], fx_mult_round(w_hz_0_1, h_1));
        z_sum[0] = sat_add(z_sum[0], fx_mult_round(w_hz_0_2, h_2));

        // z_sum[1]
        z_sum[1] = b_iz_1;
        z_sum[1] = sat_add(z_sum[1], fx_mult_round(w_iz_1_0, x_0));
        z_sum[1] = sat_add(z_sum[1], fx_mult_round(w_iz_1_1, x_1));
        z_sum[1] = sat_add(z_sum[1], fx_mult_round(w_iz_1_2, x_2));
        z_sum[1] = sat_add(z_sum[1], fx_mult_round(w_iz_1_3, x_3));
        z_sum[1] = sat_add(z_sum[1], fx_mult_round(w_iz_1_4, x_4));
        z_sum[1] = sat_add(z_sum[1], b_hz_1);
        z_sum[1] = sat_add(z_sum[1], fx_mult_round(w_hz_1_0, h_0));
        z_sum[1] = sat_add(z_sum[1], fx_mult_round(w_hz_1_1, h_1));
        z_sum[1] = sat_add(z_sum[1], fx_mult_round(w_hz_1_2, h_2));

        // z_sum[2]
        z_sum[2] = b_iz_2;
        z_sum[2] = sat_add(z_sum[2], fx_mult_round(w_iz_2_0, x_0));
        z_sum[2] = sat_add(z_sum[2], fx_mult_round(w_iz_2_1, x_1));
        z_sum[2] = sat_add(z_sum[2], fx_mult_round(w_iz_2_2, x_2));
        z_sum[2] = sat_add(z_sum[2], fx_mult_round(w_iz_2_3, x_3));
        z_sum[2] = sat_add(z_sum[2], fx_mult_round(w_iz_2_4, x_4));
        z_sum[2] = sat_add(z_sum[2], b_hz_2);
        z_sum[2] = sat_add(z_sum[2], fx_mult_round(w_hz_2_0, h_0));
        z_sum[2] = sat_add(z_sum[2], fx_mult_round(w_hz_2_1, h_1));
        z_sum[2] = sat_add(z_sum[2], fx_mult_round(w_hz_2_2, h_2));

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

    // Candidate hidden state: n_t = tanh(W_in*x + b_in + r_t ⊙ (W_hn*h + b_hn))
    // Candidate hidden state computation
    logic signed [WIDTH-1:0] wn_h[3];
    logic signed [WIDTH-1:0] gated_h[3];
    logic signed [WIDTH-1:0] n_sum[3];
    logic signed [WIDTH-1:0] n_act[3];

    always_comb begin
        // wn_h[0] = W_hn*h + b_hn
        wn_h[0] = b_hn_0;
        wn_h[0] = sat_add(wn_h[0], fx_mult_round(w_hn_0_0, h_0));
        wn_h[0] = sat_add(wn_h[0], fx_mult_round(w_hn_0_1, h_1));
        wn_h[0] = sat_add(wn_h[0], fx_mult_round(w_hn_0_2, h_2));

        // gated_h[0] = r_t ⊙ wn_h
        gated_h[0] = fx_mult_round(r_act[0], wn_h[0]);

        // n_sum[0] = W_in*x + b_in + gated_h
        n_sum[0] = b_in_0;
        n_sum[0] = sat_add(n_sum[0], fx_mult_round(w_in_0_0, x_0));
        n_sum[0] = sat_add(n_sum[0], fx_mult_round(w_in_0_1, x_1));
        n_sum[0] = sat_add(n_sum[0], fx_mult_round(w_in_0_2, x_2));
        n_sum[0] = sat_add(n_sum[0], fx_mult_round(w_in_0_3, x_3));
        n_sum[0] = sat_add(n_sum[0], fx_mult_round(w_in_0_4, x_4));
        n_sum[0] = sat_add(n_sum[0], gated_h[0]);

        // wn_h[1] = W_hn*h + b_hn
        wn_h[1] = b_hn_1;
        wn_h[1] = sat_add(wn_h[1], fx_mult_round(w_hn_1_0, h_0));
        wn_h[1] = sat_add(wn_h[1], fx_mult_round(w_hn_1_1, h_1));
        wn_h[1] = sat_add(wn_h[1], fx_mult_round(w_hn_1_2, h_2));

        // gated_h[1] = r_t ⊙ wn_h
        gated_h[1] = fx_mult_round(r_act[1], wn_h[1]);

        // n_sum[1] = W_in*x + b_in + gated_h
        n_sum[1] = b_in_1;
        n_sum[1] = sat_add(n_sum[1], fx_mult_round(w_in_1_0, x_0));
        n_sum[1] = sat_add(n_sum[1], fx_mult_round(w_in_1_1, x_1));
        n_sum[1] = sat_add(n_sum[1], fx_mult_round(w_in_1_2, x_2));
        n_sum[1] = sat_add(n_sum[1], fx_mult_round(w_in_1_3, x_3));
        n_sum[1] = sat_add(n_sum[1], fx_mult_round(w_in_1_4, x_4));
        n_sum[1] = sat_add(n_sum[1], gated_h[1]);

        // wn_h[2] = W_hn*h + b_hn
        wn_h[2] = b_hn_2;
        wn_h[2] = sat_add(wn_h[2], fx_mult_round(w_hn_2_0, h_0));
        wn_h[2] = sat_add(wn_h[2], fx_mult_round(w_hn_2_1, h_1));
        wn_h[2] = sat_add(wn_h[2], fx_mult_round(w_hn_2_2, h_2));

        // gated_h[2] = r_t ⊙ wn_h
        gated_h[2] = fx_mult_round(r_act[2], wn_h[2]);

        // n_sum[2] = W_in*x + b_in + gated_h
        n_sum[2] = b_in_2;
        n_sum[2] = sat_add(n_sum[2], fx_mult_round(w_in_2_0, x_0));
        n_sum[2] = sat_add(n_sum[2], fx_mult_round(w_in_2_1, x_1));
        n_sum[2] = sat_add(n_sum[2], fx_mult_round(w_in_2_2, x_2));
        n_sum[2] = sat_add(n_sum[2], fx_mult_round(w_in_2_3, x_3));
        n_sum[2] = sat_add(n_sum[2], fx_mult_round(w_in_2_4, x_4));
        n_sum[2] = sat_add(n_sum[2], gated_h[2]);

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

    // Final hidden state update
    // Hidden state update: h_t = (1 - z_t) ⊙ n_t + z_t ⊙ h_{t-1}
    logic signed [WIDTH-1:0] one_minus_z[3];
    logic signed [WIDTH-1:0] part1[3], part2[3];
    logic signed [WIDTH-1:0] h_new[3];

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
    end

    // Register outputs
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            y_0 <= '0;
            y_1 <= '0;
            y_2 <= '0;
        end else begin
            y_0 <= h_new[0];
            y_1 <= h_new[1];
            y_2 <= h_new[2];
        end
    end

endmodule
