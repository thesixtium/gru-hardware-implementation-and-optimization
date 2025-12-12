import subprocess
import pandas as pd
import re
from pathlib import Path

from generate_gru_ground_truth import generate_gru_ground_truth
from generate_gru_tb_sv import generate_gru_tb_sv
from modify_num_parallel import modify_num_parallel
from extract_metrics import extract_metrics
import time

from modify_constraints import modify_clock_period

# 🔧 CHANGE THIS to match your Vivado installation path
# VIVADO_PATH = r"C:\Xilinx\Vivado\2024.1\bin\vivado.bat"
VIVADO_PATH = r"/tools/Xilinx/Vivado/2024.1/bin/vivado"

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



def extract_avg_cycles(filename):
    """
    Extract the average cycles from a GRU test results file.

    Args:
        filename: Path to the results file

    Returns:
        Average cycles as an integer, or None if not found
    """
    try:
        with open(filename, 'r') as f:
            content = f.read()

        # Pattern to match "Avg cycles: XXXX per computation"
        pattern = r'Avg cycles:\s+(\d+)\s+per computation'

        match = re.search(pattern, content)

        if match:
            avg_cycles = int(match.group(1))
            return avg_cycles
        else:
            print(f"Warning: 'Avg cycles' not found in {filename}")
            return None

    except FileNotFoundError:
        print(f"Error: File '{filename}' not found")
        return None
    except Exception as e:
        print(f"Error: {e}")
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
    clock_period_range = [ 4, 5 ]
    """
    500 MHz: -period 2.000
    250 MHz: -period 4.000
    200 MHz: -period 5.000
    100 MHz: -period 10.000
    50 MHz: -period 20.000
    """

    num_parallel_range = [4]
    int_width_range = [6]
    frac_width_range = [9]

    total = len(clock_period_range) * len(num_parallel_range) * len(int_width_range) * len(frac_width_range)

    d = 4
    h = 2

    generate_gru_ground_truth(d, h, 100)

    for attempt in range(1):
        for clock_period in clock_period_range:
            for num_parallel in num_parallel_range:
                for int_bits in int_width_range:
                    for frac_bits in frac_width_range:

                        start_time = time.time()
                        count += 1

                        metrics = {}

                        with open(filename, "a") as f:
                            f.write(
                                f"{round((count / total) * 100, 5)}\tattempt = {attempt}\tnum_parallel = {num_parallel}\tclock_period = {clock_period}")

                        try:
                            modify_clock_period(
                                r"C:\Users\ajrbe\Documents\School\Thesis\BCI\Code\constraints.xdc",
                                clock_period
                            )

                            modify_num_parallel(
                                r"C:\Users\ajrbe\Documents\School\Thesis\BCI\Code\gru_cell_parallel.sv",
                                num_parallel=num_parallel,
                                data_width=int_bits + frac_bits,
                                frac_bits=frac_bits,
                                d=d,
                                h=h
                            )

                            # Accuracy Metrics
                            tb_code = generate_gru_tb_sv(INT_WIDTH=int_bits, FRAC_WIDTH=frac_bits, d=d, h=h)
                            with open("gru_tb.sv", "w+", encoding="utf-8") as f:
                                f.write(tb_code)
                            print("Generated gru_tb.sv")

                            # Other Metrics
                            run_vivado()

                            # Step 3: Extract metrics
                            metrics = extract_metrics()

                            # Read output file and calculate cycles
                            output_filename = f"cycles_d{d}_h{h}_df{int_bits+frac_bits}_fb{frac_bits}_np{num_parallel}.txt"

                            cycles = None
                            if Path(output_filename).exists():
                                cycles = extract_avg_cycles( output_filename )

                            # Read output file and calculate MAE against ground truth
                            output_filename = f"output_d{d}_h{h}_df{int_bits+frac_bits}_fb{frac_bits}_np{num_parallel}.txt"
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
                                metrics["result"] = "success"
                                metrics["Cycles"] = cycles
                                metrics["Clock Period"] = clock_period
                                metrics["MAE"] = mae_value
                                metrics["RMSE"] = rmse_value
                                metrics["Execution Time (m)"] = (time.time() - start_time) / 60
                                with open(filename, "a") as f:
                                    f.write(f'\t{metrics["Cycles"]}\t{metrics["Execution Time (m)"]}\n')

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
                                metrics["Time Utilization"] = 0
                                metrics["MAE"] = 0
                                metrics["RMSE"] = 0
                                metrics["result"] = "no metrics"
                                metrics["Cycles"] = 0
                                metrics["Clock Period"] = clock_period
                                metrics["Execution Time (m)"] = (time.time() - start_time) / 60
                                with open(filename, "a") as f:
                                    f.write(f'\t{metrics["Cycles"]}\t{metrics["Execution Time (m)"]}\n')

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
                            metrics["MAE"] = 0
                            metrics["RMSE"] = 0
                            metrics["result"] = f"exception: {e.args}"
                            metrics["Cycles"] = 0
                            metrics["Clock Period"] = clock_period
                            metrics["Execution Time (m)"] = (time.time() - start_time) / 60
                            with open(filename, "a") as f:
                                f.write(f'\t{metrics["Cycles"]}\t{metrics["Execution Time (m)"]}\n')

                            data.append(metrics)

                        # Save to CSV
                        df = pd.DataFrame(data)
                        df.to_csv("optimized_data.csv", index=False)
                        print("\n" + "=" * 60)
                        print("Results saved to optimized_data.csv")
                        print("=" * 60)

    # Print summary of MAE results
    print("\nMAE Summary:")
    print("=" * 60)
    for _, row in df.iterrows():
        if row["MAE"] > 0:
            print(f"d={row['D']}, h={row['H']}, int={row['int bits']}, frac={row['frac bits']}: MAE = {row['MAE']:.8f}")

if __name__ == "__main__":
    main()