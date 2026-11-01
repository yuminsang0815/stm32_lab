`timescale 1ns/1ps
// 과제10 TB: MCU 마스터(Mode 0, 781.25 kHz ≈ 1280 ns 주기) 모델이 0x55, 0xA5, 0x00, 0xFF를 보낸다.
// 비트 순서, CS 해제 후 다음 바이트 수신, 중간에 CS가 올라간 불완전 바이트 무시를 검사한다.
module tb;
    initial begin $dumpfile("spi_slave_rx.vcd"); $dumpvars(0, tb); end
    reg clk = 0, rst = 1, sck = 0, mosi = 0, cs_n = 1;
    always #10 clk = ~clk;                       // 50 MHz
    wire [7:0] data; wire valid;
    spi_slave_rx dut(clk, rst, sck, mosi, cs_n, data, valid);
    localparam real HALF = 640;                  // 781.25 kHz의 반주기
    integer got = 0; reg [7:0] last;
    always @(posedge clk) if (valid) begin got = got + 1; last = data; end

    task automatic send(input [7:0] b, input integer nbits);
        integer i;
        begin
            cs_n = 0; mosi = b[7]; #(HALF);           // 첫 상승 에지 전에 MSB 준비
            for (i = 7; i > 7 - nbits; i = i - 1) begin
                sck = 1; #(HALF);                     // 상승 에지: 수신 측이 읽음
                sck = 0; if (i > 0) mosi = b[i-1]; #(HALF);  // 하강 에지: 다음 비트
            end
            cs_n = 1; mosi = 0; #(4 * HALF);
        end
    endtask
    task automatic check(input [7:0] b);
        integer cnt0;
        begin
            cnt0 = got; send(b, 8);
            if (got != cnt0 + 1) $fatal(1, "byte %h: valid count %0d", b, got - cnt0);
            if (last !== b) $fatal(1, "sent %h received %h", b, last);
        end
    endtask
    initial begin
        #100 rst = 0; #200;
        check(8'h55); check(8'hA5); check(8'h00); check(8'hFF);
        send(8'hC3, 5);                              // 5비트만 보내고 CS 해제 → 무시되어야 함
        if (last !== 8'hFF) $fatal(1, "partial byte accepted");
        check(8'h3C);                                // 해제 후 처음부터 다시 받음
        $display("PASS SPI_SLAVE_RX: 55 A5 00 FF, partial byte dropped, next byte 3C"); $finish;
    end
    initial begin #200000; $fatal(1, "timeout"); end
endmodule
