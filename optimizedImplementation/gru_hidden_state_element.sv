// ============================================================================
// Final Hidden State Element Module (h_t) - FIXED
// ============================================================================
module gru_hidden_state_element #(
    parameter int DATA_WIDTH = 16,
    parameter int FRAC_BITS = 8
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

    typedef enum logic [1:0] {
        IDLE,
        COMPUTE,
        DONE
    } state_t;
    
    state_t state, next_state;
    
    logic signed [DATA_WIDTH-1:0] one;
    logic signed [2*DATA_WIDTH-1:0] term1, term2;
    
    assign one = (1 << FRAC_BITS);
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            h_t_n <= '0;
            valid_out <= 1'b0;
            term1 <= '0;
            term2 <= '0;
        end else begin
            state <= next_state;
            
            case (state)
                IDLE: begin
                    if (valid_in) begin
                        valid_out <= 1'b0;
                        // Pre-compute terms
                        term1 <= (one - z_t_n) * n_t_n;
                        term2 <= z_t_n * h_t_prev_n;
                    end
                end
                
                COMPUTE: begin
                    // Use the pre-computed terms from IDLE state
                    h_t_n <= ((term1 + term2) >>> FRAC_BITS);
                    valid_out <= 1'b1;
                end
                
                DONE: begin
                    valid_out <= 1'b0;
                end
            endcase
        end
    end
    
    always_comb begin
        next_state = state;
        
        case (state)
            IDLE: if (valid_in) next_state = COMPUTE;
            COMPUTE: next_state = DONE;
            DONE: next_state = IDLE;
        endcase
    end

endmodule