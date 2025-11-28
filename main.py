import subprocess
import pandas as pd
import re
import numpy as np
from pathlib import Path

from extract_metrics import extract_metrics
from generate_gru_ground_truth import generate_gru_ground_truth
from generate_gru_sv import generate_gru_sv
from generate_gru_tb_sv import generate_gru_tb_sv
from generate_top_level_sv import generate_top_level_sv
import time

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


def read_ground_truth_file(filename):
    """Read ground truth file and return numpy array of float values."""
    values = []

    with open(filename, 'r') as f:
        for line in f:
            line = line.strip()
            if line:
                # Parse space-separated float values
                line_values = [float(x) for x in line.split()]
                values.extend(line_values)

    return np.array(values)


def calculate_mae(array1, array2):
    """Calculate Mean Absolute Error between two arrays."""
    if len(array1) != len(array2):
        min_len = min(len(array1), len(array2))
        print(
            f"Warning: Arrays have different lengths ({len(array1)} vs {len(array2)}). Using first {min_len} elements.")
        array1 = array1[:min_len]
        array2 = array2[:min_len]

    return np.mean(np.abs(array1 - array2))


def calculate_rmse(array1, array2):
    """Calculate Mean Absolute Error between two arrays."""
    if len(array1) != len(array2):
        min_len = min(len(array1), len(array2))
        print(
            f"Warning: Arrays have different lengths ({len(array1)} vs {len(array2)}). Using first {min_len} elements.")
        array1 = array1[:min_len]
        array2 = array2[:min_len]

    return np.sqrt(np.mean( (array1 - array2) ** 2) )


def calculate_mae_against_ground_truth(d, h, int_bits, frac_bits, output_data):
    """
    Calculate MAE by comparing output_data against ground truth file.

    Args:
        d: dimension parameter
        h: hidden size parameter
        int_bits: integer bits
        frac_bits: fractional bits
        output_data: numpy array of output values from hardware

    Returns:
        MAE value or None if ground truth file not found
    """
    ground_truth_filename = f'ground_truth_d{d}_h{h}.txt'

    if not Path(ground_truth_filename).exists():
        print(f"Warning: Ground truth file {ground_truth_filename} not found")
        return None

    try:
        ground_truth_data = read_ground_truth_file(ground_truth_filename)
        mae = calculate_mae(output_data, ground_truth_data)
        return mae
    except Exception as e:
        print(f"Error calculating MAE against ground truth: {e}")
        return None


def calculate_rmse_against_ground_truth(d, h, int_bits, frac_bits, output_data):
    """
    Calculate rmse by comparing output_data against ground truth file.

    Args:
        d: dimension parameter
        h: hidden size parameter
        int_bits: integer bits
        frac_bits: fractional bits
        output_data: numpy array of output values from hardware

    Returns:
        rmse value or None if ground truth file not found
    """
    ground_truth_filename = f'ground_truth_d{d}_h{h}.txt'

    if not Path(ground_truth_filename).exists():
        print(f"Warning: Ground truth file {ground_truth_filename} not found")
        return None

    try:
        ground_truth_data = read_ground_truth_file(ground_truth_filename)
        rmse = calculate_rmse(output_data, ground_truth_data)
        return rmse
    except Exception as e:
        print(f"Error calculating rmse against ground truth: {e}")
        return None


def run_vivado():
    subprocess.run([VIVADO_PATH, "-mode", "batch", "-source", "run_vivado.tcl"], check=True)


def main():
    data = []
    filename = "status.txt"

    # Clear the file at the start
    with open(filename, "w+") as f:
        f.write("")

    count = 0
    h_range    = [ 8, 6, 4 ]  # [ 16, 12,  8,  6,  4 ]
    d_range    = [ 16, 8, 4 ]  # [ 64, 32, 16,  8,  4 ]
    int_range  = [  6 ]
    frac_range = [ 14, 9, 4 ]  # [ 24, 19, 14,  9,  4 ]
    total = len(h_range) * len(d_range) * len(int_range) * len(frac_range)

    for attempt in range(1):
        for h in h_range:
            for d in d_range:
                # Generate ground truth once per (d, h) combination
                print(f"\nGenerating ground truth for d={d}, h={h}")
                generate_gru_ground_truth(d=d, h=h)

                for int_bits in int_range:
                    for frac_bits in frac_range:
                        start_time = time.time()
                        count += 1

                        metrics = {}

                        with open(filename, "a") as f:
                            f.write(
                                f"{round((count / total) * 100, 5)}\tattempt = {attempt}\tint_bits = {int_bits}\tfrac_bits = {frac_bits}\td = {d}\th = {h}")

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

                            # Read output file and calculate MAE against ground truth
                            output_filename = f"output_d{d}_h{h}_int{int_bits}_frac{frac_bits}.txt"
                            mae_value = None
                            rmse_value = None

                            if Path(output_filename).exists():
                                try:
                                    output_data = read_q_format_file(output_filename, int_bits, frac_bits)
                                    print(f"Loaded {len(output_data)} output values from {output_filename}")

                                    # Calculate MAE against ground truth
                                    mae_value = calculate_mae_against_ground_truth(d, h, int_bits, frac_bits,
                                                                                   output_data)
                                    rmse_value = calculate_rmse_against_ground_truth(d, h, int_bits, frac_bits,
                                                                                   output_data)

                                    if mae_value is not None:
                                        print(f"MAE against ground truth: {mae_value:.8f}")

                                except Exception as e:
                                    print(f"Error reading output file {output_filename}: {e}")

                            print("\nHardware Metrics Summary")
                            print("=" * 50)
                            if metrics:
                                metrics["D"] = d
                                metrics["H"] = h
                                metrics["int bits"] = int_bits
                                metrics["frac bits"] = frac_bits
                                metrics["MAE"] = mae_value if mae_value is not None else 0
                                metrics["RMSE"] = rmse_value if rmse_value is not None else 0
                                metrics["result"] = "success"
                                metrics["Execution Time (m)"] = (time.time() - start_time) / 60
                                with open(filename, "a") as f:
                                    f.write(f'\t{metrics["MAE"]}\t{metrics["RMSE"]}\t{metrics["Execution Time (m)"]}\n')

                                for k, v in metrics.items():
                                    print(f"{k:20s}: {v}")

                                metrics["Time Utilization"] = (10 - metrics["WNS (ns)"]) / 10

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
                                metrics["Time Utilization"] = 0
                                metrics["D"] = d
                                metrics["H"] = h
                                metrics["int bits"] = int_bits
                                metrics["frac bits"] = frac_bits
                                metrics["MAE"] = mae_value if mae_value is not None else 0
                                metrics["RMSE"] = rmse_value if rmse_value is not None else 0
                                metrics["result"] = "no metrics"
                                metrics["Execution Time (m)"] = (time.time() - start_time) / 60
                                with open(filename, "a") as f:
                                    f.write(f'\t{metrics["MAE"]}\t{metrics["RMSE"]}\t{metrics["Execution Time (m)"]}\n')
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
                            metrics["Time Utilization"] = 0
                            metrics["D"] = d
                            metrics["H"] = h
                            metrics["int bits"] = int_bits
                            metrics["frac bits"] = frac_bits
                            metrics["MAE"] = 0
                            metrics["RMSE"] = 0
                            metrics["result"] = f"exception: {e.args}"
                            metrics["Execution Time (m)"] = (time.time() - start_time) / 60
                            with open(filename, "a") as f:
                                f.write(f'\t{metrics["MAE"]}\t{metrics["RMSE"]}\t{metrics["Execution Time (m)"]}\n')
                            data.append(metrics)

    # Save to CSV
    df = pd.DataFrame(data)
    df.to_csv("data.csv", index=False)
    print("\n" + "=" * 60)
    print("Results saved to data.csv")
    print("=" * 60)

    # Print summary of MAE results
    print("\nMAE Summary:")
    print("=" * 60)
    for _, row in df.iterrows():
        if row["MAE"] > 0:
            print(f"d={row['D']}, h={row['H']}, int={row['int bits']}, frac={row['frac bits']}: MAE = {row['MAE']:.8f}")

if __name__ == "__main__":
    main()