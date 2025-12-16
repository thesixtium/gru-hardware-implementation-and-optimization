// ============================================================================
// New/Candidate Gate Element Module (n_t) - Using Proper Tanh Module
// ============================================================================
module gru_new_gate_element #(
    parameter int D = 128,
    parameter int H = 256,
    parameter int DATA_WIDTH = 16,
    parameter int FRAC_BITS = 8
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

    logic signed [2*DATA_WIDTH-1:0] sum_input;
    logic signed [2*DATA_WIDTH-1:0] sum_hidden;
    logic signed [2*DATA_WIDTH-1:0] sum_hidden_gated;
    logic signed [2*DATA_WIDTH-1:0] mac_result;
    logic signed [DATA_WIDTH-1:0] pre_activation;
    logic tanh_reset;
    
    int input_mac_count;
    int hidden_mac_count;
    
    typedef enum logic [2:0] {
        IDLE,
        MAC_INPUT,
        MAC_HIDDEN,
        GATE_HIDDEN,
        ADD_BIAS,
        TANH,
        DONE
    } state_t;
    
    state_t state, next_state;
    
    // Instantiate tanh module
    tanh #(
        .INT_WIDTH(DATA_WIDTH - FRAC_BITS),
        .FRAC_WIDTH(FRAC_BITS),
        .WIDTH(DATA_WIDTH)
    ) tanh_inst (
        .reset(tanh_reset),
        .x(pre_activation),
        .y(n_t_n)
    );
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            sum_input <= '0;
            sum_hidden <= '0;
            sum_hidden_gated <= '0;
            input_mac_count <= 0;
            hidden_mac_count <= 0;
            pre_activation <= '0;
            valid_out <= 1'b0;
            tanh_reset <= 1'b1;
        end else begin
            state <= next_state;
            
            case (state)
                IDLE: begin
                    if (valid_in) begin
                        sum_input <= '0;
                        sum_hidden <= '0;
                        input_mac_count <= 0;
                        hidden_mac_count <= 0;
                        valid_out <= 1'b0;
                        tanh_reset <= 1'b1;
                    end
                end
                
                MAC_INPUT: begin
                    sum_input <= sum_input + (W_in_row[input_mac_count] * x_t[input_mac_count]);
                    input_mac_count <= input_mac_count + 1;
                end
                
                MAC_HIDDEN: begin
                    sum_hidden <= sum_hidden + (W_hn_row[hidden_mac_count] * h_t_prev[hidden_mac_count]);
                    hidden_mac_count <= hidden_mac_count + 1;
                end
                
                GATE_HIDDEN: begin
                    // Apply reset gate: r_t_n * (sum_hidden + b_hn_n)
                    sum_hidden_gated <= (r_t_n * ((sum_hidden >>> FRAC_BITS) + 
                                        {{DATA_WIDTH{b_hn_n[DATA_WIDTH-1]}}, b_hn_n})) >>> FRAC_BITS;
                end
                
                ADD_BIAS: begin
                    // Add input contribution and input bias
                    mac_result <= (sum_input >>> FRAC_BITS) + 
                                  {{DATA_WIDTH{b_in_n[DATA_WIDTH-1]}}, b_in_n} + 
                                  sum_hidden_gated[DATA_WIDTH-1:0];
                    pre_activation <= ((sum_input >>> FRAC_BITS) + 
                                      {{DATA_WIDTH{b_in_n[DATA_WIDTH-1]}}, b_in_n} + 
                                      sum_hidden_gated[DATA_WIDTH-1:0])[DATA_WIDTH-1:0];
                    tanh_reset <= 1'b0;
                end
                
                TANH: begin
                    // Output is now driven by tanh module
                    valid_out <= 1'b1;
                end
                
                DONE: begin
                    valid_out <= 1'b0;
                    tanh_reset <= 1'b1;
                end
            endcase
        end
    end
    
    always_comb begin
        next_state = state;
        
        case (state)
            IDLE: if (valid_in) next_state = MAC_INPUT;
            MAC_INPUT: if (input_mac_count == D-1) next_state = MAC_HIDDEN;
            MAC_HIDDEN: if (hidden_mac_count == H-1) next_state = GATE_HIDDEN;
            GATE_HIDDEN: next_state = ADD_BIAS;
            ADD_BIAS: next_state = TANH;
            TANH: next_state = DONE;
            DONE: next_state = IDLE;
        endcase
    end

endmodule