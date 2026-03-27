# GRU Hardware Implementation and Optimization

Research project for **ENEL 592** and **ENEL 594** at the University of Calgary. The goal is to characterize how GRU design parameters (input size, hidden state size, fractional bit width, and parallelism) affect resource utilization, timing, power consumption, and accuracy when deployed on an FPGA for Brain-Computer Interface (BCI) applications.

The project answers three research questions:

* **RQ1**: How do FPGA-based GRU deployments compare to MCU-based deployments for edge BCI?
* **RQ2**: What effect does parallelization have on FPGA-based BCI GRU models?
* **RQ3**: What effect does fractional bit width have on FPGA-based BCI GRU models?

\---

## Project Structure

```
.
├── arduinoImplementation/     # Experiment 1 — CPU/MCU baseline characterization
├── naiveImplementation/       # Experiment 2a — Combinational-logic GRU design space
├── optimizedImplementation/   # Experiment 2b — Sequential/time-multiplexed GRU design space
├── actualImplementation/      # Experiment 3 — Physical FPGA deployment attempt
├── EMBC Submission/           # LaTeX source for EMBC 2026 paper submission
├── Final Presentation.pptx
└── README.md
```

\---

## Experiments Overview

### Experiment 1 - CPU/MCU Baseline (`arduinoImplementation/`)

**Goal:** Characterize the computational cost of a single GRU step on an MCU to establish a comparison baseline.

**What was done:**

* Implemented a GRU in C++ using GRU equations
* Fully unrolled the C++ code and inlined all methods so that GCC produces flat, loopless assembly; this ensures every instruction corresponds to GRU computation, not loop overhead
* Compiled to AVR assembly using GCC and counted every instruction by type (arithmetic, data load, data store, branch, etc.)
* Result: 11,968 MCU instructions per GRU timestep
* Estimated execution time and energy per step across 8 MCUs used in current BCI literature: ARM Cortex-M3, ARM Cortex-M4F, ARM Cortex-M7, ATmega328 (Arduino Nano), ATmega2560 (Arduino Mega), Micro2440SDK, Raspberry Pi 3B, STM32L433

**Key finding:** Arithmetic and data load instructions are nearly equal in count (\~4,600 vs \~4,250), indicating that memory access, not compute, is the dominant bottleneck in software GRU execution. This is because the reset, update, and new gates all independently reload the same `x_t` and `h_{t-1}` vectors multiple times from memory.

**Key files:**

* `BCI_functions.py`: BCI dataset loading and preprocessing utilities
* `arduino_gru_host.py`: Host-side Python for communicating with Arduino
* `GRU.ipynb`: Notebook for GRU model training and weight export
* `assembly.ipynb`: Notebook for instruction counting and classification
* `main` / `main_unrolled`: C++ GRU implementations (rolled and unrolled)

\---

### Experiment 2a - Naive FPGA Implementation (`naiveImplementation/`)

**Goal:** Implement a GRU in SystemVerilog using purely combinational logic, then exhaustively test the design space.

**Architecture:** The GRU uses combinational logic only with no registers between pipeline stages.

**Design space variables (independent):**

|Variable|Values tested|
|-|-|
|Fractional width (fixed-point precision)|{4, 9, 14, 19, 24} bits|
|Input dimension `d` (BCI channels)|{4, 8, 16, 32, 64}|
|Hidden state size `h`|{4, 6, 8, 12, 16}|

**Controlled variables:** Integer width = 6 bits, target FPGA = Xilinx Artix-7 (XCU250), clock = 100 MHz, Vivado 2024.1, 100 deterministic EEG test vectors.

**Metrics collected (dependent):** LUTs, Registers, BRAMs, DSPs, WNS (timing slack), total/dynamic/static power, MAE, RMSE, clock period utilization, cycle utilization, time utilization, average utilization.

**Dataset:** EEG Motor Movement/Imagery Dataset (EEGMMIDB) from PhysioNet. 109 volunteers, 64-channel EEG at 160 Hz, motor imagery tasks. 100 test samples used. Ground truth computed using 32-bit floating-point.

**How the automation pipeline works:**

1. Python generates three SystemVerilog files per trial: the GRU module, a top-level wrapper, and a testbench with 100 deterministic test vectors
2. A Tcl script launches Vivado, runs synthesis + implementation + simulation, and dumps reports
3. Python parses the Vivado reports to extract hardware metrics and computes MAE/RMSE vs floating-point ground truth
4. Results accumulate into a pandas DataFrame saved as CSV

**Key files:**

* `main.py`: Top-level script; set your paths and design space here, then run this
* `generate_gru_sv.py`: Generates the GRU SystemVerilog module
* `generate_top_level_sv.py`: Generates the top-level wrapper
* `generate_gru_tb_sv.py`: Generates the testbench
* `run_vivado.tcl`: Tcl script that Vivado executes
* `extract_metrics.py`: Parses Vivado reports
* `float_to_fixed_point.py`: Converts floating-point weights to fixed-point
* `generate_gru_ground_truth.py`: Computes floating-point ground truth outputs
* `gru.sv` / `gru_tb.sv` / `mult.sv` / `sigmoid.sv`: Hand-written SystemVerilog modules
* `data.csv` / `data_GOOD.csv`: Collected experimental results
* `constraints.xdc`: Vivado timing constraints

**Visualizations generated** (see boxplot\_\*.png and 3d\_\*.png for examples):

* Boxplots of DSPs, LUTs, Registers, Dynamic Power, Total Power, MAE, Time Utilization vs design variables
* Correlation matrix heatmap

\---

### Experiment 2b - Optimized FPGA Implementation (`optimizedImplementation/`)

**Goal:** Same design space sweep as naiveImplementation, but with time-multiplexed sequential logic. Hardware units are reused across clock cycles rather than instantiated in full combinational parallel. This trades clock cycles for hardware area.

**What changed from naive:**

* GRU module now uses registers and an FSM to time-multiplex computations across multiple clock cycles
* Added a `Num Parallel` design variable controlling how many computation units are instantiated in parallel (1, 2, 4, 8, or 16)
* Enables explicit parallelism vs. area trade-off analysis

**Additional design space variable:**

|Variable|Values tested|
|-|-|
|Num Parallel|{1, 2, 4, 8, 16}|

**Key findings:**

* Higher fractional bit width: Lower MAE/RMSE but more LUTs/Registers; diminishing returns after \~9 fractional bits, negligible after that
* Higher parallelism: Fewer clock cycles but proportionally more hardware; no accuracy effect (as expected)
* Fractional width affects clock period utilization but not cycle utilization; parallelism affects cycle utilization but not clock period utilization
* FPGA significantly outperforms all tested MCUs on both step frequency and energy per step

\---

### Experiment 3 - Physical FPGA Deployment (`actualImplementation/`)

**Goal:** Take a single design from the optimized design space search and implement it on a physical Arty A7-100T FPGA to validate the simulation results and document implementation challenges.

**Status:** Not done because the Vivado project was set up and the design was synthesized and routed. Communication protocol between an external host and the FPGA (needed to stream 64-channel × 16-bit data at 40 kHz, i.e., Utah Array frequency) could not be completed in time.

\---

## Running the Simulations

### Prerequisites

* Python 3.11
* Xilinx Vivado 2024.1 (must be installed and licensed)
* Python packages: `numpy`, `matplotlib`, `pandas`, `scipy`

### Steps (Naive or Optimized Implementation)

1. **Set paths**: In `main.py`, update:

   * Path to the Vivado executable (use forward slashes on Linux, backslashes on Windows)
   * Output path for the results CSV
2. **Set design space**: Near the top of `main()` in `main.py`, edit the lists defining the parameter sweep (fractional widths, input dims, hidden sizes, and for optimized: num parallel)
3. **Run:**

```bash
   python main.py
   ```

   Progress is written to `status.txt`.

4. **Visualize results**: Open the Jupyter notebook (`.ipynb`) in the same folder and run all cells to regenerate all plots from the CSV.

   > \*\*Runtime note:\*\* Each Vivado trial takes several minutes. A full 625-combination sweep takes many hours. Run on a machine you can leave overnight.
   ## Dataset

   **EEG Motor Movement/Imagery Dataset (EEGMMIDB)** — available on PhysioNet:

   > Goldberger et al., PhysioBank, PhysioToolkit, and PhysioNet, 2000.

* 109 subjects, 64 EEG channels, 160 Hz sampling rate
* Motor imagery tasks (imagined left/right hand movement, feet, rest)
* 100 deterministic test samples used for all hardware accuracy evaluation
* Ground truth: 32-bit floating-point GRU running the same weights

\---

## Citation

If you use this work, please cite:

> A. Berezowski, "GRU Hardware Implementation and Optimization," University of Calgary, 2025.
> GitHub: https://github.com/thesixtium/gru-hardware-implementation-and-optimization

