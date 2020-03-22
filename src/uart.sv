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
//    input wire txEn_i,
//    input wire[7:0] txData_i,
    input wire rx_i,
    output reg tx_o,
    output reg[7:0] data_o,

    output reg[1:0] status_o, 
    output reg baudEn_o, empty_o, rx_o
);

wire baudClk;

wire rxRdy, txRdy;
wire wr = rxRdy;
wire rd = rxRdy & txRdy;

wire[7:0] rdDat;

// BaudRateGen #(.MCLK(CLK_RATE), .BAUD(BAUD_RATE)) baudGenerator (
// 	.clk_i(clk_i), 
// 	.rst_i(rst_i),
// 	.en_i(1),
// 	.baudClk_o(baudClk_o)
// );

localparam [15:0] BAUD_VAL = CLK_RATE/(BAUD_RATE*2)-1;

//baudGenerator   BaudGenerator (
//    .clk_i      (clk_i), 
//	.rst_i      (rst_i),
//	.prescaler_i(0),
//	.baud_i     (BAUD_VAL),
//	.baudClk_o  (baudClk_o)
//);

uartTX tx (
    .clk_i  (clk_i),
    .rst_i  (rst_i),
    .baud_i (BAUD_VAL),
    .wr_i   (rxRdy),
    .data_i (data_o),
    .txDat_o(tx_o),
    .rdy_o  (txRdy)
);

uartRX rx (
    .clk_i    (clk_i),
    .rst_i    (rst_i),
    .baud_i   (BAUD_VAL),
    .dat_i    (rx_i),
    .rd_i     (rd),
    .datEn_o  (rxRdy),
    .dat_o    (data_o),
    .status_o (status_o),
    .baudEn_o (baudEn_o),
    .empty_o  (empty_o),
    .rx_o     (rx_o)
);

endmodule
