// ============================================================================
// Complete GRU Cell - Parallel Implementation
// Time-multiplexed computation with configurable parallelism
// ============================================================================
module gru_cell_parallel #(
    parameter int D = 64,
    parameter int H = 16,
    parameter int INT_BITS = 10,
    parameter int FRAC_BITS = 1,
    parameter int DATA_WIDTH = INT_BITS + FRAC_BITS,
    parameter int NUM_PARALLEL = 1
) (
    input  logic                     clk,
    input  logic                     rst_n,
    input  logic                     start,

    input  logic signed [DATA_WIDTH-1:0] x_t [D-1:0],
    input  logic signed [DATA_WIDTH-1:0] h_t_prev [H-1:0],

    // Weight matrices
    input  logic signed [DATA_WIDTH-1:0] W_ir [H-1:0][D-1:0],
    input  logic signed [DATA_WIDTH-1:0] W_hr [H-1:0][H-1:0],
    input  logic signed [DATA_WIDTH-1:0] b_ir [H-1:0],
    input  logic signed [DATA_WIDTH-1:0] b_hr [H-1:0],

    input  logic signed [DATA_WIDTH-1:0] W_iz [H-1:0][D-1:0],
    input  logic signed [DATA_WIDTH-1:0] W_hz [H-1:0][H-1:0],
    input  logic signed [DATA_WIDTH-1:0] b_iz [H-1:0],
    input  logic signed [DATA_WIDTH-1:0] b_hz [H-1:0],

    input  logic signed [DATA_WIDTH-1:0] W_in [H-1:0][D-1:0],
    input  logic signed [DATA_WIDTH-1:0] W_hn [H-1:0][H-1:0],
    input  logic signed [DATA_WIDTH-1:0] b_in [H-1:0],
    input  logic signed [DATA_WIDTH-1:0] b_hn [H-1:0],

    output logic signed [DATA_WIDTH-1:0] h_t [H-1:0],
    output logic                          done
);

    // FSM states
    typedef enum logic [3:0] {
        IDLE           = 4'd0,
        COMPUTE_RESET  = 4'd1,
        WAIT_RESET     = 4'd2,
        COMPUTE_UPDATE = 4'd3,
        WAIT_UPDATE    = 4'd4,
        COMPUTE_NEW    = 4'd5,
        WAIT_NEW       = 4'd6,
        COMPUTE_HIDDEN = 4'd7,
        WAIT_HIDDEN    = 4'd8,
        DONE_STATE     = 4'd9
    } state_t;

    state_t state, next_state;

    // Index counter for time multiplexing
    logic [$clog2(H+1)-1:0] index;
    logic [$clog2(H+1)-1:0] total_iters;

    // Wait counter for pipeline delays
    logic [2:0] wait_count;

    // Valid signals for element modules
    logic valid_reset, valid_update, valid_new, valid_hidden;

    // Storage for intermediate gate values
    logic signed [DATA_WIDTH-1:0] r_t_storage [H-1:0];
    logic signed [DATA_WIDTH-1:0] z_t_storage [H-1:0];
    logic signed [DATA_WIDTH-1:0] n_t_storage [H-1:0];
    logic signed [DATA_WIDTH-1:0] h_t_storage [H-1:0];

    // Element module outputs
    logic signed [DATA_WIDTH-1:0] r_t_elem [NUM_PARALLEL-1:0];
    logic signed [DATA_WIDTH-1:0] z_t_elem [NUM_PARALLEL-1:0];
    logic signed [DATA_WIDTH-1:0] n_t_elem [NUM_PARALLEL-1:0];
    logic signed [DATA_WIDTH-1:0] h_t_elem [NUM_PARALLEL-1:0];

    logic valid_out_r [NUM_PARALLEL-1:0];
    logic valid_out_z [NUM_PARALLEL-1:0];
    logic valid_out_n [NUM_PARALLEL-1:0];
    logic valid_out_h [NUM_PARALLEL-1:0];

    // Calculate total iterations needed
    assign total_iters = (H + NUM_PARALLEL - 1) / NUM_PARALLEL;

    // ========================================================================
    // Instantiate parallel element modules
    // ========================================================================

    genvar p;
    generate
        for (p = 0; p < NUM_PARALLEL; p++) begin : gen_parallel_elements

            // Reset gate element
            gru_reset_gate_element #(
                .D(D),
                .H(H),
                .INT_BITS(INT_BITS),
                .FRAC_BITS(FRAC_BITS),
                .DATA_WIDTH(DATA_WIDTH)
            ) reset_elem (
                .clk(clk),
                .rst_n(rst_n),
                .valid_in(valid_reset && ((index * NUM_PARALLEL + p) < H)),
                .x_t(x_t),
                .h_t_prev(h_t_prev),
                .W_ir_row((index * NUM_PARALLEL + p < H) ? W_ir[index * NUM_PARALLEL + p] : W_ir[0]),
                .W_hr_row((index * NUM_PARALLEL + p < H) ? W_hr[index * NUM_PARALLEL + p] : W_hr[0]),
                .b_ir_n((index * NUM_PARALLEL + p < H) ? b_ir[index * NUM_PARALLEL + p] : b_ir[0]),
                .b_hr_n((index * NUM_PARALLEL + p < H) ? b_hr[index * NUM_PARALLEL + p] : b_hr[0]),
                .r_t_n(r_t_elem[p]),
                .valid_out(valid_out_r[p])
            );

            // Update gate element
            gru_update_gate_element #(
                .D(D),
                .H(H),
                .INT_BITS(INT_BITS),
                .FRAC_BITS(FRAC_BITS),
                .DATA_WIDTH(DATA_WIDTH)
            ) update_elem (
                .clk(clk),
                .rst_n(rst_n),
                .valid_in(valid_update && ((index * NUM_PARALLEL + p) < H)),
                .x_t(x_t),
                .h_t_prev(h_t_prev),
                .W_iz_row((index * NUM_PARALLEL + p < H) ? W_iz[index * NUM_PARALLEL + p] : W_iz[0]),
                .W_hz_row((index * NUM_PARALLEL + p < H) ? W_hz[index * NUM_PARALLEL + p] : W_hz[0]),
                .b_iz_n((index * NUM_PARALLEL + p < H) ? b_iz[index * NUM_PARALLEL + p] : b_iz[0]),
                .b_hz_n((index * NUM_PARALLEL + p < H) ? b_hz[index * NUM_PARALLEL + p] : b_hz[0]),
                .z_t_n(z_t_elem[p]),
                .valid_out(valid_out_z[p])
            );

            // New gate element
            gru_new_gate_element #(
                .D(D),
                .H(H),
                .INT_BITS(INT_BITS),
                .FRAC_BITS(FRAC_BITS),
                .DATA_WIDTH(DATA_WIDTH)
            ) new_elem (
                .clk(clk),
                .rst_n(rst_n),
                .valid_in(valid_new && ((index * NUM_PARALLEL + p) < H)),
                .x_t(x_t),
                .h_t_prev(h_t_prev),
                .r_t_n((index * NUM_PARALLEL + p < H) ? r_t_storage[index * NUM_PARALLEL + p] : '0),
                .W_in_row((index * NUM_PARALLEL + p < H) ? W_in[index * NUM_PARALLEL + p] : W_in[0]),
                .W_hn_row((index * NUM_PARALLEL + p < H) ? W_hn[index * NUM_PARALLEL + p] : W_hn[0]),
                .b_in_n((index * NUM_PARALLEL + p < H) ? b_in[index * NUM_PARALLEL + p] : b_in[0]),
                .b_hn_n((index * NUM_PARALLEL + p < H) ? b_hn[index * NUM_PARALLEL + p] : b_hn[0]),
                .n_t_n(n_t_elem[p]),
                .valid_out(valid_out_n[p])
            );

            // Hidden state element
            gru_hidden_state_element #(
                .INT_BITS(INT_BITS),
                .FRAC_BITS(FRAC_BITS),
                .DATA_WIDTH(DATA_WIDTH)
            ) hidden_elem (
                .clk(clk),
                .rst_n(rst_n),
                .valid_in(valid_hidden && ((index * NUM_PARALLEL + p) < H)),
                .z_t_n((index * NUM_PARALLEL + p < H) ? z_t_storage[index * NUM_PARALLEL + p] : '0),
                .n_t_n((index * NUM_PARALLEL + p < H) ? n_t_storage[index * NUM_PARALLEL + p] : '0),
                .h_t_prev_n((index * NUM_PARALLEL + p < H) ? h_t_prev[index * NUM_PARALLEL + p] : '0),
                .h_t_n(h_t_elem[p]),
                .valid_out(valid_out_h[p])
            );

        end
    endgenerate

    // ========================================================================
    // FSM - State register
    // ========================================================================

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

    // ========================================================================
    // FSM - Next state logic
    // ========================================================================

    always_comb begin
        next_state = state;

        case (state)
            IDLE: begin
                if (start) begin
                    next_state = COMPUTE_RESET;
                end
            end

            COMPUTE_RESET: begin
                if (index >= total_iters) begin
                    next_state = WAIT_RESET;
                end
            end

            WAIT_RESET: begin
                if (wait_count >= 3'd2) begin  // Wait for pipeline
                    next_state = COMPUTE_UPDATE;
                end
            end

            COMPUTE_UPDATE: begin
                if (index >= total_iters) begin
                    next_state = WAIT_UPDATE;
                end
            end

            WAIT_UPDATE: begin
                if (wait_count >= 3'd2) begin
                    next_state = COMPUTE_NEW;
                end
            end

            COMPUTE_NEW: begin
                if (index >= total_iters) begin
                    next_state = WAIT_NEW;
                end
            end

            WAIT_NEW: begin
                if (wait_count >= 3'd2) begin
                    next_state = COMPUTE_HIDDEN;
                end
            end

            COMPUTE_HIDDEN: begin
                if (index >= total_iters) begin
                    next_state = WAIT_HIDDEN;
                end
            end

            WAIT_HIDDEN: begin
                if (wait_count >= 3'd2) begin
                    next_state = DONE_STATE;
                end
            end

            DONE_STATE: begin
                next_state = IDLE;
            end

            default: next_state = IDLE;
        endcase
    end

    // ========================================================================
    // FSM - Output logic and control signals
    // ========================================================================

    always_comb begin
        valid_reset = 1'b0;
        valid_update = 1'b0;
        valid_new = 1'b0;
        valid_hidden = 1'b0;

        case (state)
            COMPUTE_RESET:  valid_reset = 1'b1;
            COMPUTE_UPDATE: valid_update = 1'b1;
            COMPUTE_NEW:    valid_new = 1'b1;
            COMPUTE_HIDDEN: valid_hidden = 1'b1;
            default: ;
        endcase
    end

    // ========================================================================
    // Index counter
    // ========================================================================

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            index <= '0;
        end else begin
            case (state)
                IDLE: begin
                    if (start) begin
                        index <= '0;
                    end
                end

                COMPUTE_RESET, COMPUTE_UPDATE, COMPUTE_NEW, COMPUTE_HIDDEN: begin
                    index <= index + 1;
                end

                WAIT_RESET, WAIT_UPDATE, WAIT_NEW, WAIT_HIDDEN: begin
                    index <= '0;  // Reset for next phase
                end

                default: ;
            endcase
        end
    end

    // ========================================================================
    // Wait counter for pipeline delays
    // ========================================================================

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wait_count <= '0;
        end else begin
            case (state)
                WAIT_RESET, WAIT_UPDATE, WAIT_NEW, WAIT_HIDDEN: begin
                    wait_count <= wait_count + 1;
                end
                default: begin
                    wait_count <= '0;
                end
            endcase
        end
    end

    // ========================================================================
    // Store intermediate results
    // ========================================================================

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i = 0; i < H; i++) begin
                r_t_storage[i] <= '0;
                z_t_storage[i] <= '0;
                n_t_storage[i] <= '0;
                h_t_storage[i] <= '0;
            end
        end else begin
            // Store reset gate results
            for (int p = 0; p < NUM_PARALLEL; p++) begin
                if (valid_out_r[p] && ((index - 1) * NUM_PARALLEL + p < H) &&
                    (state == COMPUTE_RESET || state == WAIT_RESET)) begin
                    r_t_storage[(index - 1) * NUM_PARALLEL + p] <= r_t_elem[p];
                end
            end

            // Store update gate results
            for (int p = 0; p < NUM_PARALLEL; p++) begin
                if (valid_out_z[p] && ((index - 1) * NUM_PARALLEL + p < H) &&
                    (state == COMPUTE_UPDATE || state == WAIT_UPDATE)) begin
                    z_t_storage[(index - 1) * NUM_PARALLEL + p] <= z_t_elem[p];
                end
            end

            // Store new gate results
            for (int p = 0; p < NUM_PARALLEL; p++) begin
                if (valid_out_n[p] && ((index - 1) * NUM_PARALLEL + p < H) &&
                    (state == COMPUTE_NEW || state == WAIT_NEW)) begin
                    n_t_storage[(index - 1) * NUM_PARALLEL + p] <= n_t_elem[p];
                end
            end

            // Store hidden state results
            for (int p = 0; p < NUM_PARALLEL; p++) begin
                if (valid_out_h[p] && ((index - 1) * NUM_PARALLEL + p < H) &&
                    (state == COMPUTE_HIDDEN || state == WAIT_HIDDEN)) begin
                    h_t_storage[(index - 1) * NUM_PARALLEL + p] <= h_t_elem[p];
                end
            end
        end
    end

    // ========================================================================
    // Output assignment
    // ========================================================================

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            done <= 1'b0;
            for (int i = 0; i < H; i++) begin
                h_t[i] <= '0;
            end
        end else begin
            if (state == DONE_STATE) begin
                done <= 1'b1;
                h_t <= h_t_storage;
            end else begin
                done <= 1'b0;
            end
        end
    end

endmodule