// uart_tx with IOB output register to fix the TxD → uart_txd OBUF timing
// violation (-3.062ns WNS).
//
// The original had TxD as a reg driven by always blocks, but Vivado was
// not packing it into the IOB flip-flop, leaving a long OBUF path.
// Marking TxD_reg with IOB="TRUE" forces it into the output I/O block,
// which absorbs the clock-to-output delay entirely.

module uart_tx(
    input        clk,
    input        rst_n,
    input        transmit,
    input  [7:0] data,
    (* IOB = "TRUE" *)
    output reg   TxD
);

    reg [3:0]  bitcounter;
    reg [13:0] counter;
    reg        state, nextstate;
    reg [9:0]  rightshiftreg;
    reg        shift;
    reg        load;
    reg        clear;

    // Internal TxD before IOB register
    reg TxD_int;

    // IOB register: sample TxD_int on every clock edge
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            TxD <= 1'b1;
        else
            TxD <= TxD_int;
    end

    always @(posedge clk) begin
        if (!rst_n) begin
            state      <= 0;
            counter    <= 0;
            bitcounter <= 0;
        end else begin
            counter <= counter + 1;
            if (counter >= 10415) begin
                state   <= nextstate;
                counter <= 0;
                if (load)  rightshiftreg <= {1'b1, data, 1'b0};
                if (clear) bitcounter <= 0;
                if (shift) begin
                    rightshiftreg <= rightshiftreg >> 1;
                    bitcounter    <= bitcounter + 1;
                end
            end
        end
    end

    always @(posedge clk) begin
        load    <= 0;
        shift   <= 0;
        clear   <= 0;
        TxD_int <= 1'b1;

        case (state)
            0: begin
                if (transmit) begin
                    nextstate <= 1;
                    load      <= 1;
                end else begin
                    nextstate <= 0;
                end
            end

            1: begin
                if (bitcounter >= 10) begin
                    nextstate <= 0;
                    clear     <= 1;
                end else begin
                    nextstate <= 1;
                    TxD_int   <= rightshiftreg[0];
                    shift     <= 1;
                end
            end

            default: nextstate <= 0;
        endcase
    end

endmodule