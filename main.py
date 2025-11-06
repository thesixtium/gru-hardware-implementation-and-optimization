import subprocess
import os
import re
import pandas as pd

# 🔧 CHANGE THIS to match your Vivado installation path
VIVADO_PATH = r"C:\Xilinx\Vivado\2024.1\bin\vivado.bat"

# Reports are generated in the project directory, not a separate reports folder
VIVADO_PROJECT_DIR = "./vivado_proj"


def run_vivado():
    subprocess.run([VIVADO_PATH, "-mode", "batch", "-source", "run_vivado.tcl"], check=True)


def extract_metrics():
    metrics = {}

    possible_locations = [
        ".",  # Current directory
        VIVADO_PROJECT_DIR,
    ]

    util_file = None
    timing_file = None
    power_file = None

    for loc in possible_locations:
        candidates = [
            os.path.join(loc, "utilization_report.txt"),
            os.path.join(loc, "utilization_post_impl.rpt"),
            os.path.join(loc, "utilization.rpt"),
        ]
        for candidate in candidates:
            if os.path.exists(candidate):
                util_file = candidate
                break
        if util_file:
            break

    # Search for timing report
    for loc in possible_locations:
        candidates = [
            os.path.join(loc, "timing_report.txt"),
            os.path.join(loc, "timing_post_impl.rpt"),
            os.path.join(loc, "timing.rpt"),
        ]
        for candidate in candidates:
            if os.path.exists(candidate):
                timing_file = candidate
                break
        if timing_file:
            break

    # Search for power report
    for loc in possible_locations:
        candidates = [
            os.path.join(loc, "power_report.txt"),
            os.path.join(loc, "power.rpt"),
        ]
        for candidate in candidates:
            if os.path.exists(candidate):
                power_file = candidate
                break
        if power_file:
            break

    # Parse Utilization Report
    if util_file:
        try:
            with open(util_file, encoding='utf-8', errors='ignore') as f:
                data = f.read()

                # Try multiple patterns for different report formats
                lut = re.search(r"CLB LUTs\s*\|\s*(\d+)", data)
                if not lut:
                    lut = re.search(r"Slice LUTs\s*\|\s*(\d+)", data)
                if not lut:
                    lut = re.search(r"LUT.*?\|\s*(\d+)", data)

                reg = re.search(r"CLB Registers\s*\|\s*(\d+)", data)
                if not reg:
                    reg = re.search(r"Slice Registers\s*\|\s*(\d+)", data)
                if not reg:
                    reg = re.search(r"Register.*?\|\s*(\d+)", data)

                bram = re.search(r"Block RAM Tile\s*\|\s*(\d+)", data)
                if not bram:
                    bram = re.search(r"RAMB\d+\s*\|\s*(\d+)", data)

                dsp = re.search(r"DSPs\s*\|\s*(\d+)", data)
                if not dsp:
                    dsp = re.search(r"DSP48E\d*\s*\|\s*(\d+)", data)

                if lut:
                    metrics["LUTs"] = int(lut.group(1))
                if reg:
                    metrics["Registers"] = int(reg.group(1))
                if bram:
                    metrics["BRAMs"] = int(bram.group(1))
                if dsp:
                    metrics["DSPs"] = int(dsp.group(1))
        except Exception as e:
            print(f"Error reading utilization report: {e}")
    else:
        print("Utilization report not found")

    # Parse Timing Report
    if timing_file:
        try:
            with open(timing_file, encoding='utf-8', errors='ignore') as f:
                data = f.read()

                # Look for WNS (Worst Negative Slack)
                wns = re.search(r"WNS\(ns\)\s+([\-\d\.]+)", data)
                if not wns:
                    wns = re.search(r"Worst.*Slack.*?([\-\d\.]+)", data)
                if not wns:
                    wns = re.search(r"slack\s+([\-\d\.]+)", data, re.IGNORECASE)

                # Look for TNS (Total Negative Slack)
                tns = re.search(r"TNS\(ns\)\s+([\-\d\.]+)", data)

                # Look for maximum frequency
                fmax = re.search(r"(?:Max Frequency|Fmax).*?([\d\.]+)\s*MHz", data, re.IGNORECASE)

                if wns:
                    metrics["WNS (ns)"] = float(wns.group(1))
                if tns:
                    metrics["TNS (ns)"] = float(tns.group(1))
                if fmax:
                    metrics["Max Freq (MHz)"] = float(fmax.group(1))
        except Exception as e:
            print(f"Error reading timing report: {e}")
    else:
        print("Timing report not found")

    # Parse Power Report
    if power_file:
        try:
            print(f"📄 Reading power from: {power_file}")
            with open(power_file, encoding='utf-8', errors='ignore') as f:
                data = f.read()

                total_power = re.search(r"Total On-Chip Power\s*\(W\)\s*\|\s*([\d\.]+)", data)
                if not total_power:
                    total_power = re.search(r"Total.*Power.*?([\d\.]+)\s*W", data)

                dynamic_power = re.search(r"Dynamic\s*\(W\)\s*\|\s*([\d\.]+)", data)
                static_power = re.search(r"Device Static\s*\(W\)\s*\|\s*([\d\.]+)", data)

                if total_power:
                    metrics["Total Power (W)"] = float(total_power.group(1))
                if dynamic_power:
                    metrics["Dynamic Power (W)"] = float(dynamic_power.group(1))
                if static_power:
                    metrics["Static Power (W)"] = float(static_power.group(1))
        except Exception as e:
            print(f"Error reading power report: {e}")
    else:
        print("Power report not found")

    return metrics

def generate_gru_sv(D=3, H=2, int_width=8, frac_width=8):
    WIDTH_EXPR = "INT_WIDTH + FRAC_WIDTH + 1"
    indent = "    "
    lines = []
    lines.append("`timescale 1ns / 1ps\n")
    lines.append(f"// d = {D}\n// h = {H}\n// auto-generated GRU module\n")
    lines.append("module gru #(\n")
    lines.append(f"{indent}parameter int INT_WIDTH  = {int_width},\n")
    lines.append(f"{indent}parameter int FRAC_WIDTH = {frac_width},\n")
    lines.append(f"{indent}parameter int WIDTH      = {WIDTH_EXPR}\n")
    lines.append(")(\n")
    lines.append(f"{indent}input  logic                     clk,\n")
    lines.append(f"{indent}input  logic                     reset,\n")
    lines.append("")

    # inputs x
    for i in range(D):
        lines.append(f"{indent}input  logic signed [WIDTH-1:0]  x_0_{i},\n")
    lines.append("")

    # previous hidden state inputs h_0_j
    for j in range(H):
        lines.append(f"{indent}input  logic signed [WIDTH-1:0]  h_0_{j},\n")
    lines.append("")

    def gen_matrix_inputs(prefix, rows, cols):
        for i in range(rows):
            for j in range(cols):
                lines.append(f"{indent}input  logic signed [WIDTH-1:0]  {prefix}_{i}_{j},\n")

    lines.append(f"{indent}// --- Weights for input gates ---\n")
    gen_matrix_inputs("w_ir", D, H)
    lines.append("")
    gen_matrix_inputs("w_iz", D, H)
    lines.append("")
    gen_matrix_inputs("w_in", D, H)
    lines.append("")

    lines.append(f"{indent}// --- Recurrent weights ---\n")

    def gen_square(prefix, n):
        for i in range(n):
            for j in range(n):
                lines.append(f"{indent}input  logic signed [WIDTH-1:0]  {prefix}_{i}_{j},\n")

    gen_square("w_hr", H)
    lines.append("")
    gen_square("w_hz", H)
    lines.append("")
    gen_square("w_hn", H)
    lines.append("")

    lines.append(f"{indent}// --- Biases ---\n")
    for gate in ["b_ir", "b_iz", "b_in", "b_hr", "b_hz", "b_hn"]:
        for j in range(H):
            lines.append(f"{indent}input  logic signed [WIDTH-1:0]  {gate}_0_{j},\n")
        lines.append("")

    lines.append(f"{indent}// --- Outputs ---\n")
    for j in range(H):
        end = "," if j != H - 1 else "\n"
        lines.append(f"{indent}output logic signed [WIDTH-1:0]  y_0_{j}{end}")
    if not lines[-1].endswith("\n"):
        lines.append("\n")
    lines.append(");\n\n")

    lines.append(f"{indent}// ---- Fixed-point multiply helper ----\n")
    lines.append(f"{indent}function automatic logic signed [WIDTH-1:0] fixed_mul(\n")
    lines.append(f"{indent * 2}input logic signed [WIDTH-1:0] a,\n")
    lines.append(f"{indent * 2}input logic signed [WIDTH-1:0] b\n")
    lines.append(f"{indent});\n")
    lines.append(f"{indent * 2}logic signed [2*WIDTH-1:0] tmp;\n")
    lines.append(f"{indent * 2}begin\n")
    lines.append(f"{indent * 3}tmp = a * b;\n")
    lines.append(f"{indent * 3}fixed_mul = tmp >>> FRAC_WIDTH;\n")
    lines.append(f"{indent * 2}end\n")
    lines.append(f"{indent}endfunction\n\n")

    def gen_gate(gate_name, w_prefix, wh_prefix, b_gate):
        lines.append(f"    // =========================================================\n")
        lines.append(f"    // {gate_name} = σ(W_{w_prefix}*x + b_{b_gate} + W_{wh_prefix}*h_prev + b_{b_gate})\n")
        lines.append(f"    // =========================================================\n\n")
        lines.append(f"    logic signed [WIDTH-1:0] {gate_name}_0[{H - 1}:0];\n")
        lines.append(f"    logic signed [WIDTH-1:0] {gate_name}_in_0[{H - 1}:0];\n\n")
        for j in range(H):
            terms = []
            for i in range(D):
                terms.append(f"fixed_mul({w_prefix}_{i}_{j}, x_0_{i})")
            for i in range(H):
                terms.append(f"fixed_mul({wh_prefix}_{i}_{j}, h_0_{i})")
            terms.append(f"{b_gate}_0_{j}")
            sumexpr = " + ".join(terms)
            lines.append(f"    assign {gate_name}_in_0[{j}] =\n        {sumexpr};\n\n")
            lines.append(f"    // instantiate sigmoid for {gate_name}[{j}]\n")
            lines.append(
                f"    sigmoid {gate_name}_sig{j}(.clk(clk), .reset(reset), .x({gate_name}_in_0[{j}]), .y({gate_name}_0[{j}]));\n\n")

    gen_gate("r", "w_ir", "w_hr", "b_ir")
    gen_gate("z", "w_iz", "w_hz", "b_iz")

    lines.append("    // =========================================================\n")
    lines.append("    // Candidate n_t = tanh(W_in*x + b_in + r_t ⊙ (W_hn*h_prev + b_hn))\n")
    lines.append("    // =========================================================\n\n")
    lines.append(f"    logic signed [WIDTH-1:0] n_0[{H - 1}:0];\n")
    lines.append(f"    logic signed [WIDTH-1:0] win_x[{H - 1}:0];\n")
    lines.append(f"    logic signed [WIDTH-1:0] whn_h[{H - 1}:0];\n")
    lines.append(f"    logic signed [WIDTH-1:0] r_whn[{H - 1}:0];\n")
    lines.append(f"    logic signed [WIDTH-1:0] n_in_0[{H - 1}:0];\n\n")

    for j in range(H):
        terms = [f"fixed_mul(w_in_{i}_{j}, x_0_{i})" for i in range(D)]
        terms.append(f"b_in_0_{j}")
        sumexpr = " + ".join(terms)
        lines.append(f"    assign win_x[{j}] = {sumexpr};\n")
    lines.append("\n")
    for j in range(H):
        terms = [f"fixed_mul(w_hn_{i}_{j}, h_0_{i})" for i in range(H)]
        terms.append(f"b_hn_0_{j}")
        sumexpr = " + ".join(terms)
        lines.append(f"    assign whn_h[{j}] = {sumexpr};\n")
    lines.append("\n")
    for j in range(H):
        lines.append(f"    assign r_whn[{j}] = fixed_mul(r_0[{j}], whn_h[{j}]);\n")
    lines.append("\n")
    for j in range(H):
        lines.append(f"    assign n_in_0[{j}] = win_x[{j}] + r_whn[{j}];\n")
        lines.append(f"    tanh n_tanh{j}(.clk(clk), .reset(reset), .x(n_in_0[{j}]), .y(n_0[{j}]));\n\n")

    lines.append("    // =========================================================\n")
    lines.append("    // Final hidden state h_t = (1 - z_t)⊙n_t + z_t⊙h_prev\n")
    lines.append("    // =========================================================\n\n")
    lines.append(f"    localparam logic signed [WIDTH-1:0] ONE_CONST = (1 <<< FRAC_WIDTH);\n\n")
    lines.append(f"    logic signed [WIDTH-1:0] one_minus_z[{H - 1}:0];\n")
    lines.append(f"    logic signed [WIDTH-1:0] part0[{H - 1}:0];\n")
    lines.append(f"    logic signed [WIDTH-1:0] part1[{H - 1}:0];\n")
    lines.append(f"    logic signed [WIDTH-1:0] hnext[{H - 1}:0];\n\n")
    for j in range(H):
        lines.append(f"    assign one_minus_z[{j}] = ONE_CONST - z_0[{j}];\n")
    lines.append("\n")
    for j in range(H):
        lines.append(f"    assign part0[{j}] = fixed_mul(one_minus_z[{j}], n_0[{j}]);\n")
        lines.append(f"    assign part1[{j}] = fixed_mul(z_0[{j}], h_0_{j});\n")
        lines.append(f"    assign hnext[{j}] = part0[{j}] + part1[{j}];\n\n")

    lines.append("    // --- Registered outputs ---\n")
    lines.append("    always_ff @(posedge clk) begin\n")
    lines.append("        if (reset) begin\n")
    for j in range(H):
        lines.append(f"            y_0_{j} <= '0;\n")
    lines.append("        end else begin\n")
    for j in range(H):
        lines.append(f"            y_0_{j} <= hnext[{j}];\n")
    lines.append("        end\n")
    lines.append("    end\n\n")
    lines.append("endmodule\n")

    return "".join(lines)


def generate_top_level_sv(D=3, H=2, int_width=8, frac_width=8):
    """Generate a top-level wrapper module for the GRU"""
    indent = "    "
    lines = []

    lines.append("`timescale 1ns / 1ps\n")
    lines.append(f"// d = {D}\n// h = {H}\n// auto-generated top-level wrapper for GRU\n")
    lines.append("module top_level(\n")
    lines.append(f"{indent}input  logic clk,\n")
    lines.append(f"{indent}input  logic reset\n")
    lines.append(");\n\n")

    # Parameters
    lines.append(f"{indent}// Parameters must match the generated GRU module parameters\n")
    lines.append(f"{indent}localparam int INT_WIDTH  = {int_width};\n")
    lines.append(f"{indent}localparam int FRAC_WIDTH = {frac_width};\n")
    lines.append(f"{indent}localparam int WIDTH      = INT_WIDTH + FRAC_WIDTH + 1;\n\n")

    # Input signals x_0_i
    lines.append(f"{indent}// --- Input signals ---\n")
    for i in range(D):
        lines.append(f"{indent}(* keep = \"true\", dont_touch = \"true\" *) logic signed [WIDTH-1:0] x_0_{i} = '0;\n")
    lines.append("\n")

    # Hidden state inputs h_0_j
    lines.append(f"{indent}// --- Previous hidden state ---\n")
    for j in range(H):
        lines.append(f"{indent}(* keep = \"true\", dont_touch = \"true\" *) logic signed [WIDTH-1:0] h_0_{j} = '0;\n")
    lines.append("\n")

    # Output signals
    lines.append(f"{indent}// --- Output signals ---\n")
    for j in range(H):
        lines.append(f"{indent}(* keep = \"true\", dont_touch = \"true\" *) logic signed [WIDTH-1:0] y_0_{j} = '0;\n")
    lines.append("\n")

    # Weight matrices
    lines.append(f"{indent}// --- Weights for input gates (initialized to small constants) ---\n")
    for prefix in ["w_ir", "w_iz", "w_in"]:
        for i in range(D):
            for j in range(H):
                lines.append(
                    f"{indent}(* keep = \"true\", dont_touch = \"true\" *) logic signed [WIDTH-1:0] {prefix}_{i}_{j} = 16'sd1;\n")
        lines.append("\n")

    # Recurrent weights
    lines.append(f"{indent}// --- Recurrent weights ---\n")
    for prefix in ["w_hr", "w_hz", "w_hn"]:
        for i in range(H):
            for j in range(H):
                lines.append(
                    f"{indent}(* keep = \"true\", dont_touch = \"true\" *) logic signed [WIDTH-1:0] {prefix}_{i}_{j} = 16'sd1;\n")
        lines.append("\n")

    # Biases
    lines.append(f"{indent}// --- Biases ---\n")
    for gate in ["b_ir", "b_iz", "b_in", "b_hr", "b_hz", "b_hn"]:
        for j in range(H):
            lines.append(
                f"{indent}(* keep = \"true\", dont_touch = \"true\" *) logic signed [WIDTH-1:0] {gate}_0_{j} = '0;\n")
        lines.append("\n")

    # Preserved outputs
    lines.append(f"{indent}// --- Final registers to capture and preserve the outputs ---\n")
    for j in range(H):
        lines.append(
            f"{indent}(* keep = \"true\", dont_touch = \"true\" *) logic signed [WIDTH-1:0] preserved_y_0_{j} = '0;\n")
    lines.append("\n")

    # GRU instantiation
    lines.append(f"{indent}// --- Instantiate the generated GRU module ---\n")
    lines.append(f"{indent}(* keep = \"true\", dont_touch = \"true\" *) gru #(\n")
    lines.append(f"{indent * 2}.INT_WIDTH(INT_WIDTH),\n")
    lines.append(f"{indent * 2}.FRAC_WIDTH(FRAC_WIDTH)\n")
    lines.append(f"{indent}) gru_inst (\n")
    lines.append(f"{indent * 2}.clk(clk),\n")
    lines.append(f"{indent * 2}.reset(reset),\n")

    # Connect inputs
    for i in range(D):
        lines.append(f"{indent * 2}.x_0_{i}(x_0_{i}),\n")
    for j in range(H):
        lines.append(f"{indent * 2}.h_0_{j}(h_0_{j}),\n")

    # Connect weights
    for prefix in ["w_ir", "w_iz", "w_in"]:
        for i in range(D):
            for j in range(H):
                lines.append(f"{indent * 2}.{prefix}_{i}_{j}({prefix}_{i}_{j}),\n")

    for prefix in ["w_hr", "w_hz", "w_hn"]:
        for i in range(H):
            for j in range(H):
                lines.append(f"{indent * 2}.{prefix}_{i}_{j}({prefix}_{i}_{j}),\n")

    # Connect biases
    for gate in ["b_ir", "b_iz", "b_in", "b_hr", "b_hz", "b_hn"]:
        for j in range(H):
            lines.append(f"{indent * 2}.{gate}_0_{j}({gate}_0_{j}),\n")

    # Connect outputs (last ones without comma)
    for j in range(H):
        end = "," if j != H - 1 else ""
        lines.append(f"{indent * 2}.y_0_{j}(y_0_{j}){end}\n")
    lines.append(f"{indent});\n\n")

    # Output preservation logic
    lines.append(f"{indent}// --- Capture outputs into preserved registers ---\n")
    lines.append(f"{indent}always_ff @(posedge clk) begin\n")
    lines.append(f"{indent * 2}if (reset) begin\n")
    for j in range(H):
        lines.append(f"{indent * 3}preserved_y_0_{j} <= '0;\n")
    lines.append(f"{indent * 2}end else begin\n")
    for j in range(H):
        lines.append(f"{indent * 3}preserved_y_0_{j} <= y_0_{j};\n")
    lines.append(f"{indent * 2}end\n")
    lines.append(f"{indent}end\n\n")

    lines.append("endmodule\n")

    return "".join(lines)


import numpy as np


def generate_tb(D=4, H=2):
    code = ""

    def sigmoid(x):
        return 1 / (1 + np.exp(-x))


    all_vars = ["clk", "reset"]
    declared_vars = set()  # Track what's been declared


    def array_to_signals(array, var_name):
        lines = []
        for i in range(array.shape[0]):
            for j in range(array.shape[1]):
                signal_name = f"{var_name}_{i}_{j}"
                if signal_name not in declared_vars:
                    lines.append(f"\treg signed [WIDTH-1:0] {signal_name};")
                    all_vars.append(signal_name)
                    declared_vars.add(signal_name)
        return "\n".join(lines) + "\n" if lines else ""


    # Generate example test file
    def generate_test_file(filename, num_tests=10):
        with open(filename, 'w') as f:
            f.write("# GRU Test Cases\n")
            f.write("# Format: x(1x4) h(1x2) w_ir(4x2) w_in(4x2) w_iz(4x2) w_hr(2x2) w_hn(2x2) w_hz(2x2) ")
            f.write("b_ir(1x2) b_in(1x2) b_iz(1x2) b_hr(1x2) b_hn(1x2) b_hz(1x2) -> y_expected(1x2)\n\n")

            for test_id in range(num_tests):
                np.random.seed(test_id)

                # Generate random inputs (smaller values for stability)
                x = np.random.randn(1, D) * 0.5
                h = np.random.randn(1, H) * 0.5

                w_ir = np.random.randn(D, H) * 0.3
                w_in = np.random.randn(D, H) * 0.3
                w_iz = np.random.randn(D, H) * 0.3

                w_hr = np.random.randn(H, H) * 0.3
                w_hn = np.random.randn(H, H) * 0.3
                w_hz = np.random.randn(H, H) * 0.3

                b_ir = np.random.randn(1, H) * 0.2
                b_in = np.random.randn(1, H) * 0.2
                b_iz = np.random.randn(1, H) * 0.2

                b_hr = np.random.randn(1, H) * 0.2
                b_hn = np.random.randn(1, H) * 0.2
                b_hz = np.random.randn(1, H) * 0.2

                # Calculate expected output
                r_t = sigmoid(x @ w_ir + b_ir + h @ w_hr + b_hr)
                n_t = np.tanh(x @ w_in + b_in + r_t * (h @ w_hn + b_hn))
                z_t = sigmoid(x @ w_iz + b_iz + h @ w_hz + b_hz)
                y = (1 - z_t) * n_t + z_t * h

                # Write test case
                arrays = [x, h, w_ir, w_in, w_iz, w_hr, w_hn, w_hz,
                          b_ir, b_in, b_iz, b_hr, b_hn, b_hz, y]

                for arr in arrays:
                    for val in arr.flatten():
                        f.write(f"{val:.6f} ")
                f.write("\n")


    # Generate the test file
    generate_test_file("gru_test_cases.txt", num_tests=20)

    # Define array dimensions for parsing
    array_dims = {
        'x': (1, D), 'h': (1, H),
        'w_ir': (D, H), 'w_in': (D, H), 'w_iz': (D, H),
        'w_hr': (H, H), 'w_hn': (H, H), 'w_hz': (H, H),
        'b_ir': (1, H), 'b_in': (1, H), 'b_iz': (1, H),
        'b_hr': (1, H), 'b_hn': (1, H), 'b_hz': (1, H),
        'y': (1, H)
    }

    # Define variable names lists
    var_names = ['x', 'h', 'w_ir', 'w_in', 'w_iz', 'w_hr', 'w_hn', 'w_hz',
                 'b_ir', 'b_in', 'b_iz', 'b_hr', 'b_hn', 'b_hz', 'y']

    input_var_names = ['x', 'h', 'w_ir', 'w_in', 'w_iz', 'w_hr', 'w_hn', 'w_hz',
                       'b_ir', 'b_in', 'b_iz', 'b_hr', 'b_hn', 'b_hz']

    code += "`timescale 1ns / 1ps\n"
    code += "\n"
    code += "module gru_tb();\n"
    code += "\n"
    code += "    // Parameters\n"
    code += "    parameter CLK_PERIOD = 10; // 10ns for 100MHz clock\n"
    code += "    parameter int INT_WIDTH  = 8;\n"
    code += "    parameter int FRAC_WIDTH = 8;\n"
    code += "    parameter int WIDTH      = INT_WIDTH + FRAC_WIDTH + 1;\n"
    code += "    parameter string TEST_FILE = \"gru_test_cases.txt\";\n"
    code += "\n"
    code += "    // Signals\n"
    code += "    reg clk = 0;\n"
    code += "    reg reset = 0;\n"
    code += "\n"

    # Declare all signals in the correct order
    for var_name in var_names:
        dims = array_dims[var_name]
        dummy_array = np.zeros(dims)
        code += array_to_signals(dummy_array, var_name)
        code += "\n"

    # Add variables for error calculation
    code += "    // Error tracking\n"
    code += "    real expected_y_0_0, expected_y_0_1;\n"
    code += "    real actual_y_0_0, actual_y_0_1;\n"
    code += "    real error_0_0, error_0_1;\n"
    code += "    real sum_squared_error = 0.0;\n"
    code += "    real sum_absolute_error = 0.0;\n"
    code += "    int test_count = 0;\n"
    code += "    real rmse, mae;\n"
    code += "\n"
    code += "    // File handling\n"
    code += "    integer file, status;\n"
    code += "    string line;\n"
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
    code += "    // Convert fixed-point to real\n"
    code += "    function real fixed_to_real(logic signed [WIDTH-1:0] val);\n"
    code += "        return $itor(val) / 256.0;\n"
    code += "    endfunction\n"
    code += "\n"
    code += "    // Test stimulus\n"
    code += "    initial begin\n"
    code += "        real values[100];\n"
    code += "        int idx;\n"
    code += "        \n"
    code += "        file = $fopen(TEST_FILE, \"r\");\n"
    code += "        if (file == 0) begin\n"
    code += "            $display(\"ERROR: Could not open test file %s\", TEST_FILE);\n"
    code += "            $finish;\n"
    code += "        end\n"
    code += "        $display(\"Opened test file: %s\", TEST_FILE);\n"
    code += "\n"
    code += "        // Initialize all signals to zero\n"
    for var_name in input_var_names:
        dims = array_dims[var_name]
        for i in range(dims[0]):
            for j in range(dims[1]):
                code += f"        {var_name}_{i}_{j} = 0;\n"
    code += "\n"
    code += "        // Initial reset\n"
    code += "        reset = 1;\n"
    code += "        #(2 * CLK_PERIOD);\n"
    code += "        reset = 0;\n"
    code += "        #(CLK_PERIOD);\n"
    code += "\n"
    code += "        // Read and process each test case\n"
    code += "        while (!$feof(file)) begin\n"
    code += "            status = $fgets(line, file);\n"
    code += "            if (status == 0) break;\n"
    code += "            \n"
    code += "            // Skip comments and empty lines\n"
    code += "            if (line.len() == 0) continue;\n"
    code += "            if (line[0] == \"#\") continue;\n"
    code += "            if (line[0] == \"\\n\") continue;\n"
    code += "            if (line[0] == \" \" && line.len() < 10) continue;\n"
    code += "            \n"
    code += "            $display(\"Processing line: %s\", line);\n"
    code += "            \n"
    code += "            // Parse the line\n"
    code += "            idx = 0;\n"
    code += "            status = $sscanf(line, \"%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f\",\n"

    # Generate scanf format for all values
    n_values = D + (D*H*3) + (H*H*3) + (8*H)
    for i in range(n_values):
        code += f"                values[{i}]"
        if i < 55:
            code += ","
        code += "\n"
    code += "            );\n"
    code += "\n"
    code += "            $display(\"  Parsed %0d values from line\", status);\n"
    code += f"            if (status < {n_values}) begin\n"
    code += f"                $display(\"  WARNING: Skipping malformed line (expected {n_values} values, got %0d)\", status);\n"
    code += "                continue;\n"
    code += "            end\n"
    code += "\n"
    code += "            // Assign input values\n"
    code += "            idx = 0;\n"

    # Use the already-defined input_var_names
    for var_name in input_var_names:
        dims = array_dims[var_name]
        for i in range(dims[0]):
            for j in range(dims[1]):
                code += f"            {var_name}_{i}_{j} = $rtoi(values[idx] * 256.0); idx = idx + 1;\n"

    code += "            // Store expected outputs\n"
    code += "            expected_y_0_0 = values[idx++];\n"
    code += "            expected_y_0_1 = values[idx++];\n"
    code += "\n"
    code += "            // Wait for computation\n"
    code += "            #(10 * CLK_PERIOD);\n"
    code += "\n"
    code += "            // Read actual outputs\n"
    code += "            actual_y_0_0 = fixed_to_real(y_0_0);\n"
    code += "            actual_y_0_1 = fixed_to_real(y_0_1);\n"
    code += "\n"
    code += "            // Calculate errors\n"
    code += "            error_0_0 = expected_y_0_0 - actual_y_0_0;\n"
    code += "            error_0_1 = expected_y_0_1 - actual_y_0_1;\n"
    code += "\n"
    code += "            sum_squared_error += (error_0_0 * error_0_0) + (error_0_1 * error_0_1);\n"
    code += "            sum_absolute_error += (error_0_0 < 0 ? -error_0_0 : error_0_0) + (error_0_1 < 0 ? -error_0_1 : error_0_1);\n"
    code += "            test_count++;\n"
    code += "\n"
    code += "            $display(\"Test %0d: Expected=[%f, %f], Actual=[%f, %f], Error=[%f, %f]\",\n"
    code += "                     test_count, expected_y_0_0, expected_y_0_1, \n"
    code += "                     actual_y_0_0, actual_y_0_1, error_0_0, error_0_1);\n"
    code += "        end\n"
    code += "\n"
    code += "        $fclose(file);\n"
    code += "\n"
    code += "        // Calculate and display metrics\n"
    code += "        if (test_count > 0) begin\n"
    code += "            rmse = $sqrt(sum_squared_error / (test_count * 2.0));\n"
    code += "            mae = sum_absolute_error / (test_count * 2.0);\n"
    code += "            \n"
    code += "            $display(\"\\n==================================\");\n"
    code += "            $display(\"Test Summary:\");\n"
    code += "            $display(\"Total tests: %0d\", test_count);\n"
    code += "            $display(\"RMSE: %f\", rmse);\n"
    code += "            $display(\"MAE:  %f\", mae);\n"
    code += "            $display(\"==================================\");\n"
    code += "        end else begin\n"
    code += "            $display(\"ERROR: No valid test cases found\");\n"
    code += "        end\n"
    code += "\n"
    code += "        #(10 * CLK_PERIOD);\n"
    code += "        $stop;\n"
    code += "    end\n"
    code += "endmodule\n"

    with open("gru_tb.sv", "w+", encoding="utf-8") as f:
        f.write(code)

    print("Generated files:")
    print("  - gru_tb.sv (testbench)")
    print("  - gru_test_cases.txt (20 test cases)")
    print("\nIMPORTANT: Make sure gru_test_cases.txt is in the simulation working directory!")
    print("For Vivado, copy it to: <project>.sim/sim_1/behav/xsim/")


def main():
    data = []

    for int_bits in [8]:
        for frac_bits in [8]:
            for d in [2]:
                for h in [2]:
                    try:
                        # Generate SV code
                        gru_code = generate_gru_sv(D=d, H=h, int_width=int_bits, frac_width=frac_bits)
                        with open("gru.sv", "w+", encoding="utf-8") as f:
                            f.write(gru_code)
                        print("Generated gru.sv")

                        # Generate top-level wrapper
                        top_level_code = generate_top_level_sv(D=d, H=h, int_width=int_bits, frac_width=frac_bits)
                        with open("top_level.sv", "w+", encoding="utf-8") as f:
                            f.write(top_level_code)
                        print("Generated top_level.sv")

                        # Accuracy Metrics
                        generate_tb(D=d, H=h)

                        # Other Metrics
                        run_vivado()

                        # Step 3: Extract metrics
                        metrics = extract_metrics()

                        print("\nHardware Metrics Summary")
                        print("=" * 50)
                        if metrics:
                            metrics["D"] = d
                            metrics["H"] = h
                            metrics["int bits"] = int_bits
                            metrics["frac bits"] = frac_bits
                            for k, v in metrics.items():
                                print(f"{k:20s}: {v}")

                            data.append(metrics)
                        else:
                            print("No metrics extracted - reports may not have been generated")
                        print("=" * 50)

                    except Exception as e:
                        print( e )

                    pd.DataFrame(data).to_csv("data.csv", index=False)



if __name__ == "__main__":
    main()
