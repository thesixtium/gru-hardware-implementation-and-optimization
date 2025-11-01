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
        end = "," if j != H-1 else "\n"
        lines.append(f"{indent}output logic signed [WIDTH-1:0]  y_0_{j}{end}")
    if not lines[-1].endswith("\n"):
        lines.append("\n")
    lines.append(");\n\n")

    lines.append(f"{indent}// ---- Fixed-point multiply helper ----\n")
    lines.append(f"{indent}function automatic logic signed [WIDTH-1:0] fixed_mul(\n")
    lines.append(f"{indent*2}input logic signed [WIDTH-1:0] a,\n")
    lines.append(f"{indent*2}input logic signed [WIDTH-1:0] b\n")
    lines.append(f"{indent});\n")
    lines.append(f"{indent*2}logic signed [2*WIDTH-1:0] tmp;\n")
    lines.append(f"{indent*2}begin\n")
    lines.append(f"{indent*3}tmp = a * b;\n")
    lines.append(f"{indent*3}fixed_mul = tmp >>> FRAC_WIDTH;\n")
    lines.append(f"{indent*2}end\n")
    lines.append(f"{indent}endfunction\n\n")

    def gen_gate(gate_name, w_prefix, wh_prefix, b_gate):
        lines.append(f"    // =========================================================\n")
        lines.append(f"    // {gate_name} = σ(W_{w_prefix}*x + b_{b_gate} + W_{wh_prefix}*h_prev + b_{b_gate})\n")
        lines.append(f"    // =========================================================\n\n")
        lines.append(f"    logic signed [WIDTH-1:0] {gate_name}_0[{H-1}:0];\n")
        lines.append(f"    logic signed [WIDTH-1:0] {gate_name}_in_0[{H-1}:0];\n\n")
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
            lines.append(f"    sigmoid {gate_name}_sig{j}(.clk(clk), .reset(reset), .x({gate_name}_in_0[{j}]), .y({gate_name}_0[{j}]));\n\n")

    gen_gate("r", "w_ir", "w_hr", "b_ir")
    gen_gate("z", "w_iz", "w_hz", "b_iz")

    lines.append("    // =========================================================\n")
    lines.append("    // Candidate n_t = tanh(W_in*x + b_in + r_t ⊙ (W_hn*h_prev + b_hn))\n")
    lines.append("    // =========================================================\n\n")
    lines.append(f"    logic signed [WIDTH-1:0] n_0[{H-1}:0];\n")
    lines.append(f"    logic signed [WIDTH-1:0] win_x[{H-1}:0];\n")
    lines.append(f"    logic signed [WIDTH-1:0] whn_h[{H-1}:0];\n")
    lines.append(f"    logic signed [WIDTH-1:0] r_whn[{H-1}:0];\n")
    lines.append(f"    logic signed [WIDTH-1:0] n_in_0[{H-1}:0];\n\n")

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
    lines.append(f"    logic signed [WIDTH-1:0] one_minus_z[{H-1}:0];\n")
    lines.append(f"    logic signed [WIDTH-1:0] part0[{H-1}:0];\n")
    lines.append(f"    logic signed [WIDTH-1:0] part1[{H-1}:0];\n")
    lines.append(f"    logic signed [WIDTH-1:0] hnext[{H-1}:0];\n\n")
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

# Generate with default D=3, H=2 and save to file, then print
sv_code = generate_gru_sv(D=4, H=2)

with open("../gru.sv", "w+", encoding="utf-8") as f:
    f.write(sv_code)