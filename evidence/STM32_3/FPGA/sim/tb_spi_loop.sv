`timescale 1ns/1ps
// 과제12 TB: 송신 FPGA(spi_tx_top) → 수신 FPGA(spi_rx_uart) 연결. 수신 측 UART 출력 "RX=xx\r\n"까지 확인한다.
// 시간을 줄이려고 CLK_HZ를 낮춘다 (1초 tick = 2,000클록, UART DIV = 8).
module tb;
    initial begin $dumpfile("spi_loop.vcd"); $dumpvars(0, tb); end
    reg clk = 0, rst = 1; reg [7:0] sw = 8'h55;
    always #10 clk = ~clk;
    wire sck, mosi, cs_n, txd; wire [7:0] led_tx, led_rx;
    spi_tx_top  #(.CLK_HZ(2000), .HALF_CYCLES(4)) master(clk, rst, sw, sck, mosi, cs_n, led_tx);
    spi_rx_uart #(.CLK_HZ(800),  .BAUD(100))      slave (clk, rst, sck, mosi, cs_n, txd, led_rx);
    localparam integer DIV = 8;
    task automatic uart_get(output [7:0] b);
        integer i;
        begin
            @(negedge txd); repeat (DIV / 2) @(posedge clk);
            for (i = 0; i < 8; i = i + 1) begin repeat (DIV) @(posedge clk); b[i] = txd; end
            repeat (DIV) @(posedge clk);
            if (txd !== 1) $fatal(1, "UART stop bit");
        end
    endtask
    task automatic expect_line(input [7:0] v);
        reg [7:0] c[0:6]; reg [7:0] t; integer i; reg [8*7-1:0] want;
        begin
            want = {"RX=", (v[7:4] < 10 ? 8'h30 + v[7:4] : 8'h37 + v[7:4]),
                    (v[3:0] < 10 ? 8'h30 + v[3:0] : 8'h37 + v[3:0]), 8'h0D, 8'h0A};
            for (i = 0; i < 7; i = i + 1) begin uart_get(t); c[i] = t; end
            for (i = 0; i < 7; i = i + 1)
                if (c[i] !== want[8*(6-i) +: 8]) $fatal(1, "UART char %0d: got %h want %h", i, c[i], want[8*(6-i) +: 8]);
            if (led_rx !== v) $fatal(1, "LED %h want %h", led_rx, v);
        end
    endtask
    initial begin
        #100 rst = 0;
        expect_line(8'h55);
        @(negedge clk) sw = 8'hA5; expect_line(8'hA5);
        @(negedge clk) sw = 8'h00; expect_line(8'h00);
        @(negedge clk) sw = 8'hFF; expect_line(8'hFF);
        $display("PASS SPI_LOOP: FPGA master -> FPGA slave -> UART RX=55 A5 00 FF"); $finish;
    end
    initial begin #2000000; $fatal(1, "timeout"); end
endmodule
