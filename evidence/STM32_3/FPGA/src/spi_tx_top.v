`timescale 1ns/1ps
// STM32_3 과제11·12 송신 FPGA 최상위: 1초마다 DIP 스위치 값 한 바이트를 SPI로 보낸다.
// SCK = 50 MHz / (2 × 50) = 500 kHz (1 MHz 이하). 보낸 값은 LED 8개에도 표시한다.
module spi_tx_top #(
    parameter integer CLK_HZ = 50_000_000,
    parameter integer HALF_CYCLES = 50
)(
    input wire clk_50mhz, rst_p,
    input wire [7:0] sw,
    output wire spi_sck, spi_mosi, spi_cs_n,
    output reg [7:0] led
);
    reg [31:0] tick_cnt;
    wire tick = (tick_cnt == CLK_HZ - 1);
    wire busy, done;
    reg start;

    spi_master_tx #(.HALF_CYCLES(HALF_CYCLES)) u_spi(.clk(clk_50mhz), .rst_p(rst_p), .start(start),
        .tx_data(sw), .sck(spi_sck), .mosi(spi_mosi), .cs_n(spi_cs_n), .busy(busy), .done(done));

    always @(posedge clk_50mhz) begin
        if (rst_p) begin tick_cnt <= 0; start <= 0; led <= 0; end
        else begin
            start <= 1'b0;
            if (tick) begin
                tick_cnt <= 0;
                if (!busy) begin start <= 1'b1; led <= sw; end
            end else tick_cnt <= tick_cnt + 1;
        end
    end
endmodule
