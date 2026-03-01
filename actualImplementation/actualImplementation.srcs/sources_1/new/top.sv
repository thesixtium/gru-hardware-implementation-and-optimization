// ============================================================
// top.sv
// Arty A7-100T | 100 MHz | GRU D=64 H=16 Q10.6
//
// Protocol (byte-oriented, 8N1 UART at 9600 baud):
//   RX: Each 16-bit fixed-point value is sent as 2 bytes, MSB-first:
//         byte[0] = data[15:8]  (high byte sent first)
//         byte[1] = data[7:0]   (low byte sent second)
//       64 values (128 bytes total) are received, then GRU runs.
//
//   TX: After GRU completes, 16 output values are sent back,
//       each as 2 bytes MSB-first (same packing).
//       Total = 32 bytes transmitted.
// ============================================================
module top #(
    parameter int D          = 64,
    parameter int H          = 16,
    parameter int INT_BITS   = 10,
    parameter int FRAC_BITS  = 6,
    parameter int DATA_WIDTH = 16,   // INT_BITS + FRAC_BITS
    parameter int NUM_PARALLEL = 1
) (
    input  logic clk,
    input  logic rst_n,
    input  logic uart_rxd,
    output logic uart_txd
);

    // --------------------------------------------------------
    // UART RX
    // --------------------------------------------------------
    logic [7:0] rx_data;

    uart_rx u_rx (
        .clk   (clk),
        .rst_n (rst_n),
        .rx    (uart_rxd),
        .data  (rx_data)
    );

    // Detect new byte: generate a 1-cycle strobe when rx_data changes.
    logic [7:0] rx_data_prev;
    logic       rx_valid;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rx_data_prev <= 8'hFF;
            rx_valid     <= 1'b0;
        end else begin
            rx_data_prev <= rx_data;
            rx_valid     <= (rx_data != rx_data_prev);
        end
    end

    // --------------------------------------------------------
    // UART TX
    // --------------------------------------------------------
    logic       transmit;
    logic [7:0] tx_byte;

    uart_tx u_tx (
        .clk      (clk),
        .rst_n    (rst_n),
        .transmit (transmit),
        .data     (tx_byte),
        .TxD      (uart_txd)
    );

    // --------------------------------------------------------
    // GRU weight/bias registers (zeros - override with ROM/params)
    // --------------------------------------------------------
    logic signed [DATA_WIDTH-1:0] W_ir [H-1:0][D-1:0];
    logic signed [DATA_WIDTH-1:0] W_hr [H-1:0][H-1:0];
    logic signed [DATA_WIDTH-1:0] b_ir [H-1:0];
    logic signed [DATA_WIDTH-1:0] b_hr [H-1:0];

    logic signed [DATA_WIDTH-1:0] W_iz [H-1:0][D-1:0];
    logic signed [DATA_WIDTH-1:0] W_hz [H-1:0][H-1:0];
    logic signed [DATA_WIDTH-1:0] b_iz [H-1:0];
    logic signed [DATA_WIDTH-1:0] b_hz [H-1:0];

    logic signed [DATA_WIDTH-1:0] W_in [H-1:0][D-1:0];
    logic signed [DATA_WIDTH-1:0] W_hn [H-1:0][H-1:0];
    logic signed [DATA_WIDTH-1:0] b_in [H-1:0];
    logic signed [DATA_WIDTH-1:0] b_hn [H-1:0];

    integer wi, wj;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (wi = 0; wi < H; wi++) begin
                b_ir[wi] <= '0; b_hr[wi] <= '0;
                b_iz[wi] <= '0; b_hz[wi] <= '0;
                b_in[wi] <= '0; b_hn[wi] <= '0;
                for (wj = 0; wj < H; wj++) begin
                    W_hr[wi][wj] <= '0;
                    W_hz[wi][wj] <= '0;
                    W_hn[wi][wj] <= '0;
                end
                for (wj = 0; wj < D; wj++) begin
                    W_ir[wi][wj] <= '0;
                    W_iz[wi][wj] <= '0;
                    W_in[wi][wj] <= '0;
                end
            end
        end
    end

    // --------------------------------------------------------
    // GRU I/O
    // --------------------------------------------------------
    logic signed [DATA_WIDTH-1:0] x_t      [D-1:0];
    logic signed [DATA_WIDTH-1:0] h_t_prev [H-1:0];
    logic signed [DATA_WIDTH-1:0] h_t      [H-1:0];
    logic gru_start, gru_done;

    gru #(
        .D(D), .H(H),
        .INT_BITS(INT_BITS), .FRAC_BITS(FRAC_BITS),
        .DATA_WIDTH(DATA_WIDTH),
        .NUM_PARALLEL(NUM_PARALLEL)
    ) u_gru (
        .clk      (clk),
        .rst_n    (rst_n),
        .start    (gru_start),
        .x_t      (x_t),
        .h_t_prev (h_t_prev),
        .W_ir(W_ir),.W_hr(W_hr),.b_ir(b_ir),.b_hr(b_hr),
        .W_iz(W_iz),.W_hz(W_hz),.b_iz(b_iz),.b_hz(b_hz),
        .W_in(W_in),.W_hn(W_hn),.b_in(b_in),.b_hn(b_hn),
        .h_t      (h_t),
        .done     (gru_done)
    );

    // --------------------------------------------------------
    // RX state machine
    // Receive 64 values x 2 bytes each = 128 bytes total.
    // MSB-first: byte 0 = data[15:8], byte 1 = data[7:0]
    // --------------------------------------------------------
    logic                    rx_byte_phase;   // 0 = high byte, 1 = low byte
    logic [$clog2(D+1)-1:0] rx_val_idx;
    logic [7:0]              rx_high_byte;    // hold high byte until low arrives

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rx_byte_phase <= 1'b0;
            rx_val_idx    <= '0;
            rx_high_byte  <= '0;
            gru_start     <= 1'b0;
            for (int i = 0; i < D; i++) x_t[i] <= '0;
        end else begin
            gru_start <= 1'b0;

            if (rx_valid) begin
                if (!rx_byte_phase) begin
                    // First byte: save high byte, wait for low
                    rx_high_byte  <= rx_data;
                    rx_byte_phase <= 1'b1;
                end else begin
                    // Second byte: assemble full 16-bit value and store
                    x_t[rx_val_idx] <= {rx_high_byte, rx_data};
                    rx_byte_phase   <= 1'b0;

                    if (rx_val_idx == D - 1) begin
                        // All 64 values received - trigger GRU
                        rx_val_idx <= '0;
                        gru_start  <= 1'b1;
                    end else begin
                        rx_val_idx <= rx_val_idx + 1;
                    end
                end
            end
        end
    end

    // Update recurrent hidden state after each GRU run
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i = 0; i < H; i++) h_t_prev[i] <= '0;
        end else if (gru_done) begin
            h_t_prev <= h_t;
        end
    end

    // --------------------------------------------------------
    // TX state machine
    // After GRU done, send 16 values x 2 bytes each = 32 bytes.
    // MSB-first: byte 0 = data[15:8], byte 1 = data[7:0]
    // --------------------------------------------------------
    localparam int BAUD_CYCLES = 10416;  // clocks per UART frame at 9600 baud, 100 MHz

    typedef enum logic [1:0] {
        TX_IDLE = 2'd0,
        TX_LOAD = 2'd1,
        TX_WAIT = 2'd2
    } tx_state_t;

    tx_state_t tx_state;

    logic                              tx_byte_phase;  // 0 = high byte, 1 = low byte
    logic [$clog2(H+1)-1:0]           tx_val_idx;
    logic [DATA_WIDTH-1:0]             tx_val_reg;
    logic [$clog2(BAUD_CYCLES+1)-1:0] baud_timer;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            tx_state      <= TX_IDLE;
            tx_byte_phase <= 1'b0;
            tx_val_idx    <= '0;
            tx_val_reg    <= '0;
            baud_timer    <= '0;
            transmit      <= 1'b0;
            tx_byte       <= 8'd0;
        end else begin
            transmit <= 1'b0;

            case (tx_state)

                TX_IDLE: begin
                    if (gru_done) begin
                        tx_val_idx    <= '0;
                        tx_byte_phase <= 1'b0;
                        tx_val_reg    <= h_t[0];
                        tx_state      <= TX_LOAD;
                    end
                end

                TX_LOAD: begin
                    // Select high or low byte
                    tx_byte    <= tx_byte_phase ? tx_val_reg[7:0] : tx_val_reg[15:8];
                    transmit   <= 1'b1;
                    baud_timer <= '0;
                    tx_state   <= TX_WAIT;
                end

                TX_WAIT: begin
                    if (baud_timer < BAUD_CYCLES) begin
                        baud_timer <= baud_timer + 1;
                    end else begin
                        if (tx_byte_phase) begin
                            // Both bytes of this value sent
                            tx_byte_phase <= 1'b0;
                            if (tx_val_idx == H - 1) begin
                                // All 16 values transmitted
                                tx_state <= TX_IDLE;
                            end else begin
                                tx_val_idx <= tx_val_idx + 1;
                                tx_val_reg <= h_t[tx_val_idx + 1];
                                tx_state   <= TX_LOAD;
                            end
                        end else begin
                            // Send the low byte next
                            tx_byte_phase <= 1'b1;
                            tx_state      <= TX_LOAD;
                        end
                    end
                end

                default: tx_state <= TX_IDLE;
            endcase
        end
    end

endmodule