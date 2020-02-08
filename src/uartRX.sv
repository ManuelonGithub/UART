



module uartRX (
	input wire clk_i, baudClk_i, rst_i,
	input wire dat_i,
	output reg datEn_o,
	output reg[7:0] dat_o
);
 

reg shiftEn, loadEn;
reg[7:0] shiftReg;
reg[2:0] count;

wire start = ~dat_i;
wire stop = dat_i;
wire done = (count == 0);

enum {IDLE, START, RECV, LOAD} RECV_STATES;

reg[1:0] state, nextState;

initial begin
	shiftReg <= 8'hFF;
	count <= 0;

	state <= IDLE;
	dat_o <= 0;
	datEn_o <= 0;
end

always @ (*) begin
	shiftEn <= 0;
	loadEn <= 0;

	case (state)
		IDLE: begin
			if (start)
				nextState <= START;
			else
				nextState <= IDLE;
		end
		START: begin
			shiftEn <= 1;

			if (~done)
				nextState <= RECV;
			else
				nextState <= START;
		end
		RECV: begin
			if (done && stop)
				nextState <= LOAD;
			else
				nextState <= RECV;
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
		dat_o <= 0;
		datEn_o <= 0;
	end
	else begin
		state <= nextState;

		if (loadEn)
			dat_o <= shiftReg;
			datEn_o <= 1;
	end
end 

always @ (negedge baudClk_i, posedge rst_i) begin
	if (rst_i) begin
		count <= 0;
		shiftReg <= 8'hFF;
	end
	else begin
		if (shiftEn) begin
			count <= 3'h7;
		end
		else if (~done) begin
			shiftReg <= {dat_i, shiftReg[7:1]};
			count--;
		end
	end
end

endmodule 