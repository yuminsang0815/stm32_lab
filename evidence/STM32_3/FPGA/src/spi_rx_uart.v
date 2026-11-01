`timescale 1ns/1ps
// STM32_3 과제10·12 수신 FPGA 최상위: SPI로 받은 바이트를 FPGA UART(9600 8N1)로 PC에 보낸다.
// PC에는 "RX=55\r\n" 형식으로 출력하고, 받은 값은 LED 8개에도 표시한다.
module spi_rx_uart #(
    parameter integer CLK_HZ = 50_000_000,
    parameter integer BAUD = 9_600
)(
    input wire clk_50mhz, rst_p,
    input wire spi_sck, spi_mosi, spi_cs_n,
    output wire uart_txd,
    output reg [7:0] led
);
    localparam integer DIV = (CLK_HZ + BAUD / 2) / BAUD;
    wire [7:0] rx_data;
    wire rx_valid, tx_ready;
    reg tx_valid;
    reg [7:0] tx_byte;
    reg [7:0] value;
    reg [2:0] idx;          // 0~6: 'R' 'X' '=' 상위 hex 하위 hex '\r' '\n'
    reg sending;

    spi_slave_rx u_spi(.clk(clk_50mhz), .rst_p(rst_p), .sck(spi_sck), .mosi(spi_mosi),
                       .cs_n(spi_cs_n), .data(rx_data), .valid(rx_valid));
    uart_tx #(.DIV(DIV)) u_tx(.clk(clk_50mhz), .rst_p(rst_p), .valid(tx_valid),
                              .data(tx_byte), .ready(tx_ready), .tx(uart_txd));

    function [7:0] hex(input [3:0] n);
        hex = (n < 10) ? (8'h30 + n) : (8'h41 + n - 10);
    endfunction

    always @(posedge clk_50mhz) begin
        if (rst_p) begin
            led <= 0; value <= 0; idx <= 0; sending <= 0; tx_valid <= 0; tx_byte <= 0;
        end else begin
            tx_valid <= 1'b0;
            if (rx_valid) begin
                led <= rx_data;
                if (!sending) begin value <= rx_data; idx <= 0; sending <= 1'b1; end
            end
            if (sending && tx_ready && !tx_valid) begin
                case (idx)
                    3'd0: tx_byte <= "R";
                    3'd1: tx_byte <= "X";
                    3'd2: tx_byte <= "=";
                    3'd3: tx_byte <= hex(value[7:4]);
                    3'd4: tx_byte <= hex(value[3:0]);
                    3'd5: tx_byte <= 8'h0D;
                    default: tx_byte <= 8'h0A;
                endcase
                tx_valid <= 1'b1;
                if (idx == 3'd6) sending <= 1'b0; else idx <= idx + 1'b1;
            end
        end
    end
endmodule
