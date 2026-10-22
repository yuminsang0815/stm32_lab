# Combo II-DLD S75 (xc7s75fgga484-1) / STM32_2 과제6·7: MCU → FPGA UART 명령 (최상위 uart_cmd)
# 9600 8N1. MCU PC10(TX) → 확장 포트 BDIO_00(F8), MCU GND ↔ 보드 GND.
# 핀 출처: 장비 교재 확장 포트(BDIO) 핀 구성표, Lab3 UART 에코(F6 = USB-UART TX), Lab3 LED.

set_property PACKAGE_PIN B6 [get_ports clk_50mhz]
create_clock -name clk_50mhz -period 20.000 [get_ports clk_50mhz]

# 리셋: 키패드 SW_1 (KEYPADS SEL 아래 = Button Switch)
set_property PACKAGE_PIN K4 [get_ports rst_p]

# MCU PC10(TX) 점퍼선 입력: 확장 포트 BDIO_00
set_property PACKAGE_PIN F8 [get_ports mcu_rxd]
# 내부 풀업: 점퍼선이 빠져 있어도 UART 대기 상태(HIGH)를 유지
set_property PULLUP TRUE [get_ports mcu_rxd]

# FPGA → PC: 보드 USB-UART (Lab3 UART 에코와 같은 TX 핀)
set_property PACKAGE_PIN F6 [get_ports uart_txd]

# LED1 = 명령 LED, LED2~LED8 = 받은 바이트 하위 7비트
set_property PACKAGE_PIN L4 [get_ports cmd_led]
set_property PACKAGE_PIN M4 [get_ports {last_low7[6]}]
set_property PACKAGE_PIN M2 [get_ports {last_low7[5]}]
set_property PACKAGE_PIN N7 [get_ports {last_low7[4]}]
set_property PACKAGE_PIN M7 [get_ports {last_low7[3]}]
set_property PACKAGE_PIN M3 [get_ports {last_low7[2]}]
set_property PACKAGE_PIN M1 [get_ports {last_low7[1]}]
set_property PACKAGE_PIN N5 [get_ports {last_low7[0]}]

set_property IOSTANDARD LVCMOS33 [get_ports *]
set_false_path -from [get_ports {rst_p mcu_rxd}]
