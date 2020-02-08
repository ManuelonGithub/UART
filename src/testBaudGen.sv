



module BaudRateGen 
#(
	parameter MCLK = 100000000,
	parameter WORD = 16,
	parameter BAUD = 115200	
 )
(
	input wire clk_i, rst_i,
	input wire en_i,
	output reg baudClk_o
);

	localparam BAUD_COUNT = ((MCLK/BAUD)/2) - 1;

	reg[WORD-1:0] count;

	initial begin
		count <= 0;
		baudClk_o <= 0;
	end

	always @ (posedge clk_i or posedge rst_i) begin
		if (rst_i) begin
			count <= 0;
			baudClk_o <= 0;
        end
		else begin
			if (count == BAUD_COUNT) begin
				baudClk_o <= ~baudClk_o;
				count <= 0;
			end
			else
				count++;
		end
	end
endmodule
