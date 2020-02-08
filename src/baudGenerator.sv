



module baudGenerator
(
	input wire clk_i, arst_i,
	input wire paramEn_i,
	input wire[15:0] baudParam,
	output reg baudClk_o
);

reg[1:0] baudPrescale;
reg[11:0] baudReg;

reg[11:0] baudCount;
reg[3:0] prescaleCount;	

initial begin
	baudClk_o		<= 0;
	baudPrescale 	<= 0;
	baudReg			<= 0;
	baudCount		<= 0;
	prescaleCount	<= 0;
end

always @ (posedge clk_i, posedge arst_i) begin
	if (arst_i) begin
		baudClk_o		<= 0;
		baudPrescale 	<= 0;
		baudReg			<= 0;
		baudCount		<= 0;
		prescaleCount	<= 0;
	end
end

endmodule