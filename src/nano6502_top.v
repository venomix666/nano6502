// nano6502
//
// A general purpose 6502 computer designed primarily for use with
// the Tang Nano 20K board.
//
// Planned features for first version:
// Text mode video output, 80 columns, over HDMI
// 64K block ram
// ROM which can be switched out
// SDCARD file access
// UART
//
//
// Future features:
// SDRAM with bank switching
// Hires graphics video modes
// USB keyboard support
// Audio
//
// Copyright (C) 2024 Henrik Löfgren

// Modules
// CPU - T65
// Address decoder
// UART - Stock from board vendor
// Graphics - Custom, based on board example
// SDCARD - TBD

// Memory map
// 0x0000           IO bank L 
// 0x0001           IO bank H
// 0x0002           ROM in/out (00 = ROM, 01 = RAM)
// 0xE000-0xFDFF    ROM or RAM
// 0xFE00-0xFEFF    IO page, controlled by IO bank regs
// 0xFF00-0xFFFF    Vectors etc... always in ROM
//
//
// IO banks
// 0x0000 ROM
// 0x0001 UART
// 0x0002 LEDs

module nano6502_top
(
    input           clk_i,
    input           rst_i, //S1
    input           uart_rx_i,
    output          uart_tx_o,
    output          leds[5:0]
);

reg     [7:0]   cpu_data_i;
wire    [7:0]   cpu_data_o;
wire    [7:0]   ram_data_o;
wire    [7:0]   uart_data_o;
wire    [15:0]  cpu_addr;
wire    [7:0]   addr_top;
wire            R_W_n;   
wire            rst_n;  // Active high reset signal
wire            rst_p;

wire            ram_cs;
wire            ram_we;
wire    [7:0]   ram_data_0;

wire    [7:0]   addr_dec_data_o;

wire            uart_cs;

wire            rom_cs;
wire    [7:0]   rom_data_o;
wire    [7:0]   ledwire;

assign rst_n = ~rst_i;
assign rst_p = rst_i;

assign leds[5] = ~ledwire[5];
assign leds[4] = ~ledwire[4];
assign leds[3] = ~ledwire[3];
assign leds[2] = ~ledwire[2];
assign leds[1] = ~ledwire[1]; 
assign leds[0] = ~ledwire[0];

// 64k x 8, main ram
/*blockram_64k main_ram(
        .dout(ram_data_o), //output [7:0] dout
        .clk(clk_i), //input clk
        .oce(ram_cs), //input oce
        .ce(ram_cs), //input ce
        .reset(rst_p), //input reset
        .wre(ram_we), //input wre
        .ad(cpu_addr), //input [15:0] ad
        .din(cpu_data_o) //input [7:0] din
);*/

instram main_ram(
    .clk(clk_i),
    .adr(cpu_addr),
    .rwn(R_W_n),
    .cs(ram_cs),
    .data_i(cpu_data_o),
    .data_o(ram_data_o)
);
addr_decoder addr_dec(
        .clk_i(clk_i),
        .rst_n_i(rst_n),
        .R_W_n(R_W_n),
        .addr_i(cpu_addr),
        .data_i(cpu_data_o),
        .data_o(addr_dec_data_o),
        .ram_cs(ram_cs),
        .ram_we(ram_we),
        .uart_cs(uart_cs),
        .rom_cs(rom_cs),
        .leds(ledwire)
);

T65 CPU(
        .Mode(2'b01),       // 65C02
        .BCD_en(1'b1),      // "others"?
        .Res_n(rst_n),
        .Enable(1'b1),
        .Clk(clk_i),
        .Rdy(1'b1),
        .Abort_n(1'b1),
        .IRQ_n(1'b1),      // Connect later, probably want UART to by interrupt driven
        .NMI_n(1'b1),
        .SO_n(1'b1),
        .R_W_n(R_W_n),
        .Sync(),
        .EF(),
        .MF(),
        .XF(),
        .ML_n(),
        .VP_n(),
        .VDA(),
        .VPA(),
        .A({addr_top, cpu_addr}),
        .DI(cpu_data_i),
        .DO(cpu_data_o),
        .Regs(),
        .DEBUG(),
        .NMI_ack()
);

uart uart_inst(
        .clk(clk_i),
        .rst_n(rst_n),
        .data_i(cpu_data_o),
        .uart_rx(uart_rx_i),
        .uart_cs(uart_cs),
        .R_W_n(R_W_n),
        .reg_addr(cpu_addr[1:0]),
        .data_o(uart_data_o),
        .uart_tx(uart_tx_o)
);

/*prom_8k bootrom(
        .dout(rom_data_o), //output [7:0] dout
        .clk(clk_i), //input clk
        .oce(rom_cs), //input oce
        .ce(rom_cs), //input ce
        .reset(rst_p), //input reset
        .ad(cpu_addr[12:0]) //input [12:0] ad
    );
*/

// CPU data mux
bootrom bootrom_inst(
    .clk(clk_i),
    .adr(cpu_addr[12:0]),
    .data(rom_data_o)
);
always @(*) begin
    if(rom_cs == 1'b1) cpu_data_i <= rom_data_o;
    else if(ram_cs == 1'b1) cpu_data_i <= ram_data_o;
    else if(uart_cs == 1'b1) cpu_data_i <= uart_data_o;
    else if(cpu_addr[15:1] == 15'd0) cpu_data_i <= addr_dec_data_o;
    else cpu_data_i <= cpu_data_o;
end

endmodule

