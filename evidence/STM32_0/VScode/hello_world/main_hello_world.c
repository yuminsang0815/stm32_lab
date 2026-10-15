/* [기초 실습] Hello world 출력 - Core/Src/main.c (v1.1.0 제공 코드, 수정 없음)
 * printf는 Core/Src/ece2_474_stdio.c의 __io_putchar()를 거쳐 UART2(PA2/PA3, ST-LINK 가상 COM 포트)로 전송된다.
 * PC: VS Code Serial Monitor, 9600 bps, 8 data bits, Parity None, 1 stop bit, View Mode Text
 */

  /* USER CODE BEGIN 2 */
  ece2_474_init();
  printf("Hello, World!\n");
  /* USER CODE END 2 */

  /* Infinite loop */
  /* USER CODE BEGIN WHILE */
  while (1)
  {
    /* USER CODE END WHILE */

    /* USER CODE BEGIN 3 */
    polling_routine();
  }
  
  /* USER CODE END 3 */

/* ---- Core/Src/ece2_474_stdio.c ---- */
int __io_putchar(int ch)
{
    /* 전달받은 문자를 한 바이트로 바꾸어 전송합니다. */
    uint8_t byte = (uint8_t)ch;
    if (HAL_UART_Transmit(&huart2, &byte, 1, 100) != HAL_OK)
    {
        return EOF;
    }
    return (unsigned char)ch;
}
