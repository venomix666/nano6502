// nano6502 bus interface for simple PSG
// Copyright (C) 2024 Henrik Löfgren
// Assuming a base clock of 1.5 MHz as this works well with I2S (usbclock divided by 8)
//
// Registers:
// 00 - Frequency OSC1 LSB
// 01 - Frequency OSC1 MSB
// 02 - Pulse width OSC1 LSB
// 03 - Pulse width OSC1 MSB (bits 0-3)
// 04 - Control register OSC1 (B0: Gate, B1: not used B2: not used B3: not used B4: Triange B5: Sawtooth B6: Pulse B7: Noise)
// 05 - Attack/decay ADSR1 (bits 0-3 decay, bits 4-7: attack)
// 06 - Sustain/release ADSR1 (bits 0-3 release, bits 4-7: sustain)
// -----------------------------------------------------
// 07 - Frequency OSC2 LSB
// 08 - Frequency OSC2 MSB
// 09 - Pulse width OSC2 LSB
// 0A - Pulse width OSC2 MSB (bits 0-3)
// 0B - Control register OSC2 (B0: Gate, B1: not used B2: not used B3: not used B4: Triange B5: Sawtooth B6: Pulse B7: Noise)
// 0C - Attack/decay ADSR2 (bits 0-3 decay, bits 4-7: attack)
// 0D - Sustain/release ADSR 2 (bits 0-3 release, bits 4-7: sustain) 
// -----------------------------------------------------
// 0E - Frequency OSC3 LSB
// 0F - Frequency OSC3 MSB
// 10 - Pulse width OSC3 LSB
// 11 - Pulse width OSC3 MSB (bits 0-3)
// 12 - Control register OSC3 (B0: Gate, B1: not used B2: not used B3: not used B4: Triange B5: Sawtooth B6: Pulse B7: Noise)
// 13 - Attack/decay ADSR3 (bits 0-3 decay, bits 4-7: attack)
// 14 - Sustain/release ADSR 3 (bits 0-3 release, bits 4-7: sustain)
// -----------------------------------------------------
// 15 - Master volume (0-255, defaults to 0)

module soundgen_interface(
	input               clk_i,
    input               clkusb_i,
	input               rst_n_i,
    input               R_W_n,
	input   [4:0]       reg_addr_i,
    input   [7:0]       data_i,
    input               soundgen_cs,
    output  [7:0]       data_o,
    output              HP_BCK,
    output              HP_WS,
    output              HP_DIN,
    output              PA_EN
);

// PA always enable for now
assign PA_EN = 1'b1;

reg [7:0]       freq1_lsb;
reg [7:0]       freq1_msb;
reg [7:0]       pulse1_lsb;
reg [3:0]       pulse1_msb;
reg [7:0]       ctrl1;
reg [7:0]       attack_decay1;
reg [7:0]       sustain_release1;


reg [7:0]       freq2_lsb;
reg [7:0]       freq2_msb;
reg [7:0]       pulse2_lsb;
reg [3:0]       pulse2_msb;
reg [7:0]       ctrl2;
reg [7:0]       attack_decay2;
reg [7:0]       sustain_release2;


reg [7:0]       freq3_lsb;
reg [7:0]       freq3_msb;
reg [7:0]       pulse3_lsb;
reg [3:0]       pulse3_msb;
reg [7:0]       ctrl3;
reg [7:0]       attack_decay3;
reg [7:0]       sustain_release3;

reg [7:0]       master_volume;

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

            5'b00111: data_o_reg = freq2_lsb;
            5'b01000: data_o_reg = freq2_msb;
            5'b01001: data_o_reg = pulse2_lsb;
            5'b01010: data_o_reg = {4'd0, pulse2_msb};
            5'b01011: data_o_reg = ctrl2;
            5'b01100: data_o_reg = attack_decay2;
            5'b01101: data_o_reg = sustain_release2;

            5'b01110: data_o_reg = freq3_lsb;
            5'b01111: data_o_reg = freq3_msb;
            5'b10000: data_o_reg = pulse3_lsb;
            5'b10001: data_o_reg = {4'd0, pulse3_msb};
            5'b10010: data_o_reg = ctrl3;
            5'b10011: data_o_reg = attack_decay3;
            5'b10100: data_o_reg = sustain_release3;

            5'b10101: data_o_reg = master_volume;
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
        sustain_release1 <= 8'd0;

        freq2_lsb <= 8'd0;
        freq2_msb <= 8'd0;
        pulse2_lsb <= 8'd0;
        pulse2_msb <= 4'd0;
        ctrl2 <= 8'd0;
        attack_decay2 <= 8'd0;
        sustain_release2 <= 8'd0;

        freq3_lsb <= 8'd0;
        freq3_msb <= 8'd0;
        pulse3_lsb <= 8'd0;
        pulse3_msb <= 4'd0;
        ctrl3 <= 8'd0;
        attack_decay3 <= 8'd0;
        sustain_release3 <= 8'd0;

        master_volume <= 8'd0;
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

            5'b00111: freq2_lsb <= data_i;
            5'b01000: freq2_msb <= data_i;
            5'b01001: pulse2_lsb <= data_i;
            5'b01010: pulse2_msb <= data_i[3:0];
            5'b01011: ctrl2 <= data_i;
            5'b01100: attack_decay2 <= data_i;
            5'b01101: sustain_release2 <= data_i;
        
            5'b01110: freq3_lsb <= data_i;
            5'b01111: freq3_msb <= data_i;
            5'b10000: pulse3_lsb <= data_i;
            5'b10001: pulse3_msb <= data_i[3:0];
            5'b10010: ctrl3 <= data_i;
            5'b10011: attack_decay3 <= data_i;
            5'b10100: sustain_release3 <= data_i;

            5'b10101: master_volume <= data_i;
        endcase
    end
end

// Create 1.5 MHz clock for audio
reg     [3:0]   audio_clkdiv;
wire            clk_1m5;
always @(posedge clkusb_i or negedge rst_n_i)
begin
    if(rst_n_i == 1'b0) audio_clkdiv <= 4'd0;
    else audio_clkdiv <= audio_clkdiv+1;
end

assign clk_1m5 = audio_clkdiv[3];

// Oscillator and ADSR #1
wire    [15:0]  osc1_out;
wire    [15:0]  adsr1_out;

oscillator osc1(
    .clk_i(clk_1m5),
    .rst_n(rst_n_i),
    .frequency({freq1_msb, freq1_lsb}),
    .duty_cycle({pulse1_msb, pulse1_lsb}),
    .pulse(ctrl1[6]),
    .sawtooth(ctrl1[5]),
    .triangle(ctrl1[4]),
    .noise(ctrl1[7]),
    .sound_o(osc1_out)
); 

adsr adsr1(
    .clk_i(clk_1m5),
    .rst_n(rst_n_i),
    .gate(ctrl1[0]),
    .att(attack_decay1[7:4]),
    .dec(attack_decay1[3:0]),
    .sus(sustain_release1[7:4]),
    .rel(sustain_release1[3:0]),
    .sound_i(osc1_out),
    .sound_o(adsr1_out)
);

// Oscillator and ADSR #2
wire    [15:0]  osc2_out;
wire    [15:0]  adsr2_out;

oscillator osc2(
    .clk_i(clk_1m5),
    .rst_n(rst_n_i),
    .frequency({freq2_msb, freq2_lsb}),
    .duty_cycle({pulse2_msb, pulse2_lsb}),
    .pulse(ctrl2[6]),
    .sawtooth(ctrl2[5]),
    .triangle(ctrl2[4]),
    .noise(ctrl2[7]),
    .sound_o(osc2_out)
); 

adsr adsr2(
    .clk_i(clk_1m5),
    .rst_n(rst_n_i),
    .gate(ctrl2[0]),
    .att(attack_decay2[7:4]),
    .dec(attack_decay2[3:0]),
    .sus(sustain_release2[7:4]),
    .rel(sustain_release2[3:0]),
    .sound_i(osc2_out),
    .sound_o(adsr2_out)
);

// Oscillator and ADSR #3
wire    [15:0]  osc3_out;
wire    [15:0]  adsr3_out;

oscillator osc3(
    .clk_i(clk_1m5),
    .rst_n(rst_n_i),
    .frequency({freq3_msb, freq3_lsb}),
    .duty_cycle({pulse3_msb, pulse3_lsb}),
    .pulse(ctrl3[6]),
    .sawtooth(ctrl3[5]),
    .triangle(ctrl3[4]),
    .noise(ctrl3[7]),
    .sound_o(osc3_out)
); 

adsr adsr3(
    .clk_i(clk_1m5),
    .rst_n(rst_n_i),
    .gate(ctrl3[0]),
    .att(attack_decay3[7:4]),
    .dec(attack_decay3[3:0]),
    .sus(sustain_release3[7:4]),
    .rel(sustain_release3[3:0]),
    .sound_i(osc3_out),
    .sound_o(adsr3_out)
);

// Mixer
wire [15:0] mixer_out;

mixer mixer_inst(
    .clk_i(clk_1m5),
    .rst_n(rst_n_i),
    .sound1_i(adsr1_out),
    .sound2_i(adsr2_out),
    .sound3_i(adsr3_out),
    .volume_i(master_volume),
    .sound_o(mixer_out)
);


// I2S output driver
wire output_req;
reg [15:0]  audio_data;

audio_drive drive(
    .clk_1p536m(clk_1m5),
    .rst_n(rst_n_i),
    .idata(audio_data),
    .req(output_req),
    .HP_BCK(HP_BCK),
    .HP_WS(HP_WS),
    .HP_DIN(HP_DIN)
);

always @(posedge clk_1m5 or negedge rst_n_i)
begin
    if(rst_n_i == 1'b0) audio_data <= 15'd0;
    else if(output_req == 1'b1) audio_data <= mixer_out;
end

endmodule