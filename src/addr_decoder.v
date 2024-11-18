// nano6502 address decoder
//
// Address decoding and special ZP registers

module addr_decoder(
	input               clk_i,
	input               rst_n_i,
    input               R_W_n,
	input   [15:0]      addr_i,
    input   [15:0]      addr_w_i,
    input   [7:0]       data_i,
    output  [7:0]       data_o,
    // RAM
    output              ram_cs,
    output              ram_we,
    // UART
    output              uart_cs,
    // ROM
    output              rom_cs,
    output              addr_dec_cs,
    output              led_cs,
    output              sd_cs,
    output              video_cs,
    output              timer_cs,
    output              usb_cs,
    output              gpio_cs,
    output              soundgen_cs
);

reg     [7:0]       io_bank_l;
reg     [7:0]       io_bank_h;
reg     [7:0]       rom_sel;
reg     [7:0]       data_o_reg;
reg                 ram_cs_reg;
reg                 uart_cs_reg;
reg                 rom_cs_reg;
reg                 led_cs_reg;
reg                 sd_cs_reg;
reg                 video_cs_reg;
reg                 timer_cs_reg;
reg                 usb_cs_reg;
reg                 gpio_cs_reg;
reg                 soundgen_cs_reg;
reg                 addr_dec_cs_reg;
reg     [7:0]       dummy_reg;

// Register writing, synchronous
always@(posedge clk_i or negedge rst_n_i)
begin
    if(rst_n_i == 1'b0)
	begin
        io_bank_l <= 8'd0;
        io_bank_h <= 8'd0;
        rom_sel <= 8'd0;
    end
    else if(R_W_n == 1'b0)
    case(addr_i)
        16'h0000: io_bank_l <= data_i;
        16'h0001: io_bank_h <= data_i;
        16'h0002: rom_sel <= data_i;
        //16'h0003: led_reg <= data_i;
        default: dummy_reg <= data_i;
    endcase
end

// Address decoding, combinatorial mux
always @(*) begin
    // Default values - nothing selected
    data_o_reg = 8'd0;
    ram_cs_reg = 1'b0;
    rom_cs_reg = 1'b0;
    uart_cs_reg = 1'b0;
    led_cs_reg = 1'b0;
    sd_cs_reg = 1'b0;
    video_cs_reg = 1'b0;
    timer_cs_reg = 1'b0;
    usb_cs_reg = 1'b0;
    gpio_cs_reg = 1'b0;
    soundgen_cs_reg = 1'b0;
    addr_dec_cs_reg = 1'b0;
    
    // IO bank low
    if(addr_w_i == 16'h0000) 
    begin
        data_o_reg = io_bank_l;
        addr_dec_cs_reg = 1'b1;
    end
    // IO bank high
    else if(addr_w_i == 16'h0001) 
    begin    
        data_o_reg = io_bank_h;
        addr_dec_cs_reg = 1'b1;
    end
    // ROM select
    else if(addr_w_i == 16'h0002)
    begin
        data_o_reg = rom_sel;
        addr_dec_cs_reg = 1'b1;
    end
    // IO space
    else if((addr_w_i >= 16'hfe00) && (addr_w_i < 16'hff00))
    begin
        case(io_bank_l)
            8'h00: rom_cs_reg = 1'b1;       // ROM
            8'h01: uart_cs_reg = 1'b1;      // UART
            8'h02: led_cs_reg = 1'b1;       // LEDs
            8'h03: sd_cs_reg = 1'b1;        // SD-card
            8'h04: video_cs_reg = 1'b1;     // Video
            8'h05: timer_cs_reg = 1'b1;     // Timer
            8'h06: usb_cs_reg = 1'b1;       // USB
            8'h07: gpio_cs_reg = 1'b1;      // GPIO
            8'h08: soundgen_cs_reg = 1'b1;  // Sound
            default: ram_cs_reg = 1'b1;     // RAM
        endcase
        
    end
    // Enable ROM
    else if((addr_w_i >= 16'he000) && (addr_w_i < 16'hffff) && (rom_sel == 8'd0))
    begin
        rom_cs_reg = 1'b1;
    end
    // Switch out ROM for RAM
    else
    begin
        ram_cs_reg = 1'b1;
    end
end

assign data_o = data_o_reg;
assign ram_cs = ram_cs_reg;
assign uart_cs = uart_cs_reg;
assign rom_cs = rom_cs_reg;
assign addr_dec_cs = addr_dec_cs_reg;
assign led_cs = led_cs_reg;
assign sd_cs = sd_cs_reg;
assign video_cs = video_cs_reg;
assign timer_cs = timer_cs_reg;
assign usb_cs = usb_cs_reg;
assign gpio_cs = gpio_cs_reg;
assign soundgen_cs = soundgen_cs_reg;

// Write enable generation
assign ram_we = ram_cs && ~R_W_n;

endmodule