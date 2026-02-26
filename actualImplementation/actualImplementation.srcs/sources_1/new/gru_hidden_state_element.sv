// ============================================================================
// Final Hidden State Element Module (h_t)
// Computes: h_t[n] = (1 - z_t[n]) * n_t[n] + z_t[n] * h_t_prev[n]
// ============================================================================
module gru_hidden_state_element #(
    parameter int INT_BITS = 16,
    parameter int FRAC_BITS = 8,
    parameter int DATA_WIDTH = INT_BITS + FRAC_BITS
) (
    input  logic                     clk,
    input  logic                     rst_n,
    input  logic                     valid_in,

    input  logic signed [DATA_WIDTH-1:0] z_t_n,      // Update gate value
    input  logic signed [DATA_WIDTH-1:0] n_t_n,      // New candidate value
    input  logic signed [DATA_WIDTH-1:0] h_t_prev_n, // Previous hidden state

    output logic signed [DATA_WIDTH-1:0] h_t_n,
    output logic                          valid_out
);

    // Fixed-point constant for 1.0
    localparam signed [DATA_WIDTH-1:0] ONE = (1 << FRAC_BITS);

    // Intermediate computations
    logic signed [DATA_WIDTH-1:0] one_minus_z;
    logic signed [DATA_WIDTH-1:0] term1;  // (1 - z_t) * n_t
    logic signed [DATA_WIDTH-1:0] term2;  // z_t * h_t_prev
    logic signed [DATA_WIDTH-1:0] h_new;

    // Compute (1 - z_t)
    assign one_minus_z = ONE - z_t_n;

    // Multiply (1 - z_t) * n_t
    mult #(
        .INT_WIDTH(INT_BITS),
        .FRAC_WIDTH(FRAC_BITS)
    ) mult_term1 (
        .a(one_minus_z),
        .b(n_t_n),
        .y(term1)
    );

    // Multiply z_t * h_t_prev
    mult #(
        .INT_WIDTH(INT_BITS),
        .FRAC_WIDTH(FRAC_BITS)
    ) mult_term2 (
        .a(z_t_n),
        .b(h_t_prev_n),
        .y(term2)
    );

    // Combine terms
    assign h_new = term1 + term2;

    // Register output
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            h_t_n <= '0;
            valid_out <= 1'b0;
        end else begin
            h_t_n <= h_new;
            valid_out <= valid_in;
        end
    end

endmodule