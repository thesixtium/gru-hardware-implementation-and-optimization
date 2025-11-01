import numpy as np

code = ""

def sigmoid(x):
    return 1 / (1 + np.exp(-x))

def float_to_q8_8_signed( x ):
    sign_bit = 0 if x >= 0 else 1
    magnitude = int(round(abs(x) * 256))  # 8 fractional bits
    magnitude_bin = f"{magnitude:016b}"
    full_bin = f"{sign_bit}{magnitude_bin}"
    formatted = "_".join(full_bin[i:i + 4] for i in range(0, len(full_bin), 4))
    return "'b" + formatted

all_vars = ["clk", "reset"]

def array_to_signals( array, var_name ):
    lines = []
    for i in range(array.shape[0]):
        for j in range(array.shape[1]):
            value = array[i, j]
            lines.append(f"\tlogic signed [WIDTH-1:0] {var_name}_{i}_{j} = {float_to_q8_8_signed(value)};")
            all_vars.append(f"{var_name}_{i}_{j}")
    return "\n".join(lines) + "\n"

x = np.array([[0.1, 0.2, 0.3, 0.4]])
h = np.array([[0.1, 0.2]])

w_ir = np.array([[0.1, 0.2], [0.3, 0.4], [0.5, 0.6], [0.5, 0.6]])
w_in = np.array([[0.1, 0.2], [0.3, 0.4], [0.5, 0.6], [0.5, 0.6]])
w_iz = np.array([[0.1, 0.2], [0.3, 0.4], [0.5, 0.6], [0.5, 0.6]])

w_hr = np.array([[0.1, 0.2], [0.3, 0.4]])
w_hn = np.array([[0.1, 0.2], [0.3, 0.4]])
w_hz = np.array([[0.1, 0.2], [0.3, 0.4]])

b_ir = np.array([[0.1, 0.2]])
b_in = np.array([[0.1, 0.2]])
b_iz = np.array([[0.1, 0.2]])

b_hr = np.array([[0.1, 0.2]])
b_hn = np.array([[0.1, 0.2]])
b_hz = np.array([[0.1, 0.2]])

r_t = sigmoid(x @ w_ir + b_ir + h @ w_hr + b_hr)
n_t = np.tanh(x @ w_in + b_in + r_t * (h @ w_hn + b_hn))
z_t = sigmoid(x @ w_iz + b_iz + h @ w_hz + b_hz)
y = (1 - z_t) * n_t + z_t * h


code += "`timescale 1ns / 1ps\n"
code += "\n"
code += "module gru_tb();\n"
code += "\n"
code += "    // Parameters\n"
code += "    parameter CLK_PERIOD = 10; // 10ns for 100MHz clock\n"
code += "    parameter int INT_WIDTH  = 8;\n"
code += "    parameter int FRAC_WIDTH = 8;\n"
code += "    parameter int WIDTH      = INT_WIDTH + FRAC_WIDTH + 1;\n"
code += "\n"
code += "    // Signals\n"
code += "    logic clk = 0;\n"
code += "    logic reset = 0;\n"
code += "\n"

for var in [
    x, h, w_ir, w_in, w_iz,
    w_hr, w_hn, w_hz, b_ir, b_in,
    b_iz, b_hr, b_hn, b_hz, y
]:
    code += array_to_signals( var, [name for name, val in locals().items() if val is var][0] )
    code += "\n"

code += "    gru uut (\n"
for var in all_vars:
    code += f"        .{var}({var})"
    if var != all_vars[-1]:
        code += ",\n"
    else:
        code += "\n"

code += "    );\n"
code += "\n"
code += "    always #(CLK_PERIOD / 2) clk = ~clk;\n"
code += "\n"
code += "    // Test stimulus\n"
code += "    initial begin\n"
code += "        reset = 0;\n"
code += "        #(10 * CLK_PERIOD);\n"
code += "        reset = 1;\n"
code += "        #(10 * CLK_PERIOD);\n"
code += "        reset = 0;\n"
code += "        #(100 * CLK_PERIOD);\n"
code += "        $stop;\n"
code += "    end\n"
code += "endmodule\n"

with open("../gru_tb.sv", "w+", encoding="utf-8") as f:
    f.write(code)


