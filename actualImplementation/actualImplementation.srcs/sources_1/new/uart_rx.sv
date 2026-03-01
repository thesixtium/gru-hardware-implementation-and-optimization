// File info:
// - Verilog copied from: https://www.instructables.com/UART-Communication-on-Basys-3-FPGA-Dev-Board-Power-1/
// - Comments added to show understanding
// - Receive bits from the Basys3's UART rx line and turn it into usable data

module uart_rx (
    input  logic clk,         // 10 MHz clock
    input  logic rst_n,       // Active low reset
    input  logic rx,          // UART recieve line
    
    output logic [7:0] data  // RX command recieved
);

    logic shift;
    logic state;
    logic nextstate;
    logic clear_bitcounter;
    logic inc_bitcounter;
    logic inc_samplecounter;
    logic clear_samplecounter;
    
    logic [3:0]  bitcounter;
    logic [1:0]  samplecounter;
    logic [13:0] counter;
    logic [9:0]  rxshiftreg;
    
    localparam clk_freq = 100_000_000;
    localparam baud_rate = 9_600;
    localparam div_sample = 4;
    localparam div_counter = clk_freq / (baud_rate * div_sample);
    localparam mid_sample = (div_sample / 2);
    localparam div_bit = 10;
    
    assign data = rxshiftreg[8:1];
   
    // Handles flags thrown by the finite state machine 
    always @(posedge clk) begin
        if (!rst_n) begin
            state <= 0;
            bitcounter <= 0;
            counter <= 0;
            samplecounter <= 0;
        end else begin
            counter <= counter + 1;
            if (counter >= div_counter - 1) begin
                counter <= 0;
                state <= nextstate;
                if (shift) rxshiftreg <= {rx, rxshiftreg[9:1]};
                if (clear_samplecounter) samplecounter <= 0;
                if (inc_samplecounter)   samplecounter <= samplecounter + 1;
                if (clear_bitcounter)    bitcounter <= 0;
                if (inc_bitcounter)      bitcounter<= bitcounter+ 1;
            end
        end
    end
    
    // Finite state machine!!
    always@(posedge clk) begin
        shift <= 0;
        clear_samplecounter <= 0;
        inc_samplecounter <= 0;
        clear_bitcounter <= 0;
        inc_bitcounter <= 0;
        nextstate <= 0;
        
        case(state)
        
            // Idle until 0 is send over the line
            // First 0 just shows that transmission is starting, so don't
            //     need to store it
            0: begin
                if (rx) begin
                    // If line is kept high, stay in idle
                    nextstate <= 0;
                end else begin
                    // If line pulled low, start to recieve
                    nextstate <= 1;            // Go to recieve state
                    clear_bitcounter <= 1;     // Reset bit counter
                    clear_samplecounter <= 1;  // Reset sample counter
                end
            end
            
            // Receiving!
            1: begin
                // Unless finished, keep recieving
                nextstate <= 1;
                
                // If in the middle of a bit, shift the rx register and
                //     the incoming data as the newest bit
                if (samplecounter == mid_sample - 1) begin
                    shift <= 1;
                end
                
                // If at the end of a transmitted bit, either go
                //     to the next bit or finish transmission
                if (samplecounter == div_sample - 1) begin
                    // UART send 10 bit long packets, if at the
                    //    end of a packet then go back to idle
                    if(bitcounter == div_bit - 1 ) begin
                        nextstate <= 0;
                    end
                    
                    // Step up by counter by one bit and reset
                    //     the sample counter
                    inc_bitcounter <= 1;
                    clear_samplecounter <= 1;
                end else begin
                    // Increase the sample counter
                    inc_samplecounter <= 1;
                end
            end
            
            default: nextstate <= 0;
        endcase
    end
endmodule
