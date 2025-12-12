set proj_name gru_proj
set proj_dir ./vivado_proj
set part_name xcu250-figd2104-2L-e
set top_module top_level
set tb_module gru_tb

# Clean and create project
if { [file exists $proj_dir] } {
    file delete -force $proj_dir
}
create_project $proj_name $proj_dir -part $part_name

# Add files
add_files /home/lex/Documents/git/gru-hardware-implementation-and-optimization/optimizedImplementation/top_level.sv
add_files /home/lex/Documents/git/gru-hardware-implementation-and-optimization/optimizedImplementation/gru_cell_parallel.sv
add_files /home/lex/Documents/git/gru-hardware-implementation-and-optimization/optimizedImplementation/gru_hidden_state_element.sv
add_files /home/lex/Documents/git/gru-hardware-implementation-and-optimization/optimizedImplementation/gru_new_gate_element.sv
add_files /home/lex/Documents/git/gru-hardware-implementation-and-optimization/optimizedImplementation/gru_reset_gate_element.sv
add_files /home/lex/Documents/git/gru-hardware-implementation-and-optimization/optimizedImplementation/gru_update_gate_element.sv
add_files -fileset sim_1 /home/lex/Documents/git/gru-hardware-implementation-and-optimization/optimizedImplementation/gru_tb.sv
read_xdc /home/lex/Documents/git/gru-hardware-implementation-and-optimization/optimizedImplementation/constraints.xdc

# Set all .sv files as SystemVerilog
foreach sv_file [glob -nocomplain /home/lex/Documents/git/gru-hardware-implementation-and-optimization/optimizedImplementation/*.sv] {
    if {[file tail $sv_file] ne "gru_tb.sv"} {
        set_property file_type {SystemVerilog} [get_files $sv_file]
    }
}

# **SET TOP MODULE BEFORE ANY ELABORATION**
set_property top $top_module [current_fileset]
update_compile_order -fileset sources_1

# Set top module for simulation
set_property top $tb_module [get_filesets sim_1]
update_compile_order -fileset sim_1

# Set simulation runtime (adjust as needed)
set_property -name {xsim.simulate.runtime} -value {1000ns} -objects [get_filesets sim_1]

# Launch simulation
launch_simulation -mode behavioral

# Run simulation for specified time (or use run all)
run 5000us

# Close simulation
close_sim -force

# Small delay to ensure clean close
after 500

# Run synthesis
synth_design -top $top_module -part $part_name

# Generate post-synthesis reports
report_utilization -file utilization_synth.txt
report_timing_summary -file timing_synth.txt
report_power -file power_synth.txt

opt_design
place_design
route_design

# Generate post-implementation reports (more accurate)
report_utilization -file utilization_report.txt
report_timing_summary -file timing_report.txt
report_power -file power_report.txt

# Generate additional detailed reports
report_route_status -file route_status.txt
report_drc -file drc_report.txt