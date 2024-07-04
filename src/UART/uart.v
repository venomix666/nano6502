module uart(
	input                        clk,
	input                        rst_n,
    input       [7:0]            data_i,
	input                        uart_rx,
    input                        uart_cs,
    input                        R_W_n,
    input       [1:0]            reg_addr,
    output      [7:0]            data_o,
	output                       uart_tx
);

parameter                        CLK_FRE  = 25.175;//Mhz
parameter                        UART_FRE = 115200;//Mhz

reg[7:0]                         tx_data;

reg                              tx_data_valid;
wire                             tx_data_ready;

wire[7:0]                        rx_data;
reg [7:0]                        rx_data_reg;
reg                              rx_data_avail;
wire                             rx_data_valid;
wire                             rx_data_ready;

assign rx_data_ready = 1'b1;//always can receive data,

// Registers for PCU axess

reg                             rx_avail;
reg                             tx_done;
reg [7:0]                       data_o_reg;


always@(posedge clk or negedge rst_n)
begin
    if(rst_n == 1'b0)
    begin
        tx_data <= 8'h00;
        tx_done <= 1'b1;
        tx_data_valid <= 1'b0;
    end
    // TX handling
    else if(tx_data_valid && tx_data_ready) 
    begin
        tx_done <= 1'b1; 
        tx_data_valid <= 1'b0;
    end
    else if(uart_cs)
    begin
        //case(reg_addr)
            if(reg_addr==2'b00 && !R_W_n)
            begin
                //if(!rw_dly)
                //begin
                    tx_done <= 1'b0;
                    tx_data <= data_i;
                    tx_data_valid <= 1'b1;
                //end
                /*else
                begin
                    data_o_reg <= tx_data;
                end*/
            end
            /*2'b01:
                data_o_reg <= {7'd0, tx_data_ready};
            2'b10:
            begin
                data_o_reg <= rx_data_reg;
                
            end
            2'b11:
            begin
                data_o_reg <= {7'd0, rx_data_avail}; 
            end*/
        //endcase
    end
    else
    begin
        tx_data_valid <= 1'b0;
    end

  

    
end

always@(*)
begin
    //if(rst_n == 1'b0) data_o_reg <= 8'd0;
    //else
    //begin
        case (reg_addr)
            2'b00: data_o_reg <= tx_data;
            2'b01: data_o_reg <= {7'd0, tx_data_ready};
            2'b10: data_o_reg <= rx_data_reg;
            2'b11: data_o_reg <= {7'd0, rx_data_avail}; 
        endcase
    //end
end


always@(posedge clk or negedge rst_n)
begin
    if(rst_n == 1'b0)
    begin
        rx_data_reg <= 8'd0;
        rx_data_avail <= 1'b0;
    end
    // Latch rx data and status
    else if(rx_data_valid)
    begin
        rx_data_reg <= rx_data;
        rx_data_avail <= 1'b1;
    end
    else if((reg_addr == 2'b10) && (uart_cs))
    begin
        rx_data_avail <= 1'b0;
    end
end

assign data_o = data_o_reg;

/*
always@(posedge clk or negedge rst_n)
begin
	if(rst_n == 1'b0)
	begin
		wait_cnt <= 32'd0;
		tx_data <= 8'd0;
		state <= IDLE;
		tx_cnt <= 8'd0;
		tx_data_valid <= 1'b0;
	end
	else
	case(state)
		IDLE:
			state <= SEND;
		SEND:
		begin
			wait_cnt <= 32'd0;
			tx_data <= tx_str;

			if(tx_data_valid == 1'b1 && tx_data_ready == 1'b1 && tx_cnt < DATA_NUM - 1)//Send 12 bytes data
			begin
				tx_cnt <= tx_cnt + 8'd1; //Send data counter
			end
			else if(tx_data_valid && tx_data_ready)//last byte sent is complete
			begin
				tx_cnt <= 8'd0;
				tx_data_valid <= 1'b0;
				state <= WAIT;
			end
			else if(~tx_data_valid)
			begin
				tx_data_valid <= 1'b1;
			end
		end
		WAIT:
		begin
			wait_cnt <= wait_cnt + 32'd1;

			if(rx_data_valid == 1'b1)
			begin
				tx_data_valid <= 1'b1;
				tx_data <= rx_data;   // send uart received data
			end
			else if(tx_data_valid && tx_data_ready)
			begin
				tx_data_valid <= 1'b0;
			end
			else if(wait_cnt >= CLK_FRE * 1000_000) // wait for 1 second
				state <= SEND;
		end
		default:
			state <= IDLE;
	endcase
end
*/
//combinational logic

uart_rx#
(
	.CLK_FRE(CLK_FRE),
	.BAUD_RATE(UART_FRE)
) uart_rx_inst
(
	.clk                        (clk                      ),
	.rst_n                      (rst_n                    ),
	.rx_data                    (rx_data                  ),
	.rx_data_valid              (rx_data_valid            ),
	.rx_data_ready              (rx_data_ready            ),
	.rx_pin                     (uart_rx                  )
);

uart_tx#
(
	.CLK_FRE(CLK_FRE),
	.BAUD_RATE(UART_FRE)
) uart_tx_inst
(
	.clk                        (clk                      ),
	.rst_n                      (rst_n                    ),
	.tx_data                    (tx_data                  ),
	.tx_data_valid              (tx_data_valid            ),
	.tx_data_ready              (tx_data_ready            ),
	.tx_pin                     (uart_tx                  )
);
endmodule