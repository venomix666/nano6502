// nano6502 bus interface for simple PSG
// Copyright (C) 2024 Henrik Löfgren
// Assuming a base clock of 1.5 MHz as this works well with I2S (usbclock divided by 8)
//
// Registers:
// 00 - Frequency OSC1 LSB
// 01 - Frequency OSC2 MSB
// 02 - Pulse width OSC1 LSB
// 03 - Pulse width OSC1 MSB (bits 0-3)
// 04 - Control register OSC1 (B0: Gate, B1: not used B2: not used B3: not used B4: Triange B5: Sawtooth B6: Pulse B7: Noise)
// 05 - Attack/decay (bits 0-3 decay, bits 4-7: attack)
// 06 - Sustain/release (bits 0-3 release, bits 4-7: sustain)
 
module soundgen_interface(
	input               clk_i,
    input               clk_1m5,
	input               rst_n_i,
    input               R_W_n,
	input   [4:0]       reg_addr_i,
    input   [7:0]       data_i,
    input               soundgen_cs,
    output  [7:0]       data_o,
    output              HP_BCK,
    output              HP_WS,
    output              HP_DIN
);

reg [7:0]       freq1_lsb;
reg [7:0]       freq1_msb;
reg [7:0]       pulse1_lsb;
reg [3:0]       pulse1_msb;
reg [7:0]       ctrl1;
reg [7:0]       attack_decay1;
reg [7:0]       sustain_release1;

// CPU interface

reg [7:0]       data_o_reg;

always @(*)
begin
        case(reg_addr_i)
            5'b00000: data_o_reg = freq1_lsb;
            5'b00001: data_o_reg = freq1_msb;
            5'b00010: data_o_reg = pulse1_lsb;
            5'b00011: data_o_reg = {4'd0, pulse1_msb};
            5'b00100: data_o_reg = ctrl1;
            5'b00101: data_o_reg = attack_decay1;
            5'b00110: data_o_reg = sustain_release1;
            default: data_o_reg = 8'd0;
        endcase
end

assign data_o = data_o_reg;

always @(posedge clk_i or negedge rst_n_i)
begin
    if(rst_n_i == 1'b0)
    begin
        freq1_lsb <= 8'd0;
        freq1_msb <= 8'd0;
        pulse1_lsb <= 8'd0;
        pulse1_msb <= 4'd0;
        ctrl1 <= 8'd0;
        attack_decay1 <= 8'd0;
        sustain_relase1 <= 8'd0;
    end
    else if((soundgen_cs) && (!R_W_n))
    begin
        case(reg_addr_i)
            5'b00000: freq1_lsb <= data_i;
            5'b00001: freq1_msb <= data_i;
            5'b00010: pulse1_lsb <= data_i;
            5'b00011: pulse1_msb <= data_i[3:0];
            5'b00100: ctrl1 <= data_i;
            5'b00101: attack_decay1 <= data_i;
            5'b00110: sustain_release1 <= data_i;
        endcase
    end
    else
        timer_start <= 1'd0;
end

// Oscillator and ADSR #1
wire    [15:0]  osc1_out;
wire    [15:0]  adsr1_out;

oscillator osc1(
    .clk_i(clk_1m5),
    .rst_n(rst_n),
    .frequency({freq1_msb, freq1_lsb}),
    .duty_cycle({pulse1_msb, pulse1_lsb}),
    .pulse(ctrl1[6]),
    .sawtooth(ctrl1[5]),
    .triangle(ctrl1[4]),
    .noise(ctrl1[8]),
    .sound_o(osc1_out)
); 

adsr adsr1(
    .clk_i(clk_1m5),
    .rst_n(rst_n),
    .gate(ctrl1[0]),
    .attack(attack_decay1[7:4]),
    .decay(attack_decay1[3:0]),
    .sustain(sustain_release1[7:4]),
    .release(sustain_release1[3:0]),
    .sound_i(osc1_out),
    .sound_o(adsr1_out)
);

// I2S output driver
wire output_req;
reg [15:0]  audio_data;

audio_drive drive(
    .clk_1p536m(clk_1m5),
    .rst_n(rst_n),
    .idata(audio_data),
    .req(output_req),
    .HP_BCK(HP_BCK),
    .HP_WS(HP_WS),
    .HP_DIN(HP_DIN)
);

always @(posedge clk_1m5 or negedge rst_n_i)
begin
    if(rst_n_i == 1'b0) audio_data <= 15'd0;
    else if(output_req == 1'b1) audio_data <= adsr1_out;
end

endmodule;