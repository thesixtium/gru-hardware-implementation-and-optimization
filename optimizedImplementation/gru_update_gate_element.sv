// ============================================================================
// Update Gate Element Module (z_t) - Using Proper Sigmoid Module
// ============================================================================
module gru_update_gate_element #(
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
    input  logic signed [DATA_WIDTH-1:0] W_iz_row [D-1:0],
    input  logic signed [DATA_WIDTH-1:0] W_hz_row [H-1:0],
    input  logic signed [DATA_WIDTH-1:0] b_iz_n,
    input  logic signed [DATA_WIDTH-1:0] b_hz_n,
    
    output logic signed [DATA_WIDTH-1:0] z_t_n,
    output logic                          valid_out
);

    logic signed [2*DATA_WIDTH-1:0] sum_input;
    logic signed [2*DATA_WIDTH-1:0] sum_hidden;
    logic signed [2*DATA_WIDTH-1:0] mac_result;
    logic signed [DATA_WIDTH-1:0] pre_activation;
    logic sigmoid_reset;
    
    int input_mac_count;
    int hidden_mac_count;
    
    typedef enum logic [2:0] {
        IDLE,
        MAC_INPUT,
        MAC_HIDDEN,
        ADD_BIAS,
        SIGMOID,
        DONE
    } state_t;
    
    state_t state, next_state;
    
    // Instantiate sigmoid module
    sigmoid #(
        .INT_WIDTH(DATA_WIDTH - FRAC_BITS),
        .FRAC_WIDTH(FRAC_BITS),
        .WIDTH(DATA_WIDTH)
    ) sigmoid_inst (
        .reset(sigmoid_reset),
        .x(pre_activation),
        .y(z_t_n)
    );
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            sum_input <= '0;
            sum_hidden <= '0;
            input_mac_count <= 0;
            hidden_mac_count <= 0;
            pre_activation <= '0;
            valid_out <= 1'b0;
            sigmoid_reset <= 1'b1;
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
                        sigmoid_reset <= 1'b1;
                    end
                end
                
                MAC_INPUT: begin
                    sum_input <= sum_input + (W_iz_row[input_mac_count] * x_t[input_mac_count]);
                    input_mac_count <= input_mac_count + 1;
                end
                
                MAC_HIDDEN: begin
                    sum_hidden <= sum_hidden + (W_hz_row[hidden_mac_count] * h_t_prev[hidden_mac_count]);
                    hidden_mac_count <= hidden_mac_count + 1;
                end
                
                ADD_BIAS: begin
                    mac_result <= (sum_input >>> FRAC_BITS) + (sum_hidden >>> FRAC_BITS) + 
                                  {{DATA_WIDTH{b_iz_n[DATA_WIDTH-1]}}, b_iz_n} + 
                                  {{DATA_WIDTH{b_hz_n[DATA_WIDTH-1]}}, b_hz_n};
                    pre_activation <= ((sum_input >>> FRAC_BITS) + (sum_hidden >>> FRAC_BITS) + 
                                      {{DATA_WIDTH{b_iz_n[DATA_WIDTH-1]}}, b_iz_n} + 
                                      {{DATA_WIDTH{b_hz_n[DATA_WIDTH-1]}}, b_hz_n})[DATA_WIDTH-1:0];
                    sigmoid_reset <= 1'b0;
                end
                
                SIGMOID: begin
                    // Output is now driven by sigmoid module
                    valid_out <= 1'b1;
                end
                
                DONE: begin
                    valid_out <= 1'b0;
                    sigmoid_reset <= 1'b1;
                end
            endcase
        end
    end
    
    always_comb begin
        next_state = state;
        
        case (state)
            IDLE: if (valid_in) next_state = MAC_INPUT;
            MAC_INPUT: if (input_mac_count == D-1) next_state = MAC_HIDDEN;
            MAC_HIDDEN: if (hidden_mac_count == H-1) next_state = ADD_BIAS;
            ADD_BIAS: next_state = SIGMOID;
            SIGMOID: next_state = DONE;
            DONE: next_state = IDLE;
        endcase
    end

endmodule