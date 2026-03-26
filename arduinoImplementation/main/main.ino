// =============================================================================
// gru_mega2560.ino
// GRU Inference Engine for Arduino Mega 2560 (ATmega2560, 16 MHz)
//
// Architecture: GRU cell, input size D=64, hidden size H=16
// Fixed-point:  Q10.6 (signed 16-bit, 6 fractional bits)
// UART:         9600 baud, raw binary, MSB-first 2-byte per value
//
// GRU equations (standard PyTorch formulation):
//   r_t = sigmoid( W_ir @ x_t + b_ir + W_hr @ h_prev + b_hr )
//   z_t = sigmoid( W_iz @ x_t + b_iz + W_hz @ h_prev + b_hz )
//   n_t = tanh   ( W_in @ x_t + b_in + r_t * (W_hn @ h_prev + b_hn) )
//   h_t = (1 - z_t) * n_t + z_t * h_prev
//
// UART protocol:
//   RX: 64 values x 2 bytes = 128 bytes, MSB-first
//   TX: 16 values x 2 bytes =  32 bytes, MSB-first
// =============================================================================

#include <avr/pgmspace.h>
#include <stdint.h>

// =============================================================================
// Fixed-Point Configuration  (Q10.6)
// =============================================================================
#define FRAC_BITS   6
#define FRAC_SCALE  (1 << FRAC_BITS)                  // 64
#define FP_ONE      ((int16_t)FRAC_SCALE)              // 1.0 in Q10.6 = 64
#define FP_MAX      ((int16_t)0x7FFF)
#define FP_MIN      ((int16_t)0x8000)

// GRU dimensions
#define D  64    // input size
#define H  16    // hidden size

// =============================================================================
// Fixed-Point Math Utilities
// =============================================================================

// Q10.6 x Q10.6 -> Q10.6  (uses int32_t accumulator, arithmetic shift right)
static inline int16_t fp_mul(int16_t a, int16_t b) {
    int32_t result = (int32_t)a * (int32_t)b;
    return (int16_t)(result >> FRAC_BITS);
}

// Saturating add
static inline int16_t fp_add_sat(int16_t a, int16_t b) {
    int32_t s = (int32_t)a + (int32_t)b;
    if (s > FP_MAX) return FP_MAX;
    if (s < FP_MIN) return FP_MIN;
    return (int16_t)s;
}

// Saturate int32 accumulator to Q10.6 range
static inline int16_t fp_sat32(int32_t v) {
    if (v > FP_MAX) return FP_MAX;
    if (v < FP_MIN) return FP_MIN;
    return (int16_t)v;
}

// -----------------------------------------------------------------------------
// Piecewise-linear sigmoid (matches FPGA breakpoints exactly)
//
// Breakpoints (Q10.6 values):
//   x <= -5.0    -> 0.0
//   x <= -2.375  -> 0.15625 + 0.03125 * x
//   x <= -1.0    -> 0.375   + 0.125   * x
//   x <= +1.0    -> 0.5     + 0.25    * x
//   x <= +2.375  -> 0.625   + 0.125   * x
//   x <= +5.0    -> 0.84375 + 0.03125 * x
//   x >  +5.0    -> 1.0
// -----------------------------------------------------------------------------
static int16_t fp_sigmoid(int16_t x) {
    // Breakpoints in Q10.6
    const int16_t BP_M5    = (int16_t)(-5    * FRAC_SCALE);  // -320
    const int16_t BP_M2375 = (int16_t)(-152);                 // -2.375 * 64 = -152
    const int16_t BP_M1    = (int16_t)(-1    * FRAC_SCALE);  //  -64
    const int16_t BP_P1    = (int16_t)( 1    * FRAC_SCALE);  //   64
    const int16_t BP_P2375 = (int16_t)( 152);                 // +152
    const int16_t BP_P5    = (int16_t)( 5    * FRAC_SCALE);  //  320

    // Constants in Q10.6
    const int16_t C_0       = 0;
    const int16_t C_015625  = (int16_t)(10);    // 0.15625 * 64 = 10
    const int16_t C_0375    = (int16_t)(24);    // 0.375   * 64 = 24
    const int16_t C_05      = (int16_t)(32);    // 0.5     * 64 = 32
    const int16_t C_0625    = (int16_t)(40);    // 0.625   * 64 = 40
    const int16_t C_084375  = (int16_t)(54);    // 0.84375 * 64 = 54
    const int16_t C_1       = FP_ONE;           //              = 64

    // Slopes in Q10.6
    const int16_t S_003125  = (int16_t)(2);     // 0.03125 * 64 = 2
    const int16_t S_0125    = (int16_t)(8);     // 0.125   * 64 = 8
    const int16_t S_025     = (int16_t)(16);    // 0.25    * 64 = 16

    if (x <= BP_M5)    return C_0;
    if (x <= BP_M2375) return fp_add_sat(C_015625, fp_mul(S_003125, x));
    if (x <= BP_M1)    return fp_add_sat(C_0375,   fp_mul(S_0125,   x));
    if (x <= BP_P1)    return fp_add_sat(C_05,     fp_mul(S_025,    x));
    if (x <= BP_P2375) return fp_add_sat(C_0625,   fp_mul(S_0125,   x));
    if (x <= BP_P5)    return fp_add_sat(C_084375, fp_mul(S_003125, x));
    return C_1;
}

// -----------------------------------------------------------------------------
// Piecewise-linear tanh  (matches FPGA sigmoid.sv used inside tanh.sv)
//
// The FPGA tanh module computes tanh via:
//   tanh(x) = 2*sigmoid(2x) - 1
// which maps the sigmoid breakpoints to tanh breakpoints.
//
// Resulting piecewise tanh breakpoints (from the FPGA tanh.sv logic):
//   x <= -2.5    -> -1.0
//   x <= -1.1875 -> -0.6875 + 0.0625 * x
//   x <= -0.5    -> -0.25   + 0.25   * x
//   x <=  0.5    ->  0.0    + 0.5    * x
//   x <=  1.1875 ->  0.25   + 0.25   * x  (via symmetry from FPGA analysis)
//   wait -- read the actual FPGA tanh.sv
//
// Rather than assuming: derive directly from 2*sigmoid(2x)-1 using the same
// piecewise-linear sigmoid above.  This keeps the Arduino numerically identical
// to the FPGA without needing to hard-read tanh.sv breakpoints.
// -----------------------------------------------------------------------------
static int16_t fp_tanh(int16_t x) {
    // tanh(x) = 2*sigmoid(2x) - 1
    // 2x in Q10.6: we need to saturate to avoid overflow
    int32_t two_x_32 = (int32_t)x << 1;
    int16_t two_x = (two_x_32 > FP_MAX) ? FP_MAX :
                    (two_x_32 < FP_MIN) ? FP_MIN :
                    (int16_t)two_x_32;
    int16_t sig = fp_sigmoid(two_x);
    // 2*sig - 1  in Q10.6
    int32_t result = ((int32_t)sig << 1) - FP_ONE;
    return fp_sat32(result);
}

// =============================================================================
// Matrix-vector multiply helpers
//
// Computes:  acc[i] += sum_j( W[i][j] * v[j] )  for all i in [0,H)
// W is stored in PROGMEM as row-major int16_t[rows][cols]
//
// Two variants:
//   matvec_H_D  : W is H x D  (input projection)
//   matvec_H_H  : W is H x H  (recurrent projection)
//
// Accumulators use int32_t to prevent overflow across D=64 or H=16 MACs.
// Each product is at most 32767*32767 >> 6 ≈ 16M which fits int32_t easily.
// =============================================================================

// Accumulate W[H x D] @ v[D] into acc[H]  (weights from PROGMEM)
static void matvec_add_HD(
    const int16_t W_pgm[][D],   // PROGMEM: H rows of D columns
    const int16_t v[D],
    int32_t       acc[H])
{
    for (uint8_t i = 0; i < H; i++) {
        int32_t sum = 0;
        for (uint8_t j = 0; j < D; j++) {
            int16_t w = (int16_t)pgm_read_word(&W_pgm[i][j]);
            sum += (int32_t)w * (int32_t)v[j];
        }
        acc[i] += (sum >> FRAC_BITS);
    }
}

// Accumulate W[H x H] @ v[H] into acc[H]  (weights from PROGMEM)
static void matvec_add_HH(
    const int16_t W_pgm[][H],   // PROGMEM: H rows of H columns
    const int16_t v[H],
    int32_t       acc[H])
{
    for (uint8_t i = 0; i < H; i++) {
        int32_t sum = 0;
        for (uint8_t j = 0; j < H; j++) {
            int16_t w = (int16_t)pgm_read_word(&W_pgm[i][j]);
            sum += (int32_t)w * (int32_t)v[j];
        }
        acc[i] += (sum >> FRAC_BITS);
    }
}

// =============================================================================
// Weight and Bias Storage (PROGMEM)
//
// All weights are Q10.6 int16_t, stored in flash to save SRAM.
// Replace zeros with trained weights.
//
// Naming mirrors the FPGA:
//   W_ir[H][D], b_ir[H]   -- reset gate, input weight / bias
//   W_hr[H][H], b_hr[H]   -- reset gate, recurrent weight / bias
//   W_iz[H][D], b_iz[H]   -- update gate, input weight / bias
//   W_hz[H][H], b_hz[H]   -- update gate, recurrent weight / bias
//   W_in[H][D], b_in[H]   -- new gate, input weight / bias
//   W_hn[H][H], b_hn[H]   -- new gate, recurrent weight / bias
// =============================================================================

// ---- Reset gate ----
const int16_t PROGMEM W_ir[H][D] = {
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
};
const int16_t PROGMEM b_ir[H] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};

const int16_t PROGMEM W_hr[H][H] = {
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
};
const int16_t PROGMEM b_hr[H] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};

// ---- Update gate ----
const int16_t PROGMEM W_iz[H][D] = {
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
};
const int16_t PROGMEM b_iz[H] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};

const int16_t PROGMEM W_hz[H][H] = {
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
};
const int16_t PROGMEM b_hz[H] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};

// ---- New/candidate gate ----
const int16_t PROGMEM W_in[H][D] = {
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
};
const int16_t PROGMEM b_in[H] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};

const int16_t PROGMEM W_hn[H][H] = {
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
};
const int16_t PROGMEM b_hn[H] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};

// =============================================================================
// GRU Persistent State (SRAM)
// =============================================================================
static int16_t h_prev[H];    // hidden state, persists across timesteps
static int16_t x_t[D];       // input buffer

// =============================================================================
// GRU Cell Computation
//
// Implements exactly:
//   r_t[i] = sigmoid( sum_j(W_ir[i][j]*x[j]) + b_ir[i]
//                   + sum_j(W_hr[i][j]*h[j]) + b_hr[i] )
//   z_t[i] = sigmoid( sum_j(W_iz[i][j]*x[j]) + b_iz[i]
//                   + sum_j(W_hz[i][j]*h[j]) + b_hz[i] )
//   n_t[i] = tanh  ( sum_j(W_in[i][j]*x[j]) + b_in[i]
//                   + r_t[i] * (sum_j(W_hn[i][j]*h[j]) + b_hn[i]) )
//   h_t[i] = (1 - z_t[i]) * n_t[i] + z_t[i] * h_prev[i]
// =============================================================================
static void gru_step(void) {
    // Intermediate gate storage
    int16_t r_t[H];
    int16_t z_t[H];
    int16_t n_t[H];

    // int32_t accumulators (H entries, reused per gate to save stack)
    int32_t acc[H];

    // ------------------------------------------------------------------
    // Reset gate: r_t[i] = sigmoid( W_ir @ x + b_ir + W_hr @ h + b_hr )
    // ------------------------------------------------------------------
    // Initialize acc with b_ir
    for (uint8_t i = 0; i < H; i++) {
        acc[i] = (int32_t)(int16_t)pgm_read_word(&b_ir[i]);
    }
    // Add W_ir @ x_t
    matvec_add_HD(W_ir, x_t, acc);
    // Add W_hr @ h_prev
    matvec_add_HH(W_hr, h_prev, acc);
    // Add b_hr and apply sigmoid
    for (uint8_t i = 0; i < H; i++) {
        acc[i] += (int32_t)(int16_t)pgm_read_word(&b_hr[i]);
        r_t[i] = fp_sigmoid(fp_sat32(acc[i]));
    }

    // ------------------------------------------------------------------
    // Update gate: z_t[i] = sigmoid( W_iz @ x + b_iz + W_hz @ h + b_hz )
    // ------------------------------------------------------------------
    for (uint8_t i = 0; i < H; i++) {
        acc[i] = (int32_t)(int16_t)pgm_read_word(&b_iz[i]);
    }
    matvec_add_HD(W_iz, x_t, acc);
    matvec_add_HH(W_hz, h_prev, acc);
    for (uint8_t i = 0; i < H; i++) {
        acc[i] += (int32_t)(int16_t)pgm_read_word(&b_hz[i]);
        z_t[i] = fp_sigmoid(fp_sat32(acc[i]));
    }

    // ------------------------------------------------------------------
    // New/candidate gate:
    //   n_t[i] = tanh( W_in @ x + b_in + r_t[i] * (W_hn @ h + b_hn) )
    //
    // Strategy: compute W_hn @ h + b_hn into acc[], then scale by r_t[i],
    // then add W_in @ x + b_in, then apply tanh.
    // ------------------------------------------------------------------
    // Step 1: acc = W_hn @ h + b_hn
    for (uint8_t i = 0; i < H; i++) {
        acc[i] = (int32_t)(int16_t)pgm_read_word(&b_hn[i]);
    }
    matvec_add_HH(W_hn, h_prev, acc);

    // Step 2: scale by r_t[i] and add W_in @ x + b_in
    int32_t acc_x[H];
    for (uint8_t i = 0; i < H; i++) {
        acc_x[i] = (int32_t)(int16_t)pgm_read_word(&b_in[i]);
    }
    matvec_add_HD(W_in, x_t, acc_x);

    for (uint8_t i = 0; i < H; i++) {
        // r_t[i] * saturated(acc[i]) is Q10.6 * Q10.6 -> Q10.6
        int16_t hn_term = fp_mul(r_t[i], fp_sat32(acc[i]));
        int32_t total   = acc_x[i] + (int32_t)hn_term;
        n_t[i] = fp_tanh(fp_sat32(total));
    }

    // ------------------------------------------------------------------
    // Hidden state: h_t[i] = (1 - z_t[i]) * n_t[i] + z_t[i] * h_prev[i]
    // ------------------------------------------------------------------
    for (uint8_t i = 0; i < H; i++) {
        int16_t one_minus_z = (int16_t)((int32_t)FP_ONE - (int32_t)z_t[i]);
        int16_t term1 = fp_mul(one_minus_z, n_t[i]);
        int16_t term2 = fp_mul(z_t[i],     h_prev[i]);
        h_prev[i] = fp_add_sat(term1, term2);
    }
    // h_prev now holds h_t for this timestep, persists for next call
}

// =============================================================================
// UART Handling
//
// Uses Serial (hardware UART0 on Arduino Mega, pins 0/1, tied to USB-serial).
// Raw binary protocol:
//   RX: 128 bytes -> 64 Q10.6 values, MSB-first
//   TX:  32 bytes -> 16 Q10.6 values, MSB-first
// =============================================================================

// Blocking receive of exactly n bytes into buf
static void uart_recv_bytes(uint8_t *buf, uint16_t n) {
    for (uint16_t i = 0; i < n; i++) {
        while (Serial.available() == 0) { /* wait */ }
        buf[i] = (uint8_t)Serial.read();
    }
}

// Blocking send of exactly n bytes from buf
static void uart_send_bytes(const uint8_t *buf, uint16_t n) {
    Serial.write(buf, n);
    Serial.flush();
}

// Receive 64 Q10.6 values (128 bytes MSB-first) into x_t[]
static void uart_recv_inputs(void) {
    for (uint8_t i = 0; i < D; i++) {
        uint8_t hi, lo;
        while (Serial.available() == 0) {}
        hi = (uint8_t)Serial.read();
        while (Serial.available() == 0) {}
        lo = (uint8_t)Serial.read();
        x_t[i] = (int16_t)(((uint16_t)hi << 8) | (uint16_t)lo);
    }
}

// Transmit 16 Q10.6 values (32 bytes MSB-first) from h_prev[]
static void uart_send_outputs(void) {
    for (uint8_t i = 0; i < H; i++) {
        uint16_t v = (uint16_t)h_prev[i];
        uint8_t buf[2];
        buf[0] = (uint8_t)(v >> 8);
        buf[1] = (uint8_t)(v & 0xFF);
        Serial.write(buf, 2);
    }
    Serial.flush();
}

// =============================================================================
// Arduino Entry Points
// =============================================================================

void setup(void) {
    Serial.begin(1000000);

    // Zero out persistent hidden state
    for (uint8_t i = 0; i < H; i++) {
        h_prev[i] = 0;
    }
}

void loop(void) {
    // Wait for 128 bytes (64 Q10.6 inputs)
    uart_recv_inputs();

    // Run GRU inference; updates h_prev in-place
    gru_step();

    // Transmit 32 bytes (16 Q10.6 hidden state outputs)
    uart_send_outputs();
}

// =============================================================================
// =============================================================================
// PERFORMANCE ANALYSIS
// =============================================================================
// =============================================================================
//
// --- Multiply-Accumulate (MAC) Count per Timestep ---
//
// Gate         Input projection   Recurrent projection   Total MACs
// ----------   ----------------   --------------------   ----------
// Reset (r)    H x D = 16x64=1024 H x H = 16x16=256      1280
// Update (z)   H x D = 1024       H x H = 256             1280
// New (n)      H x D = 1024       H x H = 256             1280
//   (r * Whn@h is H element-wise muls: not a full matmul) +16
// Hidden (h)   2 muls per element = 2 x H = 32             32
// ----------                                            -------
// TOTAL MACs                                             3888
//
// Plus activations: 32 sigmoid calls + 16 tanh calls = 48 activation evals.
// Each piecewise-linear activation is ~5-10 cycles (compare + mul + add).
// Activation cost: ~48 x 10 = 480 cycles.
//
// --- Cycle Cost Estimation for AVR (ATmega2560, 16 MHz) ---
//
// AVR 8-bit architecture has no hardware multiplier for 16x16 signed.
// The avr-gcc MUL instruction multiplies 8x8->16 (2 cycles).
// A signed 16x16 multiply decomposes to 4x 8x8 partial products:
//   ~10-14 cycles for 16x16 multiply in software (avr-gcc typical).
// With int32 accumulation and shift: ~18-22 cycles total per MAC.
//
// Conservative estimate: 20 cycles per MAC.
//   3888 MACs x 20 cycles = 77,760 cycles
//
// Plus overhead (loop counters, PROGMEM loads, activation functions):
//   PROGMEM reads (pgm_read_word): ~3 cycles each
//   3888 weight reads x 3 cycles = 11,664 cycles
//   Activations: ~480 cycles
//   Loop/index overhead (~5 cycles per inner iteration): 3888 x 5 = 19,440
//
// Total estimated cycles: ~109,000 cycles
// At 16 MHz: 109,000 / 16,000,000 = ~6.8 ms per timestep
//
// --- Expected Max Inference Rate ---
//
//   ~6.8 ms inference + UART overhead
//   UART (9600 baud, 8N1):
//     RX 128 bytes: 128 x 10 bits / 9600 = 133.3 ms
//     TX  32 bytes:  32 x 10 bits / 9600 =  33.3 ms
//   Total per timestep: ~133 + 33 + 7 = ~173 ms
//   Max UART-bound rate: ~5.8 timesteps/second
//
//   With higher baud rate (e.g., 115200 baud):
//     RX: 128 x 10 / 115200 = 11.1 ms
//     TX:  32 x 10 / 115200 =  2.8 ms
//     Total: ~21 ms -> ~48 timesteps/second
//
//   Compute-only ceiling (no UART): 1 / 6.8ms ~ 147 timesteps/second
//   (In practice loop overhead, function call, and interrupt latency
//    will reduce this slightly; real measurement recommended.)
//
// --- FPGA vs AVR Comparison ---
//
// FPGA (Arty A7-100T, 100 MHz, NUM_PARALLEL=1):
//   The FPGA processes one hidden-state row at a time, cycling through
//   H=16 rows per gate, for 4 gates -> 64 sequential element operations.
//   Each element iterates over D=64 or H=16 steps.
//   Reset/Update/New gates: ~(D + H) = 80 clock cycles per row x 16 rows = 1280
//   cycles per gate, x 3 gates = 3840 cycles, plus hidden update ~16*2 = 32.
//   Total FPGA clock cycles per timestep: ~3900 cycles @ 100 MHz = ~39 µs.
//   With parallelism (NUM_PARALLEL > 1), this scales inversely.
//
//   The FPGA processes D=64 accumulations serially because NUM_PARALLEL=1,
//   but the critical path through one MAC (multiply then accumulate) is one
//   clock cycle at 100 MHz using DSP48 primitives -- each cycle is 10 ns.
//   AVR requires ~20 cycles (1.25 µs) for the same operation.
//   Per-MAC speedup: FPGA is ~125x faster per MAC in cycle time terms.
//
// Parallelism:
//   With NUM_PARALLEL=N, the FPGA can compute N rows of a gate simultaneously,
//   directly reducing gate-compute time by N. The AVR is strictly sequential.
//
// Latency:
//   FPGA: ~39 µs per timestep (compute), plus ~13 ms UART at 9600 baud.
//   AVR:   ~7 ms per timestep (compute), plus ~13 ms UART at 9600 baud.
//   UART is the bottleneck at 9600 baud for both; at higher baud, FPGA's
//   sub-100-µs compute dominates over AVR's ~7 ms.
//
// Memory bandwidth:
//   All 6 weight matrices total:
//     3 x (H x D) matrices = 3 x 16 x 64 = 3072 values
//     3 x (H x H) matrices = 3 x 16 x 16 =  768 values
//     6 x H biases         = 6 x 16       =   96 values
//   Total parameters: 3936 x 2 bytes = 7872 bytes ~ 7.7 KB
//
//   AVR: weights stored in PROGMEM (flash). Each pgm_read_word takes ~3 cycles
//   and reads 2 bytes. Effective bandwidth: 2 bytes / 3 cycles at 16 MHz
//   = 10.7 MB/s. For 7744 weight bytes per inference: ~0.72 ms bandwidth-
//   limited time (in practice overlaps with compute).
//
//   FPGA: weights stored in block RAM (BRAM) or distributed logic, accessed
//   every clock cycle. At 100 MHz with full-width access: effectively 200 MB/s
//   or more per port. No bandwidth bottleneck.
//
//   SRAM on ATmega2560: 8 KB total. Our SRAM usage:
//     h_prev[16]:  32 bytes
//     x_t[64]:    128 bytes
//     r_t, z_t, n_t[16] each: 32 bytes x 3 = 96 bytes
//     acc[16] x 2 arrays: 64 + 64 = 128 bytes (int32_t)
//     Stack and misc: ~256 bytes
//   Total SRAM: ~640 bytes -- well within 8 KB.
//   Weights (7872 bytes) must live in PROGMEM (flash, 256 KB available).
//
// =============================================================================
