// ============================================================================
// New/Candidate Gate Element Module (n_t)
// Computes: n_t[n] = tanh(W_in[n,:] @ x_t + W_hn[n,:] @ (r_t[n] * h_t_prev) + b_in[n] + b_hn[n])
//
// Two mult instances:
//   mult_gate: computes r_t * h_t_prev[idx]  - presented in S_SEL_H,
//              result available in S_ACC_H (1-cycle registered output)
//   mult_main: computes W_hn[idx] * h_gated  - presented in S_ACC_H,
//              result available in S_ACC_H2 (new state, 1 extra cycle)
//
// To keep the FSM simple, the H-side uses three states:
//   S_SEL_H:  present gate operands (r_t, h_t_prev[idx]) to mult_gate
//   S_GATE_H: gate product ready; present (W_hn[idx], gate_product) to mult_main
//   S_ACC_H:  main product ready; accumulate
//
// Latency: 2*D + 3*H + 3 cycles from valid_in to valid_out.
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

    input  logic signed [DATA_WIDTH-1:0] x_t      [D-1:0],
    input  logic signed [DATA_WIDTH-1:0] h_t_prev [H-1:0],
    input  logic signed [DATA_WIDTH-1:0] r_t_n,
    input  logic signed [DATA_WIDTH-1:0] W_in_row [D-1:0],
    input  logic signed [DATA_WIDTH-1:0] W_hn_row [H-1:0],
    input  logic signed [DATA_WIDTH-1:0] b_in_n,
    input  logic signed [DATA_WIDTH-1:0] b_hn_n,

    output logic signed [DATA_WIDTH-1:0] n_t_n,
    output logic                          valid_out
);

    localparam int ACC_EXTRA_BITS = $clog2(D > H ? D : H) + 3;
    localparam int ACC_WIDTH      = DATA_WIDTH + ACC_EXTRA_BITS;

    localparam signed [DATA_WIDTH-1:0] MAX_VAL = {1'b0, {(DATA_WIDTH-1){1'b1}}};
    localparam signed [DATA_WIDTH-1:0] MIN_VAL = {1'b1, {(DATA_WIDTH-1){1'b0}}};

    typedef enum logic [2:0] {
        S_IDLE   = 3'd0,
        S_SEL_X  = 3'd1,
        S_ACC_X  = 3'd2,
        S_SEL_H  = 3'd3,   // present r_t * h_t_prev[idx] to mult_gate
        S_GATE_H = 3'd4,   // gate product ready; present W_hn * gate to mult_main
        S_ACC_H  = 3'd5,   // main product ready; accumulate
        S_DONE   = 3'd6
    } state_t;

    state_t                            state;
    logic [$clog2(D > H ? D : H)-1:0] idx;

    // Main multiply (W*x or W*h_gated)
    logic signed [DATA_WIDTH-1:0] main_a, main_b, main_product;
    mult #(.INT_WIDTH(INT_BITS), .FRAC_WIDTH(FRAC_BITS))
        mult_main (.clk(clk), .rst_n(rst_n), .a(main_a), .b(main_b), .y(main_product));

    // Gating multiply (r_t * h_t_prev[idx])
    logic signed [DATA_WIDTH-1:0] gate_a, gate_b, gate_product;
    mult #(.INT_WIDTH(INT_BITS), .FRAC_WIDTH(FRAC_BITS))
        mult_gate (.clk(clk), .rst_n(rst_n), .a(gate_a), .b(gate_b), .y(gate_product));

    logic signed [ACC_WIDTH-1:0] acc_x, acc_h;

    function automatic logic signed [DATA_WIDTH-1:0] saturate(
        input logic signed [ACC_WIDTH-1:0] val
    );
        if (val > $signed({{ACC_EXTRA_BITS{1'b0}}, MAX_VAL})) return MAX_VAL;
        else if (val < $signed({{ACC_EXTRA_BITS{1'b1}}, MIN_VAL})) return MIN_VAL;
        else return val[DATA_WIDTH-1:0];
    endfunction

    logic signed [DATA_WIDTH-1:0] pre_act, tanh_out;
    assign pre_act = saturate(acc_x) + saturate(acc_h);

    tanh #(.INT_WIDTH(INT_BITS), .FRAC_WIDTH(FRAC_BITS))
        tanh_inst (.clk(clk), .rst_n(rst_n), .reset(~rst_n), .x(pre_act), .y(tanh_out));

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state    <= S_IDLE;
            idx      <= '0;
            main_a   <= '0;
            main_b   <= '0;
            gate_a   <= '0;
            gate_b   <= '0;
            acc_x    <= '0;
            acc_h    <= '0;
            n_t_n    <= '0;
            valid_out <= 1'b0;
        end else begin
            valid_out <= 1'b0;

            case (state)

                S_IDLE: begin
                    if (valid_in) begin
                        acc_x <= {{ACC_EXTRA_BITS{b_in_n[DATA_WIDTH-1]}}, b_in_n};
                        idx   <= '0;
                        state <= S_SEL_X;
                    end
                end

                // Present W_in[idx] * x_t[idx] to main mult
                S_SEL_X: begin
                    main_a <= W_in_row[idx];
                    main_b <= x_t[idx];
                    state  <= S_ACC_X;
                end

                // main_product = W_in[idx] * x_t[idx]; accumulate
                S_ACC_X: begin
                    acc_x <= acc_x + {{ACC_EXTRA_BITS{main_product[DATA_WIDTH-1]}}, main_product};
                    if (idx == D - 1) begin
                        acc_h  <= {{ACC_EXTRA_BITS{b_hn_n[DATA_WIDTH-1]}}, b_hn_n};
                        // Kick off first gating multiply
                        gate_a <= r_t_n;
                        gate_b <= h_t_prev[0];
                        idx    <= '0;
                        state  <= S_GATE_H;  // skip S_SEL_H for first element
                    end else begin
                        idx   <= idx + 1;
                        state <= S_SEL_X;
                    end
                end

                // Present r_t * h_t_prev[idx] to gate mult
                S_SEL_H: begin
                    gate_a <= r_t_n;
                    gate_b <= h_t_prev[idx];
                    state  <= S_GATE_H;
                end

                // gate_product = r_t * h_t_prev[idx]; present to main mult
                S_GATE_H: begin
                    main_a <= W_hn_row[idx];
                    main_b <= gate_product;
                    state  <= S_ACC_H;
                end

                // main_product = W_hn[idx] * gate_product; accumulate
                S_ACC_H: begin
                    acc_h <= acc_h + {{ACC_EXTRA_BITS{main_product[DATA_WIDTH-1]}}, main_product};
                    if (idx == H - 1) begin
                        state <= S_DONE;
                    end else begin
                        idx   <= idx + 1;
                        state <= S_SEL_H;
                    end
                end

                S_DONE: begin
                    n_t_n     <= tanh_out;
                    valid_out <= 1'b1;
                    state     <= S_IDLE;
                end

            endcase
        end
    end

endmodule