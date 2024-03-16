module z80db(
// CPU
input clk,
input reset,
input bsrq,
input mreq,
input iorq,
input rd,
input wr,
input [7:0]A,
input A14,
input A15,
inout [7:0]D,

// SRAM
output moe, // rd ;oe
output mwe, // wr ;we
output mce, // mreq ;cs
output ma14,// для переключения банков кеш памяти.

// Блокировка штатного ПЗУ.
output romblk	// rdrom aka rdr. 
);

// SRAM
wire cash_rd = A14 | A15 | rd | mreq;
wire cash_wr = wr;
wire cash_mreq = A14 | A15 | mreq;

wire cash_is_act_rd = cash?(cash_rd):(1'b1);
wire cash_is_act_wr = cash?(cash_wr):(1'b1);
wire cash_is_act_mreq = cash?(cash_mreq):(1'b1);

assign moe = bsrq?(cash_is_act_rd):(cash_rd); // rd
assign mwe = bsrq?(cash_is_act_wr):(cash_wr); // wr
assign mce = bsrq?(cash_is_act_mreq):(cash_mreq);  // mreq
assign ma14 = reg_7ffd[4];

// Блокировка штатного ПЗУ.
assign romblk = cash | ~bsrq;

reg cash = 1'b0;

wire iord = iorq | rd;
wire iowr = iorq | wr;
//wire p7ffd = ~(A == 253);
wire p7ffd = ~(A == 253) | ~(A15 == 0) | ~(A14 == 1);

wire p7ffdrd = p7ffd | iord;

reg [7:0] reg_7ffd = 8'b0;

assign D = (p7ffdrd)?(8'bz):(reg_7ffd);

always @(negedge iowr or negedge reset) begin
	if(!reset) begin
		reg_7ffd <= 8'b0;
	end else begin
		if(p7ffd == 0) reg_7ffd <= D;
	end
end

always @(negedge iord or negedge reset) begin
	if(!reset) begin
		cash <= 1'b0; // <--- для старта из ПЗУ после сброса.
		//cash <= 1'b1; // <--- для старта из кеша после сброса.
	end else begin
		case (A)
			8'hFB : cash <= 1'b1;
			8'h7B : cash <= 1'b0;
		endcase
	end
end

endmodule

/*
RD 251 (FB) включает кешпамять
RD 123 (7B) выключает кешпамять
7ffd 32765
*/