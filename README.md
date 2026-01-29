
# GRU Hardware Implementation and Optimization

This is a GitHub project containing all my research work for the courses ENEL 592 and ENEL 594 at the University of Calgary. The focus is on hardware implementation and optimization of GRU units.

## About The project
This project houses all of the files that were made in order to characterize the performance of GRUs. In the first semester, ENEL 592, a naive implementation was made using just combinational logic to characterize a base performance. In the second semester, ENEL 594, an optimizated implementation was made that included time multiplexing via sequential logic in order to better use time resources. 

## Built With
- Python
- System Verilog
- Tcl
- Jupyter Notebook

## Top Level Folders
- EMBC Submission: Contains files for my paper submission to EMBC 2026, written in LaTeX.
- naiveImplementation: Contains the files for an unoptimized implementation of a GRU in System Verilog, Python code to test and measure across the design space, and a Tcl script to interface Python with Xilinx Vivado. THis version only uses combinational logic.
- optimizedImplementation: Contains the files for an optimized implementation of a GRU in System Verilog, Python code to test and measure across the design space, and a Tcl script to interface Python with Xilinx Vivado. This version has time multiplexing and sequential logic.

## Running the Project
Running tests on the design space of either the naive or optimized implementation are very similar. 
1. Ensure all needed tools are installed. This includes Python (3.11 was used) and Xilinx Vivado (2024.1 was used).
2. Change paths in the main file to be accurate to your system. This includes the path to Vivado (be careful of Linux vs Windows paths) and where you want the data CSV to save to.
3. Modify the desgin parameters to what you want to test. They are stored in multiple lists near the top of the main function in the main file. A grid search is done over all combinations of the parameters. 
4. Run the main script. In status.txt testing progress will be shown which can be helpful to estimate total runtime of the simulations.
5. After the simulations are done, the outputted CSV can be used with the Jupyter Notebook file in the same directory to produce visuals on the made dataset.
