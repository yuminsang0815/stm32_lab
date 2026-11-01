# STM32_3 FPGA 회로: Vivado 프로젝트 생성 → XSim(tb_spi_loop) → 합성·구현·비트스트림
# 사용법 (이 폴더에서): vivado -mode batch -source build_vivado.tcl -tclargs spi_rx_uart | spi_tx_top
set top [lindex $argv 0]
if {$top ni {spi_rx_uart spi_tx_top}} { error "usage: -tclargs spi_rx_uart | spi_tx_top" }
set root [file normalize [file dirname [info script]]]
create_project $top [file join $root vivado $top] -part xc7s75fgga484-1 -force
add_files -norecurse [glob [file join $root src *.v]]
set_property top $top [get_filesets sources_1]
add_files -fileset sim_1 -norecurse [file join $root sim tb_spi_loop.sv]
set_property top tb [get_filesets sim_1]
set_property -name xsim.simulate.runtime -value all -objects [get_filesets sim_1]
add_files -fileset constrs_1 -norecurse [file join $root constraints $top.xdc]
launch_simulation -scripts_only
set simdir [file join $root vivado $top $top.sim sim_1 behav xsim]
cd $simdir
foreach step {compile elaborate simulate} {
    set rc [catch {exec cmd.exe /c [file nativename [file join $simdir $step.bat]] 2>@1} out]
    if {$rc} { puts $out; error "xsim $step failed" }
}
cd $root
if {![regexp {PASS [^\n]*} $out pass]} { error "testbench did not print PASS" }
puts "XSIM_$pass"
launch_runs synth_1 -jobs 4
wait_on_run synth_1
launch_runs impl_1 -to_step write_bitstream -jobs 4
wait_on_run impl_1
if {[get_property PROGRESS [get_runs impl_1]] ne "100%"} { error "implementation failed" }
puts "BITSTREAM_OK [file join $root vivado $top $top.runs impl_1 $top.bit]"
close_project
