import subprocess
import pandas as pd
import re
from pathlib import Path

from modify_num_parallel import modify_num_parallel
from extract_metrics import extract_metrics
import time

from modify_constraints import modify_clock_period

# 🔧 CHANGE THIS to match your Vivado installation path
# VIVADO_PATH = r"C:\Xilinx\Vivado\2024.1\bin\vivado.bat"
VIVADO_PATH = r"/tools/Xilinx/Vivado/2024.1/bin/vivado"


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
    clock_period_range = [ i for i in range(1, 21) ]
    """
    500 MHz: -period 2.000
    250 MHz: -period 4.000
    200 MHz: -period 5.000
    100 MHz: -period 10.000
    50 MHz: -period 20.000
    """

    num_parallel_range = [ i for i in range(1, 17) ]

    total = len(clock_period_range) * len(num_parallel_range)

    for attempt in range(1):
        for num_parallel in num_parallel_range:
            for clock_period in clock_period_range:

                start_time = time.time()
                count += 1

                metrics = {}

                with open(filename, "a") as f:
                    f.write(
                        f"{round((count / total) * 100, 5)}\tattempt = {attempt}\tnum_parallel = {num_parallel}\tclock_period = {clock_period}")

                try:
                    modify_clock_period(
                        r"/home/lex/Documents/git/gru-hardware-implementation-and-optimization/optimizedImplementation/constraints.xdc",
                        clock_period
                    )

                    modify_num_parallel(
                        r"/home/lex/Documents/git/gru-hardware-implementation-and-optimization/optimizedImplementation/",
                        num_parallel
                    )

                    # Other Metrics
                    run_vivado()

                    # Step 3: Extract metrics
                    metrics = extract_metrics()

                    # Read output file and calculate MAE against ground truth
                    output_filename = f"gru_results_D64_H16_DW15_FB9_NP{num_parallel}.txt"

                    cycles = None
                    if Path(output_filename).exists():
                        cycles = extract_avg_cycles( output_filename )

                    print("\nHardware Metrics Summary")
                    print("=" * 50)
                    if metrics:
                        metrics["result"] = "success"
                        metrics["Cycles"] = cycles
                        metrics["Clock Period"] = clock_period
                        metrics["Execution Time (m)"] = (time.time() - start_time) / 60

                        for k, v in metrics.items():
                            print(f"{k:20s}: {v}")

                        with open(filename, "a") as f:
                            f.write(f'\tCycles: {metrics["Cycles"]}\tWNS: {metrics["WNS (ns)"]}\t{metrics["Execution Time (m)"]}\n')

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
                        metrics["result"] = "no metrics"
                        metrics["Cycles"] = 0
                        metrics["Clock Period"] = clock_period
                        metrics["Execution Time (m)"] = (time.time() - start_time) / 60

                        with open(filename, "a") as f:
                            f.write(f'\tCycles: {metrics["Cycles"]}\tWNS: {metrics["WNS (ns)"]}\t{metrics["Execution Time (m)"]}\n')
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
                    metrics["result"] = f"exception: {e.args}"
                    metrics["Cycles"] = 0
                    metrics["Clock Period"] = clock_period
                    metrics["Execution Time (m)"] = (time.time() - start_time) / 60

                    with open(filename, "a") as f:
                        f.write(
                            f'\tCycles: {metrics["Cycles"]}\tWNS: {metrics["WNS (ns)"]}\t{metrics["Execution Time (m)"]}\n')
                    data.append(metrics)

    # Save to CSV
    df = pd.DataFrame(data)
    df.to_csv("optimized_data.csv", index=False)
    print("\n" + "=" * 60)
    print("Results saved to optimized_data.csv")
    print("=" * 60)

    #
if __name__ == "__main__":
    main()