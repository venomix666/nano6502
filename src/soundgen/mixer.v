// Mixer for a simple PSG
// Copyright (C) 2024 Henrik Löfgren
// Assuming a base clock of 1.5 MHz as this works well with I2S (usbclock divided by 8)

module mixer(
    input               clk_i,
    input               rst_n,
    input   [15:0]      sound1_i,
    input   [15:0]      sound2_i,
    input   [15:0]      sound3_i,
    input   [7:0]       volume_i,
    output  [15:0]      sound_o      
);

reg     [17:0]  sound_mixed;
reg     [25:0]  sound_int;

// Additive mix
always @(posedge clk_i or negedge rst_n)
begin
    if(rst_n == 1'b0) sound_mixed <= 18'd0;
    else sound_mixed <= sound1_i + sound2_i + sound3_i;
end

// Volume control
always @(posedge clk_i or negedge rst_n)
begin
    if(rst_n == 1'b0) sound_int <= 26'd0;
    else sound_int <= sound_mixed * volume_i;
end

assign sound_o = sound_int[25:10];

endmodule