def generate_gru_sv(INT_WIDTH=8, FRAC_WIDTH=8, d=64, h=4):
    """
    Generate GRU module with configurable dimensions.
    d: input feature dimension
    h: hidden state dimension
    """

    # Generate input port declarations
    input_ports = []
    for i in range(d):
        input_ports.append(f"input  logic signed [WIDTH-1:0]  x_{i},")

    # Generate hidden state input ports
    hidden_in_ports = []
    for i in range(h):
        hidden_in_ports.append(f"input  logic signed [WIDTH-1:0]  h_{i},")

    # Generate weight port declarations for input weights
    weight_ir_ports = []
    weight_iz_ports = []
    weight_in_ports = []
    for i in range(h):
        for j in range(d):
            weight_ir_ports.append(f"w_ir_{i}_{j}")
            weight_iz_ports.append(f"w_iz_{i}_{j}")
            weight_in_ports.append(f"w_in_{i}_{j}")

    # Generate weight port declarations for recurrent weights
    weight_hr_ports = []
    weight_hz_ports = []
    weight_hn_ports = []
    for i in range(h):
        for j in range(h):
            weight_hr_ports.append(f"w_hr_{i}_{j}")
            weight_hz_ports.append(f"w_hz_{i}_{j}")
            weight_hn_ports.append(f"w_hn_{i}_{j}")

    # Generate bias port declarations
    bias_ports = []
    for gate in ['ir', 'iz', 'in', 'hr', 'hz', 'hn']:
        for i in range(h):
            bias_ports.append(f"b_{gate}_{i}")

    # Generate output ports
    output_ports = []
    for i in range(h):
        if i == h-1:
            output_ports.append(f"output logic signed [WIDTH-1:0]  y_{i}")
        else:
            output_ports.append(f"output logic signed [WIDTH-1:0]  y_{i},")

    # Generate gate computations
    def generate_gate_computation(gate_name, w_input_prefix, w_hidden_prefix, b_input_prefix, b_hidden_prefix):
        lines = []
        lines.append(f"    // {gate_name} gate computation")
        lines.append(f"    logic signed [WIDTH-1:0] {gate_name}_sum[{h}];")
        lines.append(f"    logic signed [WIDTH-1:0] {gate_name}_act[{h}];")
        lines.append("")
        lines.append("    always_comb begin")

        for i in range(h):
            lines.append(f"        // {gate_name}_sum[{i}]")
            lines.append(f"        {gate_name}_sum[{i}] = {b_input_prefix}_{i};")

            # Add input contributions
            for j in range(d):
                lines.append(
                    f"        {gate_name}_sum[{i}] = sat_add({gate_name}_sum[{i}], fx_mult_round({w_input_prefix}_{i}_{j}, x_{j}));")

            lines.append(f"        {gate_name}_sum[{i}] = sat_add({gate_name}_sum[{i}], {b_hidden_prefix}_{i});")

            # Add hidden contributions
            for j in range(h):
                lines.append(
                    f"        {gate_name}_sum[{i}] = sat_add({gate_name}_sum[{i}], fx_mult_round({w_hidden_prefix}_{i}_{j}, h_{j}));")
            lines.append("")

        lines.append("    end")
        lines.append("")

        # Add activation modules
        activation = "sigmoid" if gate_name in ['r', 'z'] else "tanh"
        for i in range(h):
            lines.append(
                f"    {activation} #(.INT_WIDTH(INT_WIDTH), .FRAC_WIDTH(FRAC_WIDTH)) {activation}_{gate_name}{i} (")
            lines.append(f"        .clk(clk), .reset(reset), .x({gate_name}_sum[{i}]), .y({gate_name}_act[{i}])")
            lines.append("    );")

        return "\n".join(lines)

    # Generate candidate hidden state computation
    def generate_candidate_computation():
        lines = []
        lines.append("    // Candidate hidden state computation")
        lines.append(f"    logic signed [WIDTH-1:0] wn_h[{h}];")
        lines.append(f"    logic signed [WIDTH-1:0] gated_h[{h}];")
        lines.append(f"    logic signed [WIDTH-1:0] n_sum[{h}];")
        lines.append(f"    logic signed [WIDTH-1:0] n_act[{h}];")
        lines.append("")
        lines.append("    always_comb begin")

        for i in range(h):
            lines.append(f"        // wn_h[{i}] = W_hn*h + b_hn")
            lines.append(f"        wn_h[{i}] = b_hn_{i};")
            for j in range(h):
                lines.append(f"        wn_h[{i}] = sat_add(wn_h[{i}], fx_mult_round(w_hn_{i}_{j}, h_{j}));")
            lines.append("")

            lines.append(f"        // gated_h[{i}] = r_t ⊙ wn_h")
            lines.append(f"        gated_h[{i}] = fx_mult_round(r_act[{i}], wn_h[{i}]);")
            lines.append("")

            lines.append(f"        // n_sum[{i}] = W_in*x + b_in + gated_h")
            lines.append(f"        n_sum[{i}] = b_in_{i};")
            for j in range(d):
                lines.append(f"        n_sum[{i}] = sat_add(n_sum[{i}], fx_mult_round(w_in_{i}_{j}, x_{j}));")
            lines.append(f"        n_sum[{i}] = sat_add(n_sum[{i}], gated_h[{i}]);")
            lines.append("")

        lines.append("    end")
        lines.append("")

        for i in range(h):
            lines.append(f"    tanh #(.INT_WIDTH(INT_WIDTH), .FRAC_WIDTH(FRAC_WIDTH)) tanh_n{i} (")
            lines.append(f"        .clk(clk), .reset(reset), .x(n_sum[{i}]), .y(n_act[{i}])")
            lines.append("    );")

        return "\n".join(lines)

    # Generate hidden state update
    def generate_hidden_update():
        lines = []
        lines.append("    // Hidden state update: h_t = (1 - z_t) ⊙ n_t + z_t ⊙ h_{t-1}")
        lines.append(f"    logic signed [WIDTH-1:0] one_minus_z[{h}];")
        lines.append(f"    logic signed [WIDTH-1:0] part1[{h}], part2[{h}];")
        lines.append(f"    logic signed [WIDTH-1:0] h_new[{h}];")
        lines.append("")
        lines.append("    always_comb begin")

        for i in range(h):
            lines.append(f"        one_minus_z[{i}] = sat_add(ONE, -z_act[{i}]);")
            lines.append(f"        part1[{i}] = fx_mult_round(one_minus_z[{i}], n_act[{i}]);")
            lines.append(f"        part2[{i}] = fx_mult_round(z_act[{i}], h_{i});")
            lines.append(f"        h_new[{i}] = sat_add(part1[{i}], part2[{i}]);")

        lines.append("    end")
        lines.append("")
        lines.append("    // Register outputs")
        lines.append("    always_ff @(posedge clk or posedge reset) begin")
        lines.append("        if (reset) begin")
        for i in range(h):
            lines.append(f"            y_{i} <= '0;")
        lines.append("        end else begin")
        for i in range(h):
            lines.append(f"            y_{i} <= h_new[{i}];")
        lines.append("        end")
        lines.append("    end")

        return "\n".join(lines)

    # Build the complete module
    module = f"""
`timescale 1ns / 1ps
// GRU Cell Implementation (Fixed-Point Qm.f)
// d = {d} (input features), h = {h} (hidden units)
// WIDTH = INT_WIDTH + FRAC_WIDTH + 1 (sign)

module gru #(
    parameter int INT_WIDTH  = {INT_WIDTH},
    parameter int FRAC_WIDTH = {FRAC_WIDTH},
    parameter int WIDTH      = INT_WIDTH + FRAC_WIDTH + 1
)(
    input  logic                     clk,
    input  logic                     reset,

    // Inputs (d={d})
    {chr(10).join('    ' + p for p in input_ports)}

    // Previous hidden state (h={h})
    {chr(10).join('    ' + p for p in hidden_in_ports)}

    // Input weights (h×d for each gate)
    input  logic signed [WIDTH-1:0]  {', '.join(weight_ir_ports)},
    input  logic signed [WIDTH-1:0]  {', '.join(weight_iz_ports)},
    input  logic signed [WIDTH-1:0]  {', '.join(weight_in_ports)},

    // Recurrent weights (h×h for each gate)
    input  logic signed [WIDTH-1:0]  {', '.join(weight_hr_ports)},
    input  logic signed [WIDTH-1:0]  {', '.join(weight_hz_ports)},
    input  logic signed [WIDTH-1:0]  {', '.join(weight_hn_ports)},

    // Biases (h for each gate type)
    input  logic signed [WIDTH-1:0]  {', '.join(bias_ports)},

    // Outputs (h={h})
    {chr(10).join('    ' + p for p in output_ports)}
);

    // Helper functions
    function automatic logic signed [WIDTH-1:0] sat_add(
        input logic signed [WIDTH-1:0] a,
        input logic signed [WIDTH-1:0] b
    );
        logic signed [WIDTH:0] sum_ext;
        sum_ext = {{a[WIDTH-1], a}} + {{b[WIDTH-1], b}};

        if (sum_ext[WIDTH] != sum_ext[WIDTH-1]) begin
            sat_add = sum_ext[WIDTH] ? {{1'b1, {{(WIDTH-1){{1'b0}}}}}} : {{1'b0, {{(WIDTH-1){{1'b1}}}}}};
        end else begin
            sat_add = sum_ext[WIDTH-1:0];
        end
    endfunction

    function automatic logic signed [WIDTH-1:0] fx_mult_round(
        input logic signed [WIDTH-1:0] a,
        input logic signed [WIDTH-1:0] b
    );
        logic signed [(2*WIDTH)-1:0] product;
        logic signed [WIDTH:0] rounded;

        product = a * b;
        rounded = (product[(2*WIDTH)-1:FRAC_WIDTH] + product[FRAC_WIDTH-1]);

        if (rounded[WIDTH] != rounded[WIDTH-1]) begin
            fx_mult_round = rounded[WIDTH] ? {{1'b1, {{(WIDTH-1){{1'b0}}}}}} : {{1'b0, {{(WIDTH-1){{1'b1}}}}}};
        end else begin
            fx_mult_round = rounded[WIDTH-1:0];
        end
    endfunction

    localparam logic signed [WIDTH-1:0] ONE = (1 <<< FRAC_WIDTH);

    // Reset gate: r_t = σ(W_ir*x + b_ir + W_hr*h + b_hr)
{generate_gate_computation('r', 'w_ir', 'w_hr', 'b_ir', 'b_hr')}

    // Update gate: z_t = σ(W_iz*x + b_iz + W_hz*h + b_hz)
{generate_gate_computation('z', 'w_iz', 'w_hz', 'b_iz', 'b_hz')}

    // Candidate hidden state: n_t = tanh(W_in*x + b_in + r_t ⊙ (W_hn*h + b_hn))
{generate_candidate_computation()}

    // Final hidden state update
{generate_hidden_update()}

endmodule
"""

    return module


if __name__ == "__main__":
    print(generate_gru_sv())