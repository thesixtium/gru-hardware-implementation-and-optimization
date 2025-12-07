// ============================================================================
// GRU Cell Parallel Testbench with Cycle Counting
// ============================================================================
`timescale 1ns/1ps

module tb_gru_cell_parallel #(
    parameter int D = 64,          // Smaller for faster testing
    parameter int H = 16,         // Smaller for faster testing
    parameter int DATA_WIDTH = 15,
    parameter int FRAC_BITS = 9,
    parameter int NUM_PARALLEL = 4
);

    // Clock and reset
    logic clk;
    logic rst_n;
    logic start;
    logic done;
    
    // Cycle counter
    int cycle_count;
    int computation_cycles;
    int start_cycle;
    
    // Test data
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
    
    // Expected outputs (software reference)
    real h_t_expected_float [H-1:0];
    logic signed [DATA_WIDTH-1:0] h_t_expected [H-1:0];
    
    // Debug: intermediate gate values
    logic signed [DATA_WIDTH-1:0] r_t_ref [H-1:0];
    logic signed [DATA_WIDTH-1:0] z_t_ref [H-1:0];
    logic signed [DATA_WIDTH-1:0] n_t_ref [H-1:0];
    
    // File handles
    int results_file;
    string results_filename;
    
    // Test tracking
    int test_number = 0;
    int total_tests = 0;
    int passed_tests = 0;
    
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
    
    // Test stimulus and verification
    initial begin
        // Generate filename with all parameters
        results_filename = $sformatf("gru_results_D%0d_H%0d_DW%0d_FB%0d_NP%0d.txt",
                                      D, H, DATA_WIDTH, FRAC_BITS, NUM_PARALLEL);
        results_file = $fopen(results_filename, "w");
        
        if (results_file == 0) begin
            $display("ERROR: Could not open results file!");
            $finish;
        end
        
        // Write header
        $fwrite(results_file, "==========================================================\n");
        $fwrite(results_file, "GRU Cell Parallel Test Results\n");
        $fwrite(results_file, "==========================================================\n");
        $fwrite(results_file, "Parameters:\n");
        $fwrite(results_file, "  D (Input Dimension):     %0d\n", D);
        $fwrite(results_file, "  H (Hidden Dimension):    %0d\n", H);
        $fwrite(results_file, "  DATA_WIDTH:              %0d bits\n", DATA_WIDTH);
        $fwrite(results_file, "  FRAC_BITS:               %0d bits\n", FRAC_BITS);
        $fwrite(results_file, "  NUM_PARALLEL:            %0d units\n", NUM_PARALLEL);
        $fwrite(results_file, "  Fixed-point format:      Q%0d.%0d\n", DATA_WIDTH-FRAC_BITS, FRAC_BITS);
        $fwrite(results_file, "==========================================================\n\n");
        
        // Initialize
        rst_n = 0;
        start = 0;
        
        // Reset
        repeat(10) @(posedge clk);
        rst_n = 1;
        repeat(5) @(posedge clk);
        
        // Run multiple tests
        for (int test = 0; test < 10; test++) begin
            test_number = test + 1;
            total_tests++;
            
            $display("\n========================================");
            $display("Test %0d", test_number);
            $display("========================================");
            $fwrite(results_file, "Test %0d:\n", test_number);
            $fwrite(results_file, "----------------------------------------\n");
            
            // Initialize test vectors
            initialize_test_data();
            
            // Compute expected output using floating-point reference
            compute_expected_output_float();
            
            @(posedge clk);
            
            // Start computation and measure cycles
            start_cycle = cycle_count;
            start = 1;
            @(posedge clk);
            start = 0;
            
            // Wait for completion with timeout
            fork
                begin
                    wait(done);
                    computation_cycles = cycle_count - start_cycle;
                end
                begin
                    repeat(200000) @(posedge clk);
                    $display("ERROR: Test %0d timeout!", test_number);
                    $fwrite(results_file, "ERROR: Test timeout after 200000 cycles\n\n");
                    computation_cycles = -1;
                end
            join_any
            disable fork;
            
            if (computation_cycles > 0) begin
                repeat(5) @(posedge clk); // Extra cycles to ensure outputs are stable
                
                // Report cycles
                $display("Computation completed in %0d cycles", computation_cycles);
                $display("Time: %.2f us @ 100MHz", computation_cycles * 0.01);
                $fwrite(results_file, "Cycles: %0d\n", computation_cycles);
                $fwrite(results_file, "Time:   %.2f us @ 100MHz\n", computation_cycles * 0.01);
                
                // Sample hardware internal states for debugging
                $fwrite(results_file, "\nHardware internal states (first 3 elements):\n");
                for (int i = 0; i < 3 && i < H; i++) begin
                    $fwrite(results_file, "  Element %0d:\n", i);
                    $fwrite(results_file, "    r_t[%0d] = %0d (%.3f)\n", 
                            i, dut.r_t[i], $itor(dut.r_t[i])/(2.0**FRAC_BITS));
                    $fwrite(results_file, "    z_t[%0d] = %0d (%.3f)\n",
                            i, dut.z_t[i], $itor(dut.z_t[i])/(2.0**FRAC_BITS));
                    $fwrite(results_file, "    n_t[%0d] = %0d (%.3f)\n",
                            i, dut.n_t[i], $itor(dut.n_t[i])/(2.0**FRAC_BITS));
                    $fwrite(results_file, "    h_t[%0d] = %0d (%.3f)\n",
                            i, h_t[i], $itor(h_t[i])/(2.0**FRAC_BITS));
                end
                $fwrite(results_file, "\n");
                
                // Verify outputs
                verify_outputs();
            end else begin
                break;
            end
            
            // Wait between tests
            repeat(10) @(posedge clk);
        end
        
        // Summary
        $display("\n========================================");
        $display("SUMMARY");
        $display("========================================");
        $display("Total tests:  %0d", total_tests);
        $display("Passed:       %0d", passed_tests);
        $display("Failed:       %0d", total_tests - passed_tests);
        if (computation_cycles > 0) begin
            $display("Avg cycles:   %0d", computation_cycles);
        end
        
        $fwrite(results_file, "\n==========================================================\n");
        $fwrite(results_file, "SUMMARY\n");
        $fwrite(results_file, "==========================================================\n");
        $fwrite(results_file, "Total tests:  %0d\n", total_tests);
        $fwrite(results_file, "Passed:       %0d\n", passed_tests);
        $fwrite(results_file, "Failed:       %0d\n", total_tests - passed_tests);
        if (computation_cycles > 0 && total_tests > 0) begin
            $fwrite(results_file, "Avg cycles:   %0d per computation\n", computation_cycles);
            $fwrite(results_file, "Throughput:   %.2f computations/ms @ 100MHz\n", 
                    100000.0 / computation_cycles);
        end
        $fwrite(results_file, "==========================================================\n");
        
        $fclose(results_file);
        $display("\nResults written to: %s", results_filename);
        $finish;
    end
    
    // Initialize test data with known values
    task initialize_test_data();
        // Initialize with very small values to avoid overflow
        for (int i = 0; i < D; i++) begin
            x_t[i] = ($random() & 16'h01FF) - 16'h0100; // -256 to 255
        end
        
        for (int i = 0; i < H; i++) begin
            h_t_prev[i] = ($random() & 16'h01FF) - 16'h0100;
        end
        
        // Small weights
        for (int i = 0; i < H; i++) begin
            b_ir[i] = ($random() & 16'h007F) - 16'h0040; // -64 to 63
            b_hr[i] = ($random() & 16'h007F) - 16'h0040;
            b_iz[i] = ($random() & 16'h007F) - 16'h0040;
            b_hz[i] = ($random() & 16'h007F) - 16'h0040;
            b_in[i] = ($random() & 16'h007F) - 16'h0040;
            b_hn[i] = ($random() & 16'h007F) - 16'h0040;
            
            for (int j = 0; j < D; j++) begin
                W_ir[i][j] = ($random() & 16'h001F) - 16'h0010; // -16 to 15
                W_iz[i][j] = ($random() & 16'h001F) - 16'h0010;
                W_in[i][j] = ($random() & 16'h001F) - 16'h0010;
            end
            
            for (int j = 0; j < H; j++) begin
                W_hr[i][j] = ($random() & 16'h001F) - 16'h0010;
                W_hz[i][j] = ($random() & 16'h001F) - 16'h0010;
                W_hn[i][j] = ($random() & 16'h001F) - 16'h0010;
            end
        end
    endtask
    
    // Bit-accurate fixed-point reference model (matches hardware exactly)
    task compute_expected_output_float();
        automatic logic signed [DATA_WIDTH-1:0] one;
        automatic real scale;
        
        one = (1 << FRAC_BITS);
        scale = 2.0 ** FRAC_BITS;
        
        // Compute reset gate - exactly matching hardware
        for (int i = 0; i < H; i++) begin
            automatic logic signed [2*DATA_WIDTH-1:0] sum_input;
            automatic logic signed [2*DATA_WIDTH-1:0] sum_hidden;
            automatic logic signed [2*DATA_WIDTH-1:0] mac_result;
            
            sum_input = 0;
            sum_hidden = 0;
            
            // MAC input: W_ir @ x_t
            for (int j = 0; j < D; j++) begin
                sum_input = sum_input + (W_ir[i][j] * x_t[j]);
            end
            
            // MAC hidden: W_hr @ h_t_prev
            for (int j = 0; j < H; j++) begin
                sum_hidden = sum_hidden + (W_hr[i][j] * h_t_prev[j]);
            end
            
            // Add bias (matching hardware: scale then add)
            mac_result = (sum_input >>> FRAC_BITS) + (sum_hidden >>> FRAC_BITS) + 
                         {{DATA_WIDTH{b_ir[i][DATA_WIDTH-1]}}, b_ir[i]} + 
                         {{DATA_WIDTH{b_hr[i][DATA_WIDTH-1]}}, b_hr[i]};
            
            r_t_ref[i] = sigmoid_hw(mac_result[DATA_WIDTH-1:0]);
        end
        
        // Compute update gate - exactly matching hardware
        for (int i = 0; i < H; i++) begin
            automatic logic signed [2*DATA_WIDTH-1:0] sum_input;
            automatic logic signed [2*DATA_WIDTH-1:0] sum_hidden;
            automatic logic signed [2*DATA_WIDTH-1:0] mac_result;
            
            sum_input = 0;
            sum_hidden = 0;
            
            for (int j = 0; j < D; j++) begin
                sum_input = sum_input + (W_iz[i][j] * x_t[j]);
            end
            
            for (int j = 0; j < H; j++) begin
                sum_hidden = sum_hidden + (W_hz[i][j] * h_t_prev[j]);
            end
            
            mac_result = (sum_input >>> FRAC_BITS) + (sum_hidden >>> FRAC_BITS) + 
                         {{DATA_WIDTH{b_iz[i][DATA_WIDTH-1]}}, b_iz[i]} + 
                         {{DATA_WIDTH{b_hz[i][DATA_WIDTH-1]}}, b_hz[i]};
            
            z_t_ref[i] = sigmoid_hw(mac_result[DATA_WIDTH-1:0]);
        end
        
        // Compute new gate - exactly matching hardware (with reset gate applied to hidden)
        for (int i = 0; i < H; i++) begin
            automatic logic signed [2*DATA_WIDTH-1:0] sum_input;
            automatic logic signed [2*DATA_WIDTH-1:0] sum_hidden;
            automatic logic signed [2*DATA_WIDTH-1:0] sum_hidden_gated;
            automatic logic signed [2*DATA_WIDTH-1:0] mac_result;
            
            sum_input = 0;
            sum_hidden = 0;
            
            // MAC input
            for (int j = 0; j < D; j++) begin
                sum_input = sum_input + (W_in[i][j] * x_t[j]);
            end
            
            // MAC hidden
            for (int j = 0; j < H; j++) begin
                sum_hidden = sum_hidden + (W_hn[i][j] * h_t_prev[j]);
            end
            
            // Apply reset gate: r_t * (sum_hidden + b_hn) - matching hardware exactly
            sum_hidden_gated = (r_t_ref[i] * ((sum_hidden >>> FRAC_BITS) + 
                               {{DATA_WIDTH{b_hn[i][DATA_WIDTH-1]}}, b_hn[i]})) >>> FRAC_BITS;
            
            // Add input contribution and input bias
            mac_result = (sum_input >>> FRAC_BITS) + 
                        {{DATA_WIDTH{b_in[i][DATA_WIDTH-1]}}, b_in[i]} + 
                        sum_hidden_gated[DATA_WIDTH-1:0];
            
            n_t_ref[i] = tanh_hw(mac_result[DATA_WIDTH-1:0]);
        end
        
        // Compute final hidden state - exactly matching hardware
        for (int i = 0; i < H; i++) begin
            automatic logic signed [2*DATA_WIDTH-1:0] term1;
            automatic logic signed [2*DATA_WIDTH-1:0] term2;
            
            term1 = (one - z_t_ref[i]) * n_t_ref[i];
            term2 = z_t_ref[i] * h_t_prev[i];
            
            h_t_expected[i] = ((term1 + term2) >>> FRAC_BITS);
            h_t_expected_float[i] = $itor(h_t_expected[i]) / scale;
        end
    endtask
    
    // Verify outputs
    task verify_outputs();
        automatic int errors = 0;
        automatic int max_error = 0;
        automatic real max_error_percent = 0.0;
        automatic logic signed [DATA_WIDTH-1:0] error;
        automatic logic signed [DATA_WIDTH-1:0] abs_error;
        automatic int tolerance;
        automatic real scale;
        
        scale = 2.0 ** FRAC_BITS;
        tolerance = (1 << (FRAC_BITS - 4)); // 1/16 of a unit - tight tolerance for exact match
        
        // First, let's debug the first few elements in detail
        $fwrite(results_file, "\nDetailed comparison (first 3 elements):\n");
        for (int dbg_i = 0; dbg_i < 3 && dbg_i < H; dbg_i++) begin
            $fwrite(results_file, "\nElement %0d:\n", dbg_i);
            $fwrite(results_file, "  Reset gate r_t[%0d]:   HW=%5d (%.3f)  Ref=%5d (%.3f)  Diff=%4d\n", 
                    dbg_i, 
                    dut.r_t[dbg_i], $itor(dut.r_t[dbg_i])/scale,
                    r_t_ref[dbg_i], $itor(r_t_ref[dbg_i])/scale,
                    dut.r_t[dbg_i] - r_t_ref[dbg_i]);
            $fwrite(results_file, "  Update gate z_t[%0d]:  HW=%5d (%.3f)  Ref=%5d (%.3f)  Diff=%4d\n",
                    dbg_i,
                    dut.z_t[dbg_i], $itor(dut.z_t[dbg_i])/scale,
                    z_t_ref[dbg_i], $itor(z_t_ref[dbg_i])/scale,
                    dut.z_t[dbg_i] - z_t_ref[dbg_i]);
            $fwrite(results_file, "  New gate n_t[%0d]:     HW=%5d (%.3f)  Ref=%5d (%.3f)  Diff=%4d\n",
                    dbg_i,
                    dut.n_t[dbg_i], $itor(dut.n_t[dbg_i])/scale,
                    n_t_ref[dbg_i], $itor(n_t_ref[dbg_i])/scale,
                    dut.n_t[dbg_i] - n_t_ref[dbg_i]);
            $fwrite(results_file, "  Hidden h_t[%0d]:       HW=%5d (%.3f)  Ref=%5d (%.3f)  Diff=%4d\n",
                    dbg_i,
                    h_t[dbg_i], $itor(h_t[dbg_i])/scale,
                    h_t_expected[dbg_i], h_t_expected_float[dbg_i],
                    h_t[dbg_i] - h_t_expected[dbg_i]);
        end
        $fwrite(results_file, "\n");
        
        for (int i = 0; i < H; i++) begin
            error = h_t[i] - h_t_expected[i];
            abs_error = (error < 0) ? -error : error;
            
            if (abs_error > tolerance) begin
                automatic real error_percent = 100.0 * $itor(abs_error) / (scale + 0.001);
                errors++;
                if (abs_error > max_error) begin
                    max_error = abs_error;
                    max_error_percent = error_percent;
                end
                
                if (errors <= 5) begin
                    $fwrite(results_file, "  h_t[%3d]: HW=%7d (%7.3f)  Ref=%7d (%7.3f)  Err=%5d (%5.2f%%)\n",
                            i, h_t[i], $itor(h_t[i])/scale,
                            h_t_expected[i], h_t_expected_float[i],
                            error, error_percent);
                end
            end
        end
        
        if (errors == 0) begin
            $display("PASS: All %0d outputs within tolerance", H);
            $fwrite(results_file, "Result: PASS - All %0d outputs within tolerance (%.3f)\n\n", 
                    H, $itor(tolerance)/scale);
            passed_tests++;
        end else begin
            $display("FAIL: %0d/%0d outputs exceed tolerance", errors, H);
            $display("      Max error: %0d (%.2f%%)", max_error, max_error_percent);
            $fwrite(results_file, "Result: FAIL - %0d/%0d outputs exceed tolerance\n", errors, H);
            $fwrite(results_file, "        Max error: %0d (%.3f, %.2f%%)\n", 
                    max_error, $itor(max_error)/scale, max_error_percent);
            $fwrite(results_file, "        Tolerance: %0d (%.3f)\n\n", 
                    tolerance, $itor(tolerance)/scale);
            
            if (errors > 5) begin
                $fwrite(results_file, "        (Only first 5 errors shown)\n\n");
            end
        end
    endtask
    
    // Hardware-accurate sigmoid (matches gru_reset_gate_element.sv and gru_update_gate_element.sv)
    function automatic logic signed [DATA_WIDTH-1:0] sigmoid_hw(
        input logic signed [DATA_WIDTH-1:0] x
    );
        automatic logic signed [DATA_WIDTH-1:0] one = (1 << FRAC_BITS);
        automatic logic signed [DATA_WIDTH-1:0] half = (1 << (FRAC_BITS-1));
        
        if (x < -(5*half))
            return 0;
        else if (x > (5*half))
            return one;
        else
            return ((x >>> 2) + (x >>> 3)) + half;
    endfunction
    
    // Hardware-accurate tanh (matches gru_new_gate_element.sv)
    function automatic logic signed [DATA_WIDTH-1:0] tanh_hw(
        input logic signed [DATA_WIDTH-1:0] x
    );
        automatic logic signed [DATA_WIDTH-1:0] one = (1 << FRAC_BITS);
        automatic logic signed [DATA_WIDTH-1:0] neg_one = -(1 << FRAC_BITS);
        
        if (x < -(one << 1))
            return neg_one;
        else if (x > (one << 1))
            return one;
        else
            return x >>> 1;
    endfunction

endmodule