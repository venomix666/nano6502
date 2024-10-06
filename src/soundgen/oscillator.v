// Oscillator for a simple PSG, very SID inspired
// Copyright (C) 2024 Henrik Löfgren
// Assuming a base clock of 1.5 MHz as this works well with I2S (usbclock divided by 8)
module oscillator(
    input               clk_i,
    input               rst_n,
    input   [15:0]      frequency,
    input               pulse,
    input               sawtooth,
    input               triangle,
    input               noise,
    input   [11:0]      duty_cycle,
    output  [15:0]      sound_o      
);


reg     [23:0]      osc_counter;

// Main counter
always @(posedge clk_i or negedge rst_n)
begin
    if(rst_n == 1'b0)
    begin
        osc_counter <= 0;
    end
    else
    begin
        osc_counter <= osc_counter + frequency; // 440 Hz -> frequency = 4921
    end
end


// Sawtooth oscillator
reg     [15:0]      sawtooth_out;
assign sawtooth_out = osc_counter[23:8];


// Triangle wave oscillator
reg     [15:0]      triangle_out;
always @(posedge clk_i or negedge rst_n)
begin
    if(rst_n == 1'b0)
    begin
        triangle_out <= 0;
    end
    else
    begin
        if(osc_counter[23] == 1'b0) triangle_out <= osc_counter[22:7];
        else triangle_out <= 16'hffff - osc_counter[22:7];
    end
end

// Pulse wave oscillator
reg   pulse_out;

always @(posedge clk_i or negedge rst_n)
begin
    if(rst_n == 1'b0)
    begin
        pulse_out <= 0;
    end
    else
    begin
        if(osc_counter[23] == 0) pulse_out <= 0;
        else begin
            if(osc_counter[22:11] > duty_cycle) pulse_out <= 1;
            else pulse_out <= 0;
        end
    end
end

// Noise generator (LFSR)
reg     [15:0]     noise_out;

// LFSR feedback term 0xDA2A
wire noise_feedback = noise_out[15]^noise_out[14]^noise_out[12]^noise_out[11]^noise_out[9]^noise_out[5]^noise_out[3]^noise_out[1];

always @(posedge clk_i or negedge rst_n)
begin
    if(rst_n == 1'b0)
    begin
        noise_out <= 16'haaaa;
    end
    else
    begin
        if(osc_counter == 24'd0) noise_out <= {noise_out[14:0], noise_feedback};
    end
end


// Mixer
assign sound_o[0] = (sawtooth_out[0] & sawtooth) | (triangle_out[0] & triangle) | (pulse_out & pulse) | (noise_out[0] & noise);
assign sound_o[1] = (sawtooth_out[1] & sawtooth) | (triangle_out[1] & triangle) | (pulse_out & pulse) | (noise_out[1] & noise);
assign sound_o[2] = (sawtooth_out[2] & sawtooth) | (triangle_out[2] & triangle) | (pulse_out & pulse) | (noise_out[2] & noise);
assign sound_o[3] = (sawtooth_out[3] & sawtooth) | (triangle_out[3] & triangle) | (pulse_out & pulse) | (noise_out[3] & noise);

assign sound_o[4] = (sawtooth_out[4] & sawtooth) | (triangle_out[4] & triangle) | (pulse_out & pulse) | (noise_out[4] & noise);
assign sound_o[5] = (sawtooth_out[5] & sawtooth) | (triangle_out[5] & triangle) | (pulse_out & pulse) | (noise_out[5] & noise);
assign sound_o[6] = (sawtooth_out[6] & sawtooth) | (triangle_out[6] & triangle) | (pulse_out & pulse) | (noise_out[6] & noise);
assign sound_o[7] = (sawtooth_out[7] & sawtooth) | (triangle_out[7] & triangle) | (pulse_out & pulse) | (noise_out[7] & noise);

assign sound_o[8] = (sawtooth_out[8] & sawtooth) | (triangle_out[8] & triangle) | (pulse_out & pulse) | (noise_out[8] & noise);
assign sound_o[9] = (sawtooth_out[9] & sawtooth) | (triangle_out[9] & triangle) | (pulse_out & pulse) | (noise_out[9] & noise);
assign sound_o[10] = (sawtooth_out[10] & sawtooth) | (triangle_out[10] & triangle) | (pulse_out & pulse) | (noise_out[10] & noise);
assign sound_o[11] = (sawtooth_out[11] & sawtooth) | (triangle_out[11] & triangle) | (pulse_out & pulse) | (noise_out[11] & noise);

assign sound_o[12] = (sawtooth_out[12] & sawtooth) | (triangle_out[12] & triangle) | (pulse_out & pulse) | (noise_out[12] & noise);
assign sound_o[13] = (sawtooth_out[13] & sawtooth) | (triangle_out[13] & triangle) | (pulse_out & pulse) | (noise_out[13] & noise);
assign sound_o[14] = (sawtooth_out[14] & sawtooth) | (triangle_out[14] & triangle) | (pulse_out & pulse) | (noise_out[14] & noise);
assign sound_o[15] = (sawtooth_out[15] & sawtooth) | (triangle_out[15] & triangle) | (pulse_out & pulse) | (noise_out[15] & noise);

endmodule