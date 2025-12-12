// ============================================================================
// Complete GRU Cell - Parallel Implementation (FIXED)
// ============================================================================
module gru_cell_parallel #(
    parameter int D = 4,
    parameter int H = 2,
    parameter int DATA_WIDTH = 15,
    parameter int FRAC_BITS = 9,
    parameter int NUM_PARALLEL = 4
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

    // Intermediate gate values
    logic signed [DATA_WIDTH-1:0] r_t [H-1:0];
    logic signed [DATA_WIDTH-1:0] z_t [H-1:0];
    logic signed [DATA_WIDTH-1:0] n_t [H-1:0];
    
    // Control signals for parallel units
    logic [NUM_PARALLEL-1:0] valid_in_r, valid_out_r;
    logic [NUM_PARALLEL-1:0] valid_in_z, valid_out_z;
    logic [NUM_PARALLEL-1:0] valid_in_n, valid_out_n;
    logic [NUM_PARALLEL-1:0] valid_in_h, valid_out_h;
    
    int element_index [NUM_PARALLEL-1:0];
    int current_element;
    
    // Temporary outputs from parallel units
    logic signed [DATA_WIDTH-1:0] r_t_n_temp [NUM_PARALLEL-1:0];
    logic signed [DATA_WIDTH-1:0] z_t_n_temp [NUM_PARALLEL-1:0];
    logic signed [DATA_WIDTH-1:0] n_t_n_temp [NUM_PARALLEL-1:0];
    logic signed [DATA_WIDTH-1:0] h_t_n_temp [NUM_PARALLEL-1:0];
    
    // State machine
    typedef enum logic [3:0] {
        IDLE,
        INIT_RESET,
        COMPUTE_RESET,
        WAIT_RESET,
        INIT_UPDATE,
        COMPUTE_UPDATE,
        WAIT_UPDATE,
        INIT_NEW,
        COMPUTE_NEW,
        WAIT_NEW,
        INIT_HIDDEN,
        COMPUTE_HIDDEN,
        WAIT_HIDDEN,
        FINISHED
    } state_t;
    
    state_t state, next_state;
    
    // Instantiate parallel reset gate elements
    genvar i;
    generate
        for (i = 0; i < NUM_PARALLEL; i++) begin : gen_reset_gates
            gru_reset_gate_element #(.D(D), .H(H), .DATA_WIDTH(DATA_WIDTH), .FRAC_BITS(FRAC_BITS))
            reset_gate_inst (
                .clk(clk),
                .rst_n(rst_n),
                .valid_in(valid_in_r[i]),
                .x_t(x_t),
                .h_t_prev(h_t_prev),
                .W_ir_row(W_ir[element_index[i]]),
                .W_hr_row(W_hr[element_index[i]]),
                .b_ir_n(b_ir[element_index[i]]),
                .b_hr_n(b_hr[element_index[i]]),
                .r_t_n(r_t_n_temp[i]),
                .valid_out(valid_out_r[i])
            );
        end
    endgenerate
    
    // Instantiate parallel update gate elements
    generate
        for (i = 0; i < NUM_PARALLEL; i++) begin : gen_update_gates
            gru_update_gate_element #(.D(D), .H(H), .DATA_WIDTH(DATA_WIDTH), .FRAC_BITS(FRAC_BITS))
            update_gate_inst (
                .clk(clk),
                .rst_n(rst_n),
                .valid_in(valid_in_z[i]),
                .x_t(x_t),
                .h_t_prev(h_t_prev),
                .W_iz_row(W_iz[element_index[i]]),
                .W_hz_row(W_hz[element_index[i]]),
                .b_iz_n(b_iz[element_index[i]]),
                .b_hz_n(b_hz[element_index[i]]),
                .z_t_n(z_t_n_temp[i]),
                .valid_out(valid_out_z[i])
            );
        end
    endgenerate
    
    // Instantiate parallel new gate elements
    generate
        for (i = 0; i < NUM_PARALLEL; i++) begin : gen_new_gates
            gru_new_gate_element #(.D(D), .H(H), .DATA_WIDTH(DATA_WIDTH), .FRAC_BITS(FRAC_BITS))
            new_gate_inst (
                .clk(clk),
                .rst_n(rst_n),
                .valid_in(valid_in_n[i]),
                .x_t(x_t),
                .h_t_prev(h_t_prev),
                .r_t_n(r_t[element_index[i]]),
                .W_in_row(W_in[element_index[i]]),
                .W_hn_row(W_hn[element_index[i]]),
                .b_in_n(b_in[element_index[i]]),
                .b_hn_n(b_hn[element_index[i]]),
                .n_t_n(n_t_n_temp[i]),
                .valid_out(valid_out_n[i])
            );
        end
    endgenerate
    
    // Instantiate parallel hidden state elements
    generate
        for (i = 0; i < NUM_PARALLEL; i++) begin : gen_hidden_states
            gru_hidden_state_element #(.DATA_WIDTH(DATA_WIDTH), .FRAC_BITS(FRAC_BITS))
            hidden_state_inst (
                .clk(clk),
                .rst_n(rst_n),
                .valid_in(valid_in_h[i]),
                .z_t_n(z_t[element_index[i]]),
                .n_t_n(n_t[element_index[i]]),
                .h_t_prev_n(h_t_prev[element_index[i]]),
                .h_t_n(h_t_n_temp[i]),
                .valid_out(valid_out_h[i])
            );
        end
    endgenerate
    
    // Control FSM
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            current_element <= 0;
            done <= 1'b0;
            valid_in_r <= '0;
            valid_in_z <= '0;
            valid_in_n <= '0;
            valid_in_h <= '0;
            
            // Initialize all output arrays to zero
            for (int j = 0; j < H; j++) begin
                r_t[j] <= '0;
                z_t[j] <= '0;
                n_t[j] <= '0;
                h_t[j] <= '0;
            end
            
            for (int j = 0; j < NUM_PARALLEL; j++) begin
                element_index[j] <= 0;
            end
        end else begin
            state <= next_state;
            
            case (state)
                IDLE: begin
                    if (start) begin
                        current_element <= 0;
                        done <= 1'b0;
                    end
                end
                
                // ===== RESET GATE =====
                INIT_RESET: begin
                    current_element <= 0;
                    // Set up first batch of indices
                    for (int j = 0; j < NUM_PARALLEL; j++) begin
                        if (j < H) begin
                            element_index[j] <= j;
                        end
                    end
                end
                
                COMPUTE_RESET: begin
                    // Start computation for all valid units
                    for (int j = 0; j < NUM_PARALLEL; j++) begin
                        if (element_index[j] < H) begin
                            valid_in_r[j] <= 1'b1;
                        end
                    end
                end
                
                WAIT_RESET: begin
                    // Process completions and store results
                    for (int j = 0; j < NUM_PARALLEL; j++) begin
                        if (element_index[j] < H && valid_out_r[j] && valid_in_r[j]) begin
                            // Store result
                            r_t[element_index[j]] <= r_t_n_temp[j];
                            // Clear valid_in for this unit
                            valid_in_r[j] <= 1'b0;
                        end
                    end
                    
                    // Check if all active units are done
                    if ((valid_in_r & ((1 << NUM_PARALLEL) - 1)) == '0) begin
                        // Move to next batch
                        current_element <= current_element + NUM_PARALLEL;
                        for (int j = 0; j < NUM_PARALLEL; j++) begin
                            element_index[j] <= current_element + NUM_PARALLEL + j;
                        end
                    end
                end
                
                // ===== UPDATE GATE =====
                INIT_UPDATE: begin
                    current_element <= 0;
                    for (int j = 0; j < NUM_PARALLEL; j++) begin
                        if (j < H) begin
                            element_index[j] <= j;
                        end
                    end
                end
                
                COMPUTE_UPDATE: begin
                    for (int j = 0; j < NUM_PARALLEL; j++) begin
                        if (element_index[j] < H) begin
                            valid_in_z[j] <= 1'b1;
                        end
                    end
                end
                
                WAIT_UPDATE: begin
                    for (int j = 0; j < NUM_PARALLEL; j++) begin
                        if (element_index[j] < H && valid_out_z[j] && valid_in_z[j]) begin
                            z_t[element_index[j]] <= z_t_n_temp[j];
                            valid_in_z[j] <= 1'b0;
                        end
                    end
                    
                    if ((valid_in_z & ((1 << NUM_PARALLEL) - 1)) == '0) begin
                        current_element <= current_element + NUM_PARALLEL;
                        for (int j = 0; j < NUM_PARALLEL; j++) begin
                            element_index[j] <= current_element + NUM_PARALLEL + j;
                        end
                    end
                end
                
                // ===== NEW GATE =====
                INIT_NEW: begin
                    current_element <= 0;
                    for (int j = 0; j < NUM_PARALLEL; j++) begin
                        if (j < H) begin
                            element_index[j] <= j;
                        end
                    end
                end
                
                COMPUTE_NEW: begin
                    for (int j = 0; j < NUM_PARALLEL; j++) begin
                        if (element_index[j] < H) begin
                            valid_in_n[j] <= 1'b1;
                        end
                    end
                end
                
                WAIT_NEW: begin
                    for (int j = 0; j < NUM_PARALLEL; j++) begin
                        if (element_index[j] < H && valid_out_n[j] && valid_in_n[j]) begin
                            n_t[element_index[j]] <= n_t_n_temp[j];
                            valid_in_n[j] <= 1'b0;
                        end
                    end
                    
                    if ((valid_in_n & ((1 << NUM_PARALLEL) - 1)) == '0) begin
                        current_element <= current_element + NUM_PARALLEL;
                        for (int j = 0; j < NUM_PARALLEL; j++) begin
                            element_index[j] <= current_element + NUM_PARALLEL + j;
                        end
                    end
                end
                
                // ===== HIDDEN STATE =====
                INIT_HIDDEN: begin
                    current_element <= 0;
                    for (int j = 0; j < NUM_PARALLEL; j++) begin
                        if (j < H) begin
                            element_index[j] <= j;
                        end
                    end
                end
                
                COMPUTE_HIDDEN: begin
                    for (int j = 0; j < NUM_PARALLEL; j++) begin
                        if (element_index[j] < H) begin
                            valid_in_h[j] <= 1'b1;
                        end
                    end
                end
                
                WAIT_HIDDEN: begin
                    for (int j = 0; j < NUM_PARALLEL; j++) begin
                        if (element_index[j] < H && valid_out_h[j] && valid_in_h[j]) begin
                            h_t[element_index[j]] <= h_t_n_temp[j];
                            valid_in_h[j] <= 1'b0;
                        end
                    end
                    
                    if ((valid_in_h & ((1 << NUM_PARALLEL) - 1)) == '0) begin
                        current_element <= current_element + NUM_PARALLEL;
                        for (int j = 0; j < NUM_PARALLEL; j++) begin
                            element_index[j] <= current_element + NUM_PARALLEL + j;
                        end
                    end
                end
                
                FINISHED: begin
                    done <= 1'b1;
                end
            endcase
        end
    end
    
    // Next state logic
    always_comb begin
        next_state = state;
        
        case (state)
            IDLE: if (start) next_state = INIT_RESET;
            
            INIT_RESET: next_state = COMPUTE_RESET;
            COMPUTE_RESET: next_state = WAIT_RESET;
            WAIT_RESET: begin
                if ((valid_in_r & ((1 << NUM_PARALLEL) - 1)) == '0) begin
                    if (current_element + NUM_PARALLEL >= H)
                        next_state = INIT_UPDATE;
                    else
                        next_state = COMPUTE_RESET;
                end
            end
            
            INIT_UPDATE: next_state = COMPUTE_UPDATE;
            COMPUTE_UPDATE: next_state = WAIT_UPDATE;
            WAIT_UPDATE: begin
                if ((valid_in_z & ((1 << NUM_PARALLEL) - 1)) == '0) begin
                    if (current_element + NUM_PARALLEL >= H)
                        next_state = INIT_NEW;
                    else
                        next_state = COMPUTE_UPDATE;
                end
            end
            
            INIT_NEW: next_state = COMPUTE_NEW;
            COMPUTE_NEW: next_state = WAIT_NEW;
            WAIT_NEW: begin
                if ((valid_in_n & ((1 << NUM_PARALLEL) - 1)) == '0) begin
                    if (current_element + NUM_PARALLEL >= H)
                        next_state = INIT_HIDDEN;
                    else
                        next_state = COMPUTE_NEW;
                end
            end
            
            INIT_HIDDEN: next_state = COMPUTE_HIDDEN;
            COMPUTE_HIDDEN: next_state = WAIT_HIDDEN;
            WAIT_HIDDEN: begin
                if ((valid_in_h & ((1 << NUM_PARALLEL) - 1)) == '0) begin
                    if (current_element + NUM_PARALLEL >= H)
                        next_state = FINISHED;
                    else
                        next_state = COMPUTE_HIDDEN;
                end
            end
            
            FINISHED: next_state = IDLE;
        endcase
    end

endmodule