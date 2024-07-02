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
// 0x0003 SD card
// 0x0004 Video

module nano6502_top
(
    input           clk_i,
    input           rst_i, //S1
    input           uart_rx_i,
    output          uart_tx_o,
    output          leds[5:0],
    output          ws2812_o,
    output          sdclk,
    output            tmds_clk_p    ,
    output            tmds_clk_n    ,
    output     [2:0]  tmds_data_p   ,//{r,g,b}
    output     [2:0]  tmds_data_n   ,
    inout           sdcmd,
    inout [3:0]     sddat
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

wire            addr_dec_cs;

wire            led_cs;
wire    [7:0]   led_data_o;
wire    [7:0]   ledwire;

wire            sd_cs;
wire    [7:0]   sd_data_o;

wire            video_cs;
wire    [7:0]   video_data_o;

wire            timer_cs;
wire    [7:0]   timer_data_o;

assign rst_n = ~rst_i;
assign rst_p = rst_i;

assign leds[5] = ~ledwire[5];
assign leds[4] = ~ledwire[4];
assign leds[3] = ~ledwire[3];
assign leds[2] = ~ledwire[2];
assign leds[1] = ~ledwire[1]; 
assign leds[0] = ~ledwire[0];

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
        .addr_dec_cs(addr_dec_cs),
        .led_cs(led_cs),
        .sd_cs(sd_cs),
        .video_cs(video_cs),
        .timer_cs(timer_cs)
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

//wire    WE;

/*cpu_65c02 cpuinst(
        .clk(clk_i),
        .reset(rst_p),
        .AB(cpu_addr),
        .DI(cpu_data_i),
        .DO(cpu_data_o),
        .WE(WE),
        .IRQ(1'b0),
        .NMI(1'b0), 
        .RDY(1'b1),
        .SYNC()
);*/

//assign R_W_n = ~WE;

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

bootrom bootrom_inst(
    .clk(clk_i),
    .adr(cpu_addr[12:0]),
    .data(rom_data_o)
);

leds led_inst(
    .clk_i(clk_i),
    .rst_n_i(rst_n),
    .R_W_n(R_W_n),
    .reg_addr_i(cpu_addr[1:0]),
    .data_i(cpu_data_o),
    .led_cs(led_cs),
    .data_o(led_data_o),
    .leds(ledwire),
    .ws2812(ws2812_o)
);

sd_interface sd_inst(
    .clk_i(clk_i),
    .rst_n_i(rst_n),
    .R_W_n(R_W_n),
    .reg_addr_i(cpu_addr[7:0]),
    .data_i(cpu_data_o),
    .sd_cs(sd_cs),
    .data_o(sd_data_o),
    .sdclk(sdclk),
    .sdcmd(sdcmd),
    .sddat(sddat)
);

video video_inst(
    .clk_i(clk_i),
    .rst_n_i(rst_n),
    .R_W_n(R_W_n),
    .reg_addr_i(cpu_addr[7:0]),
    .data_i(cpu_data_o),
    .video_cs(video_cs),
    .data_o(video_data_o),
    .tmds_clk_p_o(tmds_clk_p),
    .tmds_clk_n_o(tmds_clk_n),
    .tmds_data_p_o(tmds_data_p),
    .tmds_data_n_o(tmds_data_n)
);

timer timer_inst(
    .clk_i(clk_i),
    .rst_n_i(rst_n),
    .R_W_n(R_W_n),
    .reg_addr_i(cpu_addr[1:0]),
    .data_i(cpu_data_o),
    .timer_cs(timer_cs),
    .data_o(timer_data_o)    
);

always @(*) begin
    if(rom_cs == 1'b1) cpu_data_i <= rom_data_o;
    else if(sd_cs == 1'b1) cpu_data_i <= sd_data_o;
    else if(ram_cs == 1'b1) cpu_data_i <= ram_data_o;
    else if(uart_cs == 1'b1) cpu_data_i <= uart_data_o;
    else if(addr_dec_cs == 1'b1) cpu_data_i <= addr_dec_data_o;
    else if(led_cs == 1'b1) cpu_data_i <= led_data_o;
    else if(video_cs == 1'b1) cpu_data_i <= video_data_o;
    else if(timer_cs == 1'b1) cpu_data_i <= timer_data_o;
    else cpu_data_i <= 8'd0;//cpu_data_o;
end

endmodule

