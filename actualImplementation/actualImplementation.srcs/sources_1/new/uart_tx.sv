// File info:
// - Verilog copied from: https://www.instructables.com/UART-Communication-on-Basys-3-FPGA-Dev-Board-Power/
// - Comments added to show understanding
// - Transmits one packet worth of data over UART transmit line

module uart_tx(
    input clk,         // 10 MHz clock
    input rst_n,       // Active low reset
    input transmit,    // Whether or not to transmit
    input [7:0] data,  // Data to transmit
    output reg TxD     // UART transmit line
);
    
    reg [3:0] bitcounter;
    reg [13:0] counter;
    reg state,nextstate;
    reg [9:0] rightshiftreg; 
    reg shift;
    reg load;
    reg clear;
    
    // Does stuff based on flags changed by the FSM
    always @ (posedge clk) begin 
        if (!rst_n) begin
            state <=0;
            counter <=0; 
            bitcounter <=0;
        end else begin
            counter <= counter + 1; 
            
            // 10415 = master clock frequency / baud rate of 9600
            // Bayas3 is going WAY too fast to be at 9600 baud, so need
            //     to do stuff only on 9600 Hz
            if (counter >= 10415) begin 
                state <= nextstate;
                counter <=0; 
                
                // Load data with needed UART start/stop bits
                if (load) begin
                    rightshiftreg <= {1'b1,data,1'b0};
                end
                
                if (clear) begin 
                    bitcounter <=0;
                end
                
                if (shift) begin
                    rightshiftreg <= rightshiftreg >> 1;
                    bitcounter <= bitcounter + 1;
                end
            end
        end
    end 
    
    // Finite state machine!
    always @ (posedge clk) begin
        load <=0; 
        shift <=0;
        clear <=0;
        TxD <=1;  // Default held high because when UART is idle, the line is high
         
        case (state)
            // Idle
            0: begin
                if (transmit) begin
                    nextstate <= 1; 
                    load <=1; 
                    shift <=0;
                    clear <=0;
                end else begin 
                    nextstate <= 0;
                    TxD <= 1; 
                end
            end
            
            // Transmitting
            1: begin
                // UART is a 10 bit protocol, so if 10 bits have been
                //     sent then go back to idle
                if (bitcounter >=10) begin 
                    nextstate <= 0; 
                    clear <=1; 
                end else begin
                    // Send the next bit in the shift register and shift it
                    // Shift register works like a queue for this
                    nextstate <= 1;
                    TxD <= rightshiftreg[0];
                    shift <=1; 
                end
            end
        
            default: nextstate <= 0;                      
        
        endcase
    end

    
endmodule

