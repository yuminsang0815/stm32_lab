# STM32_3 SPI 코드를 프로젝트(Core/Src/ece2_474_routine.c)에 넣거나 원래 템플릿으로 되돌립니다.
# 사용법 (stm32_lab 폴더의 VS Code 터미널에서):
#   powershell -ExecutionPolicy Bypass -File .\evidence\STM32_3\VScode\use_task.ps1 master   (과제8, 9 송신, 10)
#   powershell -ExecutionPolicy Bypass -File .\evidence\STM32_3\VScode\use_task.ps1 slave    (과제9 수신, 11)
#   powershell -ExecutionPolicy Bypass -File .\evidence\STM32_3\VScode\use_task.ps1 reset
# 넣은 뒤에는 CMake Build → F5(main에서 멈추면 F5 한 번 더)로 실행합니다.
param([Parameter(Mandatory = $true)][ValidateSet('master', 'slave', 'reset')][string]$Task)

$here = $PSScriptRoot
$repo = Resolve-Path (Join-Path $here '..\..\..')
$target = Join-Path $repo 'Core\Src\ece2_474_routine.c'

switch ($Task) {
    'master' { Copy-Item (Join-Path $here 'spi_master_tx\ece2_474_routine.c') $target -Force }
    'slave'  { Copy-Item (Join-Path $here 'spi_slave_rx\ece2_474_routine.c') $target -Force }
    'reset'  { git -C $repo checkout -- Core/Src/ece2_474_routine.c }
}
Write-Host "Core/Src/ece2_474_routine.c <- $Task"
