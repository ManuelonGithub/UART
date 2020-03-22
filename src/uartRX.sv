



module uartRX
#(
	parameter BAUD_WORD = 16
 )
(
	input wire clk_i, rst_i,

	input wire[BAUD_WORD-1:0] baud_i,

	input wire dat_i, rd_i,
	output reg datEn_o, full_o, holdEn_o,
	output reg[7:0] dat_o, holdReg_o,

	output reg[1:0] status_o, 
	output reg baudEn_o, empty_o, rx_o
);

reg shiftEn, loadEn, empty;
reg[7:0] shiftReg;
reg[3:0] count;

reg baudEn, baudClk;

baudGenerator baudGen (
	.clk_i      (clk_i),
	.rst_i      (rst_i),
	.en_i       (baudEn),
	.baud_i     (baud_i),
	.baudClk_o  (baudClk)
);

fifo FifoBuffer (
	.clk_i  (clk_i),
	.rst_i  (rst_i),
	.wr_i   (loadEn),
	.rd_i   (rd_i),
	.data_i (shiftReg),
	.full_o (full_o),
	.empty_o(empty),
	.data_o (dat_o)
);

assign datEn_o = ~empty;
assign holdEn_o = loadEn;

wire start = ~dat_i;
wire stop = dat_i;
wire done = (count == 0);

enum {IDLE, RECV, STOP_RECV, LOAD} RECV_STATES;

reg[1:0] state, nextState;

always @ (*) begin
	status_o <= state; 
	baudEn_o <=  baudEn;
	empty_o <= empty;
	rx_o <= dat_i;
end

initial begin
	shiftReg <= 8'hFF;
	count <= 0;

	state <= IDLE;
end

always @ (*) begin
	shiftEn <= 0;
	loadEn <= 0;
	baudEn <= 0;

	case (state)
		IDLE: begin
			if (start)
				nextState <= RECV;
			else
				nextState <= IDLE;
		end
		RECV: begin
			baudEn <= 1;

			if (done && stop)
				nextState <= STOP_RECV;
			else
				nextState <= RECV;
		end
		STOP_RECV: begin
			baudEn <= 1;

			if (~done)
				nextState <= LOAD;
			else
				nextState <= STOP_RECV;
		end
		LOAD: begin
			loadEn <= 1;

			nextState <= IDLE;
		end
	endcase // state
end

always @ (posedge clk_i or posedge rst_i) begin
	if (rst_i) begin
		state <= IDLE;
	end
	else begin
		state <= nextState;

		if (loadEn)
			holdReg_o <= shiftReg;
	end
end 

always @ (posedge baudClk, posedge rst_i) begin
	if (rst_i) begin
		count <= 0;
		shiftReg <= 8'hFF;
	end
	else begin
		if (~done) begin
			shiftReg <= {dat_i, shiftReg[7:1]};
			count--;
		end
		else begin
		  count <= 8;
		end
	end
end

endmodule 