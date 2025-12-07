`timescale 1ns / 1ps
// Top-level wrapper for GRU Cell Parallel
// D = 128 (input features)
// H = 256 (hidden units)
module top_level(
    input  logic clk,
    input  logic rst_n,
    input  logic start,
    output logic done
);

    // Parameters matching the GRU cell
    localparam int D = 64;
    localparam int H = 16;
    localparam int DATA_WIDTH = 15;
    localparam int FRAC_BITS = 9;
    localparam int NUM_PARALLEL = 4;

    // ========================================================================
    // All signals with keep and dont_touch attributes
    // ========================================================================

    // Input vectors
    (* keep = "true", dont_touch = "true" *)
    logic signed [DATA_WIDTH-1:0] x_t [D-1:0] = '{default: '0};

    (* keep = "true", dont_touch = "true" *)
    logic signed [DATA_WIDTH-1:0] h_t_prev [H-1:0] = '{default: '0};

    // Weight matrices
    (* keep = "true", dont_touch = "true" *)
    logic signed [DATA_WIDTH-1:0] W_ir [H-1:0][D-1:0] = '{default: '{default: 16'sd1}};

    (* keep = "true", dont_touch = "true" *)
    logic signed [DATA_WIDTH-1:0] W_hr [H-1:0][H-1:0] = '{default: '{default: 16'sd1}};

    (* keep = "true", dont_touch = "true" *)
    logic signed [DATA_WIDTH-1:0] W_iz [H-1:0][D-1:0] = '{default: '{default: 16'sd1}};

    (* keep = "true", dont_touch = "true" *)
    logic signed [DATA_WIDTH-1:0] W_hz [H-1:0][H-1:0] = '{default: '{default: 16'sd1}};

    (* keep = "true", dont_touch = "true" *)
    logic signed [DATA_WIDTH-1:0] W_in [H-1:0][D-1:0] = '{default: '{default: 16'sd1}};

    (* keep = "true", dont_touch = "true" *)
    logic signed [DATA_WIDTH-1:0] W_hn [H-1:0][H-1:0] = '{default: '{default: 16'sd1}};

    // Bias vectors
    (* keep = "true", dont_touch = "true" *)
    logic signed [DATA_WIDTH-1:0] b_ir [H-1:0] = '{default: '0};

    (* keep = "true", dont_touch = "true" *)
    logic signed [DATA_WIDTH-1:0] b_hr [H-1:0] = '{default: '0};

    (* keep = "true", dont_touch = "true" *)
    logic signed [DATA_WIDTH-1:0] b_iz [H-1:0] = '{default: '0};

    (* keep = "true", dont_touch = "true" *)
    logic signed [DATA_WIDTH-1:0] b_hz [H-1:0] = '{default: '0};

    (* keep = "true", dont_touch = "true" *)
    logic signed [DATA_WIDTH-1:0] b_in [H-1:0] = '{default: '0};

    (* keep = "true", dont_touch = "true" *)
    logic signed [DATA_WIDTH-1:0] b_hn [H-1:0] = '{default: '0};

    // Output hidden state
    (* keep = "true", dont_touch = "true" *)
    logic signed [DATA_WIDTH-1:0] h_t [H-1:0];

    // Preserved outputs
    (* keep = "true", dont_touch = "true" *)
    logic signed [DATA_WIDTH-1:0] preserved_h_t [H-1:0] = '{default: '0};

    // ========================================================================
    // Instantiate GRU Cell Parallel
    // ========================================================================
    (* keep = "true", dont_touch = "true" *)
    gru_cell_parallel #(
        .D(D),
        .H(H),
        .DATA_WIDTH(DATA_WIDTH),
        .FRAC_BITS(FRAC_BITS),
        .NUM_PARALLEL(NUM_PARALLEL)
    ) gru_inst (
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

    // ========================================================================
    // Capture outputs into preserved registers
    // ========================================================================
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            preserved_h_t <= '{default: '0};
        end else begin
            preserved_h_t <= h_t;
        end
    end

endmodule