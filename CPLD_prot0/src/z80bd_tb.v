`timescale 1 ns / 10 ps

module z80bd_tb;

localparam CLK_CONST =      4;  

/* DUT inputs */

// main clock
reg CLK_24MHz   = 1'b0;

// Z80 bus & sign
reg RES     = 1'b0;
reg MREQ    = 1'b0;
reg IORQ    = 1'b0;
reg M1      = 1'b0;
reg RD      = 1'b0;
reg WR      = 1'b0;

reg [15:0]A  = 16'b0;

wire [7:0]D  = 8'b0;
reg [7:0]D_in  = 8'b0; 
reg [7:0]D_out  = 8'b0; 
reg D_is_out  = 1'b0; 

// 16550
reg U_INT;

/* DUT outputs */
// Z80 bus & sign
wire CLK;
wire NMI;
wire INT;
// RAM and ROM
wire M_A18;
wire M_A17;
wire M_A16;
wire M_A15;
wire M_A14;
wire ROM_CE;
wire RAM2_CE;
wire RAM0_CE;
wire RAM1_CE;

// 16550
wire U_CS;
wire U_CLK;

// DUT
z80bd dut(
  // main clock
  .CLK_24MHz(CLK_24MHz),
  // Z80 bus & sign
  .IORQ(IORQ),
  .MREQ(MREQ),
  .NMI(NMI),
  .INT(INT),
  .M1(M1),
  .CLK(CLK),
  .RD(RD),
  .WR(WR),
  .RES(RES),
  .D(D),
  .A(A),

  // RAM and ROM
  .M_A18(M_A18),
  .M_A17(M_A17),
  .M_A16(M_A16),
  .M_A15(M_A15),
  .M_A14(M_A14),
  .ROM_CE(ROM_CE),
  .RAM2_CE(RAM2_CE),
  .RAM0_CE(RAM0_CE),
  .RAM1_CE(RAM1_CE),
  // 16550
  .U_CS(U_CS),
  .U_CLK(U_CLK),
  .U_INT(U_INT)
);

assign D = (D_is_out) ? D_out : 8'bZ;

// Сигнал тактовой частоты.
always begin
  #CLK_CONST CLK_24MHz = ~CLK_24MHz;  
end

initial begin
  $dumpfile("z80bd_tb.vcd");
  $dumpvars;
  D_is_out = 1'b1;
  WR = 1;
  RD = 1; 
  A = 16'h0000;
  IORQ = 1;

  #200
  // page0 pert test
  $display("page0 port 0x10");
  A = 16'h0010;
  D_out = 8'h11;
  #200
  WR = 0; //<----
  RD = 1; 
  IORQ = 0;
  #200
  //if(M_A14 != 1'b1) $display("M_A14 is 1'b1");
  WR = 1; //<----
  RD = 1; 
  A = 16'h0000;
  IORQ = 1;
  D_out = 8'h00;
  
  
  
  #200
  // page0 pert test
  $display("page1 port 0x11");
  A = 16'h0011;
  D_out = 8'h11;
  #200
  WR = 0; //<----
  RD = 1; 
  IORQ = 0;
  #200
  //if(M_A14 != 1'b1) $display("M_A14 is 1'b1");
  WR = 1; //<----
  RD = 1; 
  A = 16'h0000;
  IORQ = 1;
  D_out = 8'h00;
  



  D_is_out = 1'b0;
  #1000000
  $finish;
end

endmodule