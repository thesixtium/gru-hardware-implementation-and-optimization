`timescale 1ns / 1ps

// Simple testbench to verify sigmoid and tanh behavior
module activation_test;
    parameter int INT_WIDTH  = 8;
    parameter int FRAC_WIDTH = 8;
    parameter int WIDTH      = INT_WIDTH + FRAC_WIDTH + 1;
    
    logic clk, reset;
    logic signed [WIDTH-1:0] x_sig, y_sig;
    logic signed [WIDTH-1:0] x_tanh, y_tanh;
    
    function real fixed_to_real(logic signed [WIDTH-1:0] val);
        return $itor(val) / (2.0 ** FRAC_WIDTH);
    endfunction
    
    function logic signed [WIDTH-1:0] real_to_fixed(real val);
        return $rtoi(val * (2.0 ** FRAC_WIDTH));
    endfunction
    
    // Instantiate sigmoid
    sigmoid #(.INT_WIDTH(INT_WIDTH), .FRAC_WIDTH(FRAC_WIDTH)) sig (
        .clk(clk), .reset(reset), .x(x_sig), .y(y_sig)
    );
    
    // Instantiate tanh
    tanh #(.INT_WIDTH(INT_WIDTH), .FRAC_WIDTH(FRAC_WIDTH)) tanh_inst (
        .clk(clk), .reset(reset), .x(x_tanh), .y(y_tanh)
    );
    
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    initial begin
        reset = 1;
        x_sig = 0;
        x_tanh = 0;
        #20;
        reset = 0;
        #20;
        
        $display("\n=== Activation Function Tests ===\n");
        
        // Test sigmoid
        $display("SIGMOID Tests:");
        x_sig = real_to_fixed(0.0);
        #20;
        $display("  sigmoid(%.3f) = %.3f (expected ~0.500)", 
                 fixed_to_real(x_sig), fixed_to_real(y_sig));
        
        x_sig = real_to_fixed(-4.0);
        #20;
        $display("  sigmoid(%.3f) = %.3f (expected ~0.018)", 
                 fixed_to_real(x_sig), fixed_to_real(y_sig));
        
        x_sig = real_to_fixed(4.0);
        #20;
        $display("  sigmoid(%.3f) = %.3f (expected ~0.982)", 
                 fixed_to_real(x_sig), fixed_to_real(y_sig));
        
        x_sig = real_to_fixed(1.0);
        #20;
        $display("  sigmoid(%.3f) = %.3f (expected ~0.731)", 
                 fixed_to_real(x_sig), fixed_to_real(y_sig));
        
        // Test tanh
        $display("\nTANH Tests:");
        x_tanh = real_to_fixed(0.0);
        #20;
        $display("  tanh(%.3f) = %.3f (expected 0.000)", 
                 fixed_to_real(x_tanh), fixed_to_real(y_tanh));
        
        x_tanh = real_to_fixed(-2.0);
        #20;
        $display("  tanh(%.3f) = %.3f (expected ~-0.964)", 
                 fixed_to_real(x_tanh), fixed_to_real(y_tanh));
        
        x_tanh = real_to_fixed(2.0);
        #20;
        $display("  tanh(%.3f) = %.3f (expected ~0.964)", 
                 fixed_to_real(x_tanh), fixed_to_real(y_tanh));
        
        x_tanh = real_to_fixed(1.0);
        #20;
        $display("  tanh(%.3f) = %.3f (expected ~0.762)", 
                 fixed_to_real(x_tanh), fixed_to_real(y_tanh));
        
        $display("");
        $finish;
    end
endmodule