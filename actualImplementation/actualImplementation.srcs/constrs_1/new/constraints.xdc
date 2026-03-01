##############################################################################
## Constraints File
## Device  : xc7a100tcsg324-1 (Artix-7)
## Design  : top
## Notes   : Pin assignments below use common Arty A7-100T board defaults.
##           Adjust pin locations to match your actual board/schematic.
##############################################################################

##############################################################################
## Clock
##############################################################################
set_property -dict { PACKAGE_PIN E3  IOSTANDARD LVCMOS33 } [get_ports clk]
create_clock -name sys_clk -period 10.000 -waveform {0.000 5.000} [get_ports clk]
set_input_jitter sys_clk 0.100

##############################################################################
## Reset (active-low)
##############################################################################
set_property -dict { PACKAGE_PIN C2  IOSTANDARD LVCMOS33 } [get_ports rst_n]

##############################################################################
## UART
##############################################################################
set_property -dict { PACKAGE_PIN A9  IOSTANDARD LVCMOS33 } [get_ports uart_rxd]
set_property -dict { PACKAGE_PIN D10 IOSTANDARD LVCMOS33 } [get_ports uart_txd]

##############################################################################
## Timing exceptions
##############################################################################
## False path on asynchronous reset
set_false_path -from [get_ports rst_n]

## UART pins are asynchronous to sys_clk - the UART receiver oversamples
## at 4x baud using its own internal counter and has no setup/hold
## relationship with sys_clk. set_input/output_delay with a 2ns constraint
## was treating these like a synchronous bus and causing a false -1.5ns WNS
## violation on the OBUF. False-path both directions instead.
set_false_path -from [get_ports uart_rxd]
set_false_path -to   [get_ports uart_txd]

##############################################################################
## Bitstream / Configuration
##############################################################################
set_property BITSTREAM.GENERAL.COMPRESS        TRUE  [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH     4     [current_design]
set_property CONFIG_MODE                       SPIx4  [current_design]
set_property CFGBVS                            VCCO  [current_design]
set_property CONFIG_VOLTAGE                    3.3   [current_design]
