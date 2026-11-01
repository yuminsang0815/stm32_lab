# Combo II-DLD S75 (xc7s75fgga484-1) / STM32_3 과제11·12 SPI 송신 FPGA (최상위 spi_tx_top)
# 1초마다 DIP1~8 값 한 바이트를 SCK 500 kHz로 보낸다.
# 과제11: F8(SCK) → MCU PB3, E8(MOSI) → MCU PA7, A7(CS) → MCU PA4(NSS), GND ↔ GND
# 과제12: F8·E8·A7 → 수신 FPGA의 F8·E8·A7, GND ↔ GND
set_property PACKAGE_PIN B6 [get_ports clk_50mhz]
create_clock -name clk_50mhz -period 20.000 [get_ports clk_50mhz]
set_property PACKAGE_PIN K4 [get_ports rst_p]

# 보낼 값: DIP1 = sw[7](MSB) ~ DIP8 = sw[0]
set_property PACKAGE_PIN Y1 [get_ports {sw[7]}]
set_property PACKAGE_PIN W3 [get_ports {sw[6]}]
set_property PACKAGE_PIN U2 [get_ports {sw[5]}]
set_property PACKAGE_PIN T1 [get_ports {sw[4]}]
set_property PACKAGE_PIN W4 [get_ports {sw[3]}]
set_property PACKAGE_PIN W1 [get_ports {sw[2]}]
set_property PACKAGE_PIN V4 [get_ports {sw[1]}]
set_property PACKAGE_PIN U4 [get_ports {sw[0]}]

set_property PACKAGE_PIN F8 [get_ports spi_sck]
set_property PACKAGE_PIN E8 [get_ports spi_mosi]
set_property PACKAGE_PIN A7 [get_ports spi_cs_n]

# 마지막으로 보낸 값 → LED1~LED8
set_property PACKAGE_PIN L4 [get_ports {led[7]}]
set_property PACKAGE_PIN M4 [get_ports {led[6]}]
set_property PACKAGE_PIN M2 [get_ports {led[5]}]
set_property PACKAGE_PIN N7 [get_ports {led[4]}]
set_property PACKAGE_PIN M7 [get_ports {led[3]}]
set_property PACKAGE_PIN M3 [get_ports {led[2]}]
set_property PACKAGE_PIN M1 [get_ports {led[1]}]
set_property PACKAGE_PIN N5 [get_ports {led[0]}]

set_property IOSTANDARD LVCMOS33 [get_ports *]
set_false_path -from [get_ports {rst_p sw[*]}]
