`timescale 1 ns / 10 ps

module z80db_tb;

/* DUT inputs */
// CPU
reg reset   = 1'b0;
reg bsrq    = 1'b0;
reg mreq    = 1'b0;
reg iorq    = 1'b0;
reg rd      = 1'b0;
reg wr      = 1'b0;

reg [7:0]A  = 8'b0;
reg [5:0]A_dummy = 6'b0;
reg A14     = 1'b0;
reg A15     = 1'b0;
wire [15:0] adress = {A15, A14, A_dummy, A};

wire [7:0]D  = 8'b0;
//inout [7:0]Data  = 8'b0; 
reg [7:0]D_in  = 8'b0; 
reg [7:0]D_out  = 8'b0; 
reg D_is_out  = 1'b0; 

// Джампер управления.
reg jump    = 1'b0;

/* DUT outputs */
// SRAM
wire moe; 	// rd ;oe
wire mwe; 	// wr ;we
wire mce; 	// mreq ;cs
wire ma14;	// для переключения банков кеш памяти.
// Блокировка штатного ПЗУ.
wire romblk;	// rdrom aka rdr. 

// DUT
z80db dut(
    // CPU
    .reset(reset),
    .bsrq(bsrq),
    .mreq(mreq),
    .iorq(iorq),
    .rd(rd),
    .wr(wr),
    .A(A),
    .A14(A14 ),
    .A15(A15 ),
    .D(D),
    // Джампер управления.
    .jump(jump),

    // SRAM
    .moe(moe), 	// rd ;oe
    .mwe(mwe), 	// wr ;we
    .mce(mce), 	// mreq ;cs
    .ma14(ma14),	// для переключения банков кеш памяти.

    // Блокировка штатного ПЗУ.
    .romblk(romblk)	// rdrom aka rdr. 
);

assign D = (D_is_out) ? D_out : 8'bZ;
//assign D_out = D;

assign adress = {A15, A14, A_dummy, A};
reg [4:0] cnt = 0;

initial begin
    $dumpfile("z80db_tb.vcd");
    $dumpvars;

    #10 
    force D = 8'bz;
    wr = 1;
    rd = 1;
    iorq = 1;
    mreq = 1;
    reset = 1;

    #10 reset = 0;
    #10 reset = 1;
    #10 reset = 0;
    #10 reset = 1;
    
    #100
    
    #42 {A15, A14, A_dummy, A} = 16'h7ffd;
    force D = 8'h55;
    #10
    wr = 0;
    rd = 1;
    #10 iorq = 0;
    #10 iorq = 1;
    wr = 1;

    #100
    {A15, A14, A_dummy, A} = 16'h7ffd;
    force D = 8'hff;
    #10
    wr = 0;
    rd = 1;
    #10 iorq = 0;
    #10 iorq = 1;
    wr = 1;

    #100
    {A15, A14, A_dummy, A} = 16'h00fd;
    force D = 8'hee;
    #10
    wr = 0;
    rd = 1;
    #10 iorq = 0;
    #10 iorq = 1;
    wr = 1;

    #100
    #10 reset = 0;
    #10 reset = 1;

    #100
    {A15, A14, A_dummy, A} = 16'habba;
    force D = 8'hee;
    #10
    wr = 0;
    rd = 1;
    #10 iorq = 0;
    #10 iorq = 1;
    wr = 1;

    #100
    {A15, A14, A_dummy, A} = 16'h7ffd;
    force D = 8'h08;
    #10
    wr = 0;
    rd = 1;
    #10 iorq = 0;
    #10 iorq = 1;
    wr = 1;

    #100
    {A15, A14, A_dummy, A} = 16'h7ffd;
    release D;// = 8'hz;
    D_is_out = 1'b1;
    #10
    wr = 1;
    rd = 0;
    #10 iorq = 0;
    #10
    D_out = D;
    #10 iorq = 1;
    rd = 1;

    D_out = 8'h11;
    {A15, A14, A_dummy, A} = 16'h0000;
    force D = 8'hff;
    #100
    #10 reset = 0;
    #10 reset = 1;
    #10 reset = 0;
    #10 reset = 1;
    


    #100
    $finish;
end

endmodule