import subprocess
import pandas as pd

from extract_metrics import extract_metrics
from generate_gru_sv import generate_gru_sv
from generate_gru_tb_sv import generate_gru_tb_sv
from generate_top_level_sv import generate_top_level_sv

# 🔧 CHANGE THIS to match your Vivado installation path
VIVADO_PATH = r"C:\Xilinx\Vivado\2024.1\bin\vivado.bat"


def run_vivado():
    subprocess.run([VIVADO_PATH, "-mode", "batch", "-source", "run_vivado.tcl"], check=True)


def main():
    data = []

    for attempt in range(1):
        for int_bits in [3, 4, 6, 8, 16]:
            for frac_bits in [3, 4, 6, 8, 16]:
                for d in [4, 8, 16, 32, 64]:
                    for h in [4]:
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
                            print( e )
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


                        pd.DataFrame(data).to_csv("data.csv", index=False)



if __name__ == "__main__":
    main()
