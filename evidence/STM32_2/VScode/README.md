# STM32_2 · 컴퓨터와 FPGA 통신 과제 코드

NUCLEO-G474RE, 수업 프로젝트 [Glaysia/ece2_474](https://github.com/Glaysia/ece2_474) v1.1.0 기준. 매뉴얼: [docs/STM32_2.md](../../../docs/STM32_2.md)

| 폴더 | 과제 | 바꾼 부분 | 데이터 흐름 |
|---|---|---|---|
| [task5_pc_echo_hex](task5_pc_echo_hex/ece2_474_routine.c) | STM32_2_과제5 · 받은 문자와 바이트 값(16진수) 출력 | `polling_routine()` (getchar → printf) | PC → MCU → PC |
| [task6_task7_uart3_send](task6_task7_uart3_send/ece2_474_routine.c) | STM32_2_과제6·7 · 받은 한 바이트를 UART3로 FPGA에 전송 | `polling_routine()` (getchar → HAL_UART_Transmit) | PC → MCU → FPGA → PC |
| [../FPGA_uart_cmd](../FPGA_uart_cmd) | 과제6·7의 FPGA 쪽 회로 (원본: lab6_FPGA_STM32_2 저장소 `uart_cmd`) | 에코 + LED 명령, `uart_cmd.bit` 포함 | |

`ece2_474_init()`은 모두 빈 상태다(UART 인터럽트 수신을 시작하지 않음 — getchar와 함께 쓰지 않는다). 빌드 확인(경고 0): [build_check.txt](build_check.txt)

## 공통 준비

1. 이전 디버깅이 켜져 있으면 **Shift + F5**로 끝낸다.
2. VS Code 터미널(stm32_lab 폴더)에서 과제 코드를 넣는다.
   ```
   powershell -ExecutionPolicy Bypass -File .\evidence\STM32_2\VScode\use_task.ps1 task5
   ```
   과제6·7은 `task6`, 끝나면 `reset`.
3. **CMake → Build** 후 **F5**, main에서 멈추면 **F5** 한 번 더.
4. Serial Monitor: **MCU COM 포트**, 9600, 8비트, 패리티 None, 정지 비트 1, View Mode Text. 보내기 줄바꿈(Line Ending)은 **None**.

## 과제5 · PC ↔ MCU

- FPGA 연결 없이 진행한다.
- `1`, `A`, `a`를 하나씩 보내면 `받은 문자: 1, 바이트 값: 0x31`, `0x41`, `0x61`이 출력되어야 한다.
- 아무것도 보내지 않으면 getchar에서 기다리는 상태다. F5 실행 중에 일시정지(F6)하면 Call Stack이 getchar → `__io_getchar` → HAL_UART_Receive 안에 있어 오류로 멈춘 것이 아님을 확인할 수 있다.

## 과제6 · PC → MCU → FPGA → PC

### 배선 (전원 끈 상태에서)

| MCU (NUCLEO) | FPGA 보드 (Combo II-DLD) |
|---|---|
| **PC10** (UART3 TX, CN7 왼쪽 위 핀 1) | 확장 포트 **BDIO_00 (FPGA 핀 F8)** |
| **GND** | 보드 **GND** |

PC10의 정확한 헤더 위치와 BDIO_00 커넥터 위치는 보드 실크와 교재 확장 포트 그림으로 한 번 더 확인한다.

### FPGA

1. Vivado Hardware Manager → Program Device로 [`../FPGA_uart_cmd/uart_cmd.bit`](../FPGA_uart_cmd/uart_cmd.bit)를 올린다(또는 lab6 저장소 `vivado/uart_cmd/uart_cmd.xpr`를 열어 같은 파일).
2. 클록 스위치 F(50 MHz), KEYPADS SEL 아래, 키패드 SW_1 = 리셋.
3. FPGA 보드의 USB-UART 케이블도 PC에 연결한다 → **FPGA COM 포트**가 따로 생긴다(장치 관리자에서 확인).

### 확인

- Serial Monitor 창 두 개: MCU 포트(보내기), FPGA 포트(받기). 둘 다 9600 8N1.
- MCU 포트로 `1`, `A`, `a`를 보내면 MCU 포트에 `보낸 문자: A (0x41), 전송 결과: 0`, FPGA 포트에 `A`가 나와야 한다.
- 전송 결과 0(HAL_OK)은 MCU가 보냈다는 뜻일 뿐이다. FPGA 포트에 같은 문자가 나와야 수신 성공이다. FPGA LED2~LED8에도 받은 바이트 하위 7비트가 표시된다(예: `A` = 0x41 → 100_0001).

## 과제7 · UART 명령으로 FPGA LED 제어

같은 MCU 코드·FPGA 비트스트림·배선으로 진행한다. FPGA **LED1**이 명령 LED다.

| 보낼 문자 | 기대 LED1 |
|---|---|
| `0` | 꺼짐 (여러 번 보내도 꺼짐) |
| `1` | 켜짐 (여러 번 보내도 켜짐) |
| `2` | 보낼 때마다 반전 |
| 그 밖의 문자 (예: `a`) | 유지 |

- FPGA 포트에도 보낸 문자가 그대로 나오므로 받은 명령을 함께 확인한다.
- 문자 `'1'`은 0x31이다(숫자 1 = 0x01과 다름). Serial Monitor 줄바꿈을 None으로 두어야 `\r`, `\n`이 함께 가지 않는다(가더라도 그 밖의 문자라 LED는 유지).
