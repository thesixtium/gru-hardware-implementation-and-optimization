// ============================================================================
// Final Hidden State Element Module (h_t)
// Computes: h_t[n] = (1 - z_t[n]) * n_t[n] + z_t[n] * h_t_prev[n]
//
// mult now has clk/rst_n ports and a registered output.
// term1 and term2 are therefore registered - h_new is a simple add of two
// registers, which is fast. The final output register adds one more stage.
//
// Total latency from valid_in to valid_out: 2 cycles.
// ============================================================================
module gru_hidden_state_element #(
    parameter int INT_BITS = 16,
    parameter int FRAC_BITS = 8,
    parameter int DATA_WIDTH = INT_BITS + FRAC_BITS
) (
    input  logic                     clk,
    input  logic                     rst_n,
    input  logic                     valid_in,

    input  logic signed [DATA_WIDTH-1:0] z_t_n,
    input  logic signed [DATA_WIDTH-1:0] n_t_n,
    input  logic signed [DATA_WIDTH-1:0] h_t_prev_n,

    output logic signed [DATA_WIDTH-1:0] h_t_n,
    output logic                          valid_out
);

    localparam signed [DATA_WIDTH-1:0] ONE = (1 << FRAC_BITS);

    logic signed [DATA_WIDTH-1:0] one_minus_z;
    assign one_minus_z = ONE - z_t_n;

    // Both mults now registered - term1 and term2 are pipeline outputs
    logic signed [DATA_WIDTH-1:0] term1, term2;

    mult #(.INT_WIDTH(INT_BITS), .FRAC_WIDTH(FRAC_BITS))
        mult_term1 (.clk(clk), .rst_n(rst_n), .a(one_minus_z), .b(n_t_n),      .y(term1));

    mult #(.INT_WIDTH(INT_BITS), .FRAC_WIDTH(FRAC_BITS))
        mult_term2 (.clk(clk), .rst_n(rst_n), .a(z_t_n),       .b(h_t_prev_n), .y(term2));

    // term1 + term2 is a simple add of two registered values - fast path
    // Delay valid_in by 1 cycle to match mult pipeline depth,
    // then register output
    logic valid_d1;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            valid_d1  <= 1'b0;
            h_t_n     <= '0;
            valid_out <= 1'b0;
        end else begin
            valid_d1  <= valid_in;
            h_t_n     <= term1 + term2;
            valid_out <= valid_d1;
        end
    end

endmodule