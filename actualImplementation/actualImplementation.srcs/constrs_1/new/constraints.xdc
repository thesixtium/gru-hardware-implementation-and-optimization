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
## Primary 100 MHz system clock (Arty A7 uses E3 for the 100 MHz oscillator)
set_property -dict { PACKAGE_PIN E3  IOSTANDARD LVCMOS33 } [get_ports clk]
create_clock -name sys_clk -period 10.000 -waveform {0.000 5.000} [get_ports clk]

## Clock uncertainty / jitter margin
set_input_jitter sys_clk 0.100

##############################################################################
## Reset (active-low)
## Arty A7: C2 = RESET push-button (active-low)
##############################################################################
set_property -dict { PACKAGE_PIN C2  IOSTANDARD LVCMOS33 } [get_ports rst_n]

##############################################################################
## UART
## Arty A7: A9 = USB-UART RXD (FPGA input), D10 = USB-UART TXD (FPGA output)
##############################################################################
set_property -dict { PACKAGE_PIN A9  IOSTANDARD LVCMOS33 } [get_ports uart_rxd]
set_property -dict { PACKAGE_PIN D10 IOSTANDARD LVCMOS33 } [get_ports uart_txd]

##############################################################################
## Timing exceptions
##############################################################################
## False path on asynchronous reset (crosses clock domains at deassertion)
set_false_path -from [get_ports rst_n]

## Input delay for UART RX (external signal, no source clock reference)
set_input_delay  -clock sys_clk -max 2.000 [get_ports uart_rxd]
set_input_delay  -clock sys_clk -min 0.000 [get_ports uart_rxd]

## Output delay for UART TX
set_output_delay -clock sys_clk -max 2.000 [get_ports uart_txd]
set_output_delay -clock sys_clk -min 0.000 [get_ports uart_txd]

##############################################################################
## Bitstream / Configuration
##############################################################################
set_property BITSTREAM.GENERAL.COMPRESS        TRUE  [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH     4     [current_design]
set_property CONFIG_MODE                       SPIx4  [current_design]
set_property CFGBVS                            VCCO  [current_design]
set_property CONFIG_VOLTAGE                    3.3   [current_design]