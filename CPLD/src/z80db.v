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

// Level shifter Hi-z control
output lsoe, // When lsoe is low (1'b0) level shifters pins is Hi-z

// SRAM
output moe, // rd ;oe
output mwe, // wr ;we
output mce, // mreq ;cs

// Блокировка штатного ПЗУ.
output romblk	// rdrom aka rdr. 
);

// SRAM
assign moe = A14 | A15 | rd | mreq; // rd
assign mwe = wr; // wr
assign mce = A14 | A15 | mreq;  // mreq

// Level shifter Hi-z control
assign lsoe = ~bsrq;

// Блокировка штатного ПЗУ.
assign romblk = cash;// ~(A == 8'hFB) | iorq | rd;

reg cash = 1'b0;

wire iord = iorq | rd;

always @(negedge iord) begin
	case (A)
		8'hFB : cash <= 1'b1;
		8'h7B : cash <= 1'b0;
	endcase
end

endmodule

/*
RD 251 (FB) включает кешпамять
RD 123 (7B) выключает кешпамять

*/