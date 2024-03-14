module z80db(
// CPU
input clk,
input reset,
input bsrq,
input mreq,
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
output mce  // mreq ;cs
);

// SRAM
assign moe = A14 | A15 | rd | mreq; // rd
assign mwe = wr; // wr
assign mce = A14 | A15 | mreq;  // mreq

// Level shifter Hi-z control
assign lsoe = ~bsrq;

endmodule