import subprocess
import pandas as pd
import re
import numpy as np
from pathlib import Path

from extract_metrics import extract_metrics
from generate_gru_sv import generate_gru_sv
from generate_gru_tb_sv import generate_gru_tb_sv
from generate_top_level_sv import generate_top_level_sv

# 🔧 CHANGE THIS to match your Vivado installation path
VIVADO_PATH = r"C:\Xilinx\Vivado\2024.1\bin\vivado.bat"


def parse_q_format(binary_str, int_bits, frac_bits):
    """
    Parse a binary string in Q format (signed fixed-point).
    Q format: sign bit + integer bits + fractional bits
    Total bits = 1 (sign) + int_bits + frac_bits
    """
    binary_str = binary_str.strip()
    total_bits = len(binary_str)

    # Convert binary string to integer
    value = int(binary_str, 2)

    # Check if negative (MSB is 1)
    if binary_str[0] == '1':
        # Two's complement: subtract 2^total_bits
        value -= (1 << total_bits)

    # Convert to floating point by dividing by 2^frac_bits
    float_value = value / (2 ** frac_bits)

    return float_value


def read_q_format_file(filename, int_bits, frac_bits):
    """Read a file containing Q-format binary numbers and convert to float array."""
    values = []

    with open(filename, 'r') as f:
        content = f.read()
        # Extract all binary numbers (sequences of 0s and 1s)
        binary_numbers = re.findall(r'[01]+', content)

        for binary_str in binary_numbers:
            if binary_str:  # Skip empty strings
                value = parse_q_format(binary_str, int_bits, frac_bits)
                values.append(value)

    return np.array(values)


def calculate_mae(array1, array2):
    """Calculate Mean Absolute Error between two arrays."""
    if len(array1) != len(array2):
        raise ValueError(f"Arrays must have same length. Got {len(array1)} and {len(array2)}")

    return np.mean(np.abs(array1 - array2))


def calculate_mae_metrics(d, h, int_bits, collected_outputs):
    """
    Calculate MAE for outputs with same d, h, int_bits but different frac_bits.
    Uses the highest frac_bits as ground truth.

    Args:
        d: dimension parameter
        h: hidden size parameter
        int_bits: integer bits
        collected_outputs: dict mapping (d, h, int_bits, frac_bits) -> output_data

    Returns:
        dict mapping frac_bits -> MAE value (or None for ground truth)
    """
    # Find all outputs with matching d, h, int_bits
    matching_outputs = {
        frac_bits: data
        for (d_, h_, int_bits_, frac_bits), data in collected_outputs.items()
        if d_ == d and h_ == h and int_bits_ == int_bits
    }

    if len(matching_outputs) < 2:
        # Not enough data to compare
        return {frac_bits: None for frac_bits in matching_outputs.keys()}

    # Ground truth is the one with most fractional bits
    ground_truth_frac = max(matching_outputs.keys())
    ground_truth_data = matching_outputs[ground_truth_frac]

    # Calculate MAE for each configuration
    mae_results = {}
    for frac_bits, data in matching_outputs.items():
        if frac_bits == ground_truth_frac:
            mae_results[frac_bits] = None  # Ground truth has no error
        else:
            try:
                mae = calculate_mae(data, ground_truth_data)
                mae_results[frac_bits] = mae
            except Exception as e:
                print(f"Error calculating MAE for frac_bits={frac_bits}: {e}")
                mae_results[frac_bits] = None

    return mae_results


def run_vivado():
    subprocess.run([VIVADO_PATH, "-mode", "batch", "-source", "run_vivado.tcl"], check=True)


def main():
    data = []
    # Store output data for MAE calculation
    # Key: (d, h, int_bits, frac_bits), Value: numpy array of outputs
    collected_outputs = {}

    for attempt in range(1):
        for int_bits in [6]:
            for frac_bits in range(1, 35 - 4):
                for d in range(4, 65):
                    for h in [4]:
                        metrics = {}
                        try:
                            # Generate SV code
                            top_code = generate_top_level_sv(INT_WIDTH=int_bits, FRAC_WIDTH=frac_bits, d=d, h=h)
                            with open("top_level.sv", "w+", encoding="utf-8") as f:
                                f.write(top_code)
                            print("Generated top_level.sv")

                            gru_code = generate_gru_sv(INT_WIDTH=int_bits, FRAC_WIDTH=frac_bits, d=d, h=h)
                            with open("gru.sv", "w+", encoding="utf-8") as f:
                                f.write(gru_code)
                            print("Generated gru.sv")

                            # Accuracy Metrics
                            tb_code = generate_gru_tb_sv(INT_WIDTH=int_bits, FRAC_WIDTH=frac_bits, d=d, h=h)
                            with open("gru_tb.sv", "w+", encoding="utf-8") as f:
                                f.write(tb_code)
                            print("Generated gru_tb.sv")

                            # Other Metrics
                            run_vivado()

                            # Step 3: Extract metrics
                            metrics = extract_metrics()

                            # Read output file for MAE calculation
                            output_filename = f"output_d{d}_h{h}_int{int_bits}_frac{frac_bits}.txt"
                            if Path(output_filename).exists():
                                try:
                                    output_data = read_q_format_file(output_filename, int_bits, frac_bits)
                                    collected_outputs[(d, h, int_bits, frac_bits)] = output_data
                                    print(f"Loaded {len(output_data)} output values from {output_filename}")
                                except Exception as e:
                                    print(f"Error reading output file {output_filename}: {e}")

                            print("\nHardware Metrics Summary")
                            print("=" * 50)
                            if metrics:
                                metrics["D"] = d
                                metrics["H"] = h
                                metrics["int bits"] = int_bits
                                metrics["frac bits"] = frac_bits
                                metrics["result"] = "success"

                                for k, v in metrics.items():
                                    print(f"{k:20s}: {v}")

                                data.append(metrics)
                            else:
                                metrics["LUTs"] = 0
                                metrics["Registers"] = 0
                                metrics["BRAMs"] = 0
                                metrics["DSPs"] = 0
                                metrics["WNS (ns)"] = 0
                                metrics["Total Power (W)"] = 0
                                metrics["Dynamic Power (W)"] = 0
                                metrics["Static Power (W)"] = 0
                                metrics["D"] = d
                                metrics["H"] = h
                                metrics["int bits"] = int_bits
                                metrics["frac bits"] = frac_bits
                                metrics["result"] = "no metrics"
                                data.append(metrics)
                                print("No metrics extracted - reports may not have been generated")
                            print("=" * 50)

                        except Exception as e:
                            print(e)
                            metrics["LUTs"] = 0
                            metrics["Registers"] = 0
                            metrics["BRAMs"] = 0
                            metrics["DSPs"] = 0
                            metrics["WNS (ns)"] = 0
                            metrics["Total Power (W)"] = 0
                            metrics["Dynamic Power (W)"] = 0
                            metrics["Static Power (W)"] = 0
                            metrics["D"] = d
                            metrics["H"] = h
                            metrics["int bits"] = int_bits
                            metrics["frac bits"] = frac_bits
                            metrics["result"] = f"exception: {e.args}"
                            data.append(metrics)

    # Calculate MAE metrics for all configurations
    print("\n" + "=" * 60)
    print("Calculating MAE Metrics")
    print("=" * 60)

    # Group by (d, h, int_bits) and calculate MAE
    processed_groups = set()
    for idx, row in enumerate(data):
        d = row["D"]
        h = row["H"]
        int_bits = row["int bits"]
        frac_bits = row["frac bits"]

        group_key = (d, h, int_bits)

        # Calculate MAE for this group if not already done
        if group_key not in processed_groups:
            mae_results = calculate_mae_metrics(d, h, int_bits, collected_outputs)
            processed_groups.add(group_key)

            # Print MAE results
            if mae_results:
                print(f"\nGroup: d={d}, h={h}, int_bits={int_bits}")
                ground_truth_frac = max(k for k, v in mae_results.items() if v is None)
                print(f"  Ground Truth: frac_bits={ground_truth_frac}")
                for fb, mae in sorted(mae_results.items()):
                    if mae is not None:
                        print(f"  frac_bits={fb}: MAE = {mae:.8f}")

        # Add MAE to the corresponding row
        mae_results = calculate_mae_metrics(d, h, int_bits, collected_outputs)
        mae_value = mae_results.get(frac_bits)
        data[idx]["MAE"] = mae_value if mae_value is not None else "ground_truth"

    # Save to CSV
    df = pd.DataFrame(data)
    df.to_csv("data.csv", index=False)
    print("\n" + "=" * 60)
    print("Results saved to data.csv")
    print("=" * 60)


if __name__ == "__main__":
    main()