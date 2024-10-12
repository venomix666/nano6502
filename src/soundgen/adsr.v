// ADSR for a simple PSG
// Copyright (C) 2024 Henrik Löfgren
// Assuming a base clock of 1.5 MHz as this works well with I2S (usbclock divided by 8)

module adsr(
    input               clk_i,
    input               rst_n,
    input               gate,
    input   [3:0]       att,
    input   [3:0]       dec,
    input   [3:0]       sus,
    input   [3:0]       rel,
    input   [15:0]      sound_i,
    output  [15:0]      sound_o      
);

reg       [7:0] envelope;


// Cycles between each addition/subtraction to envelope
// Same constants used for decay and release for now (On the SID they are 3 times slower)
wire [15:0] attack_table[16]; 
assign attack_table =                '{16'h000C, 16'h002F, 16'h005E, 16'h008D,
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
reg     [23:0]  sound_o_next;

wire    [7:0]   sustain_level;

assign  sustain_level = {sus, sus};

always @(posedge clk_i or negedge rst_n)
begin
    if(rst_n == 1'b0)
    begin
        envelope <= 8'd0;
        adsr_counter <= 8'd0;
        decay_counter <= 8'd0;
        state <= ATTACK_ST;
    end
    else
    begin
        case(state)
        ATTACK_ST: begin
            if(!gate) begin
                state <= RELEASE_ST;
                adsr_counter <= 16'd0;
            end
            else begin
                if(adsr_counter == attack_table[att]) begin
                    adsr_counter <= 16'd0;
                    if(envelope == 8'hff) state <= DECAY_ST;
                    else envelope <= envelope + 1;
                end
                else adsr_counter <= adsr_counter + 1;
            end
        end
        DECAY_ST: begin
            if(!gate) begin
                state <= RELEASE_ST;
                adsr_counter <= 16'd0;
            end
            else begin
                if(adsr_counter == attack_table[dec]) begin
                    adsr_counter <= 16'd0;
                    if(envelope <= sustain_level) state <= SUSTAIN_ST;
                    else envelope <= envelope - 1;
                end
                else adsr_counter <= adsr_counter + 1;
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
                if(adsr_counter == attack_table[rel]) begin
                        if(envelope != 0) envelope <= envelope - 1;
                        adsr_counter <= 0;
                end
                else adsr_counter <= adsr_counter + 1;
            end  
        end
        endcase
    end
end

// Audio output
always @(posedge clk_i or negedge rst_n)
begin
    if(rst_n == 1'b0) begin
        sound_o_next <= 16'd0;
    end
    else begin
        sound_o_next <= envelope * sound_i;
    end
end

assign sound_o = {2'b00, sound_o_next[23:10]};

endmodule
