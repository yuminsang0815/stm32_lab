# Combo II-DLD S75 (xc7s75fgga484-1) / STM32_3 과제10·12 SPI 수신 FPGA (최상위 spi_rx_uart)
# 확장 포트 BDIO 핀: 수업 저장소 Glaysia/ece2_26_2_2 verilog/extras/uart_keypad의 "BDIO00~15 in order" 핀표
#   BDIO_00 = F8 (SCK 입력), BDIO_01 = E8 (MOSI 입력), BDIO_02 = A7 (CS 입력)
# 과제10: MCU PB3(SCK) → F8, PA7(MOSI) → E8, PB6(CS) → A7, GND ↔ GND
# 과제12: 송신 FPGA의 F8·E8·A7 → 수신 FPGA의 F8·E8·A7 (같은 번호끼리), GND ↔ GND
set_property PACKAGE_PIN B6 [get_ports clk_50mhz]
create_clock -name clk_50mhz -period 20.000 [get_ports clk_50mhz]
set_property PACKAGE_PIN K4 [get_ports rst_p]

set_property PACKAGE_PIN F8 [get_ports spi_sck]
set_property PACKAGE_PIN E8 [get_ports spi_mosi]
set_property PACKAGE_PIN A7 [get_ports spi_cs_n]
# 선이 빠져도 대기 상태 유지: CS는 HIGH(미선택), SCK는 LOW
set_property PULLUP TRUE [get_ports spi_cs_n]
set_property PULLDOWN TRUE [get_ports spi_sck]

# 받은 값을 PC로: 보드 USB-UART TX (Lab3 UART와 같은 핀), 9600 8N1
set_property PACKAGE_PIN F6 [get_ports uart_txd]

# 받은 바이트 → LED1(MSB)~LED8(LSB)
set_property PACKAGE_PIN L4 [get_ports {led[7]}]
set_property PACKAGE_PIN M4 [get_ports {led[6]}]
set_property PACKAGE_PIN M2 [get_ports {led[5]}]
set_property PACKAGE_PIN N7 [get_ports {led[4]}]
set_property PACKAGE_PIN M7 [get_ports {led[3]}]
set_property PACKAGE_PIN M3 [get_ports {led[2]}]
set_property PACKAGE_PIN M1 [get_ports {led[1]}]
set_property PACKAGE_PIN N5 [get_ports {led[0]}]

set_property IOSTANDARD LVCMOS33 [get_ports *]
set_false_path -from [get_ports {rst_p spi_sck spi_mosi spi_cs_n}]
