# STM32_0 · LED와 버튼 실습 코드

NUCLEO-G474RE, 수업 프로젝트 [Glaysia/ece2_474](https://github.com/Glaysia/ece2_474) v1.1.0 기준.
각 폴더의 `ece2_474_routine.c`로 `Core/Src/ece2_474_routine.c`를 교체한 뒤 Build → F5로 실행한다. `ece2_474_init()`은 모두 빈 상태(타이머·PWM·UART 시작 호출 없음)이다.

| 폴더 | 실습 | 바꾼 함수 | 사용 핀 | 시연 영상 |
|---|---|---|---|---|
| [hello_world](hello_world/main_hello_world.c) | 기초 실습 · Hello world 출력 | 없음 (`main.c`의 `printf`) | UART2 PA2/PA3 (ST-LINK 가상 COM 포트, 9600 8N1) | [Hello_world.mp4](../videos/Hello_world.mp4) |
| [example1_led_1s](example1_led_1s/ece2_474_routine.c) | 제공 예제 1 · 1초 간격 LED | `polling_routine()` | PA5 내장 LED | |
| [example2_button_toggle](example2_button_toggle/ece2_474_routine.c) | 제공 예제 2 · 버튼으로 LED 변경 | `polling_routine()` | PC13 버튼, PA5 내장 LED | |
| [task1_button_interval](task1_button_interval/ece2_474_routine.c) | STM32_0_과제1 · 버튼으로 LED 간격 1 → 2 → 4 → 8 → 1초 | `polling_routine()` | PC13 버튼, PA5 내장 LED | [task1.mp4](../videos/task1.mp4) |
| [task2_external_led](task2_external_led/ece2_474_routine.c) | STM32_0_과제2 · 과제1을 외부 LED로 | `polling_routine()` | PC13 버튼, PB0 (`GPIO_OUT1_ece2`, Arduino A3) | [task2.mp4](../videos/task2.mp4) |

과제2 배선: PB0 → 저항(330 Ω~1 kΩ) → LED 긴 다리(+), LED 짧은 다리(−) → 보드 GND.

과제1과 과제2의 차이는 `HAL_GPIO_TogglePin()`에 넘기는 포트·핀 이름(`LED_ece2_*` → `GPIO_OUT1_ece2_*`)뿐이다.

빌드 확인 결과(4개 모두 경고 0, FLASH 약 25.8 KB / 512 KB): [build_check.txt](build_check.txt)
