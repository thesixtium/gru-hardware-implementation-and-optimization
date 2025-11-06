def generate_gru_sv( INT_WIDTH=8, FRAC_WIDTH=8 ):
    return f"""
        `timescale 1ns / 1ps
        // GRU Cell Implementation (Fixed-Point Qm.f) - CORRECTED
        // WIDTH = INT_WIDTH + FRAC_WIDTH + 1 (sign)
        
        module gru #(
            parameter int INT_WIDTH  = {INT_WIDTH},
            parameter int FRAC_WIDTH = {FRAC_WIDTH},
            parameter int WIDTH      = INT_WIDTH + FRAC_WIDTH + 1
        )(
        """ + """
            input  logic                     clk,
            input  logic                     reset,
        
            // Inputs
            input  logic signed [WIDTH-1:0]  x_0_0,
            input  logic signed [WIDTH-1:0]  x_0_1,
            input  logic signed [WIDTH-1:0]  h_0_0,
            input  logic signed [WIDTH-1:0]  h_0_1,
        
            // Weights (input)
            input  logic signed [WIDTH-1:0]  w_ir_0_0, w_ir_0_1, w_ir_1_0, w_ir_1_1,
            input  logic signed [WIDTH-1:0]  w_iz_0_0, w_iz_0_1, w_iz_1_0, w_iz_1_1,
            input  logic signed [WIDTH-1:0]  w_in_0_0, w_in_0_1, w_in_1_0, w_in_1_1,
        
            // Weights (recurrent)
            input  logic signed [WIDTH-1:0]  w_hr_0_0, w_hr_0_1, w_hr_1_0, w_hr_1_1,
            input  logic signed [WIDTH-1:0]  w_hz_0_0, w_hz_0_1, w_hz_1_0, w_hz_1_1,
            input  logic signed [WIDTH-1:0]  w_hn_0_0, w_hn_0_1, w_hn_1_0, w_hn_1_1,
        
            // Biases (matching testbench naming)
            input  logic signed [WIDTH-1:0]  b_ir_0_0, b_ir_0_1,
            input  logic signed [WIDTH-1:0]  b_iz_0_0, b_iz_0_1,
            input  logic signed [WIDTH-1:0]  b_in_0_0, b_in_0_1,
            input  logic signed [WIDTH-1:0]  b_hr_0_0, b_hr_0_1,
            input  logic signed [WIDTH-1:0]  b_hz_0_0, b_hz_0_1,
            input  logic signed [WIDTH-1:0]  b_hn_0_0, b_hn_0_1,
        
            // Outputs
            output logic signed [WIDTH-1:0]  y_0_0,
            output logic signed [WIDTH-1:0]  y_0_1
        );
        
            // ---------- Helpers ----------
            // Saturating addition
            function automatic logic signed [WIDTH-1:0] sat_add(
                input logic signed [WIDTH-1:0] a,
                input logic signed [WIDTH-1:0] b
            );
                logic signed [WIDTH:0] sum_ext;
                sum_ext = {a[WIDTH-1], a} + {b[WIDTH-1], b};
                
                // Check for overflow
                if (sum_ext[WIDTH] != sum_ext[WIDTH-1]) begin
                    // Overflow occurred
                    sat_add = sum_ext[WIDTH] ? {1'b1, {(WIDTH-1){1'b0}}} : {1'b0, {(WIDTH-1){1'b1}}};
                end else begin
                    sat_add = sum_ext[WIDTH-1:0];
                end
            endfunction
        
            // Rounded fixed-point multiply with saturation
            function automatic logic signed [WIDTH-1:0] fx_mult_round(
                input logic signed [WIDTH-1:0] a,
                input logic signed [WIDTH-1:0] b
            );
                logic signed [(2*WIDTH)-1:0] product;
                logic signed [WIDTH:0] rounded;
                
                product = a * b;
                rounded = (product[(2*WIDTH)-1:FRAC_WIDTH] + product[FRAC_WIDTH-1]);
                
                // Saturation check
                if (rounded[WIDTH] != rounded[WIDTH-1]) begin
                    fx_mult_round = rounded[WIDTH] ? {1'b1, {(WIDTH-1){1'b0}}} : {1'b0, {(WIDTH-1){1'b1}}};
                end else begin
                    fx_mult_round = rounded[WIDTH-1:0];
                end
            endfunction
        
            localparam logic signed [WIDTH-1:0] ONE = (1 <<< FRAC_WIDTH); // fixed-point 1.0
        
            // =========================
            // r_t = sigmoid(W_ir*x + b_ir + W_hr*h + b_hr)
            // =========================
            logic signed [WIDTH-1:0] r_sum0, r_sum1;
            logic signed [WIDTH-1:0] r_act0, r_act1;
            logic signed [WIDTH-1:0] r_temp0_a, r_temp0_b, r_temp1_a, r_temp1_b;
        
            always_comb begin
                // Compute r_sum0 with saturation
                r_temp0_a = sat_add(fx_mult_round(w_ir_0_0, x_0_0), fx_mult_round(w_ir_0_1, x_0_1));
                r_temp0_a = sat_add(r_temp0_a, b_ir_0_0);
                r_temp0_b = sat_add(fx_mult_round(w_hr_0_0, h_0_0), fx_mult_round(w_hr_0_1, h_0_1));
                r_temp0_b = sat_add(r_temp0_b, b_hr_0_0);
                r_sum0 = sat_add(r_temp0_a, r_temp0_b);
        
                // Compute r_sum1 with saturation
                r_temp1_a = sat_add(fx_mult_round(w_ir_1_0, x_0_0), fx_mult_round(w_ir_1_1, x_0_1));
                r_temp1_a = sat_add(r_temp1_a, b_ir_0_1);
                r_temp1_b = sat_add(fx_mult_round(w_hr_1_0, h_0_0), fx_mult_round(w_hr_1_1, h_0_1));
                r_temp1_b = sat_add(r_temp1_b, b_hr_0_1);
                r_sum1 = sat_add(r_temp1_a, r_temp1_b);
            end
        
            sigmoid #( .INT_WIDTH(INT_WIDTH), .FRAC_WIDTH(FRAC_WIDTH) ) sig_r0 (
                .clk(clk), .reset(reset), .x(r_sum0), .y(r_act0)
            );
            sigmoid #( .INT_WIDTH(INT_WIDTH), .FRAC_WIDTH(FRAC_WIDTH) ) sig_r1 (
                .clk(clk), .reset(reset), .x(r_sum1), .y(r_act1)
            );
        
            // =========================
            // z_t = sigmoid(W_iz*x + b_iz + W_hz*h + b_hz)
            // =========================
            logic signed [WIDTH-1:0] z_sum0, z_sum1;
            logic signed [WIDTH-1:0] z_act0, z_act1;
            logic signed [WIDTH-1:0] z_temp0_a, z_temp0_b, z_temp1_a, z_temp1_b;
        
            always_comb begin
                // Compute z_sum0 with saturation
                z_temp0_a = sat_add(fx_mult_round(w_iz_0_0, x_0_0), fx_mult_round(w_iz_0_1, x_0_1));
                z_temp0_a = sat_add(z_temp0_a, b_iz_0_0);
                z_temp0_b = sat_add(fx_mult_round(w_hz_0_0, h_0_0), fx_mult_round(w_hz_0_1, h_0_1));
                z_temp0_b = sat_add(z_temp0_b, b_hz_0_0);
                z_sum0 = sat_add(z_temp0_a, z_temp0_b);
        
                // Compute z_sum1 with saturation
                z_temp1_a = sat_add(fx_mult_round(w_iz_1_0, x_0_0), fx_mult_round(w_iz_1_1, x_0_1));
                z_temp1_a = sat_add(z_temp1_a, b_iz_0_1);
                z_temp1_b = sat_add(fx_mult_round(w_hz_1_0, h_0_0), fx_mult_round(w_hz_1_1, h_0_1));
                z_temp1_b = sat_add(z_temp1_b, b_hz_0_1);
                z_sum1 = sat_add(z_temp1_a, z_temp1_b);
            end
        
            sigmoid #( .INT_WIDTH(INT_WIDTH), .FRAC_WIDTH(FRAC_WIDTH) ) sig_z0 (
                .clk(clk), .reset(reset), .x(z_sum0), .y(z_act0)
            );
            sigmoid #( .INT_WIDTH(INT_WIDTH), .FRAC_WIDTH(FRAC_WIDTH) ) sig_z1 (
                .clk(clk), .reset(reset), .x(z_sum1), .y(z_act1)
            );
        
            // =========================
            // n_t = tanh(W_in*x + b_in + r_t ⊙ (W_hn*h + b_hn))
            // =========================
            logic signed [WIDTH-1:0] wn_h0, wn_h1;
            logic signed [WIDTH-1:0] gated_h0, gated_h1;
            logic signed [WIDTH-1:0] n_sum0, n_sum1;
            logic signed [WIDTH-1:0] n_act0, n_act1;
            logic signed [WIDTH-1:0] n_temp0, n_temp1;
        
            always_comb begin
                // Compute W_hn*h + b_hn
                wn_h0 = sat_add(fx_mult_round(w_hn_0_0, h_0_0), fx_mult_round(w_hn_0_1, h_0_1));
                wn_h0 = sat_add(wn_h0, b_hn_0_0);
                
                wn_h1 = sat_add(fx_mult_round(w_hn_1_0, h_0_0), fx_mult_round(w_hn_1_1, h_0_1));
                wn_h1 = sat_add(wn_h1, b_hn_0_1);
        
                // Gate with r_t
                gated_h0 = fx_mult_round(r_act0, wn_h0);
                gated_h1 = fx_mult_round(r_act1, wn_h1);
        
                // Compute W_in*x + b_in + gated_h
                n_temp0 = sat_add(fx_mult_round(w_in_0_0, x_0_0), fx_mult_round(w_in_0_1, x_0_1));
                n_temp0 = sat_add(n_temp0, b_in_0_0);
                n_sum0 = sat_add(n_temp0, gated_h0);
                
                n_temp1 = sat_add(fx_mult_round(w_in_1_0, x_0_0), fx_mult_round(w_in_1_1, x_0_1));
                n_temp1 = sat_add(n_temp1, b_in_0_1);
                n_sum1 = sat_add(n_temp1, gated_h1);
            end
        
            tanh #( .INT_WIDTH(INT_WIDTH), .FRAC_WIDTH(FRAC_WIDTH) ) tanh0 (
                .clk(clk), .reset(reset), .x(n_sum0), .y(n_act0)
            );
            tanh #( .INT_WIDTH(INT_WIDTH), .FRAC_WIDTH(FRAC_WIDTH) ) tanh1 (
                .clk(clk), .reset(reset), .x(n_sum1), .y(n_act1)
            );
        
            // =========================
            // h_t = (1 - z_t) ⊙ n_t + z_t ⊙ h_{t-1}
            // =========================
            logic signed [WIDTH-1:0] one_minus_z0, one_minus_z1;
            logic signed [WIDTH-1:0] part1_0, part1_1, part2_0, part2_1;
            logic signed [WIDTH-1:0] h_new0, h_new1;
        
            always_comb begin
                one_minus_z0 = sat_add(ONE, -z_act0);
                one_minus_z1 = sat_add(ONE, -z_act1);
        
                part1_0 = fx_mult_round(one_minus_z0, n_act0);
                part1_1 = fx_mult_round(one_minus_z1, n_act1);
                part2_0 = fx_mult_round(z_act0, h_0_0);
                part2_1 = fx_mult_round(z_act1, h_0_1);
        
                h_new0 = sat_add(part1_0, part2_0);
                h_new1 = sat_add(part1_1, part2_1);
            end
        
            // Register outputs for stable timing
            always_ff @(posedge clk or posedge reset) begin
                if (reset) begin
                    y_0_0 <= '0;
                    y_0_1 <= '0;
                end else begin
                    y_0_0 <= h_new0;
                    y_0_1 <= h_new1;
                end
            end
        
        endmodule
        """
