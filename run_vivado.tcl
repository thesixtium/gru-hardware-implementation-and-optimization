set proj_name gru_proj
set proj_dir ./vivado_proj
set part_name xc7a100tcsg324-1   
set top_module top_level

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

puts "====================================="
puts "📋 Top module set to: $top_module"
puts "====================================="

# Run synthesis
puts "Running synthesis..."
synth_design -top $top_module -part $part_name

puts "====================================="
puts "✅ Synthesis complete!"
puts "====================================="

# Generate post-synthesis reports
report_utilization -file utilization_synth.txt
report_timing_summary -file timing_synth.txt
report_power -file power_synth.txt

# Optional: Run implementation for more accurate results
puts "====================================="
puts "🔧 Running implementation..."
puts "====================================="

opt_design
place_design
route_design

puts "====================================="
puts "✅ Implementation complete!"
puts "====================================="

# Generate post-implementation reports (more accurate)
report_utilization -file utilization_report.txt
report_timing_summary -file timing_report.txt
report_power -file power_report.txt

# Generate additional detailed reports
report_route_status -file route_status.txt
report_drc -file drc_report.txt

puts "====================================="
puts "📊 All reports generated:"
puts "  Post-Synthesis:"
puts "    - utilization_synth.txt"
puts "    - timing_synth.txt"
puts "    - power_synth.txt"
puts "  Post-Implementation:"
puts "    - utilization_report.txt"
puts "    - timing_report.txt"
puts "    - power_report.txt"
puts "    - route_status.txt"
puts "    - drc_report.txt"
puts "====================================="