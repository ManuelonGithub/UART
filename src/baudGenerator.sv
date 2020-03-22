



module baudGenerator
#(
	parameter PRESCALERS = 8,
	parameter WORD = 16
 )
(
	input wire clk_i, rst_i,
	input wire en_i,
	input wire[WORD-1:0] baud_i,
	output reg baudClk_o
);

reg[WORD-1:0] baudCount;

wire baudDone;
assign baudDone = (baudCount == 0);

initial begin
	baudClk_o	<= 0;
	baudCount	<= 0;
end

always @ (posedge clk_i or posedge rst_i) begin
	if (rst_i) begin
		baudClk_o	<= 0;
		baudCount	<= 0;
	end
	else begin
		casez({baudDone, en_i})
			2'b?0: begin	// Module not enabled
				baudCount <= baud_i;
            	baudClk_o <= 0;
			end
			2'b01: begin
				baudCount <= baudCount - 1;
			end
			2'b11: begin
				baudCount <= baud_i;
            	baudClk_o <= ~baudClk_o;
			end
		endcase
	end
end

endmodule