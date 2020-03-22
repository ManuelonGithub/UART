



module uartTX
#(
	parameter BAUD_WORD = 16
 )
(
	input wire clk_i, rst_i,

	input wire[BAUD_WORD-1:0] baud_i,

	input wire wr_i,
	input wire[7:0] data_i,
	output reg txDat_o, txEn_o, rdy_o, done_o
);

localparam SHIFT_W = 10;

reg[1:0] state, nextState;

reg[7:0] data_r;
reg fifoRd, full, empty;

reg baudClk;

baudGenerator baudGen (
	.clk_i    (clk_i),
	.rst_i    (rst_i),
	.en_i     (1),
	.baud_i   (baud_i),
	.baudClk_o(baudClk)
);

fifo FifoBuffer (
	.clk_i  (clk_i),
	.rst_i  (rst_i),
	.wr_i   (wr_i),
	.rd_i   (fifoRd),
	.data_i (data_i),
	.full_o (full),
	.empty_o(empty),
	.data_o (data_r)
);

reg holdEn, shiftEn;

reg[3:0] bitCounter_r;
reg[SHIFT_W-1:0] hold_r, shift_r;

enum {IDLE, SETUP_HOLD, START_SEND, DATA_SEND} TX_STATES;


initial begin
	bitCounter_r	<= 0;
	shift_r			<= {SHIFT_W{1'b1}};
	hold_r			<= {SHIFT_W{1'b1}};
	state 			<= IDLE;
end

// UART TX state machine outputs and transition behaviour
always @ (*) begin
	shiftEn <= 0;
	txEn_o 	<= 0;
	fifoRd  <= 0;
	holdEn 	<= 0;

	case (state)
		IDLE: begin
			if (~empty) 
				nextState <= SETUP_HOLD;
			else
				nextState <= IDLE;
		end

		SETUP_HOLD: begin
			fifoRd <= 1;
			holdEn <= 1;

			nextState <= START_SEND;
		end

		START_SEND: begin
			shiftEn <= 1;

			if (~done_o)
				nextState <= DATA_SEND;
			else
				nextState <= START_SEND;
		end

		DATA_SEND: begin
			txEn_o 	<= 1;

			casez ({done_o, empty})
				2'b0?:
					nextState <= DATA_SEND;
				2'b10:
					nextState <= SETUP_HOLD;
				2'b11:
					nextState <= IDLE;
			endcase
		end

		default: begin
		  nextState <= IDLE;
		end
	endcase // state
end

// non-baudrate dependent syyncrhonous behaviour
always @ (posedge clk_i or posedge rst_i) begin
	if (rst_i) begin
		state 	<= IDLE;
		hold_r	<= {SHIFT_W{1'b1}};
	end
	else begin
		state 	<= nextState;

		// Subject to change once more modes are supported
		if (holdEn)
			hold_r	<= {1'b1, data_r, 1'b0};
	end
end

// Non-synchronous output behaviour
always @ (*) begin
	txDat_o <= shift_r[0];
	done_o	<= (bitCounter_r == 0);
	rdy_o 	<= ~full;
end

// Baudrate dependent synchronous behaviour
always @ (posedge baudClk or posedge rst_i) begin
	if (rst_i) begin
		bitCounter_r 	<= 0;
		shift_r			<= {SHIFT_W{1'b1}};
	end
	else begin
		if (done_o) begin
			if (shiftEn) begin
				shift_r 		<= hold_r;

				// Subject to change once more modes are supported
				bitCounter_r 	<= SHIFT_W;
			end
		end
		else begin
			shift_r <= {1'b1, shift_r[SHIFT_W-1:1]};
			bitCounter_r--;
		end
	end
end

endmodule