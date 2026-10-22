`timescale 1ns/1ps
// STM32_2 과제6·7용 FPGA 수신 회로 (Lab3 UART 에코의 uart_rx/uart_tx 재사용)
// 과제6: MCU PC10(TX) → 확장 GPIO mcu_rxd로 받은 바이트를 그대로 uart_txd(F6, USB-UART)로 PC에 출력
// 과제7: 받은 문자 '0' → LED 끄기, '1' → 켜기, '2' → 반전, 그 밖의 문자 → 유지
module uart_cmd #(
    parameter integer CLK_HZ = 50_000_000,
    parameter integer BAUD = 9_600
)(
    input wire clk_50mhz,
    input wire rst_p,
    input wire mcu_rxd,         // MCU PC10(TX)에서 오는 신호
    output wire uart_txd,       // 보드 USB-UART를 거쳐 PC로
    output reg cmd_led,         // 명령으로 제어하는 LED (LED1)
    output reg [6:0] last_low7  // 마지막으로 받은 바이트 하위 7비트 (LED2~LED8)
);
    localparam integer DIV = (CLK_HZ + BAUD / 2) / BAUD;

    wire [7:0] rx_data;
    wire rx_valid, rx_framing_error, tx_ready;
    reg tx_valid;
    reg [7:0] tx_data;

    uart_rx #(.DIV(DIV)) u_rx(.clk(clk_50mhz), .rst_p(rst_p), .rx(mcu_rxd),
        .data(rx_data), .valid(rx_valid), .framing_error(rx_framing_error));
    uart_tx #(.DIV(DIV)) u_tx(.clk(clk_50mhz), .rst_p(rst_p), .valid(tx_valid),
        .data(tx_data), .ready(tx_ready), .tx(uart_txd));

    always @(posedge clk_50mhz) begin
        if (rst_p) begin
            tx_valid <= 1'b0; tx_data <= 8'h00; cmd_led <= 1'b0; last_low7 <= 7'd0;
        end else begin
            tx_valid <= 1'b0;
            if (rx_valid) begin
                last_low7 <= rx_data[6:0];
                if (tx_ready) begin tx_data <= rx_data; tx_valid <= 1'b1; end
                case (rx_data)
                    8'h30: cmd_led <= 1'b0;      // '0'
                    8'h31: cmd_led <= 1'b1;      // '1'
                    8'h32: cmd_led <= ~cmd_led;  // '2'
                    default: ;                   // 그 밖의 문자: 유지
                endcase
            end
        end
    end
endmodule
