module z80bd (
    // main clock
    input CLK_24MHz,
    
    // Z80 bus & sign
    input 	IORQ,
    input 	MREQ,
    output 	NMI,
    output 	INT,
    input 	M1,
    output 	CLK,
    input 	RD,
    input 	WR,
    input 	RES,

    inout	[7:0]  D,
    input   [15:0] A,

    // RAM and ROM
    output M_A18,
    output M_A17,
    output M_A16,
    output M_A15,
    output M_A14,
    // 512kb
    output ROM_CE,
    // 512kb
    output RAM2_CE,
    // 32kb
    output RAM0_CE,
    // 32kb
    output RAM1_CE,
    
    // 16550
    output U_CS,
    output U_CLK,
    input  U_INT
    
);

// PIN mapping (PIN naming as sch)
wire [15:0] cpu_address = A;
wire [7:0] cpu_address_l = cpu_address[7:0];
wire [7:0] cpu_address_h = cpu_address[15:8];

wire [4:0] ext_mem_adr;
assign {M_A18, M_A17, M_A16, M_A15, M_A14} = ext_mem_adr;

wire [7:0] cpu_data = D;

wire cpu_clock;
assign CLK = cpu_clock;


wire slow_rom_ce_n;
assign ROM_CE = slow_rom_ce_n;
wire slow_ram_ce_n;
assign RAM2_CE = slow_ram_ce_n;
wire fast_ram0_ce_n;
assign RAM0_CE = fast_ram0_ce_n;
wire fast_ram1_ce_n;
assign RAM1_CE = fast_ram1_ce_n;

wire iorq_n = IORQ;
wire wr_n = WR;
wire rd_n = RD;

// Base io
wire iowr_n = iorq_n | wr_n;


// Clock
reg [3:0] cpu_clk_div = 4'h0;
always @(negedge CLK_24MHz) begin
    cpu_clk_div = cpu_clk_div + 1;
end
assign cpu_clock = cpu_clk_div[3];


// Memory mapper
wire [1:0] cpu_adr_page = cpu_address[15:14];
reg [7:0] mmap_page0 = 8'h0;
reg [7:0] mmap_page1 = 8'h0;
reg [7:0] mmap_page2 = 8'h0;
reg [7:0] mmap_page3 = 8'h0;
reg [7:0] mmap_outp  = 8'h0;

always @(negedge iowr_n) begin
    if(cpu_address_l == 8'h10 ) mmap_page0 <= cpu_data;
    if(cpu_address_l == 8'h11 ) mmap_page1 <= cpu_data;
    if(cpu_address_l == 8'h12 ) mmap_page2 <= cpu_data;
    if(cpu_address_l == 8'h13 ) mmap_page3 <= cpu_data;
end

//always @(*) begin  // TODO: Изучить как это работает.
always @(negedge CLK_24MHz) begin  
    if(cpu_adr_page == 0) mmap_outp <= mmap_page0;
    if(cpu_adr_page == 1) mmap_outp <= mmap_page1;
    if(cpu_adr_page == 2) mmap_outp <= mmap_page2;
    if(cpu_adr_page == 3) mmap_outp <= mmap_page3;
end

assign ext_mem_adr    =  mmap_outp[4:0];
assign slow_rom_ce_n  =  mmap_outp[6] ? 1'b1 :  mmap_outp[5];
assign slow_ram_ce_n  =  mmap_outp[6] ? 1'b1 : ~mmap_outp[5];
assign fast_ram0_ce_n = ~mmap_outp[6] ? 1'b1 :  mmap_outp[1];
assign fast_ram1_ce_n = ~mmap_outp[6] ? 1'b1 : ~mmap_outp[1];

endmodule

/*
Memory mapper

page - 16kb.

Physical address space (64kb)
0x0000...0x3fff - page0 (A15 == 0; A14 == 0)
0x4000...0x7fff - page1 (A15 == 0; A14 == 1)
0x8000...0xbfff - page2 (A15 == 1; A14 == 0)
0xc000...0xffff - page3 (A15 == 1; A14 == 1)

Virtual address space (1024kb + 64kb)(64 slow pages + 4 fast ram)
slow rom  32 pages
slow ram2 32 pages
fast ram0  2 pages
fast ram1  2 pages

*/
