set proj_name gru_proj
set proj_dir ./vivado_proj
set part_name xc7a100tcsg324-1
set top_module top_level
set tb_module gru_tb

# Clean and create project
if { [file exists $proj_dir] } {
    file delete -force $proj_dir
}
create_project $proj_name $proj_dir -part $part_name

# Add files
add_files C:/Users/ajrbe/Documents/School/Thesis/BCI/Code/top_level.sv
add_files C:/Users/ajrbe/Documents/School/Thesis/BCI/Code/gru.sv
add_files C:/Users/ajrbe/Documents/School/Thesis/BCI/Code/tanh.sv
add_files C:/Users/ajrbe/Documents/School/Thesis/BCI/Code/sigmoid.sv
add_files C:/Users/ajrbe/Documents/School/Thesis/BCI/Code/mult.sv
add_files -fileset sim_1 C:/Users/ajrbe/Documents/School/Thesis/BCI/Code/gru_tb.sv
read_xdc C:/Users/ajrbe/Documents/School/Thesis/BCI/Code/constraints.xdc

# Set all .sv files as SystemVerilog
foreach sv_file [glob -nocomplain C:/Users/ajrbe/Documents/School/Thesis/BCI/Code/*.sv] {
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
run 500ns

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