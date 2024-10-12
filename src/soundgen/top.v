// Testbench for the nano6502 sound generator

module top
(
    input clk_i,
    input rst_n_i,
    input [7:0] freq1_lsb,
    input [7:0] freq1_msb,
    input [7:0] pulse1_lsb,
    input [3:0] pulse1_msb,
    input [7:0] ctrl1,
    input [7:0] attack_decay1,
    input [7:0] sustain_release1,
    input [7:0] freq2_lsb,
    input [7:0] freq2_msb,
    input [7:0] pulse2_lsb,
    input [3:0] pulse2_msb,
    input [7:0] ctrl2,
    input [7:0] attack_decay2,
    input [7:0] sustain_release2,
    input [7:0] freq3_lsb,
    input [7:0] freq3_msb,
    input [7:0] pulse3_lsb,
    input [3:0] pulse3_msb,
    input [7:0] ctrl3,
    input [7:0] attack_decay3,
    input [7:0] sustain_release3,
    input [7:0] mixer_volume
);

    wire [15:0] osc1_out;
    wire [15:0] adsr1_out;

    wire [15:0] osc2_out;
    wire [15:0] adsr2_out;
    
    wire [15:0] osc3_out;
    wire [15:0] adsr3_out;

    wire [15:0] mixer_out;

    oscillator osc1(
        .clk_i(clk_i),
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
        .clk_i(clk_i),
        .rst_n(rst_n_i),
        .gate(ctrl1[0]),
        .att(attack_decay1[7:4]),
        .dec(attack_decay1[3:0]),
        .sus(sustain_release1[7:4]),
        .rel(sustain_release1[3:0]),
        .sound_i(osc1_out),
        .sound_o(adsr1_out)
    );

   oscillator osc2(
        .clk_i(clk_i),
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
        .clk_i(clk_i),
        .rst_n(rst_n_i),
        .gate(ctrl2[0]),
        .att(attack_decay2[7:4]),
        .dec(attack_decay2[3:0]),
        .sus(sustain_release2[7:4]),
        .rel(sustain_release2[3:0]),
        .sound_i(osc2_out),
        .sound_o(adsr2_out)
    );

    oscillator osc3(
        .clk_i(clk_i),
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
        .clk_i(clk_i),
        .rst_n(rst_n_i),
        .gate(ctrl3[0]),
        .att(attack_decay3[7:4]),
        .dec(attack_decay3[3:0]),
        .sus(sustain_release3[7:4]),
        .rel(sustain_release3[3:0]),
        .sound_i(osc3_out),
        .sound_o(adsr3_out)
    );


    mixer mixer_inst(
        .clk_i(clk_i),
        .rst_n(rst_n_i),
        .sound1_i(adsr1_out),
        .sound2_i(adsr2_out),
        .sound3_i(adsr3_out),
        .volume_i(mixer_volume),
        .sound_o(mixer_out)
    );

    // I2S output driver
    wire output_req;
    reg [15:0]  audio_data;
    wire HP_BCK;
    wire HP_WS;
    wire HP_DIN;

    audio_drive drive(
        .clk_1p536m(clk_i),
        .rst_n(rst_n_i),
        .idata(audio_data),
        .req(output_req),
        .HP_BCK(HP_BCK),
        .HP_WS(HP_WS),
        .HP_DIN(HP_DIN)
    );

    always @(posedge clk_i or negedge rst_n_i)
    begin
        if(rst_n_i == 1'b0) audio_data <= 15'd0;
        else if(output_req == 1'b1) audio_data <= mixer_out;
    end


    initial begin
        if($test$plusargs("trace") != 0) begin
            $display("[%0t] Tracing to logs/vlt_dump.vcd...\n", $time);
            $dumpfile("logs/vltdump.vcd");
            $dumpvars();
        end
        $display("[%0t] Model running...\n", $time);
    end

    always_ff @ (posedge clk_i) begin
        if($time > 1000000) begin
            $write("*-* All Finished *-*\n");
            $finish;
        end
    end
endmodule
