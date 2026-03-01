// ============================================================================
// Final Hidden State Element Module (h_t)
// Computes: h_t[n] = (1 - z_t[n]) * n_t[n] + z_t[n] * h_t_prev[n]
//
// Previously: one_minus_z was combinational (ONE - z_t_n) and fed directly
// into the DSP48 A-input in the same cycle as z_t_n arrived. The path
// index_reg → mux → subtract → DSP48.A setup was timing-critical.
//
// Fix: register all mult inputs (one_minus_z, n_t_n, z_t_n, h_t_prev_n)
// one cycle before presenting them to the multipliers. This gives the
// subtract and any upstream mux logic a full cycle before the DSP setup.
//
// Pipeline:
//   cycle 0 (valid_in):  register inputs
//   cycle 1:             present registered inputs to mults, mults compute
//   cycle 2:             term1/term2 register outputs valid, add and register
//   valid_out fires on cycle 2 (2 cycles after valid_in)
// ============================================================================
module gru_hidden_state_element #(
    parameter int INT_BITS   = 16,
    parameter int FRAC_BITS  = 8,
    parameter int DATA_WIDTH = INT_BITS + FRAC_BITS
) (
    input  logic                         clk,
    input  logic                         rst_n,
    input  logic                         valid_in,

    input  logic signed [DATA_WIDTH-1:0] z_t_n,
    input  logic signed [DATA_WIDTH-1:0] n_t_n,
    input  logic signed [DATA_WIDTH-1:0] h_t_prev_n,

    output logic signed [DATA_WIDTH-1:0] h_t_n,
    output logic                          valid_out
);

    localparam signed [DATA_WIDTH-1:0] ONE = (1 << FRAC_BITS);

    // -------------------------------------------------------------------------
    // Stage 0→1: register all inputs and compute one_minus_z
    // This gives subtract + mux logic a full cycle before DSP setup
    // -------------------------------------------------------------------------
    logic signed [DATA_WIDTH-1:0] z_r, n_r, h_prev_r, one_minus_z_r;
    logic valid_d1;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            z_r           <= '0;
            n_r           <= '0;
            h_prev_r      <= '0;
            one_minus_z_r <= '0;
            valid_d1      <= 1'b0;
        end else begin
            z_r           <= z_t_n;
            n_r           <= n_t_n;
            h_prev_r      <= h_t_prev_n;
            one_minus_z_r <= ONE - z_t_n;  // subtract has full cycle to settle
            valid_d1      <= valid_in;
        end
    end

    // -------------------------------------------------------------------------
    // Stage 1→2: multiply (registered inputs → DSP48 → registered outputs)
    // -------------------------------------------------------------------------
    logic signed [DATA_WIDTH-1:0] term1, term2;

    mult #(.INT_WIDTH(INT_BITS), .FRAC_WIDTH(FRAC_BITS))
        mult_term1 (.clk(clk), .rst_n(rst_n),
                    .a(one_minus_z_r), .b(n_r), .y(term1));

    mult #(.INT_WIDTH(INT_BITS), .FRAC_WIDTH(FRAC_BITS))
        mult_term2 (.clk(clk), .rst_n(rst_n),
                    .a(z_r), .b(h_prev_r), .y(term2));

    // -------------------------------------------------------------------------
    // Stage 2→3: add registered products and register output
    // -------------------------------------------------------------------------
    logic valid_d2;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            valid_d2  <= 1'b0;
            h_t_n     <= '0;
            valid_out <= 1'b0;
        end else begin
            valid_d2  <= valid_d1;
            h_t_n     <= term1 + term2;
            valid_out <= valid_d2;
        end
    end

endmodule