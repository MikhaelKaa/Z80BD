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


// 
parameter mem_window_0_port =   8'h10;
parameter mem_window_1_port =   8'h11;
parameter mem_window_2_port =   8'h12;
parameter mem_window_3_port =   8'h14;

parameter system_port       =   8'h20;
// bit 2 - 24 MHz
// bit 1:0 - 12, 6, 3, 1.5 MHz

parameter uart_16550_port   =   8'hef;


// PIN mapping (PIN naming as sch)
wire [15:0] cpu_address = A;
wire [7:0] cpu_address_l = cpu_address[7:0];
wire [7:0] cpu_address_h = cpu_address[15:8];

wire [4:0] ext_mem_adr;
assign {M_A18, M_A17, M_A16, M_A15, M_A14} = ext_mem_adr;

//wire [7:0] cpu_data = D;

wire cpu_clock;
assign CLK = cpu_clock;

wire reset_n = RES;

wire mreq_n = MREQ;
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

assign INT = 1'b1;
assign NMI = 1'b1;


// Base io
wire iowr_n = iorq_n | wr_n;
wire iord_n = iorq_n | rd_n;

// Clock
reg [3:0] cpu_clk_div = 4'h0;
always @(negedge CLK_24MHz) begin
    cpu_clk_div = cpu_clk_div + 1;
end
assign cpu_clock = system_reg[2]? CLK_24MHz : (cpu_clk_div[~system_reg[1:0]]);

// System register wr & rd.
reg [7:0] system_reg = 8'h00;
always @(negedge iowr_n or negedge reset_n) begin
    if(!reset_n) begin
        system_reg <= 8'h00;
    end else begin
        if(cpu_address_l == system_port ) system_reg <= D;
    end
end
wire system_rd = (~(cpu_address_l == system_port)) | iord_n;
assign D = (system_rd)?(8'hzz):(system_reg);

// Memory mapper
wire [1:0] cpu_adr_window = cpu_address[15:14];
reg [7:0] mmap_window_0 = 8'h40;
reg [7:0] mmap_window_1 = 8'h40;
reg [7:0] mmap_window_2 = 8'h40;
reg [7:0] mmap_window_3 = 8'h40;
reg [7:0] mmap_outp     = 8'h00;

// Write memory map registers.
always @(negedge iowr_n or negedge reset_n) begin
    if(!reset_n) begin
        mmap_window_0 <= 8'h40;
        mmap_window_1 <= 8'h40;
        mmap_window_2 <= 8'h40;
        mmap_window_3 <= 8'h00;
    end else begin
        if(cpu_address_l == mem_window_0_port ) mmap_window_0 <= D;
        if(cpu_address_l == mem_window_1_port ) mmap_window_1 <= D;
        if(cpu_address_l == mem_window_2_port ) mmap_window_2 <= D;
        if(cpu_address_l == mem_window_3_port ) mmap_window_3 <= D;
    end
end

// Read memory map registers.
wire window_0_rd = (~(cpu_address_l == mem_window_0_port)) | iord_n;
wire window_1_rd = (~(cpu_address_l == mem_window_1_port)) | iord_n;
wire window_2_rd = (~(cpu_address_l == mem_window_2_port)) | iord_n;
wire window_3_rd = (~(cpu_address_l == mem_window_3_port)) | iord_n;

assign D = (window_0_rd)?(8'hzz):(mmap_window_0);
assign D = (window_1_rd)?(8'hzz):(mmap_window_1);
assign D = (window_2_rd)?(8'hzz):(mmap_window_2);
assign D = (window_3_rd)?(8'hzz):(mmap_window_3);

always @(*) begin  // TODO: Изучить как это работает.
//always @(negedge CLK_24MHz) begin  
    if(cpu_adr_window == 2'b00) mmap_outp <= mmap_window_0;
    if(cpu_adr_window == 2'b01) mmap_outp <= mmap_window_1;
    if(cpu_adr_window == 2'b10) mmap_outp <= mmap_window_2;
    if(cpu_adr_window == 2'b11) mmap_outp <= mmap_window_3;
end

assign ext_mem_adr    = mmap_outp[4:0];
assign slow_rom_ce_n  = mreq_n | ( mmap_outp[6] ? 1'b1 :  mmap_outp[5]);
assign slow_ram_ce_n  = mreq_n | ( mmap_outp[6] ? 1'b1 : ~mmap_outp[5]);
assign fast_ram0_ce_n = mreq_n | (~mmap_outp[6] ? 1'b1 :  mmap_outp[1]);
assign fast_ram1_ce_n = mreq_n | (~mmap_outp[6] ? 1'b1 : ~mmap_outp[1]);


// 16550
// Clock 16550
// reg [3:0] uart_clk_cnt = 4'h0;
// reg uart_clk = 1'b0;
// always @(negedge CLK_24MHz) begin
//     if(uart_clk_cnt > 6) begin
//         uart_clk_cnt <= 4'h0;
//         uart_clk = ~uart_clk;
//     end else begin
//         uart_clk_cnt <= uart_clk_cnt + 1;
//     end
// end
//  1.8432 MHz --> 542.53472 ns
// 24.0000 MHz -->  41.66667 ns
// Похоже проще поставить кварц на 16550...
// assign U_CLK = uart_clk;

assign U_CS = iorq_n | ~(cpu_address_l == uart_16550_port);

endmodule

/*
Memory mapper

page - 16kb.

Physical address space (64kb)
0x0000...0x3fff - window_0 (A15 == 0; A14 == 0)
0x4000...0x7fff - window_1 (A15 == 0; A14 == 1)
0x8000...0xbfff - window_2 (A15 == 1; A14 == 0)
0xc000...0xffff - window_3 (A15 == 1; A14 == 1)

Virtual address space (1024kb + 64kb)(64 slow pages + 4 fast ram)
slow rom  32 pages
slow ram2 32 pages
fast ram0  2 pages
fast ram1  2 pages

*/
