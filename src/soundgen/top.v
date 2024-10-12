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
    input [7:0] sustain_release1
);

    wire [15:0] osc1_out;
    wire [15:0] adsr1_out;

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
