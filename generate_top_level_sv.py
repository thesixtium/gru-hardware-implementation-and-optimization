def generate_top_level_sv(INT_WIDTH=8, FRAC_WIDTH=8, d=64, h=4):
    """
    Generate top-level wrapper for GRU with configurable dimensions.
    d: input feature dimension
    h: hidden state dimension
    """

    # Generate input signal declarations
    input_decls = []
    for i in range(d):
        input_decls.append(f"    (* keep = \"true\", dont_touch = \"true\" *) logic signed [WIDTH-1:0] x_{i} = '0;")

    # Generate hidden state signal declarations
    hidden_decls = []
    for i in range(h):
        hidden_decls.append(f"    (* keep = \"true\", dont_touch = \"true\" *) logic signed [WIDTH-1:0] h_{i} = '0;")

    # Generate output signal declarations
    output_decls = []
    for i in range(h):
        output_decls.append(f"    (* keep = \"true\", dont_touch = \"true\" *) logic signed [WIDTH-1:0] y_{i};")

    # Generate weight declarations
    def gen_weight_decls(prefix, rows, cols, init_val='16\'sd1'):
        decls = []
        for i in range(rows):
            for j in range(cols):
                decls.append(
                    f"    (* keep = \"true\", dont_touch = \"true\" *) logic signed [WIDTH-1:0] {prefix}_{i}_{j} = {init_val};")
        return decls

    # Generate bias declarations
    def gen_bias_decls(prefix, size):
        decls = []
        for i in range(size):
            decls.append(
                f"    (* keep = \"true\", dont_touch = \"true\" *) logic signed [WIDTH-1:0] {prefix}_{i} = '0;")
        return decls

    # Generate preserved output declarations
    preserved_decls = []
    for i in range(h):
        preserved_decls.append(
            f"    (* keep = \"true\", dont_touch = \"true\" *) logic signed [WIDTH-1:0] preserved_y_{i} = '0;")

    # Generate port connections for module instantiation
    input_ports = [f"        .x_{i}(x_{i})" for i in range(d)]
    hidden_ports = [f"        .h_{i}(h_{i})" for i in range(h)]
    output_ports = [f"        .y_{i}(y_{i})" for i in range(h)]

    # Weight port connections
    weight_ir_ports = [f"        .w_ir_{i}_{j}(w_ir_{i}_{j})" for i in range(h) for j in range(d)]
    weight_iz_ports = [f"        .w_iz_{i}_{j}(w_iz_{i}_{j})" for i in range(h) for j in range(d)]
    weight_in_ports = [f"        .w_in_{i}_{j}(w_in_{i}_{j})" for i in range(h) for j in range(d)]

    weight_hr_ports = [f"        .w_hr_{i}_{j}(w_hr_{i}_{j})" for i in range(h) for j in range(h)]
    weight_hz_ports = [f"        .w_hz_{i}_{j}(w_hz_{i}_{j})" for i in range(h) for j in range(h)]
    weight_hn_ports = [f"        .w_hn_{i}_{j}(w_hn_{i}_{j})" for i in range(h) for j in range(h)]

    # Bias port connections
    bias_ports = []
    for gate in ['ir', 'iz', 'in', 'hr', 'hz', 'hn']:
        for i in range(h):
            bias_ports.append(f"        .b_{gate}_{i}(b_{gate}_{i})")

    # Generate preserved output reset and update statements
    preserved_resets = [f"            preserved_y_{i} <= '0;" for i in range(h)]
    preserved_updates = [f"            preserved_y_{i} <= y_{i};" for i in range(h)]

    # Build the complete module
    module = f"""
`timescale 1ns / 1ps
// d = {d} (input features)
// h = {h} (hidden units)
// auto-generated top-level wrapper for GRU
module top_level(
    input  logic clk,
    input  logic reset
);

    // Parameters must match the generated GRU module parameters
    localparam int INT_WIDTH  = {INT_WIDTH};
    localparam int FRAC_WIDTH = {FRAC_WIDTH};
    localparam int WIDTH      = INT_WIDTH + FRAC_WIDTH;

    // --- Input signals (d={d}) ---
{chr(10).join(input_decls)}

    // --- Previous hidden state (h={h}) ---
{chr(10).join(hidden_decls)}

    // --- Output signals (h={h}) ---
{chr(10).join(output_decls)}

    // --- Weights for input gates (h×d for each gate) ---
    // w_ir: reset gate input weights
{chr(10).join(gen_weight_decls('w_ir', h, d))}

    // w_iz: update gate input weights
{chr(10).join(gen_weight_decls('w_iz', h, d))}

    // w_in: new gate input weights
{chr(10).join(gen_weight_decls('w_in', h, d))}

    // --- Recurrent weights (h×h for each gate) ---
    // w_hr: reset gate recurrent weights
{chr(10).join(gen_weight_decls('w_hr', h, h))}

    // w_hz: update gate recurrent weights
{chr(10).join(gen_weight_decls('w_hz', h, h))}

    // w_hn: new gate recurrent weights
{chr(10).join(gen_weight_decls('w_hn', h, h))}

    // --- Biases (h for each gate type) ---
    // Input-to-hidden biases
{chr(10).join(gen_bias_decls('b_ir', h))}
{chr(10).join(gen_bias_decls('b_iz', h))}
{chr(10).join(gen_bias_decls('b_in', h))}

    // Hidden-to-hidden biases
{chr(10).join(gen_bias_decls('b_hr', h))}
{chr(10).join(gen_bias_decls('b_hz', h))}
{chr(10).join(gen_bias_decls('b_hn', h))}

    // --- Final registers to capture and preserve the outputs ---
{chr(10).join(preserved_decls)}

    // --- Instantiate the generated GRU module ---
    (* keep = "true", dont_touch = "true" *) gru #(
        .INT_WIDTH(INT_WIDTH),
        .FRAC_WIDTH(FRAC_WIDTH)
    ) gru_inst (
        .clk(clk),
        .reset(reset),
        // Input features (d={d})
{','.join(chr(10) + p for p in input_ports)},
        // Hidden states (h={h})
{','.join(chr(10) + p for p in hidden_ports)},
        // Input weights for reset gate
{','.join(chr(10) + p for p in weight_ir_ports)},
        // Input weights for update gate
{','.join(chr(10) + p for p in weight_iz_ports)},
        // Input weights for new gate
{','.join(chr(10) + p for p in weight_in_ports)},
        // Recurrent weights for reset gate
{','.join(chr(10) + p for p in weight_hr_ports)},
        // Recurrent weights for update gate
{','.join(chr(10) + p for p in weight_hz_ports)},
        // Recurrent weights for new gate
{','.join(chr(10) + p for p in weight_hn_ports)},
        // Biases
{','.join(chr(10) + p for p in bias_ports)},
        // Outputs (h={h})
{','.join(chr(10) + p for p in output_ports)}
    );

    // --- Capture outputs into preserved registers ---
    always_ff @(posedge clk) begin
        if (reset) begin
{chr(10).join(preserved_resets)}
        end else begin
{chr(10).join(preserved_updates)}
        end
    end

endmodule
"""

    return module