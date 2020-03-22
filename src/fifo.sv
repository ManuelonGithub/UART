



module fifo 
#(
	parameter WORD = 8,
	parameter DEPTH = 8
 )
(
	input wire clk_i, rst_i,
	input wire wr_i, rd_i,
	input wire[WORD-1:0] data_i,
	output reg full_o, empty_o,
	output reg[$clog2(DEPTH)-1:0] fill_o,
	output reg[WORD-1:0] data_o
);

reg[$clog2(DEPTH)-1:0] rd, wr;

reg[WORD-1:0] buffer[DEPTH];

wire[$clog2(DEPTH)-1:0] nextWr, nextWrAhead, nextRd;

assign nextWr = wr + 1;
assign nextWrAhead = wr + 2'b10;
assign nextRd = rd + 1;

initial begin
	rd 		<= 0;
	wr 		<= 0;
	fill_o 	<= 0;
	full_o  <= 0;
	empty_o <= 1;

	for (int i = 0; i < DEPTH; i++)
		buffer[i] <= -'h1;
end

always @ (posedge clk_i) begin
    data_o <= buffer[rd];
    buffer[wr] <= data_i;
end

always @ (posedge clk_i, posedge rst_i) begin
	if (rst_i) begin
		rd 		<= 0;
		wr 		<= 0;
	end
    else begin
        if (wr_i & !full_o)
            wr <= nextWr;
        
        if (rd_i  & !empty_o)
            rd <= nextRd;
    end
end

always @ (posedge clk_i, posedge rst_i) begin
	if (rst_i) begin
		full_o  <= 0;
		empty_o <= 1;
		fill_o <= 0;
	end
	else begin
		// This code is based on the zipCPU FIFO blog entry.
		// It was retrieved Feb. 3rd 2020
		// Blog URL: https://zipcpu.com/blog/2017/07/29/fifo.html
		casez({wr_i, rd_i, full_o, empty_o})
		4'b01?0: begin	// A successful read
			full_o  <= 1'b0;
			empty_o <= (nextRd == wr);
			
			fill_o--;
		end
		4'b100?: begin	// A successful write
			full_o <= (nextWrAhead == rd);
			empty_o <= 1'b0;
			
			fill_o++;
		end
		4'b11?1: begin	// Successful write, failed read
			full_o  <= 1'b0;
			empty_o <= 1'b0;
			
			fill_o++;
		end
		4'b11?0: begin	// Successful read and write
			full_o  <= full_o;
			empty_o <= 1'b0;
		end
		default: begin 
		end
		endcase
	end
end

endmodule