import math

from twosComp import  float_to_fixed_point

def generate_gru_tb_sv(INT_WIDTH=3, FRAC_WIDTH=8, d=64, h=4, NUM_TEST_VECTORS = 100):

    with open('testbenchInputs/hd_weights.txt', 'r') as f:
        input_weights = [float(x) for x in f.read().split()]

    with open('testbenchInputs/hh_weights.txt', 'r') as f:
        recurrent_weights = [float(x) for x in f.read().split()]

    with open('testbenchInputs/bias_weights.txt', 'r') as f:
        bias_weights = [float(x) for x in f.read().split()]

    with open('testbenchInputs/input_data.txt', 'r') as f:
        input_data = [[float(x) for x in line.split()] for line in f]

    testbench = "`timescale 1ns / 1ps\n"
    testbench += "\n"
    testbench += "module gru_tb;\n"
    testbench += "\n"
    testbench += "// Parameters\n"
    testbench += f"parameter int INT_WIDTH  = {INT_WIDTH};\n"
    testbench += f"parameter int FRAC_WIDTH = {FRAC_WIDTH};\n"
    testbench += "parameter int WIDTH      = INT_WIDTH + FRAC_WIDTH;\n"
    testbench += "parameter real CLK_PERIOD = 10.0;\n"
    testbench += "\n"
    testbench += "// Clock and reset\n"
    testbench += "logic clk;\n"
    testbench += "logic reset;\n"
    testbench += "\n"
    testbench += "// Inputs\n"

    for i in range(d):
        testbench += f"logic signed [WIDTH-1:0] x_{i} = 0;\n"

    testbench += "\n"

    for i in range(h):
        testbench += f"logic signed [WIDTH-1:0] h_{i} = 0;\n"

    testbench += f"\n"
    testbench += f"// Input weights (h×d for each gate)\n"

    input_count = 0
    for i in range(h):
        for j in range(d):
            testbench += f"logic signed [WIDTH-1:0] w_ir_{i}_{j} = 'b{float_to_fixed_point(input_weights[input_count % len(input_weights)], INT_WIDTH, FRAC_WIDTH)};\n"
            input_count += 1

    testbench += f"\n"
    for i in range(h):
        for j in range(d):
            testbench += f"logic signed [WIDTH-1:0] w_iz_{i}_{j} = 'b{float_to_fixed_point(input_weights[input_count % len(input_weights)], INT_WIDTH, FRAC_WIDTH)};\n"
            input_count += 1

    testbench += f"\n"
    for i in range(h):
        for j in range(d):
            testbench += f"logic signed [WIDTH-1:0] w_in_{i}_{j} = 'b{float_to_fixed_point(input_weights[input_count % len(input_weights)], INT_WIDTH, FRAC_WIDTH)};\n"
            input_count += 1

    testbench += f"\n"
    testbench += f"// Recurrent weights (h×h for each gate)\n"
    recurrent_count = 0

    for i in range(h):
        for j in range(h):
            testbench += f"logic signed [WIDTH-1:0] w_hr_{i}_{j} = 'b{float_to_fixed_point(recurrent_weights[recurrent_count % len(recurrent_weights)], INT_WIDTH, FRAC_WIDTH)};\n"
            recurrent_count += 1

    testbench += f"\n"
    for i in range(h):
        for j in range(h):
            testbench += f"logic signed [WIDTH-1:0] w_hz_{i}_{j} = 'b{float_to_fixed_point(recurrent_weights[recurrent_count % len(recurrent_weights)], INT_WIDTH, FRAC_WIDTH)};\n"
            recurrent_count += 1

    testbench += f"\n"
    for i in range(h):
        for j in range(h):
            testbench += f"logic signed [WIDTH-1:0] w_hn_{i}_{j} = 'b{float_to_fixed_point(recurrent_weights[recurrent_count % len(recurrent_weights)], INT_WIDTH, FRAC_WIDTH)};\n"
            recurrent_count += 1

    testbench += f"\n"
    testbench += f"// Biases (h for each gate type)\n"

    bias_count = 0
    for gate in ['ir', 'iz', 'in', 'hr', 'hz', 'hn']:
        for i in range(h):
            testbench += f"logic signed [WIDTH-1:0] b_{gate}_{i} = 'b{float_to_fixed_point(bias_weights[bias_count % len(bias_weights)], INT_WIDTH, FRAC_WIDTH)};\n"
            bias_count += 1
        testbench += "\n"

    testbench += f"// Outputs (h={h})\n"
    for i in range(h):
        testbench += f"logic signed [WIDTH-1:0]  y_{i} = 0;\n"

    testbench += """
gru #(
        .INT_WIDTH(INT_WIDTH),
        .FRAC_WIDTH(FRAC_WIDTH)
    ) gru_inst (
        .clk(clk),
        .reset(reset),
        // Input features (d=64)
        """

    testbench += "\t\n"
    for i in range(d):
        testbench += f".x_{i}(x_{i}), "

    testbench += "\t\n"
    for i in range(h):
        testbench += f".h_{i}(h_{i}), "

    testbench += f"\t\n"
    for i in range(h):
        for j in range(d):
            testbench += f".w_ir_{i}_{j}(w_ir_{i}_{j}), "

    testbench += f"\t\n"
    for i in range(h):
        for j in range(d):
            testbench += f".w_iz_{i}_{j}(w_iz_{i}_{j}), "

    testbench += f"\n"
    for i in range(h):
        for j in range(d):
            testbench += f".w_in_{i}_{j}(w_in_{i}_{j}), "

    testbench += f"\n"
    for i in range(h):
        for j in range(h):
            testbench += f".w_hr_{i}_{j}(w_hr_{i}_{j}), "

    testbench += f"\n"
    for i in range(h):
        for j in range(h):
            testbench += f".w_hz_{i}_{j}(w_hz_{i}_{j}), "

    testbench += f"\n"
    for i in range(h):
        for j in range(h):
            testbench += f".w_hn_{i}_{j}(w_hn_{i}_{j}), "

    testbench += f"\n"
    for gate in ['ir', 'iz', 'in', 'hr', 'hz', 'hn']:
        for i in range(h):
            testbench += f".b_{gate}_{i}(b_{gate}_{i}), "
        testbench += "\n"

    for i in range(h):
        if i == h-1:
            testbench += f".y_{i}(y_{i})"
        else:
            testbench += f".y_{i}(y_{i}), "

    testbench += "\n);"

    testbench += "\n"
    testbench += f"""
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    initial begin
        // Open file for writing (overwrite existing)
        integer fd;
        fd = $fopen("../../../../../output_d{d}_h{h}_int{INT_WIDTH}_frac{FRAC_WIDTH}.txt", "w+");
        if (fd == 0) begin
            $display("ERROR: Failed to open file!");
            $finish;
        end
    """

    for n in range (NUM_TEST_VECTORS):

        for i in range(d):
            testbench += f"    x_{i} = 'b{float_to_fixed_point( input_data[ n % len(input_data) ][ i % len(input_data[n]) ], INT_WIDTH, FRAC_WIDTH)};\n"

        testbench += "\n"

        for i in range(h):
            testbench += f"    h_{i} = 'b{float_to_fixed_point( input_data[ n % len(input_data) ][ i % len(input_data[n]) ], INT_WIDTH, FRAC_WIDTH)};\n"

        testbench += "    #20;\n"
        testbench += f"    $fdisplay(fd, \"{''.join([f'%0{INT_WIDTH+FRAC_WIDTH}b ' for _ in range(h)])[:-1]}\", {''.join([f'y_{g}, ' for g in range(h)])[:-2]});\n\n"

    testbench += "    $fclose(fd);    \n$finish;\n    end"



    return testbench + "\nendmodule"


# Example usage:
if __name__ == "__main__":
    # Generate testbench for d=64, h=4
    tb_code = generate_gru_tb_sv(INT_WIDTH=3, FRAC_WIDTH=10, d=3, h=2)
    print(tb_code)
