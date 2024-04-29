module z80io(
// CPU
input reset,// TODO: del
input clk,// TODO: del
input bsrq,// TODO: del
input mreq,// TODO: del
input iorq,
input rd,// TODO: del
input wr,// TODO: del
input [7:0]A,
inout [7:0]D,// TODO: del

// Chip select 16550.
output tl_cs,	
output ioge, 
// Джампер управления.
input jump,// TODO: del

input RTS_5V,
output RTS_3V,
input TX_5V,
output TX_3V

);

assign RTS_3V = RTS_5V;
assign TX_3V  = TX_5V;

// TODO: del
reg ioge_filt = 1'b0;
always @(negedge clk) begin
	ioge_filt = ioge_c;
end

wire ioge_c = (A == 8'hef);

assign ioge = ioge_c;
assign tl_cs = iorq | ~(A == 8'hef);


endmodule
