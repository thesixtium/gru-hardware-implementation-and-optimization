# ================================================================
# Constraints for top_level (XCU250-FIGD2104-2L-E)
# AUTO-PLACEMENT - Let Vivado choose pins
# ================================================================

# -------------------------
# Clock definition (100 MHz)
# -------------------------
# NO PIN ASSIGNMENT - Vivado will auto-place
set_property IOSTANDARD LVCMOS18 [get_ports clk]
create_clock -period 10.000 -name sys_clk -waveform {0.000 5.000} [get_ports clk]

# -------------------------
# Reset signal (active high)
# -------------------------
# NO PIN ASSIGNMENT - Vivado will auto-place
set_property IOSTANDARD LVCMOS18 [get_ports reset]
set_false_path -from [get_ports reset]

# -------------------------
# Configuration settings
# -------------------------
set_property CFGBVS GND [current_design]
set_property CONFIG_VOLTAGE 1.8 [current_design]
set_property BITSTREAM.CONFIG.OVERTEMPSHUTDOWN ENABLE [current_design]
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]

# ================================================================
# NOTE: Pins are not assigned - Vivado will auto-place them
# After implementation, you can see which pins were chosen in:
# - Implemented Design -> I/O Ports window
# - Or export: File -> Export -> Export I/O Ports
# ================================================================