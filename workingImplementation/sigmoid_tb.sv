`timescale 1ns / 1ps

module sigmoid_tb();

    // Parameters
    parameter CLK_PERIOD = 10; // 10ns for 100MHz clock

    // Signals
    logic clk = 0;
    logic reset = 0;
    logic signed [16:0] x = 0;
    logic signed [16:0] y = 0;
    
    // Instantiate the Unit Under Test (UUT)
    sigmoid uut ( clk, reset, x, y );
    
    always #(CLK_PERIOD / 2) clk = ~clk;

    // Test stimulus
    initial begin
        reset = 0;
        #(10 * CLK_PERIOD);
        reset = 1;
        #(10 * CLK_PERIOD);
        reset = 0;
        
        x = $rtoi( 3.1415   * (1 << 8));
        #(50 * CLK_PERIOD);
        if (y !== 'b0_0000_0000_1111_0001) begin
            $error("Test 1 failed");
        end
        
        x = $rtoi( -2.0  * (1 << 8));
        #(50 * CLK_PERIOD);
        if (y !== 'b0_0000_0000_0010_000) begin
            $error("Test 2 failed");
        end
        
        $stop;
    end

endmodule