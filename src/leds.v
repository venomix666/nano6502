// Simple core to control the LEDs and the WS2812 on the Tang Nano 20K board
//
// Registers:
// 00       LEDs
// 01       WS2812_R
// 02       WS2812_G
// 03       WS2812_B

module leds(
	input               clk_i,
	input               rst_n_i,
    input               R_W_n,
	input   [1:0]      reg_addr_i,
    input   [7:0]       data_i,
    input               led_cs,
    output  [7:0]       data_o,
    output  [7:0]       leds,
    output   reg        ws2812
);

parameter WS2812_NUM    = 0             ; // LED number of WS2812 (starts from 0)
parameter WS2812_WIDTH  = 24            ; // WS2812 data bit width
parameter CLK_FRE               = 27_000_000    ; // CLK frequency (mHZ)

parameter DELAY_1_HIGH  = (CLK_FRE / 1_000_000 * 0.85 )  - 1; //≈850ns±150ns    1 high level time
parameter DELAY_1_LOW   = (CLK_FRE / 1_000_000 * 0.40 )  - 1; //≈400ns±150ns    1 low level time
parameter DELAY_0_HIGH  = (CLK_FRE / 1_000_000 * 0.40 )  - 1; //≈400ns±150ns    0 high level time
parameter DELAY_0_LOW   = (CLK_FRE / 1_000_000 * 0.85 )  - 1; //≈850ns±150ns    0 low level time
//parameter DELAY_RESET   = (CLK_FRE / 10 ) - 1; //0.1s reset time ＞50us

parameter IDLE                         = 0; //state machine statement
parameter DATA_SEND             = 1;
parameter BIT_SEND_HIGH         = 2;
parameter BIT_SEND_LOW          = 3;

//parameter INIT_DATA = 24'b1111; // initial pattern

reg [ 1:0] state       = 0; // synthesis preserve  - main state machine control
reg [ 8:0] bit_send    = 0; // number of bits sent - increase for larger led strips/matrix
reg [ 8:0] data_send   = 0; // number of data sent - increase for larger led strips/matrix
reg [31:0] clk_count   = 0; // delay control
reg [23:0] WS2812_data; // WS2812 color data

reg [7:0]   led_reg;
reg [7:0]   data_o_reg;
reg [7:0]   r_reg;
reg [7:0]   g_reg;
reg [7:0]   b_reg;
reg         ws2812_start;


// LED register writing, IO page 0x02
always @(posedge clk_i or negedge rst_n_i)
begin
    if(rst_n_i == 1'b0)
    begin
        led_reg <= 8'd0;
        ws2812_start <= 1'b0;
        r_reg <= 8'd0;
        g_reg <= 8'd0;
        b_reg <= 8'd0;
    end
    else if((led_cs) && (reg_addr_i == 2'b00) && (!R_W_n))
    begin
        led_reg <= data_i;
    end
    else if((led_cs) && (reg_addr_i == 2'b01) && (!R_W_n))
    begin
        //WS2812_data[15:8] = data_i;
        r_reg = data_i;
        ws2812_start <= 1'b1;
    end
    else if((led_cs) && (reg_addr_i == 2'b10) && (!R_W_n))
    begin
        //WS2812_data[7:0] = data_i;
        g_reg = data_i;
        ws2812_start <= 1'b1;
    end
    else if((led_cs) && (reg_addr_i == 2'b11) && (!R_W_n))
    begin
        //WS2812_data[23:16] = data_i;
        b_reg = data_i;
        ws2812_start <= 1'b1;
    end
    else
    begin
        ws2812_start <= 1'b0;
    end
end

// Assemble data to WS2812 with reversed bits
assign WS2812_data = {b_reg[0], b_reg[1], b_reg[2], b_reg[3], b_reg[4], b_reg[5], b_reg[6], b_reg[7],
                      r_reg[0], r_reg[1], r_reg[2], r_reg[3], r_reg[4], r_reg[5], r_reg[6], r_reg[7],
                      g_reg[0], g_reg[1], g_reg[2], g_reg[3], g_reg[4], g_reg[5], g_reg[6], g_reg[7]};

always @(*)
begin
    case(reg_addr_i)
        2'b00: data_o_reg = led_reg;
        2'b01: data_o_reg = r_reg;
        2'b10: data_o_reg = g_reg;
        2'b11: data_o_reg = b_reg;
        default: data_o_reg = 8'd0;
    endcase
end

always@(posedge clk_i or negedge rst_n_i)
begin
    if(rst_n_i == 1'b0)
    begin
        ws2812 <= 0;
        state <= IDLE;
    end
    else
    begin
	case (state)
		IDLE:begin
			ws2812 <= 0;
			
			if(ws2812_start) begin
				clk_count <= 0;
               	state <= DATA_SEND;
			end
		end

		DATA_SEND:
			if (data_send > WS2812_NUM && bit_send == WS2812_WIDTH)begin 
                clk_count <= 0;
				data_send <= 0;
				bit_send  <= 0;
				state <= IDLE;
			end 
			else if (bit_send < WS2812_WIDTH) begin
				state    <= BIT_SEND_HIGH;
			end
			else begin
				data_send <= data_send + 1;
				bit_send  <= 0;
				state    <= BIT_SEND_HIGH;
			end
			
		BIT_SEND_HIGH:begin
			ws2812 <= 1;

			if (WS2812_data[bit_send]) 
				if (clk_count < DELAY_1_HIGH)
					clk_count <= clk_count + 1;
				else begin
					clk_count <= 0;
					state    <= BIT_SEND_LOW;
				end
			else 
				if (clk_count < DELAY_0_HIGH)
					clk_count <= clk_count + 1;
				else begin
					clk_count <= 0;
					state    <= BIT_SEND_LOW;
				end
		end

		BIT_SEND_LOW:begin
			ws2812 <= 0;

			if (WS2812_data[bit_send]) 
				if (clk_count < DELAY_1_LOW) 
					clk_count <= clk_count + 1;
				else begin
					clk_count <= 0;

					bit_send <= bit_send + 1;
					state    <= DATA_SEND;
				end
			else 
				if (clk_count < DELAY_0_LOW) 
					clk_count <= clk_count + 1;
				else begin
					clk_count <= 0;
					
					bit_send <= bit_send + 1;
					state    <= DATA_SEND;
				end
		end
	endcase
    end
end

assign leds = led_reg;
assign data_o = data_o_reg;
endmodule