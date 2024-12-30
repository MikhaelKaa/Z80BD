module z80bd (
	
	// main clock
	input CLK_24MHz,
	
	// Z80 bus & sign
	input IORQ,
	input MREQ,
	output NMI,
	output INT,
	input M1,
	output CLK,
	input RD,
	input WR,
	input RES,

	inout	[7:0] D,
	input [15:0] A,

	// RAM and ROM
	output M_A18,
	output M_A17,
	output M_A16,
	output M_A15,
	output M_A14,
	output ROM_CE,
	output RAM2_CE,
	output RAM0_CE,
	output RAM1_CE,
	
	// 16550
	output U_CS,
	output U_CLK,
	input  U_INT
	
);

endmodule
