// nano6502 address decoder
//
// Address decoding and special ZP registers

module addr_decoder(
	input               clk_i,
	input               rst_n_i,
    input               R_W_n,
	input   [15:0]      addr_i,
    input   [7:0]       data_i,
    output  [7:0]       data_o,
    // RAM
    output              ram_cs,
    output              ram_we,
    // UART
    output              uart_cs,
    // ROM
    output              rom_cs,
    output [7:0]        leds
);

reg     [7:0]       io_bank_l;
reg     [7:0]       io_bank_h;
reg     [7:0]       rom_sel;
reg     [7:0]       data_o_reg;
reg                 ram_cs_reg;
reg                 uart_cs_reg;
reg                 rom_cs_reg;
reg     [7:0]       led_reg;
reg     [7:0]       dummy_reg;
// Register writing, synchronous
always@(posedge clk_i or negedge rst_n_i)
begin
    if(rst_n_i == 1'b0)
	begin
        io_bank_l <= 8'd0;
        io_bank_h <= 8'd0;
        rom_sel <= 8'd0;
        led_reg <= 8'd0;
    end
    else if(R_W_n == 1'b0)
    case(addr_i)
        16'h0000: io_bank_l <= data_i;
        16'h0001: io_bank_h <= data_i;
        16'h0002: rom_sel <= data_i;
        16'h0003: led_reg <= data_i;
        default: dummy_reg <= data_i;
    endcase
end

// Address decoding, combinatorial mux
always @(*) begin
    if(addr_i == 16'h0000) 
    begin
        data_o_reg = io_bank_l;
        ram_cs_reg = 1'b0;
        uart_cs_reg = 1'b0;
        rom_cs_reg = 1'b0;
    end
    else if(addr_i == 16'h0001) 
    begin    
        data_o_reg = io_bank_h;
        ram_cs_reg = 1'b0;
        uart_cs_reg = 1'b0;
        rom_cs_reg = 1'b0;
    end
    else if(addr_i == 16'h0002)
    begin
        data_o_reg = rom_sel;
        ram_cs_reg = 1'b0;
        uart_cs_reg = 1'b0;
        rom_cs_reg = 1'b0;
    end
    else if((addr_i >= 16'hfe00) && (addr_i < 16'hff00))
    begin
        if(io_bank_l == 8'h01)
        begin
            uart_cs_reg = 1'b1;
            ram_cs_reg = 1'b0;
            rom_cs_reg = 1'b0;
        end
        else
        begin
            uart_cs_reg = 1'b0;
            ram_cs_reg = 1'b1;
            rom_cs_reg = 1'b0;
        end
        data_o_reg = 8'd0;
    end
    else if((addr_i >= 16'he000) && (addr_i < 16'hffff) && (rom_sel == 8'd0))
    begin
        uart_cs_reg = 1'b0;
        ram_cs_reg = 1'b0;
        rom_cs_reg = 1'b1;
        data_o_reg = 8'd0;
    end
    else
    begin
        data_o_reg = 8'd0;
        ram_cs_reg = 1'b1;
        rom_cs_reg = 1'b0;
        uart_cs_reg = 1'b0;
    end
end

assign data_o = data_o_reg;
assign ram_cs = ram_cs_reg;
assign uart_cs = uart_cs_reg;
assign rom_cs = rom_cs_reg;
assign leds = led_reg;

// Write enable generation
assign ram_we = ram_cs && ~R_W_n;

endmodule