// ============================================================
// uart_tx.sv
// Baud: 2,000,000 | Clock: 100 MHz
// Divider = 100,000,000 / 2,000,000 = 50
// ============================================================
module uart_tx (
    input  logic       clk,
    input  logic       rst_n,
    input  logic       tx_start,
    input  logic [7:0] tx_data,
    output logic       tx,
    output logic       tx_busy
);
    localparam int DIVIDER = 50;

    typedef enum logic [1:0] {
        IDLE  = 2'd0,
        START = 2'd1,
        DATA  = 2'd2,
        STOP  = 2'd3
    } state_t;

    state_t state;
    logic [$clog2(DIVIDER)-1:0] baud_cnt;
    logic [2:0] bit_idx;
    logic [7:0] shift_reg;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state    <= IDLE;
            tx       <= 1'b1;
            tx_busy  <= 1'b0;
            baud_cnt <= '0;
            bit_idx  <= '0;
            shift_reg<= '0;
        end else begin
            case (state)
                IDLE: begin
                    tx      <= 1'b1;
                    tx_busy <= 1'b0;
                    if (tx_start) begin
                        shift_reg <= tx_data;
                        tx_busy   <= 1'b1;
                        tx        <= 1'b0; // start bit
                        baud_cnt  <= '0;
                        state     <= START;
                    end
                end
                START: begin
                    if (baud_cnt == DIVIDER - 1) begin
                        baud_cnt <= '0;
                        tx       <= shift_reg[0];
                        bit_idx  <= '0;
                        state    <= DATA;
                    end else begin
                        baud_cnt <= baud_cnt + 1;
                    end
                end
                DATA: begin
                    if (baud_cnt == DIVIDER - 1) begin
                        baud_cnt <= '0;
                        if (bit_idx == 3'd7) begin
                            tx    <= 1'b1; // stop bit
                            state <= STOP;
                        end else begin
                            bit_idx <= bit_idx + 1;
                            tx      <= shift_reg[bit_idx + 1];
                        end
                    end else begin
                        baud_cnt <= baud_cnt + 1;
                    end
                end
                STOP: begin
                    if (baud_cnt == DIVIDER - 1) begin
                        baud_cnt <= '0;
                        state    <= IDLE;
                        tx_busy  <= 1'b0;
                    end else begin
                        baud_cnt <= baud_cnt + 1;
                    end
                end
                default: state <= IDLE;
            endcase
        end
    end
endmodule