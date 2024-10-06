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

reg       [7:0] envelope;


// Cycles between each addition/subtraction to envelope
// Same constants used for decay and release for now (On the SID they are 3 times slower)
const bit [15:0] attack_table =  '{16'h000C, 16'h002F, 16'h005E, 16'h008D,
                                   16'h00DF, 16'h0148, 16'h018E, 16'h01D5,
                                   16'h024A, 16'h05B9, 16'h0B72, 16'h1250,
                                   16'h16E3, 16'h44AA, 16'h7271, 16'hB71B};




parameter ATTACK_ST    = 2'd0;
parameter DECAY_ST     = 2'd1;
parameter SUSTAIN_ST   = 2'd2; 
parameter RELEASE_ST   = 3'd3;

reg     [15:0]  adsr_counter;
reg     [1:0]   decay_counter;
reg     [1:0]   state;

wire    [7:0]   sustain_level;

assign  sustain_level = {sustain, sustain};

always @(posedge clk_i or negedge rst_n_i)
begin
    if(rst_n_i == 1'b0)
    begin
        envelope <= 8'd0;
        adsr_counter <= 8'd0;
        decay_counter <= 8'd0;
        state <= ATTACK_ST;
    end
    else
    begin
        case state
        ATTACK_ST: begin
            if(!gate) begin
                state <= RELEASE_ST;
                adsr_counter <= 16'd0;
            end
            else begin
                if(adsr_counter == 16'd0) begin
                    if(envelope == 8'hff) state <= DECAY_ST;
                    else begin
                        envelope <= envelope + 1;
                        adsr_counter <= attack_table[attack];
                    end
                end
                else adsr_counter <= adsr_counter - 1;
            end
        end
        DECAY_ST: begin
            if(!gate) begin
                state <= RELEASE_ST;
                adsr_counter <= 16'd0;
            end
            else begin
                if(adsr_counter == 16'd0) begin
                    if(envelope == sustain_level) state <= SUSTAIN_ST;
                    else begin
                        envelope <= envelope - 1;
                        adsr_counter <= attack_table[decay];
                    end
                end
                else adsr_counter <= adsr_counter - 1;
            end 
        end
        SUSTAIN_ST: begin
            if(!gate) state <= RELEASE_ST;
            envelope <= sustain_level;
        end
        RELEASE_ST: begin
            if(gate) begin
                state <= ATTACK_ST;
                adsr_counter <= 16'd0;
            end
            else begin
                if(adsr_counter == 16'd0) begin             
                        if(envelope != 0) envelope <= envelope - 1;
                        adsr_counter <= attack_table[release];
                end
                else adsr_counter <= adsr_counter - 1;
            end  
        end
        endcase
    end
end

// Audio output
assign audio_out = 16'(24'(envelope * audio_in)>>8);
endmodule