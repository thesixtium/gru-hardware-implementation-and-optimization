import subprocess
import pandas as pd

from extract_metrics import extract_metrics
from generate_gru_sv import generate_gru_sv
from generate_top_level_sv import generate_top_level_sv

# 🔧 CHANGE THIS to match your Vivado installation path
VIVADO_PATH = r"C:\Xilinx\Vivado\2024.1\bin\vivado.bat"


def run_vivado():
    subprocess.run([VIVADO_PATH, "-mode", "batch", "-source", "run_vivado.tcl"], check=True)


def main():
    data = []

    for int_bits in [8]:
        for frac_bits in [8]:
            for d in [2]:
                for h in [2]:
                    try:
                        # Generate SV code
                        top_code = generate_top_level_sv(INT_WIDTH=int_bits, FRAC_WIDTH=frac_bits)
                        with open("top_level.sv", "w+", encoding="utf-8") as f:
                            f.write(top_code)
                        print("Generated top_level.sv")

                        gru_code = generate_gru_sv(INT_WIDTH=int_bits, FRAC_WIDTH=frac_bits)
                        with open("gru.sv", "w+", encoding="utf-8") as f:
                            f.write(gru_code)
                        print("Generated gru.sv")

                        # Accuracy Metrics


                        # Other Metrics
                        run_vivado()

                        # Step 3: Extract metrics
                        metrics = extract_metrics()

                        print("\nHardware Metrics Summary")
                        print("=" * 50)
                        if metrics:
                            metrics["D"] = d
                            metrics["H"] = h
                            metrics["int bits"] = int_bits
                            metrics["frac bits"] = frac_bits
                            for k, v in metrics.items():
                                print(f"{k:20s}: {v}")

                            data.append(metrics)
                        else:
                            print("No metrics extracted - reports may not have been generated")
                        print("=" * 50)

                    except Exception as e:
                        print( e )

                    pd.DataFrame(data).to_csv("data.csv", index=False)



if __name__ == "__main__":
    main()
