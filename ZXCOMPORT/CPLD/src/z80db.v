module z80io(
// CPU
input reset,
input clk,
input bsrq,
input mreq,
input iorq,
input rd,
input wr,
input [7:0]A,
inout [7:0]D,

// Блокировка штатного ПЗУ.
output tl_cs,	// rdrom aka rdr. 
output ioge, 
// Джампер управления.
input jump
);

reg ioge_filt = 1'b0;
always @(negedge clk) begin
	ioge_filt = ioge_c;
end

wire ioge_c = (A == 8'hef);

assign ioge = ioge_c;
assign tl_cs = iorq | ~(A == 8'hef);


endmodule
