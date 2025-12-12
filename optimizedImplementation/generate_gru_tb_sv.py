import math

from twosComp import float_to_fixed_point


def generate_gru_tb_sv(INT_WIDTH=3, FRAC_WIDTH=8, d=64, h=4, NUM_TEST_VECTORS=100, NUM_PARALLEL=4):
    with open('testbenchInputs/hd_weights.txt', 'r') as f:
        input_weights = [float(x) for x in f.read().split()]

    with open('testbenchInputs/hh_weights.txt', 'r') as f:
        recurrent_weights = [float(x) for x in f.read().split()]

    with open('testbenchInputs/bias_weights.txt', 'r') as f:
        bias_weights = [float(x) for x in f.read().split()]

    with open('testbenchInputs/input_data.txt', 'r') as f:
        input_data = [[float(x) for x in line.split()] for line in f]

    DATA_WIDTH = INT_WIDTH + FRAC_WIDTH

    testbench = "`timescale 1ns / 1ps\n"
    testbench += "\n"
    testbench += "module gru_tb;\n"
    testbench += "\n"
    testbench += "// Parameters\n"
    testbench += f"parameter int D          = {d};\n"
    testbench += f"parameter int H          = {h};\n"
    testbench += f"parameter int DATA_WIDTH = {DATA_WIDTH};\n"
    testbench += f"parameter int FRAC_BITS  = {FRAC_WIDTH};\n"
    testbench += f"parameter int NUM_PARALLEL = {NUM_PARALLEL};\n"
    testbench += "parameter real CLK_PERIOD = 10.0;\n"
    testbench += "\n"
    testbench += "// Clock and reset\n"
    testbench += "logic clk;\n"
    testbench += "logic rst_n;\n"
    testbench += "logic start;\n"
    testbench += "logic done;\n"
    testbench += "\n"
    testbench += "// Cycle counter\n"
    testbench += "int cycle_count = 0;\n"
    testbench += "int test_start_cycle = 0;\n"
    testbench += "int test_cycles = 0;\n"
    testbench += "int total_cycles = 0;\n"
    testbench += "bit test_timeout = 0;\n"  # FIXED: Added declaration
    testbench += "\n"
    testbench += "// Input arrays\n"
    testbench += f"logic signed [DATA_WIDTH-1:0] x_t [D-1:0];\n"
    testbench += f"logic signed [DATA_WIDTH-1:0] h_t_prev [H-1:0];\n"
    testbench += f"logic signed [DATA_WIDTH-1:0] h_t [H-1:0];\n"
    testbench += "\n"
    testbench += "// Weight matrices\n"
    testbench += "logic signed [DATA_WIDTH-1:0] W_ir [H-1:0][D-1:0];\n"
    testbench += "logic signed [DATA_WIDTH-1:0] W_hr [H-1:0][H-1:0];\n"
    testbench += "logic signed [DATA_WIDTH-1:0] b_ir [H-1:0];\n"
    testbench += "logic signed [DATA_WIDTH-1:0] b_hr [H-1:0];\n"
    testbench += "\n"
    testbench += "logic signed [DATA_WIDTH-1:0] W_iz [H-1:0][D-1:0];\n"
    testbench += "logic signed [DATA_WIDTH-1:0] W_hz [H-1:0][H-1:0];\n"
    testbench += "logic signed [DATA_WIDTH-1:0] b_iz [H-1:0];\n"
    testbench += "logic signed [DATA_WIDTH-1:0] b_hz [H-1:0];\n"
    testbench += "\n"
    testbench += "logic signed [DATA_WIDTH-1:0] W_in [H-1:0][D-1:0];\n"
    testbench += "logic signed [DATA_WIDTH-1:0] W_hn [H-1:0][H-1:0];\n"
    testbench += "logic signed [DATA_WIDTH-1:0] b_in [H-1:0];\n"
    testbench += "logic signed [DATA_WIDTH-1:0] b_hn [H-1:0];\n"
    testbench += "\n"
    testbench += "// DUT instantiation\n"
    testbench += "gru_cell_parallel #(\n"
    testbench += "    .D(D),\n"
    testbench += "    .H(H),\n"
    testbench += "    .DATA_WIDTH(DATA_WIDTH),\n"
    testbench += "    .FRAC_BITS(FRAC_BITS),\n"
    testbench += "    .NUM_PARALLEL(NUM_PARALLEL)\n"
    testbench += ") dut (\n"
    testbench += "    .clk(clk),\n"
    testbench += "    .rst_n(rst_n),\n"
    testbench += "    .start(start),\n"
    testbench += "    .x_t(x_t),\n"
    testbench += "    .h_t_prev(h_t_prev),\n"
    testbench += "    .W_ir(W_ir),\n"
    testbench += "    .W_hr(W_hr),\n"
    testbench += "    .b_ir(b_ir),\n"
    testbench += "    .b_hr(b_hr),\n"
    testbench += "    .W_iz(W_iz),\n"
    testbench += "    .W_hz(W_hz),\n"
    testbench += "    .b_iz(b_iz),\n"
    testbench += "    .b_hz(b_hz),\n"
    testbench += "    .W_in(W_in),\n"
    testbench += "    .W_hn(W_hn),\n"
    testbench += "    .b_in(b_in),\n"
    testbench += "    .b_hn(b_hn),\n"
    testbench += "    .h_t(h_t),\n"
    testbench += "    .done(done)\n"
    testbench += ");\n"
    testbench += "\n"
    testbench += "// Clock generation\n"
    testbench += "initial begin\n"
    testbench += "    clk = 0;\n"
    testbench += "    forever #5 clk = ~clk; // 100MHz clock\n"
    testbench += "end\n"
    testbench += "\n"
    testbench += "// Cycle counter\n"
    testbench += "always_ff @(posedge clk or negedge rst_n) begin\n"
    testbench += "    if (!rst_n) begin\n"
    testbench += "        cycle_count <= 0;\n"
    testbench += "    end else begin\n"
    testbench += "        cycle_count <= cycle_count + 1;\n"
    testbench += "    end\n"
    testbench += "end\n"
    testbench += "\n"
    testbench += "initial begin\n"
    testbench += "    // Open files for writing\n"
    testbench += "    integer fd_output;\n"
    testbench += "    integer fd_cycles;\n"
    testbench += "    \n"
    testbench += f"    fd_output = $fopen(\"../../../../../output_d{d}_h{h}_dw{DATA_WIDTH}_fb{FRAC_WIDTH}_np{NUM_PARALLEL}.txt\", \"w+\");\n"
    testbench += "    if (fd_output == 0) begin\n"
    testbench += "        $display(\"ERROR: Failed to open output file!\");\n"
    testbench += "        $finish;\n"
    testbench += "    end\n"
    testbench += "    \n"
    testbench += f"    fd_cycles = $fopen(\"../../../../../cycles_d{d}_h{h}_dw{DATA_WIDTH}_fb{FRAC_WIDTH}_np{NUM_PARALLEL}.txt\", \"w+\");\n"
    testbench += "    if (fd_cycles == 0) begin\n"
    testbench += "        $display(\"ERROR: Failed to open cycles file!\");\n"
    testbench += "        $fclose(fd_output);\n"
    testbench += "        $finish;\n"
    testbench += "    end\n"
    testbench += "    \n"
    testbench += "    // Write header to cycles file\n"
    testbench += "    $fdisplay(fd_cycles, \"==========================================================\");\n"
    testbench += "    $fdisplay(fd_cycles, \"GRU Cell Parallel Cycle Count Results\");\n"
    testbench += "    $fdisplay(fd_cycles, \"==========================================================\");\n"
    testbench += "    $fdisplay(fd_cycles, \"Parameters:\");\n"
    testbench += f"    $fdisplay(fd_cycles, \"  D (Input Dimension):     {d}\");\n"
    testbench += f"    $fdisplay(fd_cycles, \"  H (Hidden Dimension):    {h}\");\n"
    testbench += f"    $fdisplay(fd_cycles, \"  DATA_WIDTH:              {DATA_WIDTH}\");\n"
    testbench += f"    $fdisplay(fd_cycles, \"  FRAC_BITS:               {FRAC_WIDTH}\");\n"
    testbench += f"    $fdisplay(fd_cycles, \"  NUM_PARALLEL:            {NUM_PARALLEL}\");\n"
    testbench += f"    $fdisplay(fd_cycles, \"  Total Test Vectors:      {NUM_TEST_VECTORS}\");\n"
    testbench += "    $fdisplay(fd_cycles, \"==========================================================\");\n"
    testbench += "    $fdisplay(fd_cycles, \"\");\n"
    testbench += "    \n"
    testbench += "    // Initialize weights\n"

    # Initialize W_ir weights
    input_count = 0
    testbench += "    // Initialize W_ir weights\n"
    for i in range(h):
        for j in range(d):
            val = float_to_fixed_point(input_weights[input_count % len(input_weights)], INT_WIDTH, FRAC_WIDTH)
            testbench += f"    W_ir[{i}][{j}] = {DATA_WIDTH}'b{val};\n"
            input_count += 1

    # Initialize W_iz weights
    testbench += "\n    // Initialize W_iz weights\n"
    for i in range(h):
        for j in range(d):
            val = float_to_fixed_point(input_weights[input_count % len(input_weights)], INT_WIDTH, FRAC_WIDTH)
            testbench += f"    W_iz[{i}][{j}] = {DATA_WIDTH}'b{val};\n"
            input_count += 1

    # Initialize W_in weights
    testbench += "\n    // Initialize W_in weights\n"
    for i in range(h):
        for j in range(d):
            val = float_to_fixed_point(input_weights[input_count % len(input_weights)], INT_WIDTH, FRAC_WIDTH)
            testbench += f"    W_in[{i}][{j}] = {DATA_WIDTH}'b{val};\n"
            input_count += 1

    # Initialize recurrent weights
    recurrent_count = 0
    testbench += "\n    // Initialize W_hr weights\n"
    for i in range(h):
        for j in range(h):
            val = float_to_fixed_point(recurrent_weights[recurrent_count % len(recurrent_weights)], INT_WIDTH,
                                       FRAC_WIDTH)
            testbench += f"    W_hr[{i}][{j}] = {DATA_WIDTH}'b{val};\n"
            recurrent_count += 1

    testbench += "\n    // Initialize W_hz weights\n"
    for i in range(h):
        for j in range(h):
            val = float_to_fixed_point(recurrent_weights[recurrent_count % len(recurrent_weights)], INT_WIDTH,
                                       FRAC_WIDTH)
            testbench += f"    W_hz[{i}][{j}] = {DATA_WIDTH}'b{val};\n"
            recurrent_count += 1

    testbench += "\n    // Initialize W_hn weights\n"
    for i in range(h):
        for j in range(h):
            val = float_to_fixed_point(recurrent_weights[recurrent_count % len(recurrent_weights)], INT_WIDTH,
                                       FRAC_WIDTH)
            testbench += f"    W_hn[{i}][{j}] = {DATA_WIDTH}'b{val};\n"
            recurrent_count += 1

    # Initialize biases
    bias_count = 0
    testbench += "\n    // Initialize biases\n"
    for gate in ['ir', 'iz', 'in', 'hr', 'hz', 'hn']:
        testbench += f"\n    // Initialize b_{gate} biases\n"
        for i in range(h):
            val = float_to_fixed_point(bias_weights[bias_count % len(bias_weights)], INT_WIDTH, FRAC_WIDTH)
            testbench += f"    b_{gate}[{i}] = {DATA_WIDTH}'b{val};\n"
            bias_count += 1

    testbench += "\n    // Reset sequence\n"
    testbench += "    rst_n = 0;\n"
    testbench += "    start = 0;\n"
    testbench += "    test_start_cycle = 0;\n"
    testbench += "    test_cycles = 0;\n"
    testbench += "    total_cycles = 0;\n"
    testbench += "    test_timeout = 0;\n"
    testbench += "    repeat(10) @(posedge clk);\n"
    testbench += "    rst_n = 1;\n"
    testbench += "    repeat(5) @(posedge clk);\n"
    testbench += "\n"

    # Test vectors loop
    for n in range(NUM_TEST_VECTORS):
        testbench += f"    // Test Vector {n + 1}\n"
        testbench += "    if (!test_timeout) begin\n"
        testbench += "        test_start_cycle = cycle_count;\n"
        testbench += "        \n"

        # Load input data
        testbench += "        // Load input data\n"
        for i in range(d):
            val = float_to_fixed_point(input_data[n % len(input_data)][i % len(input_data[n])], INT_WIDTH, FRAC_WIDTH)
            testbench += f"        x_t[{i}] = {DATA_WIDTH}'b{val};\n"

        testbench += "        \n"
        for i in range(h):
            val = float_to_fixed_point(input_data[n % len(input_data)][i % len(input_data[n])], INT_WIDTH, FRAC_WIDTH)
            testbench += f"        h_t_prev[{i}] = {DATA_WIDTH}'b{val};\n"

        testbench += "        \n"
        testbench += "        @(posedge clk);\n"
        testbench += "        start = 1;\n"
        testbench += "        @(posedge clk);\n"
        testbench += "        start = 0;\n"
        testbench += "        \n"
        testbench += "        // Wait for completion with timeout\n"
        testbench += "        fork\n"
        testbench += "            begin\n"
        testbench += "                wait(done);\n"
        testbench += "                test_cycles = cycle_count - test_start_cycle;\n"
        testbench += "            end\n"
        testbench += "            begin\n"
        testbench += "                repeat(200000) @(posedge clk);\n"
        testbench += f"                $display(\"ERROR: Test {n + 1} timeout!\");\n"
        testbench += f"                $fdisplay(fd_cycles, \"Test Vector {n + 1:3d}: TIMEOUT\");\n"
        testbench += "                test_cycles = -1;\n"
        testbench += "                test_timeout = 1;\n"
        testbench += "            end\n"
        testbench += "        join_any\n"
        testbench += "        disable fork;\n"
        testbench += "        \n"
        testbench += "        if (test_cycles > 0) begin\n"
        testbench += "            repeat(5) @(posedge clk); // Extra cycles for stability\n"
        testbench += "            total_cycles = total_cycles + test_cycles;\n"
        testbench += f"            $fdisplay(fd_cycles, \"Test Vector {n + 1:3d}: %0d cycles (%.2f us @ 100MHz)\", test_cycles, test_cycles * 0.01);\n"
        testbench += "            \n"
        testbench += "            // Write outputs\n"

        # Generate format string for output
        format_str = ' '.join([f'%0{DATA_WIDTH}b' for _ in range(h)])
        h_t_list = ', '.join([f'h_t[{i}]' for i in range(h)])
        testbench += f"            $fdisplay(fd_output, \"{format_str}\", {h_t_list});\n"
        testbench += "        end else begin\n"
        testbench += f"            $display(\"Stopping simulation due to timeout on test {n + 1}\");\n"
        testbench += "        end\n"
        testbench += "        \n"
        testbench += "        repeat(5) @(posedge clk); // Wait between tests\n"
        testbench += "    end\n"
        testbench += "\n"

    # Summary and cleanup
    testbench += "    // Write summary to cycles file\n"
    testbench += "    $fdisplay(fd_cycles, \"\");\n"
    testbench += "    $fdisplay(fd_cycles, \"==========================================================\");\n"
    testbench += "    $fdisplay(fd_cycles, \"SUMMARY\");\n"
    testbench += "    $fdisplay(fd_cycles, \"==========================================================\");\n"
    testbench += f"    $fdisplay(fd_cycles, \"Total Test Vectors: %0d\", {NUM_TEST_VECTORS});\n"
    testbench += "    $fdisplay(fd_cycles, \"Total Cycles:       %0d\", total_cycles);\n"
    testbench += f"    $fdisplay(fd_cycles, \"Average Cycles:     %.2f\", real'(total_cycles) / {NUM_TEST_VECTORS});\n"
    testbench += "    $fdisplay(fd_cycles, \"Total Time:         %.2f us @ 100MHz\", total_cycles * 0.01);\n"
    testbench += f"    $fdisplay(fd_cycles, \"Average Time:       %.2f us @ 100MHz\", (total_cycles * 0.01) / {NUM_TEST_VECTORS});\n"
    testbench += f"    $fdisplay(fd_cycles, \"Throughput:         %.2f computations/ms @ 100MHz\", 100000.0 / (real'(total_cycles) / {NUM_TEST_VECTORS}));\n"
    testbench += "    $fdisplay(fd_cycles, \"==========================================================\");\n"
    testbench += "    \n"
    testbench += "    $fclose(fd_output);\n"
    testbench += "    $fclose(fd_cycles);\n"
    testbench += "    \n"
    testbench += "    $display(\"\");\n"
    testbench += "    $display(\"==========================================================\");\n"
    testbench += "    $display(\"Simulation Complete\");\n"
    testbench += "    $display(\"==========================================================\");\n"
    testbench += f"    $display(\"Test Vectors:   %0d\", {NUM_TEST_VECTORS});\n"
    testbench += "    $display(\"Total Cycles:   %0d\", total_cycles);\n"
    testbench += f"    $display(\"Average Cycles: %.2f\", real'(total_cycles) / {NUM_TEST_VECTORS});\n"
    testbench += "    $display(\"==========================================================\");\n"
    testbench += f"    $display(\"Output file:    output_d{d}_h{h}_dw{DATA_WIDTH}_fb{FRAC_WIDTH}_np{NUM_PARALLEL}.txt\");\n"
    testbench += f"    $display(\"Cycles file:    cycles_d{d}_h{h}_dw{DATA_WIDTH}_fb{FRAC_WIDTH}_np{NUM_PARALLEL}.txt\");\n"
    testbench += "    $display(\"==========================================================\");\n"
    testbench += "    \n"
    testbench += "    $finish;\n"
    testbench += "end\n"
    testbench += "\n"
    testbench += "endmodule"

    return testbench


# Example usage:
if __name__ == "__main__":
    # Generate testbench for d=64, h=4
    tb_code = generate_gru_tb_sv(INT_WIDTH=3, FRAC_WIDTH=10, d=3, h=2, NUM_TEST_VECTORS=10, NUM_PARALLEL=2)
    print(tb_code)