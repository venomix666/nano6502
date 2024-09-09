module uart(
	input                        clk,
	input                        rst_n,
    input       [7:0]            data_i,
	input                        uart_rx,
    input                        uart_cs,
    input                        uart_b_rx,
    input                        R_W_n,
    input       [3:0]            reg_addr,
    output      [7:0]            data_o,
	output                       uart_tx,
    output                       uart_b_tx
);

/*
0xfe00: TX data - write to initiate transmission
0xfe01: TX ready - UART is ready to accept a new TX byte
0xfe02: RX data
0xfe03: RX data available - high if a new byte is available in RX data
0xfe04: TX data B
0xfe05: TX ready B
0xfe06: RX data B
0xfe07: RX data available B
0xfe08: UART B baud rate
*/

parameter                        CLK_FRE  = 25.175;//Mhz
parameter                        UART_FRE = 115200;
//parameter                        UART_B_FRE = 9600;

reg[7:0]                         tx_data;

reg                              tx_data_valid;
wire                             tx_data_ready;

reg[7:0]                         tx_b_data;

reg                              tx_b_data_valid;
wire                             tx_b_data_ready;

wire[7:0]                        rx_data;
reg [7:0]                        rx_data_reg;
reg                              rx_data_avail;
wire                             rx_data_valid;
wire                             rx_data_ready;

wire[7:0]                        rx_b_data;
reg [7:0]                        rx_b_data_reg;
reg                              rx_b_data_avail;
wire                             rx_b_data_valid;
wire                             rx_b_data_ready;

assign rx_data_ready = 1'b1;//always can receive data,
assign rx_b_data_ready = 1'b1;

// Registers for CPU interface

reg                             rx_avail;
reg                             tx_done;
reg [7:0]                       data_o_reg;

reg                             rx_b_avail;
reg                             tx_b_done;
reg [7:0]                       data_b_o_reg;
reg [2:0]                       uart_b_baud;

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
        if(reg_addr==4'b0000 && !R_W_n)
        begin
                tx_done <= 1'b0;
                tx_data <= data_i;
                tx_data_valid <= 1'b1;
        end
    end
    else
    begin
        tx_data_valid <= 1'b0;
    end 
end

always@(posedge clk or negedge rst_n)
begin
    if(rst_n == 1'b0)
    begin
        tx_b_data <= 8'h00;
        tx_b_done <= 1'b1;
        tx_b_data_valid <= 1'b0;
        uart_b_baud <= 3'd1; // 9600 default baudrate
    end
    // TX handling
    else if(tx_b_data_valid && tx_b_data_ready) 
    begin
        tx_b_done <= 1'b1; 
        tx_b_data_valid <= 1'b0;
    end
    else if(uart_cs)
    begin
        if(reg_addr==4'b0100 && !R_W_n)
        begin
                tx_b_done <= 1'b0;
                tx_b_data <= data_i;
                tx_b_data_valid <= 1'b1;
        end
        else if(reg_addr==4'b1000 && !R_W_n)
        begin
            uart_b_baud <= data_i[2:0];
        end
    end
    else
    begin
        tx_b_data_valid <= 1'b0;
    end 
end

always@(*)
begin
        case (reg_addr)
            4'b0000: data_o_reg <= tx_data;
            4'b0001: data_o_reg <= {7'd0, tx_data_ready};
            4'b0010: data_o_reg <= rx_data_reg;
            4'b0011: data_o_reg <= {7'd0, rx_data_avail}; 
            4'b0100: data_o_reg <= tx_b_data;
            4'b0101: data_o_reg <= {7'd0, tx_b_data_ready};
            4'b0110: data_o_reg <= rx_b_data_reg;
            4'b0111: data_o_reg <= {7'd0, rx_b_data_avail};
            4'b1000: data_o_reg <= {5'd0, uart_b_baud};
            default: data_o_reg <= 8'd0;
        endcase
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
    else if((reg_addr == 4'b0010) && (uart_cs))
    begin
        rx_data_avail <= 1'b0;
    end
end

always@(posedge clk or negedge rst_n)
begin
    if(rst_n == 1'b0)
    begin
        rx_b_data_reg <= 8'd0;
        rx_b_data_avail <= 1'b0;
    end
    // Latch rx data and status
    else if(rx_b_data_valid)
    begin
        rx_b_data_reg <= rx_b_data;
        rx_b_data_avail <= 1'b1;
    end
    else if((reg_addr == 4'b0110) && (uart_cs))
    begin
        rx_b_data_avail <= 1'b0;
    end
end

assign data_o = data_o_reg;

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

// Instantiate UART B
uart_rx_flex#
(
	.CLK_FRE(CLK_FRE)
) uart_rx_inst_b
(
	.clk                        (clk                      ),
	.rst_n                      (rst_n                    ),
	.rx_data                    (rx_b_data                  ),
	.rx_data_valid              (rx_b_data_valid            ),
	.rx_data_ready              (rx_b_data_ready            ),
	.rx_pin                     (uart_b_rx                  ),
    .baudrate                   (uart_b_baud                )
);

uart_tx_flex#
(
	.CLK_FRE(CLK_FRE)
) uart_tx_inst_b
(
	.clk                        (clk                      ),
	.rst_n                      (rst_n                    ),
	.tx_data                    (tx_b_data                  ),
	.tx_data_valid              (tx_b_data_valid            ),
    .baudrate                   (uart_b_baud                ),
	.tx_data_ready              (tx_b_data_ready            ),
	.tx_pin                     (uart_b_tx                  )
);
endmodule