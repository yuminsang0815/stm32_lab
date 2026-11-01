# STM32_3 · SPI로 MCU와 FPGA 연결 (과제8~12)

매뉴얼: [Glaysia/ece2_26_2_2 `c/stm32/docs/STM32_3.md`](https://github.com/Glaysia/ece2_26_2_2/blob/main/c/stm32/docs/STM32_3.md). 공통 규칙: **Mode 0, 8비트, MSB first, MISO 미연결**, MCU SCK = 100 MHz / 128 = **781.25 kHz**, FPGA SCK = 50 MHz / 100 = **500 kHz**.

## 파일

| 경로 | 내용 | 사용 과제 |
|---|---|---|
| [VScode/spi_master_tx](VScode/spi_master_tx/ece2_474_routine.c) | MCU SPI1 마스터 송신. 1초마다 0x55 → 0xA5 → 0x00 → 0xFF, CS = PB6 | 8, 9(송신), 10 |
| [VScode/spi_slave_rx](VScode/spi_slave_rx/ece2_474_routine.c) | MCU SPI1 슬레이브 수신(제공 코드). NSS = PA4, `RX=xx`를 VCP로 출력 | 9(수신), 11 |
| [FPGA/src/spi_slave_rx.v](FPGA/src/spi_slave_rx.v) | FPGA SPI 수신: 2단 동기화, SCK 상승 에지 검출, 시프트 레지스터·비트 카운터, CS 해제 시 초기화 | 10, 12 |
| [FPGA/src/spi_rx_uart.v](FPGA/src/spi_rx_uart.v) | 과제10·12 수신 FPGA 최상위: 받은 값을 FPGA UART(F6, 9600)로 `RX=xx` 출력 + LED | 10, 12 |
| [FPGA/src/spi_master_tx.v](FPGA/src/spi_master_tx.v) | FPGA SPI 송신: CS LOW → MSB 준비 → SCK 500 kHz, 하강 에지에서 다음 비트 | 11, 12 |
| [FPGA/src/spi_tx_top.v](FPGA/src/spi_tx_top.v) | 과제11·12 송신 FPGA 최상위: 1초마다 DIP1~8 값을 송신 + LED | 11, 12 |
| [FPGA/sim](FPGA/sim) | 테스트벤치 3개 (수신, 송신 Mode 0 규칙, FPGA→FPGA→UART) | |
| [FPGA/constraints](FPGA/constraints) | XDC 2개, [FPGA/build_vivado.tcl](FPGA/build_vivado.tcl) | |
| [VScode](VScode) | 시뮬레이션 로그와 GTKWave 파형 | |
| [vivado](vivado) | 비트스트림 `spi_rx_uart.bit`, `spi_tx_top.bit`와 빌드 로그 | 10, 11, 12 |

MCU 코드 넣기 (stm32_lab 폴더 VS Code 터미널):
```
powershell -ExecutionPolicy Bypass -File .\evidence\STM32_3\VScode\use_task.ps1 master   # 또는 slave, reset
```
Build → F5(main에서 멈추면 F5 한 번 더). 수신 결과는 VCP UART 9600 Serial Monitor로 본다.

## 배선 (전원 끈 상태에서, GND는 항상 공통)

| 신호 | MCU 마스터 | MCU 슬레이브 | FPGA (BDIO 확장 포트) |
|---|---|---|---|
| SCK | PB3 | PB3 | BDIO_00 = **F8** |
| MOSI | PA7 | PA7 | BDIO_01 = **E8** |
| CS | PB6 | **PA4** (NSS) | BDIO_02 = **A7** |
| GND | GND | GND | GND |

- 과제9: 마스터 PB3·PA7·PB6 → 슬레이브 PB3·PA7·**PA4**. 역할 교대 때 CS도 새 마스터 PB6 → 새 슬레이브 PA4로 바꾼다.
- 과제10: MCU(마스터) PB3 → F8, PA7 → E8, PB6 → A7. FPGA에 `spi_rx_uart.bit`.
- 과제11: FPGA(마스터) F8 → MCU PB3, E8 → PA7, A7 → **PA4**. FPGA에 `spi_tx_top.bit`, MCU는 slave 코드.
- 과제12: 송신 FPGA(`spi_tx_top.bit`) F8·E8·A7 → 수신 FPGA(`spi_rx_uart.bit`) F8·E8·A7.
- BDIO 핀(F8, E8, A7)은 수업 저장소 `verilog/extras/uart_keypad`의 "BDIO00~15 in order" 핀표 기준. 커넥터의 실제 위치는 교재 확장 포트 그림으로 확인한다.

## 과제별 절차

**과제8 · MCU 송신 파형**: master 코드 실행 → 오실로스코프 CH1 = SCK(PB3), CH2 = MOSI(PA7), 가능하면 CH3 = CS(PB6). 트리거는 CS 하강(또는 SCK 상승). 확인: CS LOW 동안만 통신, SCK LOW 대기, 상승 에지 8번, 0x55 = 0 1 0 1 0 1 0 1, 0xA5 = 1 0 1 0 0 1 0 1, SCK 주기 ≈ 1.28 µs(781 kHz). VCP에 `TX=55, result=0` 등.

**과제9 · MCU → MCU**: 수신 보드에 slave 코드를 먼저 실행(2초마다 timeout은 정상 대기) → 송신 보드 master 실행. 수신 VCP에 `RX=55`, `RX=A5`, `RX=00`, `RX=FF`가 송신 순서대로 나오는지 확인. 역할 교대.

**과제10 · MCU → FPGA**: FPGA에 `spi_rx_uart.bit`, MCU master 실행. FPGA USB-UART COM 포트(9600)에 `RX=55` … 가 MCU VCP의 `TX=..`와 같은지, LED1~8에 같은 값이 보이는지 확인. SW_1 = FPGA 리셋.

**과제11 · FPGA → MCU**: FPGA에 `spi_tx_top.bit`, DIP1~8로 보낼 값 설정(예: 0101_0101 = 0x55). 먼저 오실로스코프로 F8·E8·A7 파형(SCK 500 kHz = 주기 2 µs, 1초마다 한 바이트) 확인 → MCU slave 코드 실행 후 VCP에 `RX=` 값이 DIP 값과 같은지 확인.

**과제12 · FPGA → FPGA**: 지정 조끼리 송신 FPGA(`spi_tx_top.bit`) ↔ 수신 FPGA(`spi_rx_uart.bit`) 연결. 수신 FPGA COM 포트의 `RX=xx`가 송신 FPGA의 DIP 값과 같은지 확인, 역할 교대.
