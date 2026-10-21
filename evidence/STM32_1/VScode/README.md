# STM32_1 · 인터럽트와 PWM 과제 코드

NUCLEO-G474RE, 수업 프로젝트 [Glaysia/ece2_474](https://github.com/Glaysia/ece2_474) v1.1.0 기준. 매뉴얼: [docs/STM32_1.md](../../../docs/STM32_1.md)

| 폴더 | 과제 | 바꾼 부분 | 사용 핀 |
|---|---|---|---|
| [task3_isr_interval](task3_isr_interval/ece2_474_routine.c) | STM32_1_과제3 · STM32_0_과제1(LED 간격 1 → 2 → 4 → 8 → 1초)을 버튼·TIM6 인터럽트로 재현 | `ece2_474_init()`에서 TIM6 시작, `button_isr_p7()`, `tim6_isr_p4()`, 함수 밖 `volatile` 변수 `led_interval_ticks`·`elapsed_ticks` | PC13 버튼, PA5 내장 LED |
| [task4_pwm_button](task4_pwm_button/ece2_474_routine.c) | STM32_1_과제4 · 버튼으로 PWM 비율 25% → 50% → 75% → 25%, C 디버거 사용 | `ece2_474_init()`에서 TIM3 PWM 시작, `button_isr_p7()`, 변수 `pwm_percent`·`pwm_compare` | PC13 버튼, PB4 PWM 출력 |

빌드 확인(두 과제 모두 경고 0): [build_check.txt](build_check.txt)

## 실행 순서

1. 이전 디버깅이 켜져 있으면 **Shift + F5**로 끝낸다.
2. VS Code 터미널(stm32_lab 폴더)에서 과제 코드를 프로젝트에 넣는다.
   ```
   powershell -ExecutionPolicy Bypass -File .\evidence\STM32_1\VScode\use_task.ps1 task3
   ```
   과제4는 `task4`, 원래 템플릿으로 되돌릴 때는 `reset`.
3. 왼쪽 **CMake → Build**를 누른 뒤 **F5**로 다운로드한다. main에서 멈추면 **F5**를 한 번 더 누른다. Build만 하거나 RESET만 누르면 새 프로그램으로 바뀌지 않는다.

## 과제3 확인 항목

- 다운로드 직후 PA5 LED가 1초 간격으로 켜짐·꺼짐을 반복한다 (TIM6 100 ms × 10회).
- USER 버튼(B1)을 누를 때마다 간격이 2초(20회) → 4초(40회) → 8초(80회) → 1초(10회)로 바뀐다.
- 버튼을 길게 누르고 있어도 간격은 한 번만 바뀐다 (버튼 인터럽트는 누르는 순간의 상승 에지에서만 발생, 200 ms 이내 재호출은 무시).
- `polling_routine()`은 비어 있다. 버튼과 LED 동작은 모두 ISR에서 처리한다.

## 과제4 확인 항목 · C 디버거

- 다운로드 직후 PB4에서 1 kHz, 25% PWM이 나온다. PB4와 GND를 오실로스코프(또는 계측기)에 연결한다. 계측기가 없으면 PB4 → 저항(330 Ω~1 kΩ) → LED → GND로 연결해 밝기 변화로 확인할 수 있다.
- 버튼을 누를 때마다 켜진 시간이 0.25 ms → 0.50 ms → 0.75 ms → 0.25 ms로 바뀐다 (주기 1 ms).
- 디버거 순서
  1. `button_isr_p7()` 안의 `pwm_compare = pwm_percent * 10U;` 줄(주석 `중단점 위치`)에서 **F9**로 중단점을 건다.
  2. **F5**로 디버깅 시작, main에서 멈추면 **F5** 한 번 더. 보드 버튼을 누르면 중단점에서 멈춘다.
  3. **Watch**에 `pwm_percent`, `pwm_compare`를 추가한다. 멈춘 시점에는 `pwm_percent`가 이미 새 값(예: 50)이고 `pwm_compare`는 이전 값(250)이다.
  4. **F10**으로 한 줄씩 실행하며 `pwm_compare`가 500으로 바뀌고, 다음 줄에서 TIM3 비교값이 설정되는 것을 확인한다. 함수 안으로 들어가려면 **F11**, 계속 실행은 **F5**.
  5. 중단점을 해제(F9)하고 정상 실행 상태에서 버튼으로 25 → 50 → 75 → 25%가 순환하는지 파형으로 확인한다. 디버깅 종료는 **Shift + F5**.
- 중단점으로 멈춘 동안의 시간은 측정값으로 쓰지 않는다. 파형은 중단점을 해제하고 확인한다.
