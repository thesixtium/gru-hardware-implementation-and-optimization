// ============================================================
// uart_rx.sv
// Baud: 2,000,000 | Clock: 100 MHz
// Divider = 100,000,000 / 2,000,000 = 50
// Half-period = 25 (sample at midpoint)
// ============================================================
module uart_rx (
    input  logic clk,
    input  logic rst_n,
    input  logic rx,
    output logic [7:0] rx_data,
    output logic rx_valid
);
    localparam int DIVIDER      = 50;
    localparam int HALF_DIVIDER = 25;

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
    logic rx_sync0, rx_sync1;

    // Two-stage synchronizer
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rx_sync0 <= 1'b1;
            rx_sync1 <= 1'b1;
        end else begin
            rx_sync0 <= rx;
            rx_sync1 <= rx_sync0;
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state     <= IDLE;
            baud_cnt  <= '0;
            bit_idx   <= '0;
            shift_reg <= '0;
            rx_data   <= '0;
            rx_valid  <= 1'b0;
        end else begin
            rx_valid <= 1'b0;
            case (state)
                IDLE: begin
                    if (!rx_sync1) begin // start bit detected (falling edge)
                        baud_cnt <= '0;
                        state    <= START;
                    end
                end
                START: begin
                    if (baud_cnt == HALF_DIVIDER - 1) begin
                        baud_cnt <= '0;
                        if (!rx_sync1) begin // verify still low at midpoint
                            state   <= DATA;
                            bit_idx <= '0;
                        end else begin
                            state <= IDLE; // false start
                        end
                    end else begin
                        baud_cnt <= baud_cnt + 1;
                    end
                end
                DATA: begin
                    if (baud_cnt == DIVIDER - 1) begin
                        baud_cnt          <= '0;
                        shift_reg[bit_idx] <= rx_sync1;
                        if (bit_idx == 3'd7) begin
                            state <= STOP;
                        end else begin
                            bit_idx <= bit_idx + 1;
                        end
                    end else begin
                        baud_cnt <= baud_cnt + 1;
                    end
                end
                STOP: begin
                    if (baud_cnt == DIVIDER - 1) begin
                        baud_cnt <= '0;
                        state    <= IDLE;
                        if (rx_sync1) begin // valid stop bit
                            rx_data  <= shift_reg;
                            rx_valid <= 1'b1;
                        end
                    end else begin
                        baud_cnt <= baud_cnt + 1;
                    end
                end
                default: state <= IDLE;
            endcase
        end
    end
endmodule