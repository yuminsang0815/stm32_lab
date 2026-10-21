# STM32_1 과제 코드를 프로젝트(Core/Src/ece2_474_routine.c)에 넣거나 원래 템플릿으로 되돌립니다.
# 사용법 (stm32_lab 폴더의 VS Code 터미널에서):
#   powershell -ExecutionPolicy Bypass -File .\evidence\STM32_1\VScode\use_task.ps1 task3
#   powershell -ExecutionPolicy Bypass -File .\evidence\STM32_1\VScode\use_task.ps1 task4
#   powershell -ExecutionPolicy Bypass -File .\evidence\STM32_1\VScode\use_task.ps1 reset
# 넣은 뒤에는 CMake Build → F5(main에서 멈추면 F5 한 번 더)로 실행합니다.
param([Parameter(Mandatory = $true)][ValidateSet('task3', 'task4', 'reset')][string]$Task)

$here = $PSScriptRoot
$repo = Resolve-Path (Join-Path $here '..\..\..')
$target = Join-Path $repo 'Core\Src\ece2_474_routine.c'

switch ($Task) {
    'task3' { Copy-Item (Join-Path $here 'task3_isr_interval\ece2_474_routine.c') $target -Force }
    'task4' { Copy-Item (Join-Path $here 'task4_pwm_button\ece2_474_routine.c') $target -Force }
    'reset' { git -C $repo checkout -- Core/Src/ece2_474_routine.c }
}
Write-Host "Core/Src/ece2_474_routine.c <- $Task"
