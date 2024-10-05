// ADSR for a simple PSG
// Copyright (C) 2024 Henrik Löfgren
// Assuming a base clock of 1.5 MHz as this works well with I2S (usbclock divided by 8)

module adsr(
    input               clk,
    input               rst_n,
    input               gate,
    input   [3:0]       attack,
    input   [3:0]       decay,
    input   [3:0]       sustain,
    input   [3:0]       release,
    input   [15:0]      sound_i,
    output  [15:0]      sound_o      
);

reg     [15:0]      envelope;

    

endmodule;