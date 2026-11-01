# GTKWave 창을 띄워 SPI 파형을 PNG로 캡처해 evidence/STM32_3/VScode에 저장합니다.
# 사용법: powershell -ExecutionPolicy Bypass -File capture_wave.ps1   (sim 폴더의 *.vcd가 있어야 함)
param([int]$WaitSec = 7)

Add-Type -AssemblyName System.Drawing
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class W {
    [DllImport("user32.dll")] public static extern bool SetProcessDPIAware();
    [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr h);
    [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr h, int n);
    [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr h, out RECT r);
    [DllImport("user32.dll")] public static extern bool PrintWindow(IntPtr h, IntPtr hdc, uint flags);
    public struct RECT { public int Left, Top, Right, Bottom; }
}
"@
[W]::SetProcessDPIAware() | Out-Null
$sim = Join-Path $PSScriptRoot 'sim'
$ev = Join-Path $PSScriptRoot '..\VScode'

# 이름, 파일, 확대 구간(ps). $null이면 전체
$shots = @(
    @{ name = 'spi_slave_rx_wave_full';  f = 'spi_slave_rx';  range = $null },
    @{ name = 'spi_slave_rx_wave_zoom';  f = 'spi_slave_rx';  range = @(250000, 12000000) },   # 0x55 한 바이트
    @{ name = 'spi_master_tx_wave_full'; f = 'spi_master_tx'; range = $null },
    @{ name = 'spi_master_tx_wave_zoom'; f = 'spi_master_tx'; range = @(150000, 17500000) },   # 0x55 한 바이트
    @{ name = 'spi_loop_wave_full';      f = 'spi_loop';      range = $null }
)
foreach ($s in $shots) {
    $tcl = Join-Path $env:TEMP "gtkw_$($s.name).tcl"
    if ($s.range) { "gtkwave::setZoomRangeTimes $($s.range[0]) $($s.range[1])" | Out-File -Encoding ascii $tcl }
    else { "gtkwave::/Time/Zoom/Zoom_Full" | Out-File -Encoding ascii $tcl }
    $p = Start-Process gtkwave -ArgumentList "$($s.f).gtkw", '-S', $tcl -WorkingDirectory $sim -PassThru
    Start-Sleep -Seconds $WaitSec
    $p.Refresh(); $h = $p.MainWindowHandle
    if ($h -eq [IntPtr]::Zero) { Write-Error "GTKWave window not found: $($s.name)"; $p | Stop-Process -Force; continue }
    [W]::ShowWindow($h, 3) | Out-Null; [W]::SetForegroundWindow($h) | Out-Null; Start-Sleep -Seconds 2
    $r = New-Object W+RECT; [W]::GetWindowRect($h, [ref]$r) | Out-Null
    $bmp = New-Object System.Drawing.Bitmap ($r.Right - $r.Left), ($r.Bottom - $r.Top)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.CopyFromScreen($r.Left, $r.Top, 0, 0, $bmp.Size)
    $out = Join-Path $ev "$($s.name).png"
    $bmp.Save($out, [System.Drawing.Imaging.ImageFormat]::Png); $g.Dispose(); $bmp.Dispose()
    $p | Stop-Process -Force
    Write-Host "saved $out"
}
