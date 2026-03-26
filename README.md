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

### Experiment 1 — CPU/MCU Baseline (`arduinoImplementation/`)

**Goal:** Characterize the computational cost of a single GRU inference step on an MCU to establish a comparison baseline.

**What was done:**

* Implemented a GRU in C++ using the modern PyTorch-style GRU equations (with biases, reset/update/new gates)
* Fully unrolled the C++ code and inlined all methods so that GCC produces flat, loopless assembly — this ensures every instruction corresponds to actual GRU computation, not loop overhead
* Compiled to AVR assembly using GCC and counted every instruction by type (arithmetic, data load, data store, branch, etc.)
* Result: **11,968 MCU instructions per GRU timestep**
* Estimated execution time and energy per step across 8 MCUs used in current BCI literature: ARM Cortex-M3, ARM Cortex-M4F, ARM Cortex-M7, ATmega328 (Arduino Nano), ATmega2560 (Arduino Mega), Micro2440SDK, Raspberry Pi 3B, STM32L433
* Formula used: `T = N\_cycles / f`, `E = P × T`

**Key finding:** Arithmetic and data load instructions are nearly equal in count (\~4,600 vs \~4,250), indicating that memory access — not compute — is the dominant bottleneck in software GRU execution. This is because the reset, update, and new gates all independently reload the same `x\_t` and `h\_{t-1}` vectors from memory.

**Key files:**

* `BCI\_functions.py` — BCI dataset loading and preprocessing utilities
* `arduino\_gru\_host.py` — Host-side Python for communicating with Arduino
* `GRU.ipynb` — Notebook for GRU model training and weight export
* `assembly.ipynb` — Notebook for instruction counting and classification
* `gru\_model.h` / `gru\_model.tflite` — Exported GRU model weights
* `main/` / `main\_unrolled/` — C++ GRU implementations (rolled and unrolled)

\---

### Experiment 2a — Naive FPGA Implementation (`naiveImplementation/`)

**Goal:** Implement a GRU in SystemVerilog using purely combinational logic, then sweep the design space.

**Architecture:** The GRU is controlled by an FSM sequencing through the four GRU equations (reset gate → update gate → new gate → hidden state). Each gate equation is computed as an independent module. This version uses **combinational logic only** — no registers between pipeline stages.

**Design space variables (independent):**

|Variable|Values tested|
|-|-|
|Fractional width (fixed-point precision)|{4, 9, 14, 19, 24} bits|
|Input dimension `d` (BCI channels)|{4, 8, 16, 32, 64}|
|Hidden state size `h`|{4, 6, 8, 12, 16}|

**Controlled variables:** Integer width = 6 bits, target FPGA = Xilinx Artix-7 (XCU250), clock = 100 MHz, Vivado 2024.1, 100 deterministic EEG test vectors.

**Metrics collected (dependent):** LUTs, Registers, BRAMs, DSPs, WNS (timing slack), total/dynamic/static power, MAE, RMSE, clock period utilization, cycle utilization, time utilization, average utilization.

**Dataset:** EEG Motor Movement/Imagery Dataset (EEGMMIDB) from PhysioNet — 109 volunteers, 64-channel EEG at 160 Hz, motor imagery tasks. 100 test samples used. Ground truth computed using 32-bit floating-point.

**How the automation pipeline works:**

1. Python generates three SystemVerilog files per trial: the GRU module, a top-level wrapper, and a testbench with 100 deterministic test vectors
2. A Tcl script launches Vivado, runs synthesis + implementation + simulation, and dumps reports
3. Python parses the Vivado reports to extract hardware metrics and computes MAE/RMSE vs floating-point ground truth
4. Results accumulate into a pandas DataFrame saved as CSV

**Key files:**

* `main.py` — Top-level script; set your paths and design space here, then run this
* `generate\_gru\_sv.py` — Generates the GRU SystemVerilog module
* `generate\_top\_level\_sv.py` — Generates the top-level wrapper
* `generate\_gru\_tb\_sv.py` — Generates the testbench
* `run\_vivado.tcl` — Tcl script that Vivado executes
* `extract\_metrics.py` — Parses Vivado reports
* `float\_to\_fixed\_point.py` — Converts floating-point weights to fixed-point
* `generate\_gru\_ground\_truth.py` — Computes floating-point ground truth outputs
* `gru.sv` / `gru\_tb.sv` / `mult.sv` / `sigmoid.sv` — Hand-written SystemVerilog modules
* `data.csv` / `data\_GOOD.csv` — Collected experimental results
* `constraints.xdc` — Vivado timing constraints

**Visualizations generated** (see boxplot\_*.png and 3d\_*.png for examples):

* Boxplots of DSPs, LUTs, Registers, Dynamic Power, Total Power, MAE, Time Utilization vs design variables
* Correlation matrix heatmap

\---

### Experiment 2b — Optimized FPGA Implementation (`optimizedImplementation/`)

**Goal:** Same design space sweep as naiveImplementation, but with **time-multiplexed sequential logic** — hardware units are reused across clock cycles rather than instantiated in full combinational parallel. This trades clock cycles for hardware area.

**What changed from naive:**

* GRU module now uses registers and an FSM to time-multiplex computations across multiple clock cycles
* Added a `Num Parallel` design variable controlling how many computation units are instantiated in parallel (1, 2, 4, 8, or 16)
* Enables explicit parallelism vs. area trade-off analysis

**Additional design space variable:**

|Variable|Values tested|
|-|-|
|Num Parallel|{1, 2, 4, 8, 16}|

**Total design combinations:** 5 × 5 × 5 × 5 = 625 (11 failed due to FPGA resource limits on the XCU250 — these configurations are infeasible in practice anyway)

**Key files:** Same structure as `naiveImplementation/`, plus:

* `testbenchInputs/` — Pre-generated test vectors
* Additional 3D surface plots (`3d\_\*.png`) for three-variable interaction visualization
* `Equations.docx` — Fixed-point GRU equations reference

**Key findings:**

* Higher fractional bit width → lower MAE/RMSE but more LUTs/Registers; diminishing returns after \~9 fractional bits, negligible after that
* Higher parallelism → fewer clock cycles but proportionally more hardware; no accuracy effect (as expected)
* Fractional width affects clock period utilization but not cycle utilization; parallelism affects cycle utilization but not clock period utilization
* FPGA significantly outperforms all tested MCUs on both step frequency and energy per step

\---

### Experiment 3 — Physical FPGA Deployment (`actualImplementation/`)

**Goal:** Take a single design from the optimized design space search and implement it on a physical Arty A7-100T FPGA to validate the simulation results and document implementation challenges.

**Status:** Partial — the Vivado project was set up and the design was synthesized and routed. Communication protocol between an external host and the FPGA (needed to stream 64-channel × 16-bit data at 40 kHz, i.e., Utah Array frequency) could not be completed in time.

**What's here:**

* `actualImplementation.xpr` — Vivado project file (open this in Vivado 2024.1)
* `actualImplementation.srcs/` — SystemVerilog source files for the implementation
* `actualImplementation.hw/` — Hardware handoff files
* `actualImplementation.runs/` — Vivado synthesis and implementation run outputs
* `actualImplementation.cache/` — Vivado IP cache

**To pick up where this left off:** Open `actualImplementation.xpr` in Vivado 2024.1. The main outstanding task is implementing a communication protocol capable of transferring 64 × 16-bit = 1,024 bits per sample at 40 kHz. UART is too slow; SPI or a custom parallel protocol is likely needed.

\---

## Hardware Architecture Detail

The GRU implements the modern PyTorch-style equations:

```
r\_t = σ(W\_ir·x\_t + b\_ir + W\_hr·h\_{t-1} + b\_hr)          # Reset gate
z\_t = σ(W\_iz·x\_t + b\_iz + W\_hz·h\_{t-1} + b\_hz)          # Update gate
n\_t = tanh(W\_in·x\_t + b\_in + r\_t ⊙ (W\_hn·h\_{t-1} + b\_hn)) # New gate
h\_t = (1 - z\_t) ⊙ n\_t + z\_t ⊙ h\_{t-1}                  # Hidden state
```

**Fixed-point representation:** Q6.F format where 6 is the integer width and F is the fractional width. Integer width of 6 was chosen because the test data range is −3.28 to 2.96.

**Activation functions:** Sigmoid and tanh are implemented using LUTs (lookup tables), chosen over PLA (piecewise linear approximation) for better accuracy, lower LUT usage, and higher max frequency, following Sorayaasa (2022).

**Parallelism:** The `Num Parallel` parameter controls how many MAC units are instantiated. Each MAC unit computes one dot-product element per clock cycle. The FSM time-multiplexes these units across the hidden state dimension.

\---

## Running the Simulations

### Prerequisites

* Python 3.11
* Xilinx Vivado 2024.1 (must be installed and licensed)
* Python packages: `numpy`, `matplotlib`, `pandas`, `scipy`

### Steps (Naive or Optimized Implementation)

1. **Set paths** — In `main.py`, update:

   * Path to the Vivado executable (use forward slashes on Linux, backslashes on Windows)
   * Output path for the results CSV
2. **Set design space** — Near the top of `main()` in `main.py`, edit the lists defining the parameter sweep (fractional widths, input dims, hidden sizes, and for optimized: num parallel)
3. **Run:**

```bash
   python main.py
   ```

   Progress is written to `status.txt` — tail this file to monitor runtime.

4. **Visualize results** — Open the Jupyter notebook (`.ipynb`) in the same folder and run all cells to regenerate all plots from the CSV.

   > \*\*Runtime note:\*\* Each Vivado trial takes several minutes. A full 625-combination sweep takes many hours. Run on a machine you can leave overnight.

   ### Opening the Physical Implementation

   ```
File → Open Project → actualImplementation/actualImplementation.xpr
```

   Requires Vivado 2024.1.

   \---

   ## Dataset

   **EEG Motor Movement/Imagery Dataset (EEGMMIDB)** — available on PhysioNet:

   > Goldberger et al., PhysioBank, PhysioToolkit, and PhysioNet, \*Circulation\*, 2000.

* 109 subjects, 64 EEG channels, 160 Hz sampling rate
* Motor imagery tasks (imagined left/right hand movement, feet, rest)
* 100 deterministic test samples used for all hardware accuracy evaluation
* Ground truth: 32-bit floating-point GRU running the same weights

  \---

  ## Key Results Summary

|Platform|Max Step Freq|Energy/Step|Notes|
|-|-|-|-|
|ATmega2560|\~2.1 kHz|\~30 µJ|Slowest, most energy|
|ARM Cortex-M3|\~8.4 kHz|\~3.5 µJ|Common BCI MCU|
|ARM Cortex-M4F|\~20 kHz|\~0.15 µJ|Best MCU energy|
|Arty A7-100T (FPGA)|**\~417 kHz**|**\~0.13 µJ**|Best overall|

* FPGA runs GRU steps >20× faster than the best tested MCU
* FPGA energy per step is competitive with or better than the most efficient MCUs
* 9 fractional bits is the practical accuracy sweet spot — negligible accuracy gain beyond this
* Low parallelism (1–2) is sufficient given the 100 MHz FPGA clock vs 40 kHz BCI sample rate

\---

## Tech Stack

* **SystemVerilog** — GRU hardware description
* **Python** — Design space automation, metric extraction, visualization
* **Tcl** — Vivado scripting
* **Jupyter Notebook** — Result analysis and plotting
* **C++** — MCU GRU implementation (compiled to AVR assembly via GCC)
* **Xilinx Vivado 2024.1** — Synthesis, implementation, simulation, power analysis
* **Target FPGA:** Xilinx Artix-7 (XCU250 for simulation, Arty A7-100T for physical)

\---

## If You're Picking This Up

**Start here:** Read the thesis PDF for full context. Then:

1. To understand the MCU baseline → `arduinoImplementation/assembly.ipynb`
2. To understand the FPGA design space → `optimizedImplementation/main.py` and the result CSVs + notebooks
3. To continue the physical implementation → open `actualImplementation/actualImplementation.xpr` in Vivado; the main gap is the host–FPGA communication protocol for streaming EEG data

**Suggested next steps from the thesis:**

* Implement shift-and-add (CSD) multiplication to reduce LUT usage
* Explore bit-serial structures to further reduce hardware area at the cost of latency (acceptable since 100 MHz FPGA >> 40 kHz BCI sample rate)
* Scale to full Utah Array input (1024 channels instead of 64)
* Implement and validate the host communication protocol on the Arty A7-100T

\---

## Citation

If you use this work, please cite:

> A. Berezowski, "GRU Hardware Implementation and Optimization," University of Calgary, 2025.
> GitHub: https://github.com/thesixtium/gru-hardware-implementation-and-optimization

