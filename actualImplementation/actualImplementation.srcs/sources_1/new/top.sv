// ============================================================
// top.sv
// Arty A7-100T | 100 MHz | GRU D=64 H=16 Q10.7
// ============================================================
module top #(
    parameter int D          = 64,
    parameter int H          = 16,
    parameter int INT_BITS   = 10,
    parameter int FRAC_BITS  = 7,
    parameter int DATA_WIDTH = 17  // INT_BITS + FRAC_BITS
) (
    input  logic clk,
    input  logic rst_n,
    input  logic uart_rxd,
    output logic uart_txd
);

    // --------------------------------------------------------
    // UART wires
    // --------------------------------------------------------
    logic [7:0] rx_data;
    logic       rx_valid;
    logic       tx_start;
    logic [7:0] tx_byte;
    logic       tx_busy;

    uart_rx u_rx (
        .clk     (clk),
        .rst_n   (rst_n),
        .rx      (uart_rxd),
        .rx_data (rx_data),
        .rx_valid(rx_valid)
    );

    uart_tx u_tx (
        .clk     (clk),
        .rst_n   (rst_n),
        .tx_start(tx_start),
        .tx_data (tx_byte),
        .tx      (uart_txd),
        .tx_busy (tx_busy)
    );

    // --------------------------------------------------------
    // GRU weight/bias placeholders (all zeros - user must load
    // via parameter override or separate initialization logic)
    // These are declared as local registers here. In practice,
    // synthesize with constant weights via localparam or ROM.
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

    // Initialize weights to zero at reset (placeholder)
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
        .NUM_PARALLEL(1)
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
    // Sample buffer: 64 x 16-bit (we receive 2 bytes per sample)
    // We store as DATA_WIDTH (17-bit) sign-extended from 16-bit
    // --------------------------------------------------------
    logic signed [15:0] sample_buf [D-1:0];
    logic [6:0]  sample_cnt;   // 0..63 index into sample_buf
    logic        rx_byte_toggle; // tracks low/high byte within a sample
    logic [7:0]  rx_low_byte;

    // Hidden state memory (persists across GRU runs)
    logic signed [DATA_WIDTH-1:0] h_stored [H-1:0];

    // TX state
    // We transmit H*2 = 32 bytes after each GRU run
    logic [5:0]  tx_byte_cnt;  // 0..31
    logic [4:0]  tx_h_idx;     // which h element (0..15)
    logic        tx_high;      // 0=low byte, 1=high byte
    logic signed [15:0] tx_h_word; // current word being transmitted

    // --------------------------------------------------------
    // FSM
    // --------------------------------------------------------
    typedef enum logic [2:0] {
        IDLE          = 3'd0,
        RECEIVE       = 3'd1,
        START_GRU     = 3'd2,
        WAIT_DONE     = 3'd3,
        TRANSMIT      = 3'd4,
        RESET_COUNTER = 3'd5
    } fsm_t;

    fsm_t fsm_state;

    // --------------------------------------------------------
    // Main FSM
    // --------------------------------------------------------
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            fsm_state    <= RECEIVE; // Start receiving immediately
            sample_cnt   <= '0;
            rx_byte_toggle <= 1'b0;
            rx_low_byte  <= '0;
            gru_start    <= 1'b0;
            tx_start     <= 1'b0;
            tx_byte      <= '0;
            tx_byte_cnt  <= '0;
            tx_h_idx     <= '0;
            tx_high      <= 1'b0;
            tx_h_word    <= '0;
            for (int i = 0; i < D; i++) sample_buf[i] <= '0;
            for (int i = 0; i < H; i++) begin
                h_stored[i] <= '0;
                h_t_prev[i] <= '0;
                x_t[i]      <= '0;
            end
            for (int i = H; i < D; i++) x_t[i] <= '0;
        end else begin
            // Default deasserts
            gru_start <= 1'b0;
            tx_start  <= 1'b0;

            case (fsm_state)

                // --------------------------------------------------
                // RECEIVE: accumulate bytes into sample_buf
                // --------------------------------------------------
                RECEIVE: begin
                    if (rx_valid) begin
                        if (!rx_byte_toggle) begin
                            // Low byte
                            rx_low_byte    <= rx_data;
                            rx_byte_toggle <= 1'b1;
                        end else begin
                            // High byte - form 16-bit sample (little-endian)
                            sample_buf[sample_cnt] <= {rx_data, rx_low_byte};
                            rx_byte_toggle         <= 1'b0;
                            if (sample_cnt == D - 1) begin
                                // Buffer full
                                sample_cnt <= '0;
                                fsm_state  <= START_GRU;
                            end else begin
                                sample_cnt <= sample_cnt + 1;
                            end
                        end
                    end
                end

                // --------------------------------------------------
                // START_GRU: load x_t, h_t_prev, pulse start
                // --------------------------------------------------
                START_GRU: begin
                    for (int i = 0; i < D; i++) begin
                        // Sign-extend 16-bit Q10.7 to DATA_WIDTH (17-bit)
                        x_t[i] <= DATA_WIDTH'(signed'(sample_buf[i]));
                    end
                    for (int i = 0; i < H; i++) begin
                        h_t_prev[i] <= h_stored[i];
                    end
                    gru_start <= 1'b1;
                    fsm_state <= WAIT_DONE;
                end

                // --------------------------------------------------
                // WAIT_DONE: wait for GRU done pulse
                // --------------------------------------------------
                WAIT_DONE: begin
                    if (gru_done) begin
                        // Save new hidden state
                        for (int i = 0; i < H; i++) begin
                            h_stored[i] <= h_t[i];
                        end
                        // Prepare transmit
                        tx_byte_cnt <= '0;
                        tx_h_idx    <= '0;
                        tx_high     <= 1'b0;
                        tx_h_word   <= h_t[0][15:0]; // low 16 bits of h_t[0]
                        fsm_state   <= TRANSMIT;
                    end
                end

                // --------------------------------------------------
                // TRANSMIT: send H*2 = 32 bytes over UART
                // little-endian 16-bit per hidden element
                // --------------------------------------------------
                TRANSMIT: begin
                    if (!tx_busy && !tx_start) begin
                        if (!tx_high) begin
                            tx_byte  <= tx_h_word[7:0];  // low byte
                            tx_start <= 1'b1;
                            tx_high  <= 1'b1;
                        end else begin
                            tx_byte  <= tx_h_word[15:8]; // high byte
                            tx_start <= 1'b1;
                            tx_high  <= 1'b0;
                            if (tx_h_idx == H - 1) begin
                                // All H outputs sent
                                fsm_state <= RECEIVE;
                            end else begin
                                tx_h_idx  <= tx_h_idx + 1;
                                tx_h_word <= h_t[tx_h_idx + 1][15:0];
                            end
                        end
                    end
                end

                RESET_COUNTER: begin
                    // Unused but defined for FSM completeness
                    sample_cnt <= '0;
                    fsm_state  <= RECEIVE;
                end

                default: fsm_state <= RECEIVE;
            endcase
        end
    end

endmodule