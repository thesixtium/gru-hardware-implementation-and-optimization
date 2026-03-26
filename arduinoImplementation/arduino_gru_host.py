"""
arduino_gru_host.py
====================
Host-side Python script for communicating with the Arduino Mega 2560
running gru_mega2560.ino.

Data pipeline (mirrors GRU.ipynb exactly):
  1. Load 1.npy  (shape: 259520 x 65)
  2. Filter to labels 0 and 1 only
  3. Segment with extract() -> (N, segment_length*no_feature + 1)
  4. Normalise with StandardScaler (fit on train split)
  5. Reshape to (samples, 16, 64)  -- 16 timesteps x 64 features
  6. For each sample, stream 16 timesteps to the Arduino one at a time:
       TX: 64 x int16 Q10.6  = 128 bytes  (MSB-first per value)
       RX: 16 x int16 Q10.6  =  32 bytes  (MSB-first per value)
     The Arduino's hidden state persists across the 16 timesteps of one
     sample, then a reset byte is sent to flush it before the next sample.

UART protocol (matches gru_mega2560.ino):
  - 9600 baud, 8N1, raw binary
  - Each int16 value: 2 bytes, MSB first
  - Reset command: 0xFF 0xFF (two bytes not valid as Q10.6 input header
    in normal use; Arduino checks for this and zeroes h_prev)

Usage:
  python arduino_gru_host.py --port COM3 --data 1.npy
  python arduino_gru_host.py --port /dev/ttyUSB0 --data 1.npy --baud 115200

Dependencies:
  pip install numpy pyserial scikit-learn
"""

import argparse
import struct
import sys
import time
import warnings
from typing import Optional

import numpy as np
import serial
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler

warnings.filterwarnings("ignore")

# ---------------------------------------------------------------------------
# Constants (must match gru_mega2560.ino and GRU.ipynb)
# ---------------------------------------------------------------------------
D              = 64       # input features per timestep
H              = 16       # GRU hidden size (= output values per timestep)
SEGMENT_LENGTH = 16       # timesteps per sample window
FRAC_BITS      = 6        # Q10.6
FRAC_SCALE     = 1 << FRAC_BITS   # 64
Q10_6_MAX      =  32767
Q10_6_MIN      = -32768

# Two-byte reset command sent before each new sample to zero h_prev on Arduino.
# 0xFF 0xFF is an illegal Q10.6 MSB in context (the Arduino .ino checks it).
RESET_CMD      = bytes([0xFF, 0xFF])

# Removed labels (matches notebook)
REMOVED_LABELS = [2, 3, 4, 5, 6, 7, 8, 9, 10]


# ---------------------------------------------------------------------------
# Data helpers (mirrors GRU.ipynb)
# ---------------------------------------------------------------------------

def extract(dataset: np.ndarray,
            n_classes: int,
            n_fea: int,
            time_window: int,
            moving: float) -> np.ndarray:
    """
    Sliding-window segmentation identical to BCI_functions.extract().

    dataset : (N, n_fea+1) array, last column is label
    moving  : step size (may be fractional; rounded to int)
    Returns : (M, time_window*n_fea + 1) where last column is the label
              of the last row in each window.
    """
    step      = max(1, int(round(moving)))
    n_rows    = dataset.shape[0]
    data_list = []

    for start in range(0, n_rows - time_window + 1, step):
        window = dataset[start : start + time_window, :n_fea]   # (T, F)
        label  = dataset[start + time_window - 1, -1]           # scalar
        row    = np.append(window.flatten(), label)
        data_list.append(row)

    return np.array(data_list, dtype=np.float32)


def load_and_preprocess(npy_path: str, random_state: int = 42):
    """
    Full preprocessing pipeline from GRU.ipynb.

    Returns
    -------
    train_3d : (N_train, 16, 64) float32  normalised
    test_3d  : (N_test,  16, 64) float32  normalised
    train_labels : (N_train,) int64
    test_labels  : (N_test,)  int64
    scaler       : fitted StandardScaler (for reference / further use)
    """
    print(f"[data] Loading {npy_path} ...")
    dataset = np.load(npy_path)
    print(f"[data] Raw shape: {dataset.shape}")

    # Filter labels
    for ll in REMOVED_LABELS:
        dataset = dataset[dataset[:, -1] != ll]
    print(f"[data] After label filter: {dataset.shape}")

    n_class    = 2   # only labels 0 and 1 remain
    no_feature = D
    segment_length = SEGMENT_LENGTH

    # Segmentation
    data_seg = extract(dataset,
                       n_classes=n_class,
                       n_fea=no_feature,
                       time_window=segment_length,
                       moving=segment_length / 2)
    print(f"[data] After segmentation: {data_seg.shape}")

    no_longfeature   = no_feature * segment_length
    data_seg_feature = data_seg[:, :no_longfeature]
    data_seg_label   = data_seg[:, no_longfeature : no_longfeature + 1]

    train_feature, test_feature, train_label, test_label = train_test_split(
        data_seg_feature, data_seg_label,
        shuffle=True, random_state=random_state
    )

    # Normalisation (StandardScaler fit on train 2-D, applied to test)
    train_2d = train_feature.reshape(-1, no_feature)
    test_2d  = test_feature.reshape(-1, no_feature)

    scaler         = StandardScaler().fit(train_2d)
    train_norm     = scaler.transform(train_2d)
    test_norm      = scaler.transform(test_2d)

    # Reshape to (samples, timesteps, features)
    train_3d = train_norm.reshape(-1, segment_length, no_feature).astype(np.float32)
    test_3d  = test_norm.reshape(-1, segment_length, no_feature).astype(np.float32)

    train_labels = train_label.flatten().astype(np.int64)
    test_labels  = test_label.flatten().astype(np.int64)

    print(f"[data] Train: {train_3d.shape}  Test: {test_3d.shape}")
    return train_3d, test_3d, train_labels, test_labels, scaler


# ---------------------------------------------------------------------------
# Fixed-point conversion
# ---------------------------------------------------------------------------

def float_to_q10_6(value: float) -> int:
    """Clip and convert a float to Q10.6 int16."""
    raw = int(round(value * FRAC_SCALE))
    return max(Q10_6_MIN, min(Q10_6_MAX, raw))


def q10_6_to_float(raw: int) -> float:
    """Convert a Q10.6 int16 back to float."""
    return raw / FRAC_SCALE


def encode_timestep(x: np.ndarray) -> bytes:
    """
    Encode one timestep vector (64 float32 values) into 128 bytes:
    each value -> Q10.6 int16 -> 2 bytes MSB-first (big-endian signed).
    """
    assert x.shape == (D,), f"Expected ({D},), got {x.shape}"
    out = bytearray(D * 2)
    for i, v in enumerate(x):
        q = float_to_q10_6(float(v))
        # struct.pack '>h' = big-endian signed short
        out[i*2 : i*2+2] = struct.pack(">h", q)
    return bytes(out)


def decode_hidden(raw_bytes: bytes) -> np.ndarray:
    """
    Decode 32 bytes (16 x Q10.6 int16 MSB-first) into float32 array.
    """
    assert len(raw_bytes) == H * 2, f"Expected {H*2} bytes, got {len(raw_bytes)}"
    result = np.zeros(H, dtype=np.float32)
    for i in range(H):
        val = struct.unpack(">h", raw_bytes[i*2 : i*2+2])[0]
        result[i] = q10_6_to_float(val)
    return result


# ---------------------------------------------------------------------------
# Serial communication
# ---------------------------------------------------------------------------

def open_serial(port: str, baud: int, timeout: float = 5.0) -> serial.Serial:
    """Open the serial port and wait for Arduino to boot."""
    print(f"[uart] Opening {port} at {baud} baud ...")
    ser = serial.Serial(port, baud, timeout=timeout)
    # Arduino resets on DTR; give it 2 s to boot
    time.sleep(2.0)
    ser.reset_input_buffer()
    ser.reset_output_buffer()
    print("[uart] Port open, Arduino ready.")
    return ser


def send_reset(ser: serial.Serial) -> None:
    """
    Send reset command to zero h_prev on the Arduino before a new sample.
    The Arduino .ino loop() checks for 0xFF 0xFF as the first two bytes
    of an incoming frame and resets its hidden state instead of running GRU.
    """
    ser.write(RESET_CMD)
    ser.flush()
    # Brief pause to let the Arduino process the reset
    time.sleep(0.01)
    ser.reset_input_buffer()


def recv_exact(ser: serial.Serial, n: int) -> bytes:
    """Blocking read of exactly n bytes; raises TimeoutError on failure."""
    buf = bytearray()
    deadline = time.monotonic() + ser.timeout
    while len(buf) < n:
        chunk = ser.read(n - len(buf))
        if not chunk:
            if time.monotonic() > deadline:
                raise TimeoutError(
                    f"[uart] Timeout waiting for {n} bytes "
                    f"(got {len(buf)} so far)"
                )
        buf.extend(chunk)
    return bytes(buf)


def run_sample(ser: serial.Serial,
               sample: np.ndarray,
               verbose: bool = False) -> np.ndarray:
    """
    Send one sample (shape: 16 x 64) to the Arduino timestep by timestep
    and collect the final hidden state after all 16 steps.

    The Arduino's hidden state accumulates across the 16 timesteps, so we
    stream them in order.  Only the last RX (after timestep 16) is returned.

    Returns the final hidden state as float32 (shape: H=16).
    """
    assert sample.shape == (SEGMENT_LENGTH, D), \
        f"Expected ({SEGMENT_LENGTH}, {D}), got {sample.shape}"

    final_hidden = None

    for t in range(SEGMENT_LENGTH):
        # ---- TX: 128 bytes ------------------------------------------------
        payload = encode_timestep(sample[t])
        ser.write(payload)
        ser.flush()

        # ---- RX: 32 bytes (hidden state after this timestep) --------------
        rx_raw = recv_exact(ser, H * 2)
        hidden = decode_hidden(rx_raw)

        if verbose:
            print(f"  t={t:2d}  h={hidden[:4]} ...")

        final_hidden = hidden

    return final_hidden


# ---------------------------------------------------------------------------
# Inference loop
# ---------------------------------------------------------------------------

def run_inference(ser: serial.Serial,
                  data_3d: np.ndarray,
                  labels: np.ndarray,
                  max_samples: Optional[int] = None,
                  verbose: bool = False) -> dict:
    """
    Stream all (or max_samples) samples through the Arduino and collect
    the final hidden states.

    Returns a dict with:
      hidden_states : (N, H) float32 -- final h after each sample's 16 steps
      labels        : (N,)   int64
      throughput_ts : float  -- timesteps per second
    """
    n = len(data_3d) if max_samples is None else min(max_samples, len(data_3d))
    hidden_states = np.zeros((n, H), dtype=np.float32)

    print(f"\n[inference] Running {n} samples ({n * SEGMENT_LENGTH} timesteps total) ...")
    t_start = time.monotonic()

    for i in range(n):
        # Reset h_prev on Arduino before each new independent sample
        send_reset(ser)

        hidden_states[i] = run_sample(ser, data_3d[i], verbose=verbose)

        if (i + 1) % 10 == 0 or (i + 1) == n:
            elapsed = time.monotonic() - t_start
            ts_done = (i + 1) * SEGMENT_LENGTH
            rate    = ts_done / elapsed if elapsed > 0 else 0
            print(f"  [{i+1:4d}/{n}]  {rate:.1f} timesteps/s", end="\r")

    elapsed = time.monotonic() - t_start
    total_ts = n * SEGMENT_LENGTH
    throughput = total_ts / elapsed if elapsed > 0 else 0

    print(f"\n[inference] Done. {total_ts} timesteps in {elapsed:.2f}s "
          f"({throughput:.1f} ts/s)")

    return {
        "hidden_states": hidden_states,
        "labels":        labels[:n],
        "throughput_ts": throughput,
    }


# ---------------------------------------------------------------------------
# Sanity-check / loopback mode (no Arduino needed)
# ---------------------------------------------------------------------------

def loopback_test(data_3d: np.ndarray, n_samples: int = 3) -> None:
    """
    Dry-run: encode then immediately decode a few samples without a serial
    port.  Useful for verifying the Q10.6 encoding pipeline offline.
    """
    print("\n[loopback] Encoding/decoding test (no Arduino required):")
    for i in range(min(n_samples, len(data_3d))):
        sample = data_3d[i]   # (16, 64)
        for t in range(SEGMENT_LENGTH):
            encoded = encode_timestep(sample[t])
            decoded = np.array(
                [q10_6_to_float(struct.unpack(">h", encoded[j*2:j*2+2])[0])
                 for j in range(D)],
                dtype=np.float32
            )
            max_err = float(np.abs(sample[t] - decoded).max())
        print(f"  sample {i}  max Q10.6 quantisation error: {max_err:.5f}")
    print("[loopback] OK")


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def build_parser() -> argparse.ArgumentParser:
    p = argparse.ArgumentParser(
        description="Stream BCI data to Arduino GRU and collect hidden states."
    )
    p.add_argument("--port",    required=False, default=None,
                   help="Serial port, e.g. COM3 or /dev/ttyUSB0. "
                        "Omit to run loopback test only.")
    p.add_argument("--data",    required=False, default="1.npy",
                   help="Path to the .npy dataset (default: 1.npy)")
    p.add_argument("--baud",    type=int, default=1000000,
                   help="UART baud rate (default: 9600, match Arduino sketch)")
    p.add_argument("--split",   choices=["train", "test"], default="test",
                   help="Which split to stream (default: test)")
    p.add_argument("--samples", type=int, default=None,
                   help="Max number of samples to stream (default: all)")
    p.add_argument("--seed",    type=int, default=42,
                   help="Random seed for train/test split (default: 42)")
    p.add_argument("--verbose", action="store_true",
                   help="Print hidden state after every timestep")
    p.add_argument("--loopback", action="store_true",
                   help="Run encoding loopback test and exit (no Arduino needed)")
    p.add_argument("--save",    default=None,
                   help="Path to save hidden states as .npy (e.g. hidden.npy)")
    return p


def main() -> None:
    args = build_parser().parse_args()

    # ---- Load & preprocess data -------------------------------------------
    train_3d, test_3d, train_labels, test_labels, scaler = \
        load_and_preprocess(args.data, random_state=args.seed)

    if args.split == "train":
        data_3d, labels = train_3d, train_labels
    else:
        data_3d, labels = test_3d, test_labels

    print(f"[main] Using '{args.split}' split: {data_3d.shape[0]} samples, "
          f"shape {data_3d.shape}")

    # ---- Loopback test (offline) ------------------------------------------
    if args.loopback or args.port is None:
        loopback_test(data_3d, n_samples=5)
        if args.port is None:
            print("\n[main] No --port specified. Exiting after loopback test.")
            print("       Run with --port <port> to connect to the Arduino.")
            sys.exit(0)

    # ---- Open serial port -------------------------------------------------
    ser = open_serial(args.port, args.baud, timeout=10.0)

    try:
        # ---- Run inference ------------------------------------------------
        results = run_inference(
            ser, data_3d, labels,
            max_samples=args.samples,
            verbose=args.verbose
        )

        # ---- Report -------------------------------------------------------
        hs     = results["hidden_states"]   # (N, 16)
        lbls   = results["labels"]
        print(f"\n[results] Hidden state matrix: {hs.shape}")
        print(f"[results] Label distribution:  "
              f"class 0 = {(lbls==0).sum()}, class 1 = {(lbls==1).sum()}")
        print(f"[results] Hidden state stats -- "
              f"mean={hs.mean():.4f}  std={hs.std():.4f}  "
              f"min={hs.min():.4f}  max={hs.max():.4f}")
        print(f"[results] Throughput: {results['throughput_ts']:.1f} timesteps/s")

        if args.save:
            np.save(args.save, hs)
            label_path = args.save.replace(".npy", "_labels.npy")
            np.save(label_path, lbls)
            print(f"[results] Saved hidden states -> {args.save}")
            print(f"[results] Saved labels        -> {label_path}")

    finally:
        ser.close()
        print("[uart] Port closed.")


if __name__ == "__main__":
    main()
