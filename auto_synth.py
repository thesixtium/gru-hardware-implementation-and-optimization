import subprocess
import os
import re

# 🔧 CHANGE THIS to match your Vivado installation path
VIVADO_PATH = r"C:\Xilinx\Vivado\2024.1\bin\vivado.bat"

# Reports are generated in the project directory, not a separate reports folder
VIVADO_PROJECT_DIR = "./vivado_proj"


def run_vivado():
    """Run Vivado in batch mode using the provided Tcl script."""
    print("🚀 Running Vivado synthesis and implementation...")

    # Use full path to Vivado batch launcher
    subprocess.run([VIVADO_PATH, "-mode", "batch", "-source", "run_vivado.tcl"], check=True)

    print("✅ Vivado run completed.")


def extract_metrics():
    """Parse Vivado report files and extract key metrics."""
    metrics = {}

    # Look for reports in the current directory (where Vivado writes them)
    # and also in the project directory
    possible_locations = [
        ".",  # Current directory
        VIVADO_PROJECT_DIR,
    ]

    util_file = None
    timing_file = None
    power_file = None

    # Search for utilization report
    for loc in possible_locations:
        candidates = [
            os.path.join(loc, "utilization_report.txt"),
            os.path.join(loc, "utilization_post_impl.rpt"),
            os.path.join(loc, "utilization.rpt"),
        ]
        for candidate in candidates:
            if os.path.exists(candidate):
                util_file = candidate
                break
        if util_file:
            break

    # Search for timing report
    for loc in possible_locations:
        candidates = [
            os.path.join(loc, "timing_report.txt"),
            os.path.join(loc, "timing_post_impl.rpt"),
            os.path.join(loc, "timing.rpt"),
        ]
        for candidate in candidates:
            if os.path.exists(candidate):
                timing_file = candidate
                break
        if timing_file:
            break

    # Search for power report
    for loc in possible_locations:
        candidates = [
            os.path.join(loc, "power_report.txt"),
            os.path.join(loc, "power.rpt"),
        ]
        for candidate in candidates:
            if os.path.exists(candidate):
                power_file = candidate
                break
        if power_file:
            break

    # Parse Utilization Report
    if util_file:
        try:
            print(f"📄 Reading utilization from: {util_file}")
            with open(util_file, encoding='utf-8', errors='ignore') as f:
                data = f.read()

                # Try multiple patterns for different report formats
                lut = re.search(r"CLB LUTs\s*\|\s*(\d+)", data)
                if not lut:
                    lut = re.search(r"Slice LUTs\s*\|\s*(\d+)", data)
                if not lut:
                    lut = re.search(r"LUT.*?\|\s*(\d+)", data)

                reg = re.search(r"CLB Registers\s*\|\s*(\d+)", data)
                if not reg:
                    reg = re.search(r"Slice Registers\s*\|\s*(\d+)", data)
                if not reg:
                    reg = re.search(r"Register.*?\|\s*(\d+)", data)

                bram = re.search(r"Block RAM Tile\s*\|\s*(\d+)", data)
                if not bram:
                    bram = re.search(r"RAMB\d+\s*\|\s*(\d+)", data)

                dsp = re.search(r"DSPs\s*\|\s*(\d+)", data)
                if not dsp:
                    dsp = re.search(r"DSP48E\d*\s*\|\s*(\d+)", data)

                if lut:
                    metrics["LUTs"] = int(lut.group(1))
                if reg:
                    metrics["Registers"] = int(reg.group(1))
                if bram:
                    metrics["BRAMs"] = int(bram.group(1))
                if dsp:
                    metrics["DSPs"] = int(dsp.group(1))
        except Exception as e:
            print(f"⚠️ Error reading utilization report: {e}")
    else:
        print("⚠️ Utilization report not found")

    # Parse Timing Report
    if timing_file:
        try:
            print(f"📄 Reading timing from: {timing_file}")
            with open(timing_file, encoding='utf-8', errors='ignore') as f:
                data = f.read()

                # Look for WNS (Worst Negative Slack)
                wns = re.search(r"WNS\(ns\)\s+([\-\d\.]+)", data)
                if not wns:
                    wns = re.search(r"Worst.*Slack.*?([\-\d\.]+)", data)
                if not wns:
                    wns = re.search(r"slack\s+([\-\d\.]+)", data, re.IGNORECASE)

                # Look for TNS (Total Negative Slack)
                tns = re.search(r"TNS\(ns\)\s+([\-\d\.]+)", data)

                # Look for maximum frequency
                fmax = re.search(r"(?:Max Frequency|Fmax).*?([\d\.]+)\s*MHz", data, re.IGNORECASE)

                if wns:
                    metrics["WNS (ns)"] = float(wns.group(1))
                if tns:
                    metrics["TNS (ns)"] = float(tns.group(1))
                if fmax:
                    metrics["Max Freq (MHz)"] = float(fmax.group(1))
        except Exception as e:
            print(f"⚠️ Error reading timing report: {e}")
    else:
        print("⚠️ Timing report not found")

    # Parse Power Report
    if power_file:
        try:
            print(f"📄 Reading power from: {power_file}")
            with open(power_file, encoding='utf-8', errors='ignore') as f:
                data = f.read()

                total_power = re.search(r"Total On-Chip Power\s*\(W\)\s*\|\s*([\d\.]+)", data)
                if not total_power:
                    total_power = re.search(r"Total.*Power.*?([\d\.]+)\s*W", data)

                dynamic_power = re.search(r"Dynamic\s*\(W\)\s*\|\s*([\d\.]+)", data)
                static_power = re.search(r"Device Static\s*\(W\)\s*\|\s*([\d\.]+)", data)

                if total_power:
                    metrics["Total Power (W)"] = float(total_power.group(1))
                if dynamic_power:
                    metrics["Dynamic Power (W)"] = float(dynamic_power.group(1))
                if static_power:
                    metrics["Static Power (W)"] = float(static_power.group(1))
        except Exception as e:
            print(f"⚠️ Error reading power report: {e}")
    else:
        print("⚠️ Power report not found")

    return metrics


def main():
    # Step 1: (Optional) Generate Verilog here if needed
    # import gru_gen; gru_gen.generate_verilog()

    # Step 2: Run Vivado
    run_vivado()

    # Step 3: Extract metrics
    metrics = extract_metrics()

    print("\n📊 Hardware Metrics Summary")
    print("=" * 50)
    if metrics:
        for k, v in metrics.items():
            print(f"{k:20s}: {v}")
    else:
        print("No metrics extracted - reports may not have been generated")
    print("=" * 50)


if __name__ == "__main__":
    main()