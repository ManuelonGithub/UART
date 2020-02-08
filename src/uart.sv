`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/31/2020 05:28:47 PM
// Design Name: 
// Module Name: uart
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module uart 
#(
    parameter CLK_RATE = 100000000,
    parameter BAUD_RATE = 9600
 )
(
    input wire clk_i, rst_i,
    input wire txEn_i,
    input wire rx_i,
    input wire[7:0] data_i,
    output reg baudClk_o, tx_o, rdy_o, done_o, datEn_o,
    output reg[7:0] data_o
);

wire baudClk;

wire en;

//button_press_detector buttonDetect (
//    .clk_i   (clk_i),
//    .button_i(txEn_i),
//    .press_o (en)
//);

assign en = txEn_i;

BaudRateGen #(.MCLK(CLK_RATE), .BAUD(BAUD_RATE)) baudGenerator (
	.clk_i(clk_i), 
	.rst_i(rst_i),
	.en_i(1),
	.baudClk_o(baudClk_o)
);

uartTX tx (
    .clk_i    (clk_i),
    .baudClk_i(baudClk_o),
    .rst_i    (rst_i),
    .en_i     (en),
    .data_i   (data_i),
    .txDat_o  (tx_o),
    .rdy_o    (rdy_o),
    .done_o   (done_o)
);

uartRX rx (
	.clk_i(clk_i), 
	.baudClk_i(baudClk_o), 
	.rst_i(rst_i),
	.dat_i(tx_o),
	.datEn_o(datEn_o),
    .dat_o(data_o)
);

endmodule
