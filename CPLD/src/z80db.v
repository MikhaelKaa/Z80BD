module z80db(
// CPU
input clk,
input reset,
input bsrq,
input mreq,
input rd,
input wr,

// Level shifter Hi-z control
output lsoe, // When lsoe is low (1'b0) level shifters pins is Hi-z

// SRAM
output moe, // rd
output mwe, // wr
output mce  // mreq
);

assign moe = rd;
assign mwe = wr;
assign mce = mreq;
assign lsoe = bsrq?(1'b0):(1'b1);

endmodule