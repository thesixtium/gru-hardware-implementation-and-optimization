`timescale 1ns / 1ps

module gru_tb;

// Parameters
parameter int D          = 4;
parameter int H          = 2;
parameter int DATA_WIDTH = 15;
parameter int FRAC_BITS  = 9;
parameter int NUM_PARALLEL = 4;
parameter real CLK_PERIOD = 10.0;

// Clock and reset
logic clk;
logic rst_n;
logic start;
logic done;

// Cycle counter
int cycle_count = 0;
int test_start_cycle = 0;
int test_cycles = 0;
int total_cycles = 0;
bit test_timeout = 0;

// Input arrays
logic signed [DATA_WIDTH-1:0] x_t [D-1:0];
logic signed [DATA_WIDTH-1:0] h_t_prev [H-1:0];
logic signed [DATA_WIDTH-1:0] h_t [H-1:0];

// Weight matrices
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

// DUT instantiation
gru_cell_parallel #(
    .D(D),
    .H(H),
    .DATA_WIDTH(DATA_WIDTH),
    .FRAC_BITS(FRAC_BITS),
    .NUM_PARALLEL(NUM_PARALLEL)
) dut (
    .clk(clk),
    .rst_n(rst_n),
    .start(start),
    .x_t(x_t),
    .h_t_prev(h_t_prev),
    .W_ir(W_ir),
    .W_hr(W_hr),
    .b_ir(b_ir),
    .b_hr(b_hr),
    .W_iz(W_iz),
    .W_hz(W_hz),
    .b_iz(b_iz),
    .b_hz(b_hz),
    .W_in(W_in),
    .W_hn(W_hn),
    .b_in(b_in),
    .b_hn(b_hn),
    .h_t(h_t),
    .done(done)
);

// Clock generation
initial begin
    clk = 0;
    forever #5 clk = ~clk; // 100MHz clock
end

// Cycle counter
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cycle_count <= 0;
    end else begin
        cycle_count <= cycle_count + 1;
    end
end

initial begin
    // Open files for writing
    integer fd_output;
    integer fd_cycles;
    
    fd_output = $fopen("../../../../../output_d4_h2_dw15_fb9_np4.txt", "w+");
    if (fd_output == 0) begin
        $display("ERROR: Failed to open output file!");
        $finish;
    end
    
    fd_cycles = $fopen("../../../../../cycles_d4_h2_dw15_fb9_np4.txt", "w+");
    if (fd_cycles == 0) begin
        $display("ERROR: Failed to open cycles file!");
        $fclose(fd_output);
        $finish;
    end
    
    // Write header to cycles file
    $fdisplay(fd_cycles, "==========================================================");
    $fdisplay(fd_cycles, "GRU Cell Parallel Cycle Count Results");
    $fdisplay(fd_cycles, "==========================================================");
    $fdisplay(fd_cycles, "Parameters:");
    $fdisplay(fd_cycles, "  D (Input Dimension):     4");
    $fdisplay(fd_cycles, "  H (Hidden Dimension):    2");
    $fdisplay(fd_cycles, "  DATA_WIDTH:              15");
    $fdisplay(fd_cycles, "  FRAC_BITS:               9");
    $fdisplay(fd_cycles, "  NUM_PARALLEL:            4");
    $fdisplay(fd_cycles, "  Total Test Vectors:      100");
    $fdisplay(fd_cycles, "==========================================================");
    $fdisplay(fd_cycles, "");
    
    // Initialize weights
    // Initialize W_ir weights
    W_ir[0][0] = 15'b000000000101001;
    W_ir[0][1] = 15'b000000001001110;
    W_ir[0][2] = 15'b000000000111100;
    W_ir[0][3] = 15'b000000001000110;
    W_ir[1][0] = 15'b111111111011010;
    W_ir[1][1] = 15'b111111110101011;
    W_ir[1][2] = 15'b000000000111010;
    W_ir[1][3] = 15'b000000000011111;

    // Initialize W_iz weights
    W_iz[0][0] = 15'b111111110010000;
    W_iz[0][1] = 15'b000000000001011;
    W_iz[0][2] = 15'b000000001111101;
    W_iz[0][3] = 15'b111111111111111;
    W_iz[1][0] = 15'b000000001010000;
    W_iz[1][1] = 15'b000000000010110;
    W_iz[1][2] = 15'b000000000010100;
    W_iz[1][3] = 15'b000000001011101;

    // Initialize W_in weights
    W_in[0][0] = 15'b111111111110000;
    W_in[0][1] = 15'b000000001101110;
    W_in[0][2] = 15'b111111111110010;
    W_in[0][3] = 15'b000000001001001;
    W_in[1][0] = 15'b111111111110001;
    W_in[1][1] = 15'b000000001000100;
    W_in[1][2] = 15'b000000000110001;
    W_in[1][3] = 15'b000000000110010;

    // Initialize W_hr weights
    W_hr[0][0] = 15'b000000000000111;
    W_hr[0][1] = 15'b000000000010011;
    W_hr[1][0] = 15'b000000000011111;
    W_hr[1][1] = 15'b111111110101110;

    // Initialize W_hz weights
    W_hz[0][0] = 15'b000000010001100;
    W_hz[0][1] = 15'b000000010010111;
    W_hz[1][0] = 15'b000000010010101;
    W_hz[1][1] = 15'b111111101101100;

    // Initialize W_hn weights
    W_hn[0][0] = 15'b000000001111111;
    W_hn[0][1] = 15'b000000010010000;
    W_hn[1][0] = 15'b111111110111111;
    W_hn[1][1] = 15'b111111110110010;

    // Initialize biases

    // Initialize b_ir biases
    b_ir[0] = 15'b000000000001100;
    b_ir[1] = 15'b000000010000101;

    // Initialize b_iz biases
    b_iz[0] = 15'b000000011101110;
    b_iz[1] = 15'b000000001010010;

    // Initialize b_in biases
    b_in[0] = 15'b000000001100001;
    b_in[1] = 15'b000000001000101;

    // Initialize b_hr biases
    b_hr[0] = 15'b000000011111100;
    b_hr[1] = 15'b111111111111010;

    // Initialize b_hz biases
    b_hz[0] = 15'b000000010101010;
    b_hz[1] = 15'b000000000011101;

    // Initialize b_hn biases
    b_hn[0] = 15'b000000011100001;
    b_hn[1] = 15'b000000000100110;

    // Reset sequence
    rst_n = 0;
    start = 0;
    test_start_cycle = 0;
    test_cycles = 0;
    total_cycles = 0;
    test_timeout = 0;
    repeat(10) @(posedge clk);
    rst_n = 1;
    repeat(5) @(posedge clk);

    // Test Vector 1
    if (!test_timeout) begin
        test_start_cycle = cycle_count;
        
        // Load input data
        x_t[0] = 15'b000001001000101;
        x_t[1] = 15'b000001101101100;
        x_t[2] = 15'b000010000010010;
        x_t[3] = 15'b000010010001101;
        
        h_t_prev[0] = 15'b000001001000101;
        h_t_prev[1] = 15'b000001101101100;
        
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        // Wait for completion with timeout
        fork
            begin
                wait(done);
                test_cycles = cycle_count - test_start_cycle;
            end
            begin
                repeat(200000) @(posedge clk);
                $display("ERROR: Test 1 timeout!");
                $fdisplay(fd_cycles, "Test Vector   1: TIMEOUT");
                test_cycles = -1;
                test_timeout = 1;
            end
        join_any
        disable fork;
        
        if (test_cycles > 0) begin
            repeat(5) @(posedge clk); // Extra cycles for stability
            total_cycles = total_cycles + test_cycles;
            $fdisplay(fd_cycles, "Test Vector   1: %0d cycles (%.2f us @ 100MHz)", test_cycles, test_cycles * 0.01);
            
            // Write outputs
            $fdisplay(fd_output, "%015b %015b", h_t[0], h_t[1]);
        end else begin
            $display("Stopping simulation due to timeout on test 1");
        end
        
        repeat(5) @(posedge clk); // Wait between tests
    end

    // Test Vector 2
    if (!test_timeout) begin
        test_start_cycle = cycle_count;
        
        // Load input data
        x_t[0] = 15'b000001011100010;
        x_t[1] = 15'b000010010010010;
        x_t[2] = 15'b000010100011001;
        x_t[3] = 15'b000010101011000;
        
        h_t_prev[0] = 15'b000001011100010;
        h_t_prev[1] = 15'b000010010010010;
        
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        // Wait for completion with timeout
        fork
            begin
                wait(done);
                test_cycles = cycle_count - test_start_cycle;
            end
            begin
                repeat(200000) @(posedge clk);
                $display("ERROR: Test 2 timeout!");
                $fdisplay(fd_cycles, "Test Vector   2: TIMEOUT");
                test_cycles = -1;
                test_timeout = 1;
            end
        join_any
        disable fork;
        
        if (test_cycles > 0) begin
            repeat(5) @(posedge clk); // Extra cycles for stability
            total_cycles = total_cycles + test_cycles;
            $fdisplay(fd_cycles, "Test Vector   2: %0d cycles (%.2f us @ 100MHz)", test_cycles, test_cycles * 0.01);
            
            // Write outputs
            $fdisplay(fd_output, "%015b %015b", h_t[0], h_t[1]);
        end else begin
            $display("Stopping simulation due to timeout on test 2");
        end
        
        repeat(5) @(posedge clk); // Wait between tests
    end

    // Test Vector 3
    if (!test_timeout) begin
        test_start_cycle = cycle_count;
        
        // Load input data
        x_t[0] = 15'b000001111110111;
        x_t[1] = 15'b000010000110000;
        x_t[2] = 15'b000010000001001;
        x_t[3] = 15'b000001111111100;
        
        h_t_prev[0] = 15'b000001111110111;
        h_t_prev[1] = 15'b000010000110000;
        
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        // Wait for completion with timeout
        fork
            begin
                wait(done);
                test_cycles = cycle_count - test_start_cycle;
            end
            begin
                repeat(200000) @(posedge clk);
                $display("ERROR: Test 3 timeout!");
                $fdisplay(fd_cycles, "Test Vector   3: TIMEOUT");
                test_cycles = -1;
                test_timeout = 1;
            end
        join_any
        disable fork;
        
        if (test_cycles > 0) begin
            repeat(5) @(posedge clk); // Extra cycles for stability
            total_cycles = total_cycles + test_cycles;
            $fdisplay(fd_cycles, "Test Vector   3: %0d cycles (%.2f us @ 100MHz)", test_cycles, test_cycles * 0.01);
            
            // Write outputs
            $fdisplay(fd_output, "%015b %015b", h_t[0], h_t[1]);
        end else begin
            $display("Stopping simulation due to timeout on test 3");
        end
        
        repeat(5) @(posedge clk); // Wait between tests
    end

    // Test Vector 4
    if (!test_timeout) begin
        test_start_cycle = cycle_count;
        
        // Load input data
        x_t[0] = 15'b000001011001111;
        x_t[1] = 15'b000001011110111;
        x_t[2] = 15'b000001101000110;
        x_t[3] = 15'b000001110011011;
        
        h_t_prev[0] = 15'b000001011001111;
        h_t_prev[1] = 15'b000001011110111;
        
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        // Wait for completion with timeout
        fork
            begin
                wait(done);
                test_cycles = cycle_count - test_start_cycle;
            end
            begin
                repeat(200000) @(posedge clk);
                $display("ERROR: Test 4 timeout!");
                $fdisplay(fd_cycles, "Test Vector   4: TIMEOUT");
                test_cycles = -1;
                test_timeout = 1;
            end
        join_any
        disable fork;
        
        if (test_cycles > 0) begin
            repeat(5) @(posedge clk); // Extra cycles for stability
            total_cycles = total_cycles + test_cycles;
            $fdisplay(fd_cycles, "Test Vector   4: %0d cycles (%.2f us @ 100MHz)", test_cycles, test_cycles * 0.01);
            
            // Write outputs
            $fdisplay(fd_output, "%015b %015b", h_t[0], h_t[1]);
        end else begin
            $display("Stopping simulation due to timeout on test 4");
        end
        
        repeat(5) @(posedge clk); // Wait between tests
    end

    // Test Vector 5
    if (!test_timeout) begin
        test_start_cycle = cycle_count;
        
        // Load input data
        x_t[0] = 15'b000000111000100;
        x_t[1] = 15'b000001001011010;
        x_t[2] = 15'b000001010011000;
        x_t[3] = 15'b000001100010100;
        
        h_t_prev[0] = 15'b000000111000100;
        h_t_prev[1] = 15'b000001001011010;
        
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        // Wait for completion with timeout
        fork
            begin
                wait(done);
                test_cycles = cycle_count - test_start_cycle;
            end
            begin
                repeat(200000) @(posedge clk);
                $display("ERROR: Test 5 timeout!");
                $fdisplay(fd_cycles, "Test Vector   5: TIMEOUT");
                test_cycles = -1;
                test_timeout = 1;
            end
        join_any
        disable fork;
        
        if (test_cycles > 0) begin
            repeat(5) @(posedge clk); // Extra cycles for stability
            total_cycles = total_cycles + test_cycles;
            $fdisplay(fd_cycles, "Test Vector   5: %0d cycles (%.2f us @ 100MHz)", test_cycles, test_cycles * 0.01);
            
            // Write outputs
            $fdisplay(fd_output, "%015b %015b", h_t[0], h_t[1]);
        end else begin
            $display("Stopping simulation due to timeout on test 5");
        end
        
        repeat(5) @(posedge clk); // Wait between tests
    end

    // Test Vector 6
    if (!test_timeout) begin
        test_start_cycle = cycle_count;
        
        // Load input data
        x_t[0] = 15'b000000100110000;
        x_t[1] = 15'b000000111101111;
        x_t[2] = 15'b000001001000000;
        x_t[3] = 15'b000001010111101;
        
        h_t_prev[0] = 15'b000000100110000;
        h_t_prev[1] = 15'b000000111101111;
        
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        // Wait for completion with timeout
        fork
            begin
                wait(done);
                test_cycles = cycle_count - test_start_cycle;
            end
            begin
                repeat(200000) @(posedge clk);
                $display("ERROR: Test 6 timeout!");
                $fdisplay(fd_cycles, "Test Vector   6: TIMEOUT");
                test_cycles = -1;
                test_timeout = 1;
            end
        join_any
        disable fork;
        
        if (test_cycles > 0) begin
            repeat(5) @(posedge clk); // Extra cycles for stability
            total_cycles = total_cycles + test_cycles;
            $fdisplay(fd_cycles, "Test Vector   6: %0d cycles (%.2f us @ 100MHz)", test_cycles, test_cycles * 0.01);
            
            // Write outputs
            $fdisplay(fd_output, "%015b %015b", h_t[0], h_t[1]);
        end else begin
            $display("Stopping simulation due to timeout on test 6");
        end
        
        repeat(5) @(posedge clk); // Wait between tests
    end

    // Test Vector 7
    if (!test_timeout) begin
        test_start_cycle = cycle_count;
        
        // Load input data
        x_t[0] = 15'b000000110001001;
        x_t[1] = 15'b000001001010000;
        x_t[2] = 15'b000001010111111;
        x_t[3] = 15'b000001101001110;
        
        h_t_prev[0] = 15'b000000110001001;
        h_t_prev[1] = 15'b000001001010000;
        
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        // Wait for completion with timeout
        fork
            begin
                wait(done);
                test_cycles = cycle_count - test_start_cycle;
            end
            begin
                repeat(200000) @(posedge clk);
                $display("ERROR: Test 7 timeout!");
                $fdisplay(fd_cycles, "Test Vector   7: TIMEOUT");
                test_cycles = -1;
                test_timeout = 1;
            end
        join_any
        disable fork;
        
        if (test_cycles > 0) begin
            repeat(5) @(posedge clk); // Extra cycles for stability
            total_cycles = total_cycles + test_cycles;
            $fdisplay(fd_cycles, "Test Vector   7: %0d cycles (%.2f us @ 100MHz)", test_cycles, test_cycles * 0.01);
            
            // Write outputs
            $fdisplay(fd_output, "%015b %015b", h_t[0], h_t[1]);
        end else begin
            $display("Stopping simulation due to timeout on test 7");
        end
        
        repeat(5) @(posedge clk); // Wait between tests
    end

    // Test Vector 8
    if (!test_timeout) begin
        test_start_cycle = cycle_count;
        
        // Load input data
        x_t[0] = 15'b000000110001001;
        x_t[1] = 15'b000001000101001;
        x_t[2] = 15'b000001010011000;
        x_t[3] = 15'b000001101011000;
        
        h_t_prev[0] = 15'b000000110001001;
        h_t_prev[1] = 15'b000001000101001;
        
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        // Wait for completion with timeout
        fork
            begin
                wait(done);
                test_cycles = cycle_count - test_start_cycle;
            end
            begin
                repeat(200000) @(posedge clk);
                $display("ERROR: Test 8 timeout!");
                $fdisplay(fd_cycles, "Test Vector   8: TIMEOUT");
                test_cycles = -1;
                test_timeout = 1;
            end
        join_any
        disable fork;
        
        if (test_cycles > 0) begin
            repeat(5) @(posedge clk); // Extra cycles for stability
            total_cycles = total_cycles + test_cycles;
            $fdisplay(fd_cycles, "Test Vector   8: %0d cycles (%.2f us @ 100MHz)", test_cycles, test_cycles * 0.01);
            
            // Write outputs
            $fdisplay(fd_output, "%015b %015b", h_t[0], h_t[1]);
        end else begin
            $display("Stopping simulation due to timeout on test 8");
        end
        
        repeat(5) @(posedge clk); // Wait between tests
    end

    // Test Vector 9
    if (!test_timeout) begin
        test_start_cycle = cycle_count;
        
        // Load input data
        x_t[0] = 15'b000000101110101;
        x_t[1] = 15'b000000111011011;
        x_t[2] = 15'b000001001011101;
        x_t[3] = 15'b000001011110111;
        
        h_t_prev[0] = 15'b000000101110101;
        h_t_prev[1] = 15'b000000111011011;
        
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        // Wait for completion with timeout
        fork
            begin
                wait(done);
                test_cycles = cycle_count - test_start_cycle;
            end
            begin
                repeat(200000) @(posedge clk);
                $display("ERROR: Test 9 timeout!");
                $fdisplay(fd_cycles, "Test Vector   9: TIMEOUT");
                test_cycles = -1;
                test_timeout = 1;
            end
        join_any
        disable fork;
        
        if (test_cycles > 0) begin
            repeat(5) @(posedge clk); // Extra cycles for stability
            total_cycles = total_cycles + test_cycles;
            $fdisplay(fd_cycles, "Test Vector   9: %0d cycles (%.2f us @ 100MHz)", test_cycles, test_cycles * 0.01);
            
            // Write outputs
            $fdisplay(fd_output, "%015b %015b", h_t[0], h_t[1]);
        end else begin
            $display("Stopping simulation due to timeout on test 9");
        end
        
        repeat(5) @(posedge clk); // Wait between tests
    end

    // Test Vector 10
    if (!test_timeout) begin
        test_start_cycle = cycle_count;
        
        // Load input data
        x_t[0] = 15'b000000100010011;
        x_t[1] = 15'b000000100110101;
        x_t[2] = 15'b000000110011011;
        x_t[3] = 15'b000001000100010;
        
        h_t_prev[0] = 15'b000000100010011;
        h_t_prev[1] = 15'b000000100110101;
        
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        // Wait for completion with timeout
        fork
            begin
                wait(done);
                test_cycles = cycle_count - test_start_cycle;
            end
            begin
                repeat(200000) @(posedge clk);
                $display("ERROR: Test 10 timeout!");
                $fdisplay(fd_cycles, "Test Vector  10: TIMEOUT");
                test_cycles = -1;
                test_timeout = 1;
            end
        join_any
        disable fork;
        
        if (test_cycles > 0) begin
            repeat(5) @(posedge clk); // Extra cycles for stability
            total_cycles = total_cycles + test_cycles;
            $fdisplay(fd_cycles, "Test Vector  10: %0d cycles (%.2f us @ 100MHz)", test_cycles, test_cycles * 0.01);
            
            // Write outputs
            $fdisplay(fd_output, "%015b %015b", h_t[0], h_t[1]);
        end else begin
            $display("Stopping simulation due to timeout on test 10");
        end
        
        repeat(5) @(posedge clk); // Wait between tests
    end

    // Test Vector 11
    if (!test_timeout) begin
        test_start_cycle = cycle_count;
        
        // Load input data
        x_t[0] = 15'b000000001100001;
        x_t[1] = 15'b000000001110001;
        x_t[2] = 15'b000000010101000;
        x_t[3] = 15'b000000100001010;
        
        h_t_prev[0] = 15'b000000001100001;
        h_t_prev[1] = 15'b000000001110001;
        
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        // Wait for completion with timeout
        fork
            begin
                wait(done);
                test_cycles = cycle_count - test_start_cycle;
            end
            begin
                repeat(200000) @(posedge clk);
                $display("ERROR: Test 11 timeout!");
                $fdisplay(fd_cycles, "Test Vector  11: TIMEOUT");
                test_cycles = -1;
                test_timeout = 1;
            end
        join_any
        disable fork;
        
        if (test_cycles > 0) begin
            repeat(5) @(posedge clk); // Extra cycles for stability
            total_cycles = total_cycles + test_cycles;
            $fdisplay(fd_cycles, "Test Vector  11: %0d cycles (%.2f us @ 100MHz)", test_cycles, test_cycles * 0.01);
            
            // Write outputs
            $fdisplay(fd_output, "%015b %015b", h_t[0], h_t[1]);
        end else begin
            $display("Stopping simulation due to timeout on test 11");
        end
        
        repeat(5) @(posedge clk); // Wait between tests
    end

    // Test Vector 12
    if (!test_timeout) begin
        test_start_cycle = cycle_count;
        
        // Load input data
        x_t[0] = 15'b000000101001110;
        x_t[1] = 15'b000000100000100;
        x_t[2] = 15'b000000100000000;
        x_t[3] = 15'b000000100001010;
        
        h_t_prev[0] = 15'b000000101001110;
        h_t_prev[1] = 15'b000000100000100;
        
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        // Wait for completion with timeout
        fork
            begin
                wait(done);
                test_cycles = cycle_count - test_start_cycle;
            end
            begin
                repeat(200000) @(posedge clk);
                $display("ERROR: Test 12 timeout!");
                $fdisplay(fd_cycles, "Test Vector  12: TIMEOUT");
                test_cycles = -1;
                test_timeout = 1;
            end
        join_any
        disable fork;
        
        if (test_cycles > 0) begin
            repeat(5) @(posedge clk); // Extra cycles for stability
            total_cycles = total_cycles + test_cycles;
            $fdisplay(fd_cycles, "Test Vector  12: %0d cycles (%.2f us @ 100MHz)", test_cycles, test_cycles * 0.01);
            
            // Write outputs
            $fdisplay(fd_output, "%015b %015b", h_t[0], h_t[1]);
        end else begin
            $display("Stopping simulation due to timeout on test 12");
        end
        
        repeat(5) @(posedge clk); // Wait between tests
    end

    // Test Vector 13
    if (!test_timeout) begin
        test_start_cycle = cycle_count;
        
        // Load input data
        x_t[0] = 15'b000000101011000;
        x_t[1] = 15'b000000100100001;
        x_t[2] = 15'b000000100010011;
        x_t[3] = 15'b000000100011101;
        
        h_t_prev[0] = 15'b000000101011000;
        h_t_prev[1] = 15'b000000100100001;
        
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        // Wait for completion with timeout
        fork
            begin
                wait(done);
                test_cycles = cycle_count - test_start_cycle;
            end
            begin
                repeat(200000) @(posedge clk);
                $display("ERROR: Test 13 timeout!");
                $fdisplay(fd_cycles, "Test Vector  13: TIMEOUT");
                test_cycles = -1;
                test_timeout = 1;
            end
        join_any
        disable fork;
        
        if (test_cycles > 0) begin
            repeat(5) @(posedge clk); // Extra cycles for stability
            total_cycles = total_cycles + test_cycles;
            $fdisplay(fd_cycles, "Test Vector  13: %0d cycles (%.2f us @ 100MHz)", test_cycles, test_cycles * 0.01);
            
            // Write outputs
            $fdisplay(fd_output, "%015b %015b", h_t[0], h_t[1]);
        end else begin
            $display("Stopping simulation due to timeout on test 13");
        end
        
        repeat(5) @(posedge clk); // Wait between tests
    end

    // Test Vector 14
    if (!test_timeout) begin
        test_start_cycle = cycle_count;
        
        // Load input data
        x_t[0] = 15'b000000011110101;
        x_t[1] = 15'b000000001011101;
        x_t[2] = 15'b000000010000010;
        x_t[3] = 15'b000000011010000;
        
        h_t_prev[0] = 15'b000000011110101;
        h_t_prev[1] = 15'b000000001011101;
        
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        // Wait for completion with timeout
        fork
            begin
                wait(done);
                test_cycles = cycle_count - test_start_cycle;
            end
            begin
                repeat(200000) @(posedge clk);
                $display("ERROR: Test 14 timeout!");
                $fdisplay(fd_cycles, "Test Vector  14: TIMEOUT");
                test_cycles = -1;
                test_timeout = 1;
            end
        join_any
        disable fork;
        
        if (test_cycles > 0) begin
            repeat(5) @(posedge clk); // Extra cycles for stability
            total_cycles = total_cycles + test_cycles;
            $fdisplay(fd_cycles, "Test Vector  14: %0d cycles (%.2f us @ 100MHz)", test_cycles, test_cycles * 0.01);
            
            // Write outputs
            $fdisplay(fd_output, "%015b %015b", h_t[0], h_t[1]);
        end else begin
            $display("Stopping simulation due to timeout on test 14");
        end
        
        repeat(5) @(posedge clk); // Wait between tests
    end

    // Test Vector 15
    if (!test_timeout) begin
        test_start_cycle = cycle_count;
        
        // Load input data
        x_t[0] = 15'b000000100111010;
        x_t[1] = 15'b000000010110101;
        x_t[2] = 15'b000000010110010;
        x_t[3] = 15'b000000011011001;
        
        h_t_prev[0] = 15'b000000100111010;
        h_t_prev[1] = 15'b000000010110101;
        
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        // Wait for completion with timeout
        fork
            begin
                wait(done);
                test_cycles = cycle_count - test_start_cycle;
            end
            begin
                repeat(200000) @(posedge clk);
                $display("ERROR: Test 15 timeout!");
                $fdisplay(fd_cycles, "Test Vector  15: TIMEOUT");
                test_cycles = -1;
                test_timeout = 1;
            end
        join_any
        disable fork;
        
        if (test_cycles > 0) begin
            repeat(5) @(posedge clk); // Extra cycles for stability
            total_cycles = total_cycles + test_cycles;
            $fdisplay(fd_cycles, "Test Vector  15: %0d cycles (%.2f us @ 100MHz)", test_cycles, test_cycles * 0.01);
            
            // Write outputs
            $fdisplay(fd_output, "%015b %015b", h_t[0], h_t[1]);
        end else begin
            $display("Stopping simulation due to timeout on test 15");
        end
        
        repeat(5) @(posedge clk); // Wait between tests
    end

    // Test Vector 16
    if (!test_timeout) begin
        test_start_cycle = cycle_count;
        
        // Load input data
        x_t[0] = 15'b000000110100111;
        x_t[1] = 15'b000000110010110;
        x_t[2] = 15'b000000110111000;
        x_t[3] = 15'b000000111111011;
        
        h_t_prev[0] = 15'b000000110100111;
        h_t_prev[1] = 15'b000000110010110;
        
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        // Wait for completion with timeout
        fork
            begin
                wait(done);
                test_cycles = cycle_count - test_start_cycle;
            end
            begin
                repeat(200000) @(posedge clk);
                $display("ERROR: Test 16 timeout!");
                $fdisplay(fd_cycles, "Test Vector  16: TIMEOUT");
                test_cycles = -1;
                test_timeout = 1;
            end
        join_any
        disable fork;
        
        if (test_cycles > 0) begin
            repeat(5) @(posedge clk); // Extra cycles for stability
            total_cycles = total_cycles + test_cycles;
            $fdisplay(fd_cycles, "Test Vector  16: %0d cycles (%.2f us @ 100MHz)", test_cycles, test_cycles * 0.01);
            
            // Write outputs
            $fdisplay(fd_output, "%015b %015b", h_t[0], h_t[1]);
        end else begin
            $display("Stopping simulation due to timeout on test 16");
        end
        
        repeat(5) @(posedge clk); // Wait between tests
    end

    // Test Vector 17
    if (!test_timeout) begin
        test_start_cycle = cycle_count;
        
        // Load input data
        x_t[0] = 15'b000000001001101;
        x_t[1] = 15'b000000001110001;
        x_t[2] = 15'b111111001111111;
        x_t[3] = 15'b111111100000000;
        
        h_t_prev[0] = 15'b000000001001101;
        h_t_prev[1] = 15'b000000001110001;
        
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        // Wait for completion with timeout
        fork
            begin
                wait(done);
                test_cycles = cycle_count - test_start_cycle;
            end
            begin
                repeat(200000) @(posedge clk);
                $display("ERROR: Test 17 timeout!");
                $fdisplay(fd_cycles, "Test Vector  17: TIMEOUT");
                test_cycles = -1;
                test_timeout = 1;
            end
        join_any
        disable fork;
        
        if (test_cycles > 0) begin
            repeat(5) @(posedge clk); // Extra cycles for stability
            total_cycles = total_cycles + test_cycles;
            $fdisplay(fd_cycles, "Test Vector  17: %0d cycles (%.2f us @ 100MHz)", test_cycles, test_cycles * 0.01);
            
            // Write outputs
            $fdisplay(fd_output, "%015b %015b", h_t[0], h_t[1]);
        end else begin
            $display("Stopping simulation due to timeout on test 17");
        end
        
        repeat(5) @(posedge clk); // Wait between tests
    end

    // Test Vector 18
    if (!test_timeout) begin
        test_start_cycle = cycle_count;
        
        // Load input data
        x_t[0] = 15'b000000101001110;
        x_t[1] = 15'b000000110000011;
        x_t[2] = 15'b000000000000011;
        x_t[3] = 15'b000000001010010;
        
        h_t_prev[0] = 15'b000000101001110;
        h_t_prev[1] = 15'b000000110000011;
        
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        // Wait for completion with timeout
        fork
            begin
                wait(done);
                test_cycles = cycle_count - test_start_cycle;
            end
            begin
                repeat(200000) @(posedge clk);
                $display("ERROR: Test 18 timeout!");
                $fdisplay(fd_cycles, "Test Vector  18: TIMEOUT");
                test_cycles = -1;
                test_timeout = 1;
            end
        join_any
        disable fork;
        
        if (test_cycles > 0) begin
            repeat(5) @(posedge clk); // Extra cycles for stability
            total_cycles = total_cycles + test_cycles;
            $fdisplay(fd_cycles, "Test Vector  18: %0d cycles (%.2f us @ 100MHz)", test_cycles, test_cycles * 0.01);
            
            // Write outputs
            $fdisplay(fd_output, "%015b %015b", h_t[0], h_t[1]);
        end else begin
            $display("Stopping simulation due to timeout on test 18");
        end
        
        repeat(5) @(posedge clk); // Wait between tests
    end

    // Test Vector 19
    if (!test_timeout) begin
        test_start_cycle = cycle_count;
        
        // Load input data
        x_t[0] = 15'b000001001001110;
        x_t[1] = 15'b000001000010110;
        x_t[2] = 15'b000000010011111;
        x_t[3] = 15'b000000010110011;
        
        h_t_prev[0] = 15'b000001001001110;
        h_t_prev[1] = 15'b000001000010110;
        
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        // Wait for completion with timeout
        fork
            begin
                wait(done);
                test_cycles = cycle_count - test_start_cycle;
            end
            begin
                repeat(200000) @(posedge clk);
                $display("ERROR: Test 19 timeout!");
                $fdisplay(fd_cycles, "Test Vector  19: TIMEOUT");
                test_cycles = -1;
                test_timeout = 1;
            end
        join_any
        disable fork;
        
        if (test_cycles > 0) begin
            repeat(5) @(posedge clk); // Extra cycles for stability
            total_cycles = total_cycles + test_cycles;
            $fdisplay(fd_cycles, "Test Vector  19: %0d cycles (%.2f us @ 100MHz)", test_cycles, test_cycles * 0.01);
            
            // Write outputs
            $fdisplay(fd_output, "%015b %015b", h_t[0], h_t[1]);
        end else begin
            $display("Stopping simulation due to timeout on test 19");
        end
        
        repeat(5) @(posedge clk); // Wait between tests
    end

    // Test Vector 20
    if (!test_timeout) begin
        test_start_cycle = cycle_count;
        
        // Load input data
        x_t[0] = 15'b000001110010100;
        x_t[1] = 15'b000001101011001;
        x_t[2] = 15'b000000111101001;
        x_t[3] = 15'b000000111000001;
        
        h_t_prev[0] = 15'b000001110010100;
        h_t_prev[1] = 15'b000001101011001;
        
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        // Wait for completion with timeout
        fork
            begin
                wait(done);
                test_cycles = cycle_count - test_start_cycle;
            end
            begin
                repeat(200000) @(posedge clk);
                $display("ERROR: Test 20 timeout!");
                $fdisplay(fd_cycles, "Test Vector  20: TIMEOUT");
                test_cycles = -1;
                test_timeout = 1;
            end
        join_any
        disable fork;
        
        if (test_cycles > 0) begin
            repeat(5) @(posedge clk); // Extra cycles for stability
            total_cycles = total_cycles + test_cycles;
            $fdisplay(fd_cycles, "Test Vector  20: %0d cycles (%.2f us @ 100MHz)", test_cycles, test_cycles * 0.01);
            
            // Write outputs
            $fdisplay(fd_output, "%015b %015b", h_t[0], h_t[1]);
        end else begin
            $display("Stopping simulation due to timeout on test 20");
        end
        
        repeat(5) @(posedge clk); // Wait between tests
    end

    // Test Vector 21
    if (!test_timeout) begin
        test_start_cycle = cycle_count;
        
        // Load input data
        x_t[0] = 15'b000000101110101;
        x_t[1] = 15'b000000110010110;
        x_t[2] = 15'b000000010000010;
        x_t[3] = 15'b000000010001100;
        
        h_t_prev[0] = 15'b000000101110101;
        h_t_prev[1] = 15'b000000110010110;
        
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        // Wait for completion with timeout
        fork
            begin
                wait(done);
                test_cycles = cycle_count - test_start_cycle;
            end
            begin
                repeat(200000) @(posedge clk);
                $display("ERROR: Test 21 timeout!");
                $fdisplay(fd_cycles, "Test Vector  21: TIMEOUT");
                test_cycles = -1;
                test_timeout = 1;
            end
        join_any
        disable fork;
        
        if (test_cycles > 0) begin
            repeat(5) @(posedge clk); // Extra cycles for stability
            total_cycles = total_cycles + test_cycles;
            $fdisplay(fd_cycles, "Test Vector  21: %0d cycles (%.2f us @ 100MHz)", test_cycles, test_cycles * 0.01);
            
            // Write outputs
            $fdisplay(fd_output, "%015b %015b", h_t[0], h_t[1]);
        end else begin
            $display("Stopping simulation due to timeout on test 21");
        end
        
        repeat(5) @(posedge clk); // Wait between tests
    end

    // Test Vector 22
    if (!test_timeout) begin
        test_start_cycle = cycle_count;
        
        // Load input data
        x_t[0] = 15'b000000001100001;
        x_t[1] = 15'b000000010110101;
        x_t[2] = 15'b111111111010011;
        x_t[3] = 15'b000000000100010;
        
        h_t_prev[0] = 15'b000000001100001;
        h_t_prev[1] = 15'b000000010110101;
        
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        // Wait for completion with timeout
        fork
            begin
                wait(done);
                test_cycles = cycle_count - test_start_cycle;
            end
            begin
                repeat(200000) @(posedge clk);
                $display("ERROR: Test 22 timeout!");
                $fdisplay(fd_cycles, "Test Vector  22: TIMEOUT");
                test_cycles = -1;
                test_timeout = 1;
            end
        join_any
        disable fork;
        
        if (test_cycles > 0) begin
            repeat(5) @(posedge clk); // Extra cycles for stability
            total_cycles = total_cycles + test_cycles;
            $fdisplay(fd_cycles, "Test Vector  22: %0d cycles (%.2f us @ 100MHz)", test_cycles, test_cycles * 0.01);
            
            // Write outputs
            $fdisplay(fd_output, "%015b %015b", h_t[0], h_t[1]);
        end else begin
            $display("Stopping simulation due to timeout on test 22");
        end
        
        repeat(5) @(posedge clk); // Wait between tests
    end

    // Test Vector 23
    if (!test_timeout) begin
        test_start_cycle = cycle_count;
        
        // Load input data
        x_t[0] = 15'b000001001100010;
        x_t[1] = 15'b000001000010110;
        x_t[2] = 15'b000000010110010;
        x_t[3] = 15'b000000100001010;
        
        h_t_prev[0] = 15'b000001001100010;
        h_t_prev[1] = 15'b000001000010110;
        
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        // Wait for completion with timeout
        fork
            begin
                wait(done);
                test_cycles = cycle_count - test_start_cycle;
            end
            begin
                repeat(200000) @(posedge clk);
                $display("ERROR: Test 23 timeout!");
                $fdisplay(fd_cycles, "Test Vector  23: TIMEOUT");
                test_cycles = -1;
                test_timeout = 1;
            end
        join_any
        disable fork;
        
        if (test_cycles > 0) begin
            repeat(5) @(posedge clk); // Extra cycles for stability
            total_cycles = total_cycles + test_cycles;
            $fdisplay(fd_cycles, "Test Vector  23: %0d cycles (%.2f us @ 100MHz)", test_cycles, test_cycles * 0.01);
            
            // Write outputs
            $fdisplay(fd_output, "%015b %015b", h_t[0], h_t[1]);
        end else begin
            $display("Stopping simulation due to timeout on test 23");
        end
        
        repeat(5) @(posedge clk); // Wait between tests
    end

    // Test Vector 24
    if (!test_timeout) begin
        test_start_cycle = cycle_count;
        
        // Load input data
        x_t[0] = 15'b000000010001001;
        x_t[1] = 15'b000000011011100;
        x_t[2] = 15'b111111111110000;
        x_t[3] = 15'b000000001101111;
        
        h_t_prev[0] = 15'b000000010001001;
        h_t_prev[1] = 15'b000000011011100;
        
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        // Wait for completion with timeout
        fork
            begin
                wait(done);
                test_cycles = cycle_count - test_start_cycle;
            end
            begin
                repeat(200000) @(posedge clk);
                $display("ERROR: Test 24 timeout!");
                $fdisplay(fd_cycles, "Test Vector  24: TIMEOUT");
                test_cycles = -1;
                test_timeout = 1;
            end
        join_any
        disable fork;
        
        if (test_cycles > 0) begin
            repeat(5) @(posedge clk); // Extra cycles for stability
            total_cycles = total_cycles + test_cycles;
            $fdisplay(fd_cycles, "Test Vector  24: %0d cycles (%.2f us @ 100MHz)", test_cycles, test_cycles * 0.01);
            
            // Write outputs
            $fdisplay(fd_output, "%015b %015b", h_t[0], h_t[1]);
        end else begin
            $display("Stopping simulation due to timeout on test 24");
        end
        
        repeat(5) @(posedge clk); // Wait between tests
    end

    // Test Vector 25
    if (!test_timeout) begin
        test_start_cycle = cycle_count;
        
        // Load input data
        x_t[0] = 15'b000000010010011;
        x_t[1] = 15'b000000100100001;
        x_t[2] = 15'b000000000111110;
        x_t[3] = 15'b000000010011111;
        
        h_t_prev[0] = 15'b000000010010011;
        h_t_prev[1] = 15'b000000100100001;
        
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        // Wait for completion with timeout
        fork
            begin
                wait(done);
                test_cycles = cycle_count - test_start_cycle;
            end
            begin
                repeat(200000) @(posedge clk);
                $display("ERROR: Test 25 timeout!");
                $fdisplay(fd_cycles, "Test Vector  25: TIMEOUT");
                test_cycles = -1;
                test_timeout = 1;
            end
        join_any
        disable fork;
        
        if (test_cycles > 0) begin
            repeat(5) @(posedge clk); // Extra cycles for stability
            total_cycles = total_cycles + test_cycles;
            $fdisplay(fd_cycles, "Test Vector  25: %0d cycles (%.2f us @ 100MHz)", test_cycles, test_cycles * 0.01);
            
            // Write outputs
            $fdisplay(fd_output, "%015b %015b", h_t[0], h_t[1]);
        end else begin
            $display("Stopping simulation due to timeout on test 25");
        end
        
        repeat(5) @(posedge clk); // Wait between tests
    end

    // Test Vector 26
    if (!test_timeout) begin
        test_start_cycle = cycle_count;
        
        // Load input data
        x_t[0] = 15'b000000010100110;
        x_t[1] = 15'b000000110001101;
        x_t[2] = 15'b000000011100011;
        x_t[3] = 15'b000000101100001;
        
        h_t_prev[0] = 15'b000000010100110;
        h_t_prev[1] = 15'b000000110001101;
        
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        // Wait for completion with timeout
        fork
            begin
                wait(done);
                test_cycles = cycle_count - test_start_cycle;
            end
            begin
                repeat(200000) @(posedge clk);
                $display("ERROR: Test 26 timeout!");
                $fdisplay(fd_cycles, "Test Vector  26: TIMEOUT");
                test_cycles = -1;
                test_timeout = 1;
            end
        join_any
        disable fork;
        
        if (test_cycles > 0) begin
            repeat(5) @(posedge clk); // Extra cycles for stability
            total_cycles = total_cycles + test_cycles;
            $fdisplay(fd_cycles, "Test Vector  26: %0d cycles (%.2f us @ 100MHz)", test_cycles, test_cycles * 0.01);
            
            // Write outputs
            $fdisplay(fd_output, "%015b %015b", h_t[0], h_t[1]);
        end else begin
            $display("Stopping simulation due to timeout on test 26");
        end
        
        repeat(5) @(posedge clk); // Wait between tests
    end

    // Test Vector 27
    if (!test_timeout) begin
        test_start_cycle = cycle_count;
        
        // Load input data
        x_t[0] = 15'b111111110011100;
        x_t[1] = 15'b000000001011101;
        x_t[2] = 15'b000000000001101;
        x_t[3] = 15'b000000010010110;
        
        h_t_prev[0] = 15'b111111110011100;
        h_t_prev[1] = 15'b000000001011101;
        
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        // Wait for completion with timeout
        fork
            begin
                wait(done);
                test_cycles = cycle_count - test_start_cycle;
            end
            begin
                repeat(200000) @(posedge clk);
                $display("ERROR: Test 27 timeout!");
                $fdisplay(fd_cycles, "Test Vector  27: TIMEOUT");
                test_cycles = -1;
                test_timeout = 1;
            end
        join_any
        disable fork;
        
        if (test_cycles > 0) begin
            repeat(5) @(posedge clk); // Extra cycles for stability
            total_cycles = total_cycles + test_cycles;
            $fdisplay(fd_cycles, "Test Vector  27: %0d cycles (%.2f us @ 100MHz)", test_cycles, test_cycles * 0.01);
            
            // Write outputs
            $fdisplay(fd_output, "%015b %015b", h_t[0], h_t[1]);
        end else begin
            $display("Stopping simulation due to timeout on test 27");
        end
        
        repeat(5) @(posedge clk); // Wait between tests
    end

    // Test Vector 28
    if (!test_timeout) begin
        test_start_cycle = cycle_count;
        
        // Load input data
        x_t[0] = 15'b000000010001001;
        x_t[1] = 15'b000000010001110;
        x_t[2] = 15'b111111111100110;
        x_t[3] = 15'b000000000001110;
        
        h_t_prev[0] = 15'b000000010001001;
        h_t_prev[1] = 15'b000000010001110;
        
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        // Wait for completion with timeout
        fork
            begin
                wait(done);
                test_cycles = cycle_count - test_start_cycle;
            end
            begin
                repeat(200000) @(posedge clk);
                $display("ERROR: Test 28 timeout!");
                $fdisplay(fd_cycles, "Test Vector  28: TIMEOUT");
                test_cycles = -1;
                test_timeout = 1;
            end
        join_any
        disable fork;
        
        if (test_cycles > 0) begin
            repeat(5) @(posedge clk); // Extra cycles for stability
            total_cycles = total_cycles + test_cycles;
            $fdisplay(fd_cycles, "Test Vector  28: %0d cycles (%.2f us @ 100MHz)", test_cycles, test_cycles * 0.01);
            
            // Write outputs
            $fdisplay(fd_output, "%015b %015b", h_t[0], h_t[1]);
        end else begin
            $display("Stopping simulation due to timeout on test 28");
        end
        
        repeat(5) @(posedge clk); // Wait between tests
    end

    // Test Vector 29
    if (!test_timeout) begin
        test_start_cycle = cycle_count;
        
        // Load input data
        x_t[0] = 15'b000000010100110;
        x_t[1] = 15'b000000010100010;
        x_t[2] = 15'b111111110110110;
        x_t[3] = 15'b111111111001011;
        
        h_t_prev[0] = 15'b000000010100110;
        h_t_prev[1] = 15'b000000010100010;
        
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        // Wait for completion with timeout
        fork
            begin
                wait(done);
                test_cycles = cycle_count - test_start_cycle;
            end
            begin
                repeat(200000) @(posedge clk);
                $display("ERROR: Test 29 timeout!");
                $fdisplay(fd_cycles, "Test Vector  29: TIMEOUT");
                test_cycles = -1;
                test_timeout = 1;
            end
        join_any
        disable fork;
        
        if (test_cycles > 0) begin
            repeat(5) @(posedge clk); // Extra cycles for stability
            total_cycles = total_cycles + test_cycles;
            $fdisplay(fd_cycles, "Test Vector  29: %0d cycles (%.2f us @ 100MHz)", test_cycles, test_cycles * 0.01);
            
            // Write outputs
            $fdisplay(fd_output, "%015b %015b", h_t[0], h_t[1]);
        end else begin
            $display("Stopping simulation due to timeout on test 29");
        end
        
        repeat(5) @(posedge clk); // Wait between tests
    end

    // Test Vector 30
    if (!test_timeout) begin
        test_start_cycle = cycle_count;
        
        // Load input data
        x_t[0] = 15'b000000101111111;
        x_t[1] = 15'b000000111000111;
        x_t[2] = 15'b000000011001111;
        x_t[3] = 15'b000000011110110;
        
        h_t_prev[0] = 15'b000000101111111;
        h_t_prev[1] = 15'b000000111000111;
        
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        // Wait for completion with timeout
        fork
            begin
                wait(done);
                test_cycles = cycle_count - test_start_cycle;
            end
            begin
                repeat(200000) @(posedge clk);
                $display("ERROR: Test 30 timeout!");
                $fdisplay(fd_cycles, "Test Vector  30: TIMEOUT");
                test_cycles = -1;
                test_timeout = 1;
            end
        join_any
        disable fork;
        
        if (test_cycles > 0) begin
            repeat(5) @(posedge clk); // Extra cycles for stability
            total_cycles = total_cycles + test_cycles;
            $fdisplay(fd_cycles, "Test Vector  30: %0d cycles (%.2f us @ 100MHz)", test_cycles, test_cycles * 0.01);
            
            // Write outputs
            $fdisplay(fd_output, "%015b %015b", h_t[0], h_t[1]);
        end else begin
            $display("Stopping simulation due to timeout on test 30");
        end
        
        repeat(5) @(posedge clk); // Wait between tests
    end

    // Test Vector 31
    if (!test_timeout) begin
        test_start_cycle = cycle_count;
        
        // Load input data
        x_t[0] = 15'b000000111110110;
        x_t[1] = 15'b000001000000010;
        x_t[2] = 15'b000000011100011;
        x_t[3] = 15'b000000101101010;
        
        h_t_prev[0] = 15'b000000111110110;
        h_t_prev[1] = 15'b000001000000010;
        
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        // Wait for completion with timeout
        fork
            begin
                wait(done);
                test_cycles = cycle_count - test_start_cycle;
            end
            begin
                repeat(200000) @(posedge clk);
                $display("ERROR: Test 31 timeout!");
                $fdisplay(fd_cycles, "Test Vector  31: TIMEOUT");
                test_cycles = -1;
                test_timeout = 1;
            end
        join_any
        disable fork;
        
        if (test_cycles > 0) begin
            repeat(5) @(posedge clk); // Extra cycles for stability
            total_cycles = total_cycles + test_cycles;
            $fdisplay(fd_cycles, "Test Vector  31: %0d cycles (%.2f us @ 100MHz)", test_cycles, test_cycles * 0.01);
            
            // Write outputs
            $fdisplay(fd_output, "%015b %015b", h_t[0], h_t[1]);
        end else begin
            $display("Stopping simulation due to timeout on test 31");
        end
        
        repeat(5) @(posedge clk); // Wait between tests
    end

    // Test Vector 32
    if (!test_timeout) begin
        test_start_cycle = cycle_count;
        
        // Load input data
        x_t[0] = 15'b000000011000100;
        x_t[1] = 15'b000000101001000;
        x_t[2] = 15'b111111111100110;
        x_t[3] = 15'b000000100100111;
        
        h_t_prev[0] = 15'b000000011000100;
        h_t_prev[1] = 15'b000000101001000;
        
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        // Wait for completion with timeout
        fork
            begin
                wait(done);
                test_cycles = cycle_count - test_start_cycle;
            end
            begin
                repeat(200000) @(posedge clk);
                $display("ERROR: Test 32 timeout!");
                $fdisplay(fd_cycles, "Test Vector  32: TIMEOUT");
                test_cycles = -1;
                test_timeout = 1;
            end
        join_any
        disable fork;
        
        if (test_cycles > 0) begin
            repeat(5) @(posedge clk); // Extra cycles for stability
            total_cycles = total_cycles + test_cycles;
            $fdisplay(fd_cycles, "Test Vector  32: %0d cycles (%.2f us @ 100MHz)", test_cycles, test_cycles * 0.01);
            
            // Write outputs
            $fdisplay(fd_output, "%015b %015b", h_t[0], h_t[1]);
        end else begin
            $display("Stopping simulation due to timeout on test 32");
        end
        
        repeat(5) @(posedge clk); // Wait between tests
    end

    // Test Vector 33
    if (!test_timeout) begin
        test_start_cycle = cycle_count;
        
        // Load input data
        x_t[0] = 15'b111111101010111;
        x_t[1] = 15'b111111101001011;
        x_t[2] = 15'b111111100000111;
        x_t[3] = 15'b111111100010011;
        
        h_t_prev[0] = 15'b111111101010111;
        h_t_prev[1] = 15'b111111101001011;
        
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        // Wait for completion with timeout
        fork
            begin
                wait(done);
                test_cycles = cycle_count - test_start_cycle;
            end
            begin
                repeat(200000) @(posedge clk);
                $display("ERROR: Test 33 timeout!");
                $fdisplay(fd_cycles, "Test Vector  33: TIMEOUT");
                test_cycles = -1;
                test_timeout = 1;
            end
        join_any
        disable fork;
        
        if (test_cycles > 0) begin
            repeat(5) @(posedge clk); // Extra cycles for stability
            total_cycles = total_cycles + test_cycles;
            $fdisplay(fd_cycles, "Test Vector  33: %0d cycles (%.2f us @ 100MHz)", test_cycles, test_cycles * 0.01);
            
            // Write outputs
            $fdisplay(fd_output, "%015b %015b", h_t[0], h_t[1]);
        end else begin
            $display("Stopping simulation due to timeout on test 33");
        end
        
        repeat(5) @(posedge clk); // Wait between tests
    end

    // Test Vector 34
    if (!test_timeout) begin
        test_start_cycle = cycle_count;
        
        // Load input data
        x_t[0] = 15'b111111000111001;
        x_t[1] = 15'b111111000111001;
        x_t[2] = 15'b111110111101101;
        x_t[3] = 15'b111110111010100;
        
        h_t_prev[0] = 15'b111111000111001;
        h_t_prev[1] = 15'b111111000111001;
        
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        // Wait for completion with timeout
        fork
            begin
                wait(done);
                test_cycles = cycle_count - test_start_cycle;
            end
            begin
                repeat(200000) @(posedge clk);
                $display("ERROR: Test 34 timeout!");
                $fdisplay(fd_cycles, "Test Vector  34: TIMEOUT");
                test_cycles = -1;
                test_timeout = 1;
            end
        join_any
        disable fork;
        
        if (test_cycles > 0) begin
            repeat(5) @(posedge clk); // Extra cycles for stability
            total_cycles = total_cycles + test_cycles;
            $fdisplay(fd_cycles, "Test Vector  34: %0d cycles (%.2f us @ 100MHz)", test_cycles, test_cycles * 0.01);
            
            // Write outputs
            $fdisplay(fd_output, "%015b %015b", h_t[0], h_t[1]);
        end else begin
            $display("Stopping simulation due to timeout on test 34");
        end
        
        repeat(5) @(posedge clk); // Wait between tests
    end

    // Test Vector 35
    if (!test_timeout) begin
        test_start_cycle = cycle_count;
        
        // Load input data
        x_t[0] = 15'b111111000011011;
        x_t[1] = 15'b111111000001000;
        x_t[2] = 15'b111110110110011;
        x_t[3] = 15'b111110111010100;
        
        h_t_prev[0] = 15'b111111000011011;
        h_t_prev[1] = 15'b111111000001000;
        
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        // Wait for completion with timeout
        fork
            begin
                wait(done);
                test_cycles = cycle_count - test_start_cycle;
            end
            begin
                repeat(200000) @(posedge clk);
                $display("ERROR: Test 35 timeout!");
                $fdisplay(fd_cycles, "Test Vector  35: TIMEOUT");
                test_cycles = -1;
                test_timeout = 1;
            end
        join_any
        disable fork;
        
        if (test_cycles > 0) begin
            repeat(5) @(posedge clk); // Extra cycles for stability
            total_cycles = total_cycles + test_cycles;
            $fdisplay(fd_cycles, "Test Vector  35: %0d cycles (%.2f us @ 100MHz)", test_cycles, test_cycles * 0.01);
            
            // Write outputs
            $fdisplay(fd_output, "%015b %015b", h_t[0], h_t[1]);
        end else begin
            $display("Stopping simulation due to timeout on test 35");
        end
        
        repeat(5) @(posedge clk); // Wait between tests
    end

    // Test Vector 36
    if (!test_timeout) begin
        test_start_cycle = cycle_count;
        
        // Load input data
        x_t[0] = 15'b111111011001101;
        x_t[1] = 15'b111111101010101;
        x_t[2] = 15'b111111100101110;
        x_t[3] = 15'b111111101000011;
        
        h_t_prev[0] = 15'b111111011001101;
        h_t_prev[1] = 15'b111111101010101;
        
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        // Wait for completion with timeout
        fork
            begin
                wait(done);
                test_cycles = cycle_count - test_start_cycle;
            end
            begin
                repeat(200000) @(posedge clk);
                $display("ERROR: Test 36 timeout!");
                $fdisplay(fd_cycles, "Test Vector  36: TIMEOUT");
                test_cycles = -1;
                test_timeout = 1;
            end
        join_any
        disable fork;
        
        if (test_cycles > 0) begin
            repeat(5) @(posedge clk); // Extra cycles for stability
            total_cycles = total_cycles + test_cycles;
            $fdisplay(fd_cycles, "Test Vector  36: %0d cycles (%.2f us @ 100MHz)", test_cycles, test_cycles * 0.01);
            
            // Write outputs
            $fdisplay(fd_output, "%015b %015b", h_t[0], h_t[1]);
        end else begin
            $display("Stopping simulation due to timeout on test 36");
        end
        
        repeat(5) @(posedge clk); // Wait between tests
    end

    // Test Vector 37
    if (!test_timeout) begin
        test_start_cycle = cycle_count;
        
        // Load input data
        x_t[0] = 15'b111111111000011;
        x_t[1] = 15'b000000001011101;
        x_t[2] = 15'b111111111110000;
        x_t[3] = 15'b111111111000001;
        
        h_t_prev[0] = 15'b111111111000011;
        h_t_prev[1] = 15'b000000001011101;
        
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        // Wait for completion with timeout
        fork
            begin
                wait(done);
                test_cycles = cycle_count - test_start_cycle;
            end
            begin
                repeat(200000) @(posedge clk);
                $display("ERROR: Test 37 timeout!");
                $fdisplay(fd_cycles, "Test Vector  37: TIMEOUT");
                test_cycles = -1;
                test_timeout = 1;
            end
        join_any
        disable fork;
        
        if (test_cycles > 0) begin
            repeat(5) @(posedge clk); // Extra cycles for stability
            total_cycles = total_cycles + test_cycles;
            $fdisplay(fd_cycles, "Test Vector  37: %0d cycles (%.2f us @ 100MHz)", test_cycles, test_cycles * 0.01);
            
            // Write outputs
            $fdisplay(fd_output, "%015b %015b", h_t[0], h_t[1]);
        end else begin
            $display("Stopping simulation due to timeout on test 37");
        end
        
        repeat(5) @(posedge clk); // Wait between tests
    end

    // Test Vector 38
    if (!test_timeout) begin
        test_start_cycle = cycle_count;
        
        // Load input data
        x_t[0] = 15'b000000000100110;
        x_t[1] = 15'b000000000011001;
        x_t[2] = 15'b111111110001111;
        x_t[3] = 15'b111111100100110;
        
        h_t_prev[0] = 15'b000000000100110;
        h_t_prev[1] = 15'b000000000011001;
        
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        // Wait for completion with timeout
        fork
            begin
                wait(done);
                test_cycles = cycle_count - test_start_cycle;
            end
            begin
                repeat(200000) @(posedge clk);
                $display("ERROR: Test 38 timeout!");
                $fdisplay(fd_cycles, "Test Vector  38: TIMEOUT");
                test_cycles = -1;
                test_timeout = 1;
            end
        join_any
        disable fork;
        
        if (test_cycles > 0) begin
            repeat(5) @(posedge clk); // Extra cycles for stability
            total_cycles = total_cycles + test_cycles;
            $fdisplay(fd_cycles, "Test Vector  38: %0d cycles (%.2f us @ 100MHz)", test_cycles, test_cycles * 0.01);
            
            // Write outputs
            $fdisplay(fd_output, "%015b %015b", h_t[0], h_t[1]);
        end else begin
            $display("Stopping simulation due to timeout on test 38");
        end
        
        repeat(5) @(posedge clk); // Wait between tests
    end

    // Test Vector 39
    if (!test_timeout) begin
        test_start_cycle = cycle_count;
        
        // Load input data
        x_t[0] = 15'b000000100110000;
        x_t[1] = 15'b000000100100001;
        x_t[2] = 15'b000000001011011;
        x_t[3] = 15'b111111111010100;
        
        h_t_prev[0] = 15'b000000100110000;
        h_t_prev[1] = 15'b000000100100001;
        
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        // Wait for completion with timeout
        fork
            begin
                wait(done);
                test_cycles = cycle_count - test_start_cycle;
            end
            begin
                repeat(200000) @(posedge clk);
                $display("ERROR: Test 39 timeout!");
                $fdisplay(fd_cycles, "Test Vector  39: TIMEOUT");
                test_cycles = -1;
                test_timeout = 1;
            end
        join_any
        disable fork;
        
        if (test_cycles > 0) begin
            repeat(5) @(posedge clk); // Extra cycles for stability
            total_cycles = total_cycles + test_cycles;
            $fdisplay(fd_cycles, "Test Vector  39: %0d cycles (%.2f us @ 100MHz)", test_cycles, test_cycles * 0.01);
            
            // Write outputs
            $fdisplay(fd_output, "%015b %015b", h_t[0], h_t[1]);
        end else begin
            $display("Stopping simulation due to timeout on test 39");
        end
        
        repeat(5) @(posedge clk); // Wait between tests
    end

    // Test Vector 40
    if (!test_timeout) begin
        test_start_cycle = cycle_count;
        
        // Load input data
        x_t[0] = 15'b000000011110101;
        x_t[1] = 15'b000000100101011;
        x_t[2] = 15'b000000001011011;
        x_t[3] = 15'b000000000001110;
        
        h_t_prev[0] = 15'b000000011110101;
        h_t_prev[1] = 15'b000000100101011;
        
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        // Wait for completion with timeout
        fork
            begin
                wait(done);
                test_cycles = cycle_count - test_start_cycle;
            end
            begin
                repeat(200000) @(posedge clk);
                $display("ERROR: Test 40 timeout!");
                $fdisplay(fd_cycles, "Test Vector  40: TIMEOUT");
                test_cycles = -1;
                test_timeout = 1;
            end
        join_any
        disable fork;
        
        if (test_cycles > 0) begin
            repeat(5) @(posedge clk); // Extra cycles for stability
            total_cycles = total_cycles + test_cycles;
            $fdisplay(fd_cycles, "Test Vector  40: %0d cycles (%.2f us @ 100MHz)", test_cycles, test_cycles * 0.01);
            
            // Write outputs
            $fdisplay(fd_output, "%015b %015b", h_t[0], h_t[1]);
        end else begin
            $display("Stopping simulation due to timeout on test 40");
        end
        
        repeat(5) @(posedge clk); // Wait between tests
    end

    // Test Vector 41
    if (!test_timeout) begin
        test_start_cycle = cycle_count;
        
        // Load input data
        x_t[0] = 15'b000000000110000;
        x_t[1] = 15'b000000010001110;
        x_t[2] = 15'b000000000100000;
        x_t[3] = 15'b111111111010100;
        
        h_t_prev[0] = 15'b000000000110000;
        h_t_prev[1] = 15'b000000010001110;
        
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        // Wait for completion with timeout
        fork
            begin
                wait(done);
                test_cycles = cycle_count - test_start_cycle;
            end
            begin
                repeat(200000) @(posedge clk);
                $display("ERROR: Test 41 timeout!");
                $fdisplay(fd_cycles, "Test Vector  41: TIMEOUT");
                test_cycles = -1;
                test_timeout = 1;
            end
        join_any
        disable fork;
        
        if (test_cycles > 0) begin
            repeat(5) @(posedge clk); // Extra cycles for stability
            total_cycles = total_cycles + test_cycles;
            $fdisplay(fd_cycles, "Test Vector  41: %0d cycles (%.2f us @ 100MHz)", test_cycles, test_cycles * 0.01);
            
            // Write outputs
            $fdisplay(fd_output, "%015b %015b", h_t[0], h_t[1]);
        end else begin
            $display("Stopping simulation due to timeout on test 41");
        end
        
        repeat(5) @(posedge clk); // Wait between tests
    end

    // Test Vector 42
    if (!test_timeout) begin
        test_start_cycle = cycle_count;
        
        // Load input data
        x_t[0] = 15'b000000100010011;
        x_t[1] = 15'b000000111010001;
        x_t[2] = 15'b000000101101011;
        x_t[3] = 15'b000000100110000;
        
        h_t_prev[0] = 15'b000000100010011;
        h_t_prev[1] = 15'b000000111010001;
        
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        // Wait for completion with timeout
        fork
            begin
                wait(done);
                test_cycles = cycle_count - test_start_cycle;
            end
            begin
                repeat(200000) @(posedge clk);
                $display("ERROR: Test 42 timeout!");
                $fdisplay(fd_cycles, "Test Vector  42: TIMEOUT");
                test_cycles = -1;
                test_timeout = 1;
            end
        join_any
        disable fork;
        
        if (test_cycles > 0) begin
            repeat(5) @(posedge clk); // Extra cycles for stability
            total_cycles = total_cycles + test_cycles;
            $fdisplay(fd_cycles, "Test Vector  42: %0d cycles (%.2f us @ 100MHz)", test_cycles, test_cycles * 0.01);
            
            // Write outputs
            $fdisplay(fd_output, "%015b %015b", h_t[0], h_t[1]);
        end else begin
            $display("Stopping simulation due to timeout on test 42");
        end
        
        repeat(5) @(posedge clk); // Wait between tests
    end

    // Test Vector 43
    if (!test_timeout) begin
        test_start_cycle = cycle_count;
        
        // Load input data
        x_t[0] = 15'b000000101100010;
        x_t[1] = 15'b000000110110100;
        x_t[2] = 15'b000000101010111;
        x_t[3] = 15'b000000101001101;
        
        h_t_prev[0] = 15'b000000101100010;
        h_t_prev[1] = 15'b000000110110100;
        
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        // Wait for completion with timeout
        fork
            begin
                wait(done);
                test_cycles = cycle_count - test_start_cycle;
            end
            begin
                repeat(200000) @(posedge clk);
                $display("ERROR: Test 43 timeout!");
                $fdisplay(fd_cycles, "Test Vector  43: TIMEOUT");
                test_cycles = -1;
                test_timeout = 1;
            end
        join_any
        disable fork;
        
        if (test_cycles > 0) begin
            repeat(5) @(posedge clk); // Extra cycles for stability
            total_cycles = total_cycles + test_cycles;
            $fdisplay(fd_cycles, "Test Vector  43: %0d cycles (%.2f us @ 100MHz)", test_cycles, test_cycles * 0.01);
            
            // Write outputs
            $fdisplay(fd_output, "%015b %015b", h_t[0], h_t[1]);
        end else begin
            $display("Stopping simulation due to timeout on test 43");
        end
        
        repeat(5) @(posedge clk); // Wait between tests
    end

    // Test Vector 44
    if (!test_timeout) begin
        test_start_cycle = cycle_count;
        
        // Load input data
        x_t[0] = 15'b000000101000100;
        x_t[1] = 15'b000000101001000;
        x_t[2] = 15'b000000011100011;
        x_t[3] = 15'b000000011110110;
        
        h_t_prev[0] = 15'b000000101000100;
        h_t_prev[1] = 15'b000000101001000;
        
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        // Wait for completion with timeout
        fork
            begin
                wait(done);
                test_cycles = cycle_count - test_start_cycle;
            end
            begin
                repeat(200000) @(posedge clk);
                $display("ERROR: Test 44 timeout!");
                $fdisplay(fd_cycles, "Test Vector  44: TIMEOUT");
                test_cycles = -1;
                test_timeout = 1;
            end
        join_any
        disable fork;
        
        if (test_cycles > 0) begin
            repeat(5) @(posedge clk); // Extra cycles for stability
            total_cycles = total_cycles + test_cycles;
            $fdisplay(fd_cycles, "Test Vector  44: %0d cycles (%.2f us @ 100MHz)", test_cycles, test_cycles * 0.01);
            
            // Write outputs
            $fdisplay(fd_output, "%015b %015b", h_t[0], h_t[1]);
        end else begin
            $display("Stopping simulation due to timeout on test 44");
        end
        
        repeat(5) @(posedge clk); // Wait between tests
    end

    // Test Vector 45
    if (!test_timeout) begin
        test_start_cycle = cycle_count;
        
        // Load input data
        x_t[0] = 15'b000000111000100;
        x_t[1] = 15'b000000111111000;
        x_t[2] = 15'b000000111000010;
        x_t[3] = 15'b000000110011011;
        
        h_t_prev[0] = 15'b000000111000100;
        h_t_prev[1] = 15'b000000111111000;
        
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        // Wait for completion with timeout
        fork
            begin
                wait(done);
                test_cycles = cycle_count - test_start_cycle;
            end
            begin
                repeat(200000) @(posedge clk);
                $display("ERROR: Test 45 timeout!");
                $fdisplay(fd_cycles, "Test Vector  45: TIMEOUT");
                test_cycles = -1;
                test_timeout = 1;
            end
        join_any
        disable fork;
        
        if (test_cycles > 0) begin
            repeat(5) @(posedge clk); // Extra cycles for stability
            total_cycles = total_cycles + test_cycles;
            $fdisplay(fd_cycles, "Test Vector  45: %0d cycles (%.2f us @ 100MHz)", test_cycles, test_cycles * 0.01);
            
            // Write outputs
            $fdisplay(fd_output, "%015b %015b", h_t[0], h_t[1]);
        end else begin
            $display("Stopping simulation due to timeout on test 45");
        end
        
        repeat(5) @(posedge clk); // Wait between tests
    end

    // Test Vector 46
    if (!test_timeout) begin
        test_start_cycle = cycle_count;
        
        // Load input data
        x_t[0] = 15'b000000110100111;
        x_t[1] = 15'b000001000001100;
        x_t[2] = 15'b000000110100101;
        x_t[3] = 15'b000000101110100;
        
        h_t_prev[0] = 15'b000000110100111;
        h_t_prev[1] = 15'b000001000001100;
        
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        // Wait for completion with timeout
        fork
            begin
                wait(done);
                test_cycles = cycle_count - test_start_cycle;
            end
            begin
                repeat(200000) @(posedge clk);
                $display("ERROR: Test 46 timeout!");
                $fdisplay(fd_cycles, "Test Vector  46: TIMEOUT");
                test_cycles = -1;
                test_timeout = 1;
            end
        join_any
        disable fork;
        
        if (test_cycles > 0) begin
            repeat(5) @(posedge clk); // Extra cycles for stability
            total_cycles = total_cycles + test_cycles;
            $fdisplay(fd_cycles, "Test Vector  46: %0d cycles (%.2f us @ 100MHz)", test_cycles, test_cycles * 0.01);
            
            // Write outputs
            $fdisplay(fd_output, "%015b %015b", h_t[0], h_t[1]);
        end else begin
            $display("Stopping simulation due to timeout on test 46");
        end
        
        repeat(5) @(posedge clk); // Wait between tests
    end

    // Test Vector 47
    if (!test_timeout) begin
        test_start_cycle = cycle_count;
        
        // Load input data
        x_t[0] = 15'b000001001011000;
        x_t[1] = 15'b000001010111100;
        x_t[2] = 15'b000001000110111;
        x_t[3] = 15'b000001000111111;
        
        h_t_prev[0] = 15'b000001001011000;
        h_t_prev[1] = 15'b000001010111100;
        
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        // Wait for completion with timeout
        fork
            begin
                wait(done);
                test_cycles = cycle_count - test_start_cycle;
            end
            begin
                repeat(200000) @(posedge clk);
                $display("ERROR: Test 47 timeout!");
                $fdisplay(fd_cycles, "Test Vector  47: TIMEOUT");
                test_cycles = -1;
                test_timeout = 1;
            end
        join_any
        disable fork;
        
        if (test_cycles > 0) begin
            repeat(5) @(posedge clk); // Extra cycles for stability
            total_cycles = total_cycles + test_cycles;
            $fdisplay(fd_cycles, "Test Vector  47: %0d cycles (%.2f us @ 100MHz)", test_cycles, test_cycles * 0.01);
            
            // Write outputs
            $fdisplay(fd_output, "%015b %015b", h_t[0], h_t[1]);
        end else begin
            $display("Stopping simulation due to timeout on test 47");
        end
        
        repeat(5) @(posedge clk); // Wait between tests
    end

    // Test Vector 48
    if (!test_timeout) begin
        test_start_cycle = cycle_count;
        
        // Load input data
        x_t[0] = 15'b000000101011000;
        x_t[1] = 15'b000000110111110;
        x_t[2] = 15'b000000110010001;
        x_t[3] = 15'b000000111111011;
        
        h_t_prev[0] = 15'b000000101011000;
        h_t_prev[1] = 15'b000000110111110;
        
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        // Wait for completion with timeout
        fork
            begin
                wait(done);
                test_cycles = cycle_count - test_start_cycle;
            end
            begin
                repeat(200000) @(posedge clk);
                $display("ERROR: Test 48 timeout!");
                $fdisplay(fd_cycles, "Test Vector  48: TIMEOUT");
                test_cycles = -1;
                test_timeout = 1;
            end
        join_any
        disable fork;
        
        if (test_cycles > 0) begin
            repeat(5) @(posedge clk); // Extra cycles for stability
            total_cycles = total_cycles + test_cycles;
            $fdisplay(fd_cycles, "Test Vector  48: %0d cycles (%.2f us @ 100MHz)", test_cycles, test_cycles * 0.01);
            
            // Write outputs
            $fdisplay(fd_output, "%015b %015b", h_t[0], h_t[1]);
        end else begin
            $display("Stopping simulation due to timeout on test 48");
        end
        
        repeat(5) @(posedge clk); // Wait between tests
    end

    // Test Vector 49
    if (!test_timeout) begin
        test_start_cycle = cycle_count;
        
        // Load input data
        x_t[0] = 15'b111111001110100;
        x_t[1] = 15'b111110101111111;
        x_t[2] = 15'b111110001101001;
        x_t[3] = 15'b111101101111101;
        
        h_t_prev[0] = 15'b111111001110100;
        h_t_prev[1] = 15'b111110101111111;
        
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        // Wait for completion with timeout
        fork
            begin
                wait(done);
                test_cycles = cycle_count - test_start_cycle;
            end
            begin
                repeat(200000) @(posedge clk);
                $display("ERROR: Test 49 timeout!");
                $fdisplay(fd_cycles, "Test Vector  49: TIMEOUT");
                test_cycles = -1;
                test_timeout = 1;
            end
        join_any
        disable fork;
        
        if (test_cycles > 0) begin
            repeat(5) @(posedge clk); // Extra cycles for stability
            total_cycles = total_cycles + test_cycles;
            $fdisplay(fd_cycles, "Test Vector  49: %0d cycles (%.2f us @ 100MHz)", test_cycles, test_cycles * 0.01);
            
            // Write outputs
            $fdisplay(fd_output, "%015b %015b", h_t[0], h_t[1]);
        end else begin
            $display("Stopping simulation due to timeout on test 49");
        end
        
        repeat(5) @(posedge clk); // Wait between tests
    end

    // Test Vector 50
    if (!test_timeout) begin
        test_start_cycle = cycle_count;
        
        // Load input data
        x_t[0] = 15'b111110101110011;
        x_t[1] = 15'b111110010011110;
        x_t[2] = 15'b111101101001111;
        x_t[3] = 15'b111101001000111;
        
        h_t_prev[0] = 15'b111110101110011;
        h_t_prev[1] = 15'b111110010011110;
        
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        // Wait for completion with timeout
        fork
            begin
                wait(done);
                test_cycles = cycle_count - test_start_cycle;
            end
            begin
                repeat(200000) @(posedge clk);
                $display("ERROR: Test 50 timeout!");
                $fdisplay(fd_cycles, "Test Vector  50: TIMEOUT");
                test_cycles = -1;
                test_timeout = 1;
            end
        join_any
        disable fork;
        
        if (test_cycles > 0) begin
            repeat(5) @(posedge clk); // Extra cycles for stability
            total_cycles = total_cycles + test_cycles;
            $fdisplay(fd_cycles, "Test Vector  50: %0d cycles (%.2f us @ 100MHz)", test_cycles, test_cycles * 0.01);
            
            // Write outputs
            $fdisplay(fd_output, "%015b %015b", h_t[0], h_t[1]);
        end else begin
            $display("Stopping simulation due to timeout on test 50");
        end
        
        repeat(5) @(posedge clk); // Wait between tests
    end

    // Test Vector 51
    if (!test_timeout) begin
        test_start_cycle = cycle_count;
        
        // Load input data
        x_t[0] = 15'b111110110010001;
        x_t[1] = 15'b111110010001010;
        x_t[2] = 15'b111101110010011;
        x_t[3] = 15'b111101010011110;
        
        h_t_prev[0] = 15'b111110110010001;
        h_t_prev[1] = 15'b111110010001010;
        
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        // Wait for completion with timeout
        fork
            begin
                wait(done);
                test_cycles = cycle_count - test_start_cycle;
            end
            begin
                repeat(200000) @(posedge clk);
                $display("ERROR: Test 51 timeout!");
                $fdisplay(fd_cycles, "Test Vector  51: TIMEOUT");
                test_cycles = -1;
                test_timeout = 1;
            end
        join_any
        disable fork;
        
        if (test_cycles > 0) begin
            repeat(5) @(posedge clk); // Extra cycles for stability
            total_cycles = total_cycles + test_cycles;
            $fdisplay(fd_cycles, "Test Vector  51: %0d cycles (%.2f us @ 100MHz)", test_cycles, test_cycles * 0.01);
            
            // Write outputs
            $fdisplay(fd_output, "%015b %015b", h_t[0], h_t[1]);
        end else begin
            $display("Stopping simulation due to timeout on test 51");
        end
        
        repeat(5) @(posedge clk); // Wait between tests
    end

    // Test Vector 52
    if (!test_timeout) begin
        test_start_cycle = cycle_count;
        
        // Load input data
        x_t[0] = 15'b111111011010111;
        x_t[1] = 15'b111111000010010;
        x_t[2] = 15'b111110011111010;
        x_t[3] = 15'b111101111111010;
        
        h_t_prev[0] = 15'b111111011010111;
        h_t_prev[1] = 15'b111111000010010;
        
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        // Wait for completion with timeout
        fork
            begin
                wait(done);
                test_cycles = cycle_count - test_start_cycle;
            end
            begin
                repeat(200000) @(posedge clk);
                $display("ERROR: Test 52 timeout!");
                $fdisplay(fd_cycles, "Test Vector  52: TIMEOUT");
                test_cycles = -1;
                test_timeout = 1;
            end
        join_any
        disable fork;
        
        if (test_cycles > 0) begin
            repeat(5) @(posedge clk); // Extra cycles for stability
            total_cycles = total_cycles + test_cycles;
            $fdisplay(fd_cycles, "Test Vector  52: %0d cycles (%.2f us @ 100MHz)", test_cycles, test_cycles * 0.01);
            
            // Write outputs
            $fdisplay(fd_output, "%015b %015b", h_t[0], h_t[1]);
        end else begin
            $display("Stopping simulation due to timeout on test 52");
        end
        
        repeat(5) @(posedge clk); // Wait between tests
    end

    // Test Vector 53
    if (!test_timeout) begin
        test_start_cycle = cycle_count;
        
        // Load input data
        x_t[0] = 15'b111111111010111;
        x_t[1] = 15'b111111100000111;
        x_t[2] = 15'b111111000010100;
        x_t[3] = 15'b111110101100000;
        
        h_t_prev[0] = 15'b111111111010111;
        h_t_prev[1] = 15'b111111100000111;
        
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        // Wait for completion with timeout
        fork
            begin
                wait(done);
                test_cycles = cycle_count - test_start_cycle;
            end
            begin
                repeat(200000) @(posedge clk);
                $display("ERROR: Test 53 timeout!");
                $fdisplay(fd_cycles, "Test Vector  53: TIMEOUT");
                test_cycles = -1;
                test_timeout = 1;
            end
        join_any
        disable fork;
        
        if (test_cycles > 0) begin
            repeat(5) @(posedge clk); // Extra cycles for stability
            total_cycles = total_cycles + test_cycles;
            $fdisplay(fd_cycles, "Test Vector  53: %0d cycles (%.2f us @ 100MHz)", test_cycles, test_cycles * 0.01);
            
            // Write outputs
            $fdisplay(fd_output, "%015b %015b", h_t[0], h_t[1]);
        end else begin
            $display("Stopping simulation due to timeout on test 53");
        end
        
        repeat(5) @(posedge clk); // Wait between tests
    end

    // Test Vector 54
    if (!test_timeout) begin
        test_start_cycle = cycle_count;
        
        // Load input data
        x_t[0] = 15'b111111110110000;
        x_t[1] = 15'b111111011110011;
        x_t[2] = 15'b111111000100111;
        x_t[3] = 15'b111110110011010;
        
        h_t_prev[0] = 15'b111111110110000;
        h_t_prev[1] = 15'b111111011110011;
        
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        // Wait for completion with timeout
        fork
            begin
                wait(done);
                test_cycles = cycle_count - test_start_cycle;
            end
            begin
                repeat(200000) @(posedge clk);
                $display("ERROR: Test 54 timeout!");
                $fdisplay(fd_cycles, "Test Vector  54: TIMEOUT");
                test_cycles = -1;
                test_timeout = 1;
            end
        join_any
        disable fork;
        
        if (test_cycles > 0) begin
            repeat(5) @(posedge clk); // Extra cycles for stability
            total_cycles = total_cycles + test_cycles;
            $fdisplay(fd_cycles, "Test Vector  54: %0d cycles (%.2f us @ 100MHz)", test_cycles, test_cycles * 0.01);
            
            // Write outputs
            $fdisplay(fd_output, "%015b %015b", h_t[0], h_t[1]);
        end else begin
            $display("Stopping simulation due to timeout on test 54");
        end
        
        repeat(5) @(posedge clk); // Wait between tests
    end

    // Test Vector 55
    if (!test_timeout) begin
        test_start_cycle = cycle_count;
        
        // Load input data
        x_t[0] = 15'b111111110011100;
        x_t[1] = 15'b111111011000010;
        x_t[2] = 15'b111110110111101;
        x_t[3] = 15'b111110100001001;
        
        h_t_prev[0] = 15'b111111110011100;
        h_t_prev[1] = 15'b111111011000010;
        
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        // Wait for completion with timeout
        fork
            begin
                wait(done);
                test_cycles = cycle_count - test_start_cycle;
            end
            begin
                repeat(200000) @(posedge clk);
                $display("ERROR: Test 55 timeout!");
                $fdisplay(fd_cycles, "Test Vector  55: TIMEOUT");
                test_cycles = -1;
                test_timeout = 1;
            end
        join_any
        disable fork;
        
        if (test_cycles > 0) begin
            repeat(5) @(posedge clk); // Extra cycles for stability
            total_cycles = total_cycles + test_cycles;
            $fdisplay(fd_cycles, "Test Vector  55: %0d cycles (%.2f us @ 100MHz)", test_cycles, test_cycles * 0.01);
            
            // Write outputs
            $fdisplay(fd_output, "%015b %015b", h_t[0], h_t[1]);
        end else begin
            $display("Stopping simulation due to timeout on test 55");
        end
        
        repeat(5) @(posedge clk); // Wait between tests
    end

    // Test Vector 56
    if (!test_timeout) begin
        test_start_cycle = cycle_count;
        
        // Load input data
        x_t[0] = 15'b111111101110100;
        x_t[1] = 15'b111111001101010;
        x_t[2] = 15'b111110101011011;
        x_t[3] = 15'b111110011011001;
        
        h_t_prev[0] = 15'b111111101110100;
        h_t_prev[1] = 15'b111111001101010;
        
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        // Wait for completion with timeout
        fork
            begin
                wait(done);
                test_cycles = cycle_count - test_start_cycle;
            end
            begin
                repeat(200000) @(posedge clk);
                $display("ERROR: Test 56 timeout!");
                $fdisplay(fd_cycles, "Test Vector  56: TIMEOUT");
                test_cycles = -1;
                test_timeout = 1;
            end
        join_any
        disable fork;
        
        if (test_cycles > 0) begin
            repeat(5) @(posedge clk); // Extra cycles for stability
            total_cycles = total_cycles + test_cycles;
            $fdisplay(fd_cycles, "Test Vector  56: %0d cycles (%.2f us @ 100MHz)", test_cycles, test_cycles * 0.01);
            
            // Write outputs
            $fdisplay(fd_output, "%015b %015b", h_t[0], h_t[1]);
        end else begin
            $display("Stopping simulation due to timeout on test 56");
        end
        
        repeat(5) @(posedge clk); // Wait between tests
    end

    // Test Vector 57
    if (!test_timeout) begin
        test_start_cycle = cycle_count;
        
        // Load input data
        x_t[0] = 15'b111111101100001;
        x_t[1] = 15'b111110111110101;
        x_t[2] = 15'b111110011111010;
        x_t[3] = 15'b111110001101110;
        
        h_t_prev[0] = 15'b111111101100001;
        h_t_prev[1] = 15'b111110111110101;
        
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        // Wait for completion with timeout
        fork
            begin
                wait(done);
                test_cycles = cycle_count - test_start_cycle;
            end
            begin
                repeat(200000) @(posedge clk);
                $display("ERROR: Test 57 timeout!");
                $fdisplay(fd_cycles, "Test Vector  57: TIMEOUT");
                test_cycles = -1;
                test_timeout = 1;
            end
        join_any
        disable fork;
        
        if (test_cycles > 0) begin
            repeat(5) @(posedge clk); // Extra cycles for stability
            total_cycles = total_cycles + test_cycles;
            $fdisplay(fd_cycles, "Test Vector  57: %0d cycles (%.2f us @ 100MHz)", test_cycles, test_cycles * 0.01);
            
            // Write outputs
            $fdisplay(fd_output, "%015b %015b", h_t[0], h_t[1]);
        end else begin
            $display("Stopping simulation due to timeout on test 57");
        end
        
        repeat(5) @(posedge clk); // Wait between tests
    end

    // Test Vector 58
    if (!test_timeout) begin
        test_start_cycle = cycle_count;
        
        // Load input data
        x_t[0] = 15'b111111011101010;
        x_t[1] = 15'b111110110110000;
        x_t[2] = 15'b111110011001010;
        x_t[3] = 15'b111110000110100;
        
        h_t_prev[0] = 15'b111111011101010;
        h_t_prev[1] = 15'b111110110110000;
        
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        // Wait for completion with timeout
        fork
            begin
                wait(done);
                test_cycles = cycle_count - test_start_cycle;
            end
            begin
                repeat(200000) @(posedge clk);
                $display("ERROR: Test 58 timeout!");
                $fdisplay(fd_cycles, "Test Vector  58: TIMEOUT");
                test_cycles = -1;
                test_timeout = 1;
            end
        join_any
        disable fork;
        
        if (test_cycles > 0) begin
            repeat(5) @(posedge clk); // Extra cycles for stability
            total_cycles = total_cycles + test_cycles;
            $fdisplay(fd_cycles, "Test Vector  58: %0d cycles (%.2f us @ 100MHz)", test_cycles, test_cycles * 0.01);
            
            // Write outputs
            $fdisplay(fd_output, "%015b %015b", h_t[0], h_t[1]);
        end else begin
            $display("Stopping simulation due to timeout on test 58");
        end
        
        repeat(5) @(posedge clk); // Wait between tests
    end

    // Test Vector 59
    if (!test_timeout) begin
        test_start_cycle = cycle_count;
        
        // Load input data
        x_t[0] = 15'b111111011100000;
        x_t[1] = 15'b111110111111110;
        x_t[2] = 15'b111110011010100;
        x_t[3] = 15'b111110000101011;
        
        h_t_prev[0] = 15'b111111011100000;
        h_t_prev[1] = 15'b111110111111110;
        
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        // Wait for completion with timeout
        fork
            begin
                wait(done);
                test_cycles = cycle_count - test_start_cycle;
            end
            begin
                repeat(200000) @(posedge clk);
                $display("ERROR: Test 59 timeout!");
                $fdisplay(fd_cycles, "Test Vector  59: TIMEOUT");
                test_cycles = -1;
                test_timeout = 1;
            end
        join_any
        disable fork;
        
        if (test_cycles > 0) begin
            repeat(5) @(posedge clk); // Extra cycles for stability
            total_cycles = total_cycles + test_cycles;
            $fdisplay(fd_cycles, "Test Vector  59: %0d cycles (%.2f us @ 100MHz)", test_cycles, test_cycles * 0.01);
            
            // Write outputs
            $fdisplay(fd_output, "%015b %015b", h_t[0], h_t[1]);
        end else begin
            $display("Stopping simulation due to timeout on test 59");
        end
        
        repeat(5) @(posedge clk); // Wait between tests
    end

    // Test Vector 60
    if (!test_timeout) begin
        test_start_cycle = cycle_count;
        
        // Load input data
        x_t[0] = 15'b111111111010111;
        x_t[1] = 15'b111111011111101;
        x_t[2] = 15'b111110110011111;
        x_t[3] = 15'b111110011101100;
        
        h_t_prev[0] = 15'b111111111010111;
        h_t_prev[1] = 15'b111111011111101;
        
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        // Wait for completion with timeout
        fork
            begin
                wait(done);
                test_cycles = cycle_count - test_start_cycle;
            end
            begin
                repeat(200000) @(posedge clk);
                $display("ERROR: Test 60 timeout!");
                $fdisplay(fd_cycles, "Test Vector  60: TIMEOUT");
                test_cycles = -1;
                test_timeout = 1;
            end
        join_any
        disable fork;
        
        if (test_cycles > 0) begin
            repeat(5) @(posedge clk); // Extra cycles for stability
            total_cycles = total_cycles + test_cycles;
            $fdisplay(fd_cycles, "Test Vector  60: %0d cycles (%.2f us @ 100MHz)", test_cycles, test_cycles * 0.01);
            
            // Write outputs
            $fdisplay(fd_output, "%015b %015b", h_t[0], h_t[1]);
        end else begin
            $display("Stopping simulation due to timeout on test 60");
        end
        
        repeat(5) @(posedge clk); // Wait between tests
    end

    // Test Vector 61
    if (!test_timeout) begin
        test_start_cycle = cycle_count;
        
        // Load input data
        x_t[0] = 15'b111111111001101;
        x_t[1] = 15'b111111010101110;
        x_t[2] = 15'b111110101101111;
        x_t[3] = 15'b111110010011111;
        
        h_t_prev[0] = 15'b111111111001101;
        h_t_prev[1] = 15'b111111010101110;
        
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        // Wait for completion with timeout
        fork
            begin
                wait(done);
                test_cycles = cycle_count - test_start_cycle;
            end
            begin
                repeat(200000) @(posedge clk);
                $display("ERROR: Test 61 timeout!");
                $fdisplay(fd_cycles, "Test Vector  61: TIMEOUT");
                test_cycles = -1;
                test_timeout = 1;
            end
        join_any
        disable fork;
        
        if (test_cycles > 0) begin
            repeat(5) @(posedge clk); // Extra cycles for stability
            total_cycles = total_cycles + test_cycles;
            $fdisplay(fd_cycles, "Test Vector  61: %0d cycles (%.2f us @ 100MHz)", test_cycles, test_cycles * 0.01);
            
            // Write outputs
            $fdisplay(fd_output, "%015b %015b", h_t[0], h_t[1]);
        end else begin
            $display("Stopping simulation due to timeout on test 61");
        end
        
        repeat(5) @(posedge clk); // Wait between tests
    end

    // Test Vector 62
    if (!test_timeout) begin
        test_start_cycle = cycle_count;
        
        // Load input data
        x_t[0] = 15'b000000001001101;
        x_t[1] = 15'b111111100100100;
        x_t[2] = 15'b111110110111101;
        x_t[3] = 15'b111110001011011;
        
        h_t_prev[0] = 15'b000000001001101;
        h_t_prev[1] = 15'b111111100100100;
        
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        // Wait for completion with timeout
        fork
            begin
                wait(done);
                test_cycles = cycle_count - test_start_cycle;
            end
            begin
                repeat(200000) @(posedge clk);
                $display("ERROR: Test 62 timeout!");
                $fdisplay(fd_cycles, "Test Vector  62: TIMEOUT");
                test_cycles = -1;
                test_timeout = 1;
            end
        join_any
        disable fork;
        
        if (test_cycles > 0) begin
            repeat(5) @(posedge clk); // Extra cycles for stability
            total_cycles = total_cycles + test_cycles;
            $fdisplay(fd_cycles, "Test Vector  62: %0d cycles (%.2f us @ 100MHz)", test_cycles, test_cycles * 0.01);
            
            // Write outputs
            $fdisplay(fd_output, "%015b %015b", h_t[0], h_t[1]);
        end else begin
            $display("Stopping simulation due to timeout on test 62");
        end
        
        repeat(5) @(posedge clk); // Wait between tests
    end

    // Test Vector 63
    if (!test_timeout) begin
        test_start_cycle = cycle_count;
        
        // Load input data
        x_t[0] = 15'b000000000001000;
        x_t[1] = 15'b111111101101000;
        x_t[2] = 15'b111111000001010;
        x_t[3] = 15'b111110010101000;
        
        h_t_prev[0] = 15'b000000000001000;
        h_t_prev[1] = 15'b111111101101000;
        
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        // Wait for completion with timeout
        fork
            begin
                wait(done);
                test_cycles = cycle_count - test_start_cycle;
            end
            begin
                repeat(200000) @(posedge clk);
                $display("ERROR: Test 63 timeout!");
                $fdisplay(fd_cycles, "Test Vector  63: TIMEOUT");
                test_cycles = -1;
                test_timeout = 1;
            end
        join_any
        disable fork;
        
        if (test_cycles > 0) begin
            repeat(5) @(posedge clk); // Extra cycles for stability
            total_cycles = total_cycles + test_cycles;
            $fdisplay(fd_cycles, "Test Vector  63: %0d cycles (%.2f us @ 100MHz)", test_cycles, test_cycles * 0.01);
            
            // Write outputs
            $fdisplay(fd_output, "%015b %015b", h_t[0], h_t[1]);
        end else begin
            $display("Stopping simulation due to timeout on test 63");
        end
        
        repeat(5) @(posedge clk); // Wait between tests
    end

    // Test Vector 64
    if (!test_timeout) begin
        test_start_cycle = cycle_count;
        
        // Load input data
        x_t[0] = 15'b000000001110101;
        x_t[1] = 15'b111111110101101;
        x_t[2] = 15'b111111000111011;
        x_t[3] = 15'b111110011101100;
        
        h_t_prev[0] = 15'b000000001110101;
        h_t_prev[1] = 15'b111111110101101;
        
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        // Wait for completion with timeout
        fork
            begin
                wait(done);
                test_cycles = cycle_count - test_start_cycle;
            end
            begin
                repeat(200000) @(posedge clk);
                $display("ERROR: Test 64 timeout!");
                $fdisplay(fd_cycles, "Test Vector  64: TIMEOUT");
                test_cycles = -1;
                test_timeout = 1;
            end
        join_any
        disable fork;
        
        if (test_cycles > 0) begin
            repeat(5) @(posedge clk); // Extra cycles for stability
            total_cycles = total_cycles + test_cycles;
            $fdisplay(fd_cycles, "Test Vector  64: %0d cycles (%.2f us @ 100MHz)", test_cycles, test_cycles * 0.01);
            
            // Write outputs
            $fdisplay(fd_output, "%015b %015b", h_t[0], h_t[1]);
        end else begin
            $display("Stopping simulation due to timeout on test 64");
        end
        
        repeat(5) @(posedge clk); // Wait between tests
    end

    // Test Vector 65
    if (!test_timeout) begin
        test_start_cycle = cycle_count;
        
        // Load input data
        x_t[0] = 15'b111110010011010;
        x_t[1] = 15'b111110111100001;
        x_t[2] = 15'b111111000010100;
        x_t[3] = 15'b111111101001101;
        
        h_t_prev[0] = 15'b111110010011010;
        h_t_prev[1] = 15'b111110111100001;
        
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        // Wait for completion with timeout
        fork
            begin
                wait(done);
                test_cycles = cycle_count - test_start_cycle;
            end
            begin
                repeat(200000) @(posedge clk);
                $display("ERROR: Test 65 timeout!");
                $fdisplay(fd_cycles, "Test Vector  65: TIMEOUT");
                test_cycles = -1;
                test_timeout = 1;
            end
        join_any
        disable fork;
        
        if (test_cycles > 0) begin
            repeat(5) @(posedge clk); // Extra cycles for stability
            total_cycles = total_cycles + test_cycles;
            $fdisplay(fd_cycles, "Test Vector  65: %0d cycles (%.2f us @ 100MHz)", test_cycles, test_cycles * 0.01);
            
            // Write outputs
            $fdisplay(fd_output, "%015b %015b", h_t[0], h_t[1]);
        end else begin
            $display("Stopping simulation due to timeout on test 65");
        end
        
        repeat(5) @(posedge clk); // Wait between tests
    end

    // Test Vector 66
    if (!test_timeout) begin
        test_start_cycle = cycle_count;
        
        // Load input data
        x_t[0] = 15'b111110011011111;
        x_t[1] = 15'b111111001000011;
        x_t[2] = 15'b111111001110101;
        x_t[3] = 15'b111111101010111;
        
        h_t_prev[0] = 15'b111110011011111;
        h_t_prev[1] = 15'b111111001000011;
        
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        // Wait for completion with timeout
        fork
            begin
                wait(done);
                test_cycles = cycle_count - test_start_cycle;
            end
            begin
                repeat(200000) @(posedge clk);
                $display("ERROR: Test 66 timeout!");
                $fdisplay(fd_cycles, "Test Vector  66: TIMEOUT");
                test_cycles = -1;
                test_timeout = 1;
            end
        join_any
        disable fork;
        
        if (test_cycles > 0) begin
            repeat(5) @(posedge clk); // Extra cycles for stability
            total_cycles = total_cycles + test_cycles;
            $fdisplay(fd_cycles, "Test Vector  66: %0d cycles (%.2f us @ 100MHz)", test_cycles, test_cycles * 0.01);
            
            // Write outputs
            $fdisplay(fd_output, "%015b %015b", h_t[0], h_t[1]);
        end else begin
            $display("Stopping simulation due to timeout on test 66");
        end
        
        repeat(5) @(posedge clk); // Wait between tests
    end

    // Test Vector 67
    if (!test_timeout) begin
        test_start_cycle = cycle_count;
        
        // Load input data
        x_t[0] = 15'b111110101001100;
        x_t[1] = 15'b111111010101110;
        x_t[2] = 15'b111111010101111;
        x_t[3] = 15'b111111101000011;
        
        h_t_prev[0] = 15'b111110101001100;
        h_t_prev[1] = 15'b111111010101110;
        
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        // Wait for completion with timeout
        fork
            begin
                wait(done);
                test_cycles = cycle_count - test_start_cycle;
            end
            begin
                repeat(200000) @(posedge clk);
                $display("ERROR: Test 67 timeout!");
                $fdisplay(fd_cycles, "Test Vector  67: TIMEOUT");
                test_cycles = -1;
                test_timeout = 1;
            end
        join_any
        disable fork;
        
        if (test_cycles > 0) begin
            repeat(5) @(posedge clk); // Extra cycles for stability
            total_cycles = total_cycles + test_cycles;
            $fdisplay(fd_cycles, "Test Vector  67: %0d cycles (%.2f us @ 100MHz)", test_cycles, test_cycles * 0.01);
            
            // Write outputs
            $fdisplay(fd_output, "%015b %015b", h_t[0], h_t[1]);
        end else begin
            $display("Stopping simulation due to timeout on test 67");
        end
        
        repeat(5) @(posedge clk); // Wait between tests
    end

    // Test Vector 68
    if (!test_timeout) begin
        test_start_cycle = cycle_count;
        
        // Load input data
        x_t[0] = 15'b111111000011011;
        x_t[1] = 15'b111111100100100;
        x_t[2] = 15'b111111011110011;
        x_t[3] = 15'b111111101001101;
        
        h_t_prev[0] = 15'b111111000011011;
        h_t_prev[1] = 15'b111111100100100;
        
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        // Wait for completion with timeout
        fork
            begin
                wait(done);
                test_cycles = cycle_count - test_start_cycle;
            end
            begin
                repeat(200000) @(posedge clk);
                $display("ERROR: Test 68 timeout!");
                $fdisplay(fd_cycles, "Test Vector  68: TIMEOUT");
                test_cycles = -1;
                test_timeout = 1;
            end
        join_any
        disable fork;
        
        if (test_cycles > 0) begin
            repeat(5) @(posedge clk); // Extra cycles for stability
            total_cycles = total_cycles + test_cycles;
            $fdisplay(fd_cycles, "Test Vector  68: %0d cycles (%.2f us @ 100MHz)", test_cycles, test_cycles * 0.01);
            
            // Write outputs
            $fdisplay(fd_output, "%015b %015b", h_t[0], h_t[1]);
        end else begin
            $display("Stopping simulation due to timeout on test 68");
        end
        
        repeat(5) @(posedge clk); // Wait between tests
    end

    // Test Vector 69
    if (!test_timeout) begin
        test_start_cycle = cycle_count;
        
        // Load input data
        x_t[0] = 15'b111110111110100;
        x_t[1] = 15'b111111011110011;
        x_t[2] = 15'b111111011100000;
        x_t[3] = 15'b111111101001101;
        
        h_t_prev[0] = 15'b111110111110100;
        h_t_prev[1] = 15'b111111011110011;
        
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        // Wait for completion with timeout
        fork
            begin
                wait(done);
                test_cycles = cycle_count - test_start_cycle;
            end
            begin
                repeat(200000) @(posedge clk);
                $display("ERROR: Test 69 timeout!");
                $fdisplay(fd_cycles, "Test Vector  69: TIMEOUT");
                test_cycles = -1;
                test_timeout = 1;
            end
        join_any
        disable fork;
        
        if (test_cycles > 0) begin
            repeat(5) @(posedge clk); // Extra cycles for stability
            total_cycles = total_cycles + test_cycles;
            $fdisplay(fd_cycles, "Test Vector  69: %0d cycles (%.2f us @ 100MHz)", test_cycles, test_cycles * 0.01);
            
            // Write outputs
            $fdisplay(fd_output, "%015b %015b", h_t[0], h_t[1]);
        end else begin
            $display("Stopping simulation due to timeout on test 69");
        end
        
        repeat(5) @(posedge clk); // Wait between tests
    end

    // Test Vector 70
    if (!test_timeout) begin
        test_start_cycle = cycle_count;
        
        // Load input data
        x_t[0] = 15'b111110111111110;
        x_t[1] = 15'b111111100000111;
        x_t[2] = 15'b111111101000001;
        x_t[3] = 15'b111111111101000;
        
        h_t_prev[0] = 15'b111110111111110;
        h_t_prev[1] = 15'b111111100000111;
        
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        // Wait for completion with timeout
        fork
            begin
                wait(done);
                test_cycles = cycle_count - test_start_cycle;
            end
            begin
                repeat(200000) @(posedge clk);
                $display("ERROR: Test 70 timeout!");
                $fdisplay(fd_cycles, "Test Vector  70: TIMEOUT");
                test_cycles = -1;
                test_timeout = 1;
            end
        join_any
        disable fork;
        
        if (test_cycles > 0) begin
            repeat(5) @(posedge clk); // Extra cycles for stability
            total_cycles = total_cycles + test_cycles;
            $fdisplay(fd_cycles, "Test Vector  70: %0d cycles (%.2f us @ 100MHz)", test_cycles, test_cycles * 0.01);
            
            // Write outputs
            $fdisplay(fd_output, "%015b %015b", h_t[0], h_t[1]);
        end else begin
            $display("Stopping simulation due to timeout on test 70");
        end
        
        repeat(5) @(posedge clk); // Wait between tests
    end

    // Test Vector 71
    if (!test_timeout) begin
        test_start_cycle = cycle_count;
        
        // Load input data
        x_t[0] = 15'b111110100010001;
        x_t[1] = 15'b111111000111001;
        x_t[2] = 15'b111111001101011;
        x_t[3] = 15'b111111101101010;
        
        h_t_prev[0] = 15'b111110100010001;
        h_t_prev[1] = 15'b111111000111001;
        
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        // Wait for completion with timeout
        fork
            begin
                wait(done);
                test_cycles = cycle_count - test_start_cycle;
            end
            begin
                repeat(200000) @(posedge clk);
                $display("ERROR: Test 71 timeout!");
                $fdisplay(fd_cycles, "Test Vector  71: TIMEOUT");
                test_cycles = -1;
                test_timeout = 1;
            end
        join_any
        disable fork;
        
        if (test_cycles > 0) begin
            repeat(5) @(posedge clk); // Extra cycles for stability
            total_cycles = total_cycles + test_cycles;
            $fdisplay(fd_cycles, "Test Vector  71: %0d cycles (%.2f us @ 100MHz)", test_cycles, test_cycles * 0.01);
            
            // Write outputs
            $fdisplay(fd_output, "%015b %015b", h_t[0], h_t[1]);
        end else begin
            $display("Stopping simulation due to timeout on test 71");
        end
        
        repeat(5) @(posedge clk); // Wait between tests
    end

    // Test Vector 72
    if (!test_timeout) begin
        test_start_cycle = cycle_count;
        
        // Load input data
        x_t[0] = 15'b111110101010110;
        x_t[1] = 15'b111111010011011;
        x_t[2] = 15'b111111010011100;
        x_t[3] = 15'b111111110101110;
        
        h_t_prev[0] = 15'b111110101010110;
        h_t_prev[1] = 15'b111111010011011;
        
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        // Wait for completion with timeout
        fork
            begin
                wait(done);
                test_cycles = cycle_count - test_start_cycle;
            end
            begin
                repeat(200000) @(posedge clk);
                $display("ERROR: Test 72 timeout!");
                $fdisplay(fd_cycles, "Test Vector  72: TIMEOUT");
                test_cycles = -1;
                test_timeout = 1;
            end
        join_any
        disable fork;
        
        if (test_cycles > 0) begin
            repeat(5) @(posedge clk); // Extra cycles for stability
            total_cycles = total_cycles + test_cycles;
            $fdisplay(fd_cycles, "Test Vector  72: %0d cycles (%.2f us @ 100MHz)", test_cycles, test_cycles * 0.01);
            
            // Write outputs
            $fdisplay(fd_output, "%015b %015b", h_t[0], h_t[1]);
        end else begin
            $display("Stopping simulation due to timeout on test 72");
        end
        
        repeat(5) @(posedge clk); // Wait between tests
    end

    // Test Vector 73
    if (!test_timeout) begin
        test_start_cycle = cycle_count;
        
        // Load input data
        x_t[0] = 15'b111111000111001;
        x_t[1] = 15'b111111100011010;
        x_t[2] = 15'b111111100000111;
        x_t[3] = 15'b000000000000101;
        
        h_t_prev[0] = 15'b111111000111001;
        h_t_prev[1] = 15'b111111100011010;
        
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        // Wait for completion with timeout
        fork
            begin
                wait(done);
                test_cycles = cycle_count - test_start_cycle;
            end
            begin
                repeat(200000) @(posedge clk);
                $display("ERROR: Test 73 timeout!");
                $fdisplay(fd_cycles, "Test Vector  73: TIMEOUT");
                test_cycles = -1;
                test_timeout = 1;
            end
        join_any
        disable fork;
        
        if (test_cycles > 0) begin
            repeat(5) @(posedge clk); // Extra cycles for stability
            total_cycles = total_cycles + test_cycles;
            $fdisplay(fd_cycles, "Test Vector  73: %0d cycles (%.2f us @ 100MHz)", test_cycles, test_cycles * 0.01);
            
            // Write outputs
            $fdisplay(fd_output, "%015b %015b", h_t[0], h_t[1]);
        end else begin
            $display("Stopping simulation due to timeout on test 73");
        end
        
        repeat(5) @(posedge clk); // Wait between tests
    end

    // Test Vector 74
    if (!test_timeout) begin
        test_start_cycle = cycle_count;
        
        // Load input data
        x_t[0] = 15'b111111001101010;
        x_t[1] = 15'b111111101111100;
        x_t[2] = 15'b111111100110111;
        x_t[3] = 15'b000000000100010;
        
        h_t_prev[0] = 15'b111111001101010;
        h_t_prev[1] = 15'b111111101111100;
        
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        // Wait for completion with timeout
        fork
            begin
                wait(done);
                test_cycles = cycle_count - test_start_cycle;
            end
            begin
                repeat(200000) @(posedge clk);
                $display("ERROR: Test 74 timeout!");
                $fdisplay(fd_cycles, "Test Vector  74: TIMEOUT");
                test_cycles = -1;
                test_timeout = 1;
            end
        join_any
        disable fork;
        
        if (test_cycles > 0) begin
            repeat(5) @(posedge clk); // Extra cycles for stability
            total_cycles = total_cycles + test_cycles;
            $fdisplay(fd_cycles, "Test Vector  74: %0d cycles (%.2f us @ 100MHz)", test_cycles, test_cycles * 0.01);
            
            // Write outputs
            $fdisplay(fd_output, "%015b %015b", h_t[0], h_t[1]);
        end else begin
            $display("Stopping simulation due to timeout on test 74");
        end
        
        repeat(5) @(posedge clk); // Wait between tests
    end

    // Test Vector 75
    if (!test_timeout) begin
        test_start_cycle = cycle_count;
        
        // Load input data
        x_t[0] = 15'b111111001000011;
        x_t[1] = 15'b111111110100011;
        x_t[2] = 15'b111111101000001;
        x_t[3] = 15'b000000000011000;
        
        h_t_prev[0] = 15'b111111001000011;
        h_t_prev[1] = 15'b111111110100011;
        
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        // Wait for completion with timeout
        fork
            begin
                wait(done);
                test_cycles = cycle_count - test_start_cycle;
            end
            begin
                repeat(200000) @(posedge clk);
                $display("ERROR: Test 75 timeout!");
                $fdisplay(fd_cycles, "Test Vector  75: TIMEOUT");
                test_cycles = -1;
                test_timeout = 1;
            end
        join_any
        disable fork;
        
        if (test_cycles > 0) begin
            repeat(5) @(posedge clk); // Extra cycles for stability
            total_cycles = total_cycles + test_cycles;
            $fdisplay(fd_cycles, "Test Vector  75: %0d cycles (%.2f us @ 100MHz)", test_cycles, test_cycles * 0.01);
            
            // Write outputs
            $fdisplay(fd_output, "%015b %015b", h_t[0], h_t[1]);
        end else begin
            $display("Stopping simulation due to timeout on test 75");
        end
        
        repeat(5) @(posedge clk); // Wait between tests
    end

    // Test Vector 76
    if (!test_timeout) begin
        test_start_cycle = cycle_count;
        
        // Load input data
        x_t[0] = 15'b111110111010110;
        x_t[1] = 15'b111111001111110;
        x_t[2] = 15'b111111001101011;
        x_t[3] = 15'b111111101110100;
        
        h_t_prev[0] = 15'b111110111010110;
        h_t_prev[1] = 15'b111111001111110;
        
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        // Wait for completion with timeout
        fork
            begin
                wait(done);
                test_cycles = cycle_count - test_start_cycle;
            end
            begin
                repeat(200000) @(posedge clk);
                $display("ERROR: Test 76 timeout!");
                $fdisplay(fd_cycles, "Test Vector  76: TIMEOUT");
                test_cycles = -1;
                test_timeout = 1;
            end
        join_any
        disable fork;
        
        if (test_cycles > 0) begin
            repeat(5) @(posedge clk); // Extra cycles for stability
            total_cycles = total_cycles + test_cycles;
            $fdisplay(fd_cycles, "Test Vector  76: %0d cycles (%.2f us @ 100MHz)", test_cycles, test_cycles * 0.01);
            
            // Write outputs
            $fdisplay(fd_output, "%015b %015b", h_t[0], h_t[1]);
        end else begin
            $display("Stopping simulation due to timeout on test 76");
        end
        
        repeat(5) @(posedge clk); // Wait between tests
    end

    // Test Vector 77
    if (!test_timeout) begin
        test_start_cycle = cycle_count;
        
        // Load input data
        x_t[0] = 15'b111111100010010;
        x_t[1] = 15'b111111110101101;
        x_t[2] = 15'b111111110000101;
        x_t[3] = 15'b000000001101111;
        
        h_t_prev[0] = 15'b111111100010010;
        h_t_prev[1] = 15'b111111110101101;
        
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        // Wait for completion with timeout
        fork
            begin
                wait(done);
                test_cycles = cycle_count - test_start_cycle;
            end
            begin
                repeat(200000) @(posedge clk);
                $display("ERROR: Test 77 timeout!");
                $fdisplay(fd_cycles, "Test Vector  77: TIMEOUT");
                test_cycles = -1;
                test_timeout = 1;
            end
        join_any
        disable fork;
        
        if (test_cycles > 0) begin
            repeat(5) @(posedge clk); // Extra cycles for stability
            total_cycles = total_cycles + test_cycles;
            $fdisplay(fd_cycles, "Test Vector  77: %0d cycles (%.2f us @ 100MHz)", test_cycles, test_cycles * 0.01);
            
            // Write outputs
            $fdisplay(fd_output, "%015b %015b", h_t[0], h_t[1]);
        end else begin
            $display("Stopping simulation due to timeout on test 77");
        end
        
        repeat(5) @(posedge clk); // Wait between tests
    end

    // Test Vector 78
    if (!test_timeout) begin
        test_start_cycle = cycle_count;
        
        // Load input data
        x_t[0] = 15'b111111101001101;
        x_t[1] = 15'b111111110101101;
        x_t[2] = 15'b111111101000001;
        x_t[3] = 15'b111111111110001;
        
        h_t_prev[0] = 15'b111111101001101;
        h_t_prev[1] = 15'b111111110101101;
        
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        // Wait for completion with timeout
        fork
            begin
                wait(done);
                test_cycles = cycle_count - test_start_cycle;
            end
            begin
                repeat(200000) @(posedge clk);
                $display("ERROR: Test 78 timeout!");
                $fdisplay(fd_cycles, "Test Vector  78: TIMEOUT");
                test_cycles = -1;
                test_timeout = 1;
            end
        join_any
        disable fork;
        
        if (test_cycles > 0) begin
            repeat(5) @(posedge clk); // Extra cycles for stability
            total_cycles = total_cycles + test_cycles;
            $fdisplay(fd_cycles, "Test Vector  78: %0d cycles (%.2f us @ 100MHz)", test_cycles, test_cycles * 0.01);
            
            // Write outputs
            $fdisplay(fd_output, "%015b %015b", h_t[0], h_t[1]);
        end else begin
            $display("Stopping simulation due to timeout on test 78");
        end
        
        repeat(5) @(posedge clk); // Wait between tests
    end

    // Test Vector 79
    if (!test_timeout) begin
        test_start_cycle = cycle_count;
        
        // Load input data
        x_t[0] = 15'b111111010010010;
        x_t[1] = 15'b111111100100100;
        x_t[2] = 15'b111111011001101;
        x_t[3] = 15'b111111101000011;
        
        h_t_prev[0] = 15'b111111010010010;
        h_t_prev[1] = 15'b111111100100100;
        
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        // Wait for completion with timeout
        fork
            begin
                wait(done);
                test_cycles = cycle_count - test_start_cycle;
            end
            begin
                repeat(200000) @(posedge clk);
                $display("ERROR: Test 79 timeout!");
                $fdisplay(fd_cycles, "Test Vector  79: TIMEOUT");
                test_cycles = -1;
                test_timeout = 1;
            end
        join_any
        disable fork;
        
        if (test_cycles > 0) begin
            repeat(5) @(posedge clk); // Extra cycles for stability
            total_cycles = total_cycles + test_cycles;
            $fdisplay(fd_cycles, "Test Vector  79: %0d cycles (%.2f us @ 100MHz)", test_cycles, test_cycles * 0.01);
            
            // Write outputs
            $fdisplay(fd_output, "%015b %015b", h_t[0], h_t[1]);
        end else begin
            $display("Stopping simulation due to timeout on test 79");
        end
        
        repeat(5) @(posedge clk); // Wait between tests
    end

    // Test Vector 80
    if (!test_timeout) begin
        test_start_cycle = cycle_count;
        
        // Load input data
        x_t[0] = 15'b111111010101111;
        x_t[1] = 15'b111111101011111;
        x_t[2] = 15'b111111101000001;
        x_t[3] = 15'b111111111010100;
        
        h_t_prev[0] = 15'b111111010101111;
        h_t_prev[1] = 15'b111111101011111;
        
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        // Wait for completion with timeout
        fork
            begin
                wait(done);
                test_cycles = cycle_count - test_start_cycle;
            end
            begin
                repeat(200000) @(posedge clk);
                $display("ERROR: Test 80 timeout!");
                $fdisplay(fd_cycles, "Test Vector  80: TIMEOUT");
                test_cycles = -1;
                test_timeout = 1;
            end
        join_any
        disable fork;
        
        if (test_cycles > 0) begin
            repeat(5) @(posedge clk); // Extra cycles for stability
            total_cycles = total_cycles + test_cycles;
            $fdisplay(fd_cycles, "Test Vector  80: %0d cycles (%.2f us @ 100MHz)", test_cycles, test_cycles * 0.01);
            
            // Write outputs
            $fdisplay(fd_output, "%015b %015b", h_t[0], h_t[1]);
        end else begin
            $display("Stopping simulation due to timeout on test 80");
        end
        
        repeat(5) @(posedge clk); // Wait between tests
    end

    // Test Vector 81
    if (!test_timeout) begin
        test_start_cycle = cycle_count;
        
        // Load input data
        x_t[0] = 15'b000000011100001;
        x_t[1] = 15'b000000011100110;
        x_t[2] = 15'b000000001011011;
        x_t[3] = 15'b000000011000110;
        
        h_t_prev[0] = 15'b000000011100001;
        h_t_prev[1] = 15'b000000011100110;
        
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        // Wait for completion with timeout
        fork
            begin
                wait(done);
                test_cycles = cycle_count - test_start_cycle;
            end
            begin
                repeat(200000) @(posedge clk);
                $display("ERROR: Test 81 timeout!");
                $fdisplay(fd_cycles, "Test Vector  81: TIMEOUT");
                test_cycles = -1;
                test_timeout = 1;
            end
        join_any
        disable fork;
        
        if (test_cycles > 0) begin
            repeat(5) @(posedge clk); // Extra cycles for stability
            total_cycles = total_cycles + test_cycles;
            $fdisplay(fd_cycles, "Test Vector  81: %0d cycles (%.2f us @ 100MHz)", test_cycles, test_cycles * 0.01);
            
            // Write outputs
            $fdisplay(fd_output, "%015b %015b", h_t[0], h_t[1]);
        end else begin
            $display("Stopping simulation due to timeout on test 81");
        end
        
        repeat(5) @(posedge clk); // Wait between tests
    end

    // Test Vector 82
    if (!test_timeout) begin
        test_start_cycle = cycle_count;
        
        // Load input data
        x_t[0] = 15'b000000001001101;
        x_t[1] = 15'b000000001100111;
        x_t[2] = 15'b000000000001101;
        x_t[3] = 15'b000000010011111;
        
        h_t_prev[0] = 15'b000000001001101;
        h_t_prev[1] = 15'b000000001100111;
        
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        // Wait for completion with timeout
        fork
            begin
                wait(done);
                test_cycles = cycle_count - test_start_cycle;
            end
            begin
                repeat(200000) @(posedge clk);
                $display("ERROR: Test 82 timeout!");
                $fdisplay(fd_cycles, "Test Vector  82: TIMEOUT");
                test_cycles = -1;
                test_timeout = 1;
            end
        join_any
        disable fork;
        
        if (test_cycles > 0) begin
            repeat(5) @(posedge clk); // Extra cycles for stability
            total_cycles = total_cycles + test_cycles;
            $fdisplay(fd_cycles, "Test Vector  82: %0d cycles (%.2f us @ 100MHz)", test_cycles, test_cycles * 0.01);
            
            // Write outputs
            $fdisplay(fd_output, "%015b %015b", h_t[0], h_t[1]);
        end else begin
            $display("Stopping simulation due to timeout on test 82");
        end
        
        repeat(5) @(posedge clk); // Wait between tests
    end

    // Test Vector 83
    if (!test_timeout) begin
        test_start_cycle = cycle_count;
        
        // Load input data
        x_t[0] = 15'b111111110110000;
        x_t[1] = 15'b000000000000101;
        x_t[2] = 15'b000000000000011;
        x_t[3] = 15'b000000011000110;
        
        h_t_prev[0] = 15'b111111110110000;
        h_t_prev[1] = 15'b000000000000101;
        
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        // Wait for completion with timeout
        fork
            begin
                wait(done);
                test_cycles = cycle_count - test_start_cycle;
            end
            begin
                repeat(200000) @(posedge clk);
                $display("ERROR: Test 83 timeout!");
                $fdisplay(fd_cycles, "Test Vector  83: TIMEOUT");
                test_cycles = -1;
                test_timeout = 1;
            end
        join_any
        disable fork;
        
        if (test_cycles > 0) begin
            repeat(5) @(posedge clk); // Extra cycles for stability
            total_cycles = total_cycles + test_cycles;
            $fdisplay(fd_cycles, "Test Vector  83: %0d cycles (%.2f us @ 100MHz)", test_cycles, test_cycles * 0.01);
            
            // Write outputs
            $fdisplay(fd_output, "%015b %015b", h_t[0], h_t[1]);
        end else begin
            $display("Stopping simulation due to timeout on test 83");
        end
        
        repeat(5) @(posedge clk); // Wait between tests
    end

    // Test Vector 84
    if (!test_timeout) begin
        test_start_cycle = cycle_count;
        
        // Load input data
        x_t[0] = 15'b111111011010111;
        x_t[1] = 15'b111111100111000;
        x_t[2] = 15'b111111100011010;
        x_t[3] = 15'b111111111000001;
        
        h_t_prev[0] = 15'b111111011010111;
        h_t_prev[1] = 15'b111111100111000;
        
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        // Wait for completion with timeout
        fork
            begin
                wait(done);
                test_cycles = cycle_count - test_start_cycle;
            end
            begin
                repeat(200000) @(posedge clk);
                $display("ERROR: Test 84 timeout!");
                $fdisplay(fd_cycles, "Test Vector  84: TIMEOUT");
                test_cycles = -1;
                test_timeout = 1;
            end
        join_any
        disable fork;
        
        if (test_cycles > 0) begin
            repeat(5) @(posedge clk); // Extra cycles for stability
            total_cycles = total_cycles + test_cycles;
            $fdisplay(fd_cycles, "Test Vector  84: %0d cycles (%.2f us @ 100MHz)", test_cycles, test_cycles * 0.01);
            
            // Write outputs
            $fdisplay(fd_output, "%015b %015b", h_t[0], h_t[1]);
        end else begin
            $display("Stopping simulation due to timeout on test 84");
        end
        
        repeat(5) @(posedge clk); // Wait between tests
    end

    // Test Vector 85
    if (!test_timeout) begin
        test_start_cycle = cycle_count;
        
        // Load input data
        x_t[0] = 15'b111111101001101;
        x_t[1] = 15'b111111110011001;
        x_t[2] = 15'b111111100000111;
        x_t[3] = 15'b111111101100000;
        
        h_t_prev[0] = 15'b111111101001101;
        h_t_prev[1] = 15'b111111110011001;
        
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        // Wait for completion with timeout
        fork
            begin
                wait(done);
                test_cycles = cycle_count - test_start_cycle;
            end
            begin
                repeat(200000) @(posedge clk);
                $display("ERROR: Test 85 timeout!");
                $fdisplay(fd_cycles, "Test Vector  85: TIMEOUT");
                test_cycles = -1;
                test_timeout = 1;
            end
        join_any
        disable fork;
        
        if (test_cycles > 0) begin
            repeat(5) @(posedge clk); // Extra cycles for stability
            total_cycles = total_cycles + test_cycles;
            $fdisplay(fd_cycles, "Test Vector  85: %0d cycles (%.2f us @ 100MHz)", test_cycles, test_cycles * 0.01);
            
            // Write outputs
            $fdisplay(fd_output, "%015b %015b", h_t[0], h_t[1]);
        end else begin
            $display("Stopping simulation due to timeout on test 85");
        end
        
        repeat(5) @(posedge clk); // Wait between tests
    end

    // Test Vector 86
    if (!test_timeout) begin
        test_start_cycle = cycle_count;
        
        // Load input data
        x_t[0] = 15'b111111101001101;
        x_t[1] = 15'b111111110100011;
        x_t[2] = 15'b111111100101110;
        x_t[3] = 15'b111111101010111;
        
        h_t_prev[0] = 15'b111111101001101;
        h_t_prev[1] = 15'b111111110100011;
        
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        // Wait for completion with timeout
        fork
            begin
                wait(done);
                test_cycles = cycle_count - test_start_cycle;
            end
            begin
                repeat(200000) @(posedge clk);
                $display("ERROR: Test 86 timeout!");
                $fdisplay(fd_cycles, "Test Vector  86: TIMEOUT");
                test_cycles = -1;
                test_timeout = 1;
            end
        join_any
        disable fork;
        
        if (test_cycles > 0) begin
            repeat(5) @(posedge clk); // Extra cycles for stability
            total_cycles = total_cycles + test_cycles;
            $fdisplay(fd_cycles, "Test Vector  86: %0d cycles (%.2f us @ 100MHz)", test_cycles, test_cycles * 0.01);
            
            // Write outputs
            $fdisplay(fd_output, "%015b %015b", h_t[0], h_t[1]);
        end else begin
            $display("Stopping simulation due to timeout on test 86");
        end
        
        repeat(5) @(posedge clk); // Wait between tests
    end

    // Test Vector 87
    if (!test_timeout) begin
        test_start_cycle = cycle_count;
        
        // Load input data
        x_t[0] = 15'b000000000010010;
        x_t[1] = 15'b000000000101100;
        x_t[2] = 15'b111111110100010;
        x_t[3] = 15'b111111110101110;
        
        h_t_prev[0] = 15'b000000000010010;
        h_t_prev[1] = 15'b000000000101100;
        
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        // Wait for completion with timeout
        fork
            begin
                wait(done);
                test_cycles = cycle_count - test_start_cycle;
            end
            begin
                repeat(200000) @(posedge clk);
                $display("ERROR: Test 87 timeout!");
                $fdisplay(fd_cycles, "Test Vector  87: TIMEOUT");
                test_cycles = -1;
                test_timeout = 1;
            end
        join_any
        disable fork;
        
        if (test_cycles > 0) begin
            repeat(5) @(posedge clk); // Extra cycles for stability
            total_cycles = total_cycles + test_cycles;
            $fdisplay(fd_cycles, "Test Vector  87: %0d cycles (%.2f us @ 100MHz)", test_cycles, test_cycles * 0.01);
            
            // Write outputs
            $fdisplay(fd_output, "%015b %015b", h_t[0], h_t[1]);
        end else begin
            $display("Stopping simulation due to timeout on test 87");
        end
        
        repeat(5) @(posedge clk); // Wait between tests
    end

    // Test Vector 88
    if (!test_timeout) begin
        test_start_cycle = cycle_count;
        
        // Load input data
        x_t[0] = 15'b000000001111111;
        x_t[1] = 15'b000000010000100;
        x_t[2] = 15'b111111111110000;
        x_t[3] = 15'b111111111111011;
        
        h_t_prev[0] = 15'b000000001111111;
        h_t_prev[1] = 15'b000000010000100;
        
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        // Wait for completion with timeout
        fork
            begin
                wait(done);
                test_cycles = cycle_count - test_start_cycle;
            end
            begin
                repeat(200000) @(posedge clk);
                $display("ERROR: Test 88 timeout!");
                $fdisplay(fd_cycles, "Test Vector  88: TIMEOUT");
                test_cycles = -1;
                test_timeout = 1;
            end
        join_any
        disable fork;
        
        if (test_cycles > 0) begin
            repeat(5) @(posedge clk); // Extra cycles for stability
            total_cycles = total_cycles + test_cycles;
            $fdisplay(fd_cycles, "Test Vector  88: %0d cycles (%.2f us @ 100MHz)", test_cycles, test_cycles * 0.01);
            
            // Write outputs
            $fdisplay(fd_output, "%015b %015b", h_t[0], h_t[1]);
        end else begin
            $display("Stopping simulation due to timeout on test 88");
        end
        
        repeat(5) @(posedge clk); // Wait between tests
    end

    // Test Vector 89
    if (!test_timeout) begin
        test_start_cycle = cycle_count;
        
        // Load input data
        x_t[0] = 15'b000000010110000;
        x_t[1] = 15'b000000010001110;
        x_t[2] = 15'b000000000010111;
        x_t[3] = 15'b000000001011100;
        
        h_t_prev[0] = 15'b000000010110000;
        h_t_prev[1] = 15'b000000010001110;
        
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        // Wait for completion with timeout
        fork
            begin
                wait(done);
                test_cycles = cycle_count - test_start_cycle;
            end
            begin
                repeat(200000) @(posedge clk);
                $display("ERROR: Test 89 timeout!");
                $fdisplay(fd_cycles, "Test Vector  89: TIMEOUT");
                test_cycles = -1;
                test_timeout = 1;
            end
        join_any
        disable fork;
        
        if (test_cycles > 0) begin
            repeat(5) @(posedge clk); // Extra cycles for stability
            total_cycles = total_cycles + test_cycles;
            $fdisplay(fd_cycles, "Test Vector  89: %0d cycles (%.2f us @ 100MHz)", test_cycles, test_cycles * 0.01);
            
            // Write outputs
            $fdisplay(fd_output, "%015b %015b", h_t[0], h_t[1]);
        end else begin
            $display("Stopping simulation due to timeout on test 89");
        end
        
        repeat(5) @(posedge clk); // Wait between tests
    end

    // Test Vector 90
    if (!test_timeout) begin
        test_start_cycle = cycle_count;
        
        // Load input data
        x_t[0] = 15'b000000011100001;
        x_t[1] = 15'b000000011011100;
        x_t[2] = 15'b000000010010101;
        x_t[3] = 15'b000000011110110;
        
        h_t_prev[0] = 15'b000000011100001;
        h_t_prev[1] = 15'b000000011011100;
        
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        // Wait for completion with timeout
        fork
            begin
                wait(done);
                test_cycles = cycle_count - test_start_cycle;
            end
            begin
                repeat(200000) @(posedge clk);
                $display("ERROR: Test 90 timeout!");
                $fdisplay(fd_cycles, "Test Vector  90: TIMEOUT");
                test_cycles = -1;
                test_timeout = 1;
            end
        join_any
        disable fork;
        
        if (test_cycles > 0) begin
            repeat(5) @(posedge clk); // Extra cycles for stability
            total_cycles = total_cycles + test_cycles;
            $fdisplay(fd_cycles, "Test Vector  90: %0d cycles (%.2f us @ 100MHz)", test_cycles, test_cycles * 0.01);
            
            // Write outputs
            $fdisplay(fd_output, "%015b %015b", h_t[0], h_t[1]);
        end else begin
            $display("Stopping simulation due to timeout on test 90");
        end
        
        repeat(5) @(posedge clk); // Wait between tests
    end

    // Test Vector 91
    if (!test_timeout) begin
        test_start_cycle = cycle_count;
        
        // Load input data
        x_t[0] = 15'b000000010001001;
        x_t[1] = 15'b000000100100001;
        x_t[2] = 15'b000000101010111;
        x_t[3] = 15'b000000111001011;
        
        h_t_prev[0] = 15'b000000010001001;
        h_t_prev[1] = 15'b000000100100001;
        
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        // Wait for completion with timeout
        fork
            begin
                wait(done);
                test_cycles = cycle_count - test_start_cycle;
            end
            begin
                repeat(200000) @(posedge clk);
                $display("ERROR: Test 91 timeout!");
                $fdisplay(fd_cycles, "Test Vector  91: TIMEOUT");
                test_cycles = -1;
                test_timeout = 1;
            end
        join_any
        disable fork;
        
        if (test_cycles > 0) begin
            repeat(5) @(posedge clk); // Extra cycles for stability
            total_cycles = total_cycles + test_cycles;
            $fdisplay(fd_cycles, "Test Vector  91: %0d cycles (%.2f us @ 100MHz)", test_cycles, test_cycles * 0.01);
            
            // Write outputs
            $fdisplay(fd_output, "%015b %015b", h_t[0], h_t[1]);
        end else begin
            $display("Stopping simulation due to timeout on test 91");
        end
        
        repeat(5) @(posedge clk); // Wait between tests
    end

    // Test Vector 92
    if (!test_timeout) begin
        test_start_cycle = cycle_count;
        
        // Load input data
        x_t[0] = 15'b000000011100001;
        x_t[1] = 15'b000000110101010;
        x_t[2] = 15'b000000111101001;
        x_t[3] = 15'b000001001001001;
        
        h_t_prev[0] = 15'b000000011100001;
        h_t_prev[1] = 15'b000000110101010;
        
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        // Wait for completion with timeout
        fork
            begin
                wait(done);
                test_cycles = cycle_count - test_start_cycle;
            end
            begin
                repeat(200000) @(posedge clk);
                $display("ERROR: Test 92 timeout!");
                $fdisplay(fd_cycles, "Test Vector  92: TIMEOUT");
                test_cycles = -1;
                test_timeout = 1;
            end
        join_any
        disable fork;
        
        if (test_cycles > 0) begin
            repeat(5) @(posedge clk); // Extra cycles for stability
            total_cycles = total_cycles + test_cycles;
            $fdisplay(fd_cycles, "Test Vector  92: %0d cycles (%.2f us @ 100MHz)", test_cycles, test_cycles * 0.01);
            
            // Write outputs
            $fdisplay(fd_output, "%015b %015b", h_t[0], h_t[1]);
        end else begin
            $display("Stopping simulation due to timeout on test 92");
        end
        
        repeat(5) @(posedge clk); // Wait between tests
    end

    // Test Vector 93
    if (!test_timeout) begin
        test_start_cycle = cycle_count;
        
        // Load input data
        x_t[0] = 15'b000000110100111;
        x_t[1] = 15'b000001001011010;
        x_t[2] = 15'b000001001110001;
        x_t[3] = 15'b000001010110011;
        
        h_t_prev[0] = 15'b000000110100111;
        h_t_prev[1] = 15'b000001001011010;
        
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        // Wait for completion with timeout
        fork
            begin
                wait(done);
                test_cycles = cycle_count - test_start_cycle;
            end
            begin
                repeat(200000) @(posedge clk);
                $display("ERROR: Test 93 timeout!");
                $fdisplay(fd_cycles, "Test Vector  93: TIMEOUT");
                test_cycles = -1;
                test_timeout = 1;
            end
        join_any
        disable fork;
        
        if (test_cycles > 0) begin
            repeat(5) @(posedge clk); // Extra cycles for stability
            total_cycles = total_cycles + test_cycles;
            $fdisplay(fd_cycles, "Test Vector  93: %0d cycles (%.2f us @ 100MHz)", test_cycles, test_cycles * 0.01);
            
            // Write outputs
            $fdisplay(fd_output, "%015b %015b", h_t[0], h_t[1]);
        end else begin
            $display("Stopping simulation due to timeout on test 93");
        end
        
        repeat(5) @(posedge clk); // Wait between tests
    end

    // Test Vector 94
    if (!test_timeout) begin
        test_start_cycle = cycle_count;
        
        // Load input data
        x_t[0] = 15'b000001001000101;
        x_t[1] = 15'b000001011110111;
        x_t[2] = 15'b000001011101111;
        x_t[3] = 15'b000001100001010;
        
        h_t_prev[0] = 15'b000001001000101;
        h_t_prev[1] = 15'b000001011110111;
        
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        // Wait for completion with timeout
        fork
            begin
                wait(done);
                test_cycles = cycle_count - test_start_cycle;
            end
            begin
                repeat(200000) @(posedge clk);
                $display("ERROR: Test 94 timeout!");
                $fdisplay(fd_cycles, "Test Vector  94: TIMEOUT");
                test_cycles = -1;
                test_timeout = 1;
            end
        join_any
        disable fork;
        
        if (test_cycles > 0) begin
            repeat(5) @(posedge clk); // Extra cycles for stability
            total_cycles = total_cycles + test_cycles;
            $fdisplay(fd_cycles, "Test Vector  94: %0d cycles (%.2f us @ 100MHz)", test_cycles, test_cycles * 0.01);
            
            // Write outputs
            $fdisplay(fd_output, "%015b %015b", h_t[0], h_t[1]);
        end else begin
            $display("Stopping simulation due to timeout on test 94");
        end
        
        repeat(5) @(posedge clk); // Wait between tests
    end

    // Test Vector 95
    if (!test_timeout) begin
        test_start_cycle = cycle_count;
        
        // Load input data
        x_t[0] = 15'b000000100011101;
        x_t[1] = 15'b000000110100000;
        x_t[2] = 15'b000000101100001;
        x_t[3] = 15'b000000101001101;
        
        h_t_prev[0] = 15'b000000100011101;
        h_t_prev[1] = 15'b000000110100000;
        
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        // Wait for completion with timeout
        fork
            begin
                wait(done);
                test_cycles = cycle_count - test_start_cycle;
            end
            begin
                repeat(200000) @(posedge clk);
                $display("ERROR: Test 95 timeout!");
                $fdisplay(fd_cycles, "Test Vector  95: TIMEOUT");
                test_cycles = -1;
                test_timeout = 1;
            end
        join_any
        disable fork;
        
        if (test_cycles > 0) begin
            repeat(5) @(posedge clk); // Extra cycles for stability
            total_cycles = total_cycles + test_cycles;
            $fdisplay(fd_cycles, "Test Vector  95: %0d cycles (%.2f us @ 100MHz)", test_cycles, test_cycles * 0.01);
            
            // Write outputs
            $fdisplay(fd_output, "%015b %015b", h_t[0], h_t[1]);
        end else begin
            $display("Stopping simulation due to timeout on test 95");
        end
        
        repeat(5) @(posedge clk); // Wait between tests
    end

    // Test Vector 96
    if (!test_timeout) begin
        test_start_cycle = cycle_count;
        
        // Load input data
        x_t[0] = 15'b000000010001001;
        x_t[1] = 15'b000000011111010;
        x_t[2] = 15'b000000010110010;
        x_t[3] = 15'b000000010101001;
        
        h_t_prev[0] = 15'b000000010001001;
        h_t_prev[1] = 15'b000000011111010;
        
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        // Wait for completion with timeout
        fork
            begin
                wait(done);
                test_cycles = cycle_count - test_start_cycle;
            end
            begin
                repeat(200000) @(posedge clk);
                $display("ERROR: Test 96 timeout!");
                $fdisplay(fd_cycles, "Test Vector  96: TIMEOUT");
                test_cycles = -1;
                test_timeout = 1;
            end
        join_any
        disable fork;
        
        if (test_cycles > 0) begin
            repeat(5) @(posedge clk); // Extra cycles for stability
            total_cycles = total_cycles + test_cycles;
            $fdisplay(fd_cycles, "Test Vector  96: %0d cycles (%.2f us @ 100MHz)", test_cycles, test_cycles * 0.01);
            
            // Write outputs
            $fdisplay(fd_output, "%015b %015b", h_t[0], h_t[1]);
        end else begin
            $display("Stopping simulation due to timeout on test 96");
        end
        
        repeat(5) @(posedge clk); // Wait between tests
    end

    // Test Vector 97
    if (!test_timeout) begin
        test_start_cycle = cycle_count;
        
        // Load input data
        x_t[0] = 15'b111111110001000;
        x_t[1] = 15'b111111110010000;
        x_t[2] = 15'b111111011110011;
        x_t[3] = 15'b111111101001101;
        
        h_t_prev[0] = 15'b111111110001000;
        h_t_prev[1] = 15'b111111110010000;
        
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        // Wait for completion with timeout
        fork
            begin
                wait(done);
                test_cycles = cycle_count - test_start_cycle;
            end
            begin
                repeat(200000) @(posedge clk);
                $display("ERROR: Test 97 timeout!");
                $fdisplay(fd_cycles, "Test Vector  97: TIMEOUT");
                test_cycles = -1;
                test_timeout = 1;
            end
        join_any
        disable fork;
        
        if (test_cycles > 0) begin
            repeat(5) @(posedge clk); // Extra cycles for stability
            total_cycles = total_cycles + test_cycles;
            $fdisplay(fd_cycles, "Test Vector  97: %0d cycles (%.2f us @ 100MHz)", test_cycles, test_cycles * 0.01);
            
            // Write outputs
            $fdisplay(fd_output, "%015b %015b", h_t[0], h_t[1]);
        end else begin
            $display("Stopping simulation due to timeout on test 97");
        end
        
        repeat(5) @(posedge clk); // Wait between tests
    end

    // Test Vector 98
    if (!test_timeout) begin
        test_start_cycle = cycle_count;
        
        // Load input data
        x_t[0] = 15'b000000000001000;
        x_t[1] = 15'b111111111111011;
        x_t[2] = 15'b111111101010100;
        x_t[3] = 15'b111111111001011;
        
        h_t_prev[0] = 15'b000000000001000;
        h_t_prev[1] = 15'b111111111111011;
        
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        // Wait for completion with timeout
        fork
            begin
                wait(done);
                test_cycles = cycle_count - test_start_cycle;
            end
            begin
                repeat(200000) @(posedge clk);
                $display("ERROR: Test 98 timeout!");
                $fdisplay(fd_cycles, "Test Vector  98: TIMEOUT");
                test_cycles = -1;
                test_timeout = 1;
            end
        join_any
        disable fork;
        
        if (test_cycles > 0) begin
            repeat(5) @(posedge clk); // Extra cycles for stability
            total_cycles = total_cycles + test_cycles;
            $fdisplay(fd_cycles, "Test Vector  98: %0d cycles (%.2f us @ 100MHz)", test_cycles, test_cycles * 0.01);
            
            // Write outputs
            $fdisplay(fd_output, "%015b %015b", h_t[0], h_t[1]);
        end else begin
            $display("Stopping simulation due to timeout on test 98");
        end
        
        repeat(5) @(posedge clk); // Wait between tests
    end

    // Test Vector 99
    if (!test_timeout) begin
        test_start_cycle = cycle_count;
        
        // Load input data
        x_t[0] = 15'b111111101110100;
        x_t[1] = 15'b111111101001011;
        x_t[2] = 15'b111111010111001;
        x_t[3] = 15'b111111100111010;
        
        h_t_prev[0] = 15'b111111101110100;
        h_t_prev[1] = 15'b111111101001011;
        
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        // Wait for completion with timeout
        fork
            begin
                wait(done);
                test_cycles = cycle_count - test_start_cycle;
            end
            begin
                repeat(200000) @(posedge clk);
                $display("ERROR: Test 99 timeout!");
                $fdisplay(fd_cycles, "Test Vector  99: TIMEOUT");
                test_cycles = -1;
                test_timeout = 1;
            end
        join_any
        disable fork;
        
        if (test_cycles > 0) begin
            repeat(5) @(posedge clk); // Extra cycles for stability
            total_cycles = total_cycles + test_cycles;
            $fdisplay(fd_cycles, "Test Vector  99: %0d cycles (%.2f us @ 100MHz)", test_cycles, test_cycles * 0.01);
            
            // Write outputs
            $fdisplay(fd_output, "%015b %015b", h_t[0], h_t[1]);
        end else begin
            $display("Stopping simulation due to timeout on test 99");
        end
        
        repeat(5) @(posedge clk); // Wait between tests
    end

    // Test Vector 100
    if (!test_timeout) begin
        test_start_cycle = cycle_count;
        
        // Load input data
        x_t[0] = 15'b111111101110100;
        x_t[1] = 15'b111111100100100;
        x_t[2] = 15'b111111001011000;
        x_t[3] = 15'b111111011101100;
        
        h_t_prev[0] = 15'b111111101110100;
        h_t_prev[1] = 15'b111111100100100;
        
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        // Wait for completion with timeout
        fork
            begin
                wait(done);
                test_cycles = cycle_count - test_start_cycle;
            end
            begin
                repeat(200000) @(posedge clk);
                $display("ERROR: Test 100 timeout!");
                $fdisplay(fd_cycles, "Test Vector 100: TIMEOUT");
                test_cycles = -1;
                test_timeout = 1;
            end
        join_any
        disable fork;
        
        if (test_cycles > 0) begin
            repeat(5) @(posedge clk); // Extra cycles for stability
            total_cycles = total_cycles + test_cycles;
            $fdisplay(fd_cycles, "Test Vector 100: %0d cycles (%.2f us @ 100MHz)", test_cycles, test_cycles * 0.01);
            
            // Write outputs
            $fdisplay(fd_output, "%015b %015b", h_t[0], h_t[1]);
        end else begin
            $display("Stopping simulation due to timeout on test 100");
        end
        
        repeat(5) @(posedge clk); // Wait between tests
    end

    // Write summary to cycles file
    $fdisplay(fd_cycles, "");
    $fdisplay(fd_cycles, "==========================================================");
    $fdisplay(fd_cycles, "SUMMARY");
    $fdisplay(fd_cycles, "==========================================================");
    $fdisplay(fd_cycles, "Total Test Vectors: %0d", 100);
    $fdisplay(fd_cycles, "Total Cycles:       %0d", total_cycles);
    $fdisplay(fd_cycles, "Average Cycles:     %.2f", real'(total_cycles) / 100);
    $fdisplay(fd_cycles, "Total Time:         %.2f us @ 100MHz", total_cycles * 0.01);
    $fdisplay(fd_cycles, "Average Time:       %.2f us @ 100MHz", (total_cycles * 0.01) / 100);
    $fdisplay(fd_cycles, "Throughput:         %.2f computations/ms @ 100MHz", 100000.0 / (real'(total_cycles) / 100));
    $fdisplay(fd_cycles, "==========================================================");
    
    $fclose(fd_output);
    $fclose(fd_cycles);
    
    $display("");
    $display("==========================================================");
    $display("Simulation Complete");
    $display("==========================================================");
    $display("Test Vectors:   %0d", 100);
    $display("Total Cycles:   %0d", total_cycles);
    $display("Average Cycles: %.2f", real'(total_cycles) / 100);
    $display("==========================================================");
    $display("Output file:    output_d4_h2_dw15_fb9_np4.txt");
    $display("Cycles file:    cycles_d4_h2_dw15_fb9_np4.txt");
    $display("==========================================================");
    
    $finish;
end

endmodule