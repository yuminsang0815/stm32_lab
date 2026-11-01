`timescale 1ns/1ps
// SPI 슬레이브 수신 (Mode 0, 8비트, MSB first) · STM32_3 과제10·12
// - SCK·MOSI·CS를 50 MHz 클록으로 2단 동기화한 뒤 사용 (외부 비동기 입력)
// - CS가 LOW인 동안 SCK 상승 에지마다 MOSI를 시프트 레지스터에 넣고 비트 수를 센다
// - 8비트를 받으면 data에 저장하고 valid를 한 클록 1로 낸다
// - CS가 HIGH가 되면 비트 카운터를 0으로 되돌려 다음 바이트를 처음부터 받는다
module spi_slave_rx(
    input wire clk, rst_p,
    input wire sck, mosi, cs_n,
    output reg [7:0] data,
    output reg valid
);
    (* ASYNC_REG = "TRUE" *) reg [1:0] sck_s, mosi_s, cs_s;
    reg sck_d;
    reg [7:0] shift;
    reg [2:0] bit_cnt;

    wire sck_now  = sck_s[1];
    wire cs_low   = !cs_s[1];
    wire sck_rise = sck_now && !sck_d;

    always @(posedge clk) begin
        if (rst_p) begin
            sck_s <= 0; mosi_s <= 0; cs_s <= 2'b11; sck_d <= 0;
            shift <= 0; bit_cnt <= 0; data <= 0; valid <= 0;
        end else begin
            sck_s  <= {sck_s[0], sck};
            mosi_s <= {mosi_s[0], mosi};
            cs_s   <= {cs_s[0], cs_n};
            sck_d  <= sck_now;
            valid  <= 1'b0;
            if (!cs_low) begin
                bit_cnt <= 0;                         // CS 해제: 다음 바이트 준비
            end else if (sck_rise) begin
                shift <= {shift[6:0], mosi_s[1]};     // MSB first
                if (bit_cnt == 3'd7) begin
                    data <= {shift[6:0], mosi_s[1]};
                    valid <= 1'b1;
                    bit_cnt <= 0;
                end else begin
                    bit_cnt <= bit_cnt + 1'b1;
                end
            end
        end
    end
endmodule
