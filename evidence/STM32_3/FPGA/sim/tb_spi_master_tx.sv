`timescale 1ns/1ps
// 과제11 TB: spi_master_tx가 Mode 0 규칙을 지키는지 독립 모델로 검사한다.
// SCK LOW 대기, CS LOW 동안 상승 에지 8번, 상승 에지에서 MOSI 안정(셋업), 하강 에지에서만 MOSI 변화, SCK 1 MHz 이하
module tb;
    initial begin $dumpfile("spi_master_tx.vcd"); $dumpvars(0, tb); end
    reg clk = 0, rst = 1, start = 0; reg [7:0] tx = 0;
    always #10 clk = ~clk;
    wire sck, mosi, cs_n, busy, done;
    spi_master_tx #(.HALF_CYCLES(50)) dut(clk, rst, start, tx, sck, mosi, cs_n, busy, done);
    reg [7:0] cap; integer rises; realtime last_rise = 0, period = 0, last_mosi = 0;
    always @(mosi) begin
        last_mosi = $realtime;
        if (!cs_n && sck) $fatal(1, "MOSI changed while SCK high");
    end
    always @(negedge cs_n) begin rises = 0; cap = 0; if (sck !== 0) $fatal(1, "SCK not idle low"); end
    always @(posedge sck) begin
        if (cs_n) $fatal(1, "SCK edge outside CS");
        if ($realtime - last_mosi < 20) $fatal(1, "MOSI setup too short");
        if (last_rise > 0 && rises > 0) period = $realtime - last_rise;
        last_rise = $realtime; cap = {cap[6:0], mosi}; rises = rises + 1;
    end
    task automatic xfer(input [7:0] b);
        begin
            @(negedge clk); tx = b; start = 1; @(negedge clk); start = 0;
            @(posedge done); #1;
            if (rises != 8) $fatal(1, "rising edges = %0d", rises);
            if (cap !== b) $fatal(1, "sent %h captured %h", b, cap);
            if (!cs_n || sck) $fatal(1, "CS/SCK not released");
            if (period < 1000) $fatal(1, "SCK period %0.0f ns < 1000 ns (> 1 MHz)", period);
        end
    endtask
    initial begin
        #100 rst = 0; #100;
        xfer(8'h55); xfer(8'hA5); xfer(8'h00); xfer(8'hFF);
        $display("PASS SPI_MASTER_TX: Mode0, 8 rising edges, MSB first, SCK %0.0f kHz", 1e6 / period); $finish;
    end
    initial begin #200000; $fatal(1, "timeout"); end
endmodule
