// GPIO core for the nano6502
//
// Registers:
// 00       Data register 1 (GPIO 0-7)
// 01       Data register 2 (GPIO 8-12)
// 02       Direction register 1 (GPIO 0-7), 0 = Input, 1=Output
// 03       Direction register 2 (GPIO 8-12), 0 = Input, 1=Output

module gpio(
	input               clk_i,
	input               rst_n_i,
    input               R_W_n,
	input   [1:0]       reg_addr_i,
    input   [7:0]       data_i,
    input               gpio_cs,
    output  [7:0]       data_o,
    inout  [12:0]       gpio
);

reg     [12:0]          gpio_out;
reg     [12:0]          gpio_direction;
reg     [7:0]           data_o_reg;

always @(*)
begin
        case(reg_addr_i)
            2'b00: data_o_reg = gpio[7:0];
            2'b01: data_o_reg = {3'd0, gpio[12:8]};
            2'b10: data_o_reg = gpio_direction[7:0];
            2'b11: data_o_reg = {3'd0, gpio_direction[12:8]};
            default: data_o_reg = 8'd0;
        endcase
end

always @(posedge clk_i or negedge rst_n_i)
begin
    if(rst_n_i == 1'b0)
    begin
        gpio_direction <= 12'd0;
        gpio_out <= 12'd0;
    end
    else if(gpio_cs && !R_W_n)
    begin
        case(reg_addr_i)
            2'b00: gpio_out[7:0] <= data_i;
            2'b01: gpio_out[12:8] <= data_i[4:0];
            2'b10: gpio_direction[7:0] <= data_i;
            2'b11: gpio_direction[12:8] <= data_i[4:0];
        endcase
    end
end

assign data_o = data_o_reg;

assign gpio[0] = gpio_direction[0] ? gpio_out[0] : 1'bZ;
assign gpio[1] = gpio_direction[1] ? gpio_out[1] : 1'bZ;
assign gpio[2] = gpio_direction[2] ? gpio_out[2] : 1'bZ;
assign gpio[3] = gpio_direction[3] ? gpio_out[3] : 1'bZ;
assign gpio[4] = gpio_direction[4] ? gpio_out[4] : 1'bZ;
assign gpio[5] = gpio_direction[5] ? gpio_out[5] : 1'bZ;
assign gpio[6] = gpio_direction[6] ? gpio_out[6] : 1'bZ;
assign gpio[7] = gpio_direction[7] ? gpio_out[7] : 1'bZ;
assign gpio[8] = gpio_direction[8] ? gpio_out[8] : 1'bZ;
assign gpio[9] = gpio_direction[9] ? gpio_out[9] : 1'bZ;
assign gpio[10] = gpio_direction[10] ? gpio_out[10] : 1'bZ;
assign gpio[11] = gpio_direction[11] ? gpio_out[11] : 1'bZ;
assign gpio[12] = gpio_direction[12] ? gpio_out[12] : 1'bZ;

endmodule