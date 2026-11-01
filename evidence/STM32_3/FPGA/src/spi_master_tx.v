`timescale 1ns/1ps
// SPI 마스터 송신 (Mode 0, 8비트, MSB first) · STM32_3 과제11·12
// - start가 1이면 CS를 LOW로 내리고 첫 비트(MSB)를 MOSI에 준비한 뒤 SCK를 시작한다
// - SCK는 LOW 대기, HALF_CYCLES마다 반전: f_SCK = f_clk / (2 × HALF_CYCLES) (기본 50 MHz/100 = 500 kHz)
// - 수신 측이 상승 에지에서 읽고, 마스터는 하강 에지에서 다음 비트로 바꾼다
// - 8번째 하강 에지 뒤 반주기 기다렸다가 CS를 HIGH로 올리고 done을 한 클록 낸다
module spi_master_tx #(parameter integer HALF_CYCLES = 50)(
    input wire clk, rst_p,
    input wire start,
    input wire [7:0] tx_data,
    output reg sck, mosi, cs_n,
    output reg busy, done
);
    reg [31:0] cnt;
    reg [7:0] shift;
    reg [3:0] edges;       // 지나간 하강 에지 수 (0~8)

    always @(posedge clk) begin
        if (rst_p) begin
            sck <= 0; mosi <= 0; cs_n <= 1; busy <= 0; done <= 0;
            cnt <= 0; shift <= 0; edges <= 0;
        end else begin
            done <= 1'b0;
            if (!busy) begin
                if (start) begin
                    busy <= 1'b1; cs_n <= 1'b0; cnt <= 0; edges <= 0;
                    shift <= tx_data; mosi <= tx_data[7];   // 첫 상승 에지 전에 MSB 준비
                end
            end else if (cnt == HALF_CYCLES - 1) begin
                cnt <= 0;
                if (edges == 4'd8) begin                    // 마지막 하강 에지 뒤 반주기: 종료
                    cs_n <= 1'b1; busy <= 1'b0; done <= 1'b1; mosi <= 1'b0;
                end else if (!sck) begin
                    sck <= 1'b1;                            // 상승 에지: 수신 측이 MOSI를 읽음
                end else begin
                    sck <= 1'b0;                            // 하강 에지: 다음 비트 준비
                    edges <= edges + 1'b1;
                    shift <= {shift[6:0], 1'b0};
                    mosi <= shift[6];
                end
            end else begin
                cnt <= cnt + 1;
            end
        end
    end
endmodule
