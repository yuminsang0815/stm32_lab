`timescale 1ns/1ps
// MCU가 9600 8N1(축소: DIV=8)로 문자를 보내면 FPGA가 PC로 같은 문자를 내보내고 LED 명령을 처리하는지 검사
module tb;
    // 파형 저장 (GTKWave로 확인)
    initial begin $dumpfile("uart_cmd.vcd"); $dumpvars(0, tb); end
    localparam integer DIV = 8;
    reg clk = 0, rst = 1, mcu_tx = 1;
    always #5 clk = ~clk;
    wire pc_rx, led;
    wire [6:0] low7;
    uart_cmd #(.CLK_HZ(800), .BAUD(100)) dut(clk, rst, mcu_tx, pc_rx, led, low7);

    task automatic mcu_send(input [7:0] b);
        integer i;
        begin
            @(negedge clk); mcu_tx = 0; repeat (DIV) @(negedge clk);
            for (i = 0; i < 8; i = i + 1) begin mcu_tx = b[i]; repeat (DIV) @(negedge clk); end
            mcu_tx = 1; repeat (DIV) @(negedge clk);
        end
    endtask
    task automatic pc_receive(output [7:0] b);
        integer i;
        begin
            @(negedge pc_rx); repeat (DIV / 2) @(posedge clk);
            if (pc_rx !== 0) $fatal(1, "start bit");
            for (i = 0; i < 8; i = i + 1) begin repeat (DIV) @(posedge clk); b[i] = pc_rx; end
            repeat (DIV) @(posedge clk);
            if (pc_rx !== 1) $fatal(1, "stop bit");
        end
    endtask
    task automatic check(input [7:0] ch, input expected_led);
        reg [7:0] got;
        begin
            fork mcu_send(ch); pc_receive(got); join
            repeat (2) @(posedge clk); #1;
            if (got !== ch) $fatal(1, "echo sent=%h got=%h", ch, got);
            if (led !== expected_led) $fatal(1, "LED after '%c' expected=%0d got=%0d", ch, expected_led, led);
            if (low7 !== ch[6:0]) $fatal(1, "low7");
            checks = checks + 1;
        end
    endtask
    integer checks = 0;
    initial begin
        repeat (3) @(negedge clk); rst = 0; repeat (4) @(negedge clk);
        check("A", 0);   // 과제6: 일반 문자 에코, LED 유지
        check("1", 1);   // 켜기
        check("1", 1);   // 반복해도 켜짐
        check("2", 0);   // 반전
        check("2", 1);   // 다시 반전
        check("a", 1);   // 그 밖의 문자: 유지
        check("0", 0);   // 끄기
        check("0", 0);   // 반복해도 꺼짐
        $display("PASS UART_CMD: %0d echoes, LED 0/1/2 commands, other chars hold", checks); $finish;
    end
    initial begin #200000; $fatal(1, "timeout"); end
endmodule
