// ============================================================================
// New/Candidate Gate Element Module (n_t)
// Computes: n_t[n] = tanh(W_in[n,:] @ x_t + W_hn[n,:] @ (r_t[n] * h_t_prev) + b_in[n] + b_hn[n])
// ============================================================================
module gru_new_gate_element #(
    parameter int D = 128,
    parameter int H = 256,
    parameter int INT_BITS = 16,
    parameter int FRAC_BITS = 8,
    parameter int DATA_WIDTH = INT_BITS + FRAC_BITS
) (
    input  logic                     clk,
    input  logic                     rst_n,
    input  logic                     valid_in,

    input  logic signed [DATA_WIDTH-1:0] x_t [D-1:0],
    input  logic signed [DATA_WIDTH-1:0] h_t_prev [H-1:0],
    input  logic signed [DATA_WIDTH-1:0] r_t_n,      // Reset gate value for this element
    input  logic signed [DATA_WIDTH-1:0] W_in_row [D-1:0],
    input  logic signed [DATA_WIDTH-1:0] W_hn_row [H-1:0],
    input  logic signed [DATA_WIDTH-1:0] b_in_n,
    input  logic signed [DATA_WIDTH-1:0] b_hn_n,

    output logic signed [DATA_WIDTH-1:0] n_t_n,
    output logic                          valid_out
);

    // Calculate accumulator width with extra bits to prevent overflow
    localparam int ACC_EXTRA_BITS = $clog2(D > H ? D : H) + 3;  // +3 for safety margin
    localparam int ACC_WIDTH = DATA_WIDTH + ACC_EXTRA_BITS;

    // Wide accumulators for preventing overflow
    logic signed [ACC_WIDTH-1:0] acc_x;
    logic signed [ACC_WIDTH-1:0] acc_h;

    // Product arrays (standard width)
    logic signed [DATA_WIDTH-1:0] prod_x [D-1:0];
    logic signed [DATA_WIDTH-1:0] h_gated [H-1:0];
    logic signed [DATA_WIDTH-1:0] prod_h [H-1:0];

    // Truncated/saturated accumulator outputs
    logic signed [DATA_WIDTH-1:0] acc_x_sat;
    logic signed [DATA_WIDTH-1:0] acc_h_sat;

    // Pre-activation sum
    logic signed [DATA_WIDTH-1:0] pre_act;

    // Tanh output
    logic signed [DATA_WIDTH-1:0] tanh_out;

    // Saturation limits
    localparam signed [DATA_WIDTH-1:0] MAX_VAL = {1'b0, {(DATA_WIDTH-1){1'b1}}};  // Maximum positive value
    localparam signed [DATA_WIDTH-1:0] MIN_VAL = {1'b1, {(DATA_WIDTH-1){1'b0}}};  // Minimum negative value

    // Generate multipliers for input projection
    genvar i;
    generate
        for (i = 0; i < D; i++) begin : gen_mult_x
            mult #(
                .INT_WIDTH(INT_BITS),
                .FRAC_WIDTH(FRAC_BITS)
            ) mult_x_inst (
                .a(W_in_row[i]),
                .b(x_t[i]),
                .y(prod_x[i])
            );
        end
    endgenerate

    // Generate multipliers for gating operation (r_t * h_t_prev)
    generate
        for (i = 0; i < H; i++) begin : gen_gate
            mult #(
                .INT_WIDTH(INT_BITS),
                .FRAC_WIDTH(FRAC_BITS)
            ) mult_gate_inst (
                .a(r_t_n),
                .b(h_t_prev[i]),
                .y(h_gated[i])
            );
        end
    endgenerate

    // Generate multipliers for recurrent projection
    generate
        for (i = 0; i < H; i++) begin : gen_mult_h
            mult #(
                .INT_WIDTH(INT_BITS),
                .FRAC_WIDTH(FRAC_BITS)
            ) mult_h_inst (
                .a(W_hn_row[i]),
                .b(h_gated[i]),
                .y(prod_h[i])
            );
        end
    endgenerate

    // Accumulate input projection with wide accumulator
    always_comb begin
        acc_x = $signed({{ACC_EXTRA_BITS{b_in_n[DATA_WIDTH-1]}}, b_in_n});  // Sign-extend bias
        for (int j = 0; j < D; j++) begin
            acc_x = acc_x + $signed({{ACC_EXTRA_BITS{prod_x[j][DATA_WIDTH-1]}}, prod_x[j]});
        end
    end

    // Accumulate recurrent projection with wide accumulator
    always_comb begin
        acc_h = $signed({{ACC_EXTRA_BITS{b_hn_n[DATA_WIDTH-1]}}, b_hn_n});  // Sign-extend bias
        for (int j = 0; j < H; j++) begin
            acc_h = acc_h + $signed({{ACC_EXTRA_BITS{prod_h[j][DATA_WIDTH-1]}}, prod_h[j]});
        end
    end

    // Saturate acc_x to DATA_WIDTH
    always_comb begin
        if (acc_x > $signed({{ACC_EXTRA_BITS{1'b0}}, MAX_VAL})) begin
            acc_x_sat = MAX_VAL;  // Saturate to max positive
        end else if (acc_x < $signed({{ACC_EXTRA_BITS{1'b1}}, MIN_VAL})) begin
            acc_x_sat = MIN_VAL;  // Saturate to max negative
        end else begin
            acc_x_sat = acc_x[DATA_WIDTH-1:0];  // Truncate to DATA_WIDTH
        end
    end

    // Saturate acc_h to DATA_WIDTH
    always_comb begin
        if (acc_h > $signed({{ACC_EXTRA_BITS{1'b0}}, MAX_VAL})) begin
            acc_h_sat = MAX_VAL;  // Saturate to max positive
        end else if (acc_h < $signed({{ACC_EXTRA_BITS{1'b1}}, MIN_VAL})) begin
            acc_h_sat = MIN_VAL;  // Saturate to max negative
        end else begin
            acc_h_sat = acc_h[DATA_WIDTH-1:0];  // Truncate to DATA_WIDTH
        end
    end

    // Sum both projections
    assign pre_act = acc_x_sat + acc_h_sat;

    // Apply tanh activation
    tanh #(
        .INT_WIDTH(INT_BITS),
        .FRAC_WIDTH(FRAC_BITS)
    ) tanh_inst (
        .reset(~rst_n),
        .x(pre_act),
        .y(tanh_out)
    );

    // Register output
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            n_t_n <= '0;
            valid_out <= 1'b0;
        end else begin
            n_t_n <= tanh_out;
            valid_out <= valid_in;
        end
    end

endmodule