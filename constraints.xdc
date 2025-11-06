# ================================================================
# Constraints for top_level (XC7A100TCSG324-1)
# ================================================================

# -------------------------
# Clock definition (100 MHz)
# -------------------------
# Using E3 as the clock pin (typical for Nexys A7/Basys3 boards)
set_property PACKAGE_PIN E3 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]

# Define the timing constraint for the clock (100 MHz = 10ns period)
create_clock -period 10.000 -name sys_clk -waveform {0.000 5.000} [get_ports clk]

# -------------------------
# Reset signal (active high)
# -------------------------
# Using C12 as reset button pin
set_property PACKAGE_PIN C12 [get_ports reset]
set_property IOSTANDARD LVCMOS33 [get_ports reset]

# -------------------------
# Configuration settings
# -------------------------
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]

# -------------------------
# Timing exceptions (optional)
# -------------------------
# Add false paths or multicycle paths if needed for your design