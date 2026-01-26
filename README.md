
# GRU Hardware Implementation and Optimization

This is a GitHub project containing all my research work for the courses ENEL 592 and ENEL 599 at the University of Calgary. The focus is on hardware implementation and optimization of GRU units.

## About The project
This project houses all of the files that were made in order to characterize the performance of GRUs. In the first semester, ENEL 592, a naive implementation was made using just combinational logic to characterize a base performance. In the second semester, ENEL 599, an optimizated implementation was made that included time multiplexing via sequential logic in order to better use time resources. 

## Built With
- Python
- System Verilog
- Tcl

## Top Level Folders
- EMBC Submission: Contains files for my paper submission to EMBC 2026, written in LaTeX.
- naiveImplementation: Contains the files for an unoptimized implementation of a GRU in System Verilog, Python code to test and measure across the design space, and a Tcl script to interface Python with Xilinx Vivado. THis version only uses combinational logic.
- optimizedImplementation: Contains the files for an optimized implementation of a GRU in System Verilog, Python code to test and measure across the design space, and a Tcl script to interface Python with Xilinx Vivado. This version has time multiplexing and sequential logic.
