// SD-card interface for the nano6502
//
// Registers:
// 00-03    -   SD card address (00=LSB, 03=MSB)
// 04       -   SD card busy
// 05       -   SD card start read (write any value to start)
// 06       -   SD card start write (write any value to start)
// 07       -   Access page - Sets page of sector to access (0-3)
// 08       -   SD card status
// 09       -   SD card type
// 80-FF    -   128 byte access to data, controlled by page register
//

module sd_interface(
	input               clk_i,
	input               rst_n_i,
    input               R_W_n,
	input   [7:0]       reg_addr_i,
    input   [7:0]       data_i,
    input               sd_cs,
    output  [7:0]       data_o,
    output              sdclk,
    inout               sdcmd,
    inout   [3:0]       sddat
);

parameter IDLE      = 2'd0;
parameter READING   = 2'd1;
parameter WRITING   = 2'd2;    

reg [31:0]  address;
reg         rd;
reg         wr;
reg [7:0]   data_o_reg;
reg [7:0]   sd_data_o;
reg [7:0]   page;
reg [1:0]   state;

wire byte_available;
wire ready_for_next_byte;
wire [7:0] sd_data_i;
wire rbusy;
wire rdone;
wire outen;
wire [8:0] outaddr;
wire [3:0] card_stat;
wire [1:0] card_type;
wire [7:0] buf_data_o;

sector_dpram buffer(
    .clka(clk_i),
    .reseta(1'b0), 
    .cea(1'b1), 					
    .ada(outaddr), 
    .wrea(outen), 
    .dina(sd_data_o),
    .ocea(1'b1), 
    .douta(sd_data_i),
					
    .clkb(~clk_i), 
    .resetb(1'b0), 
    .ceb(1'b1), 
    .adb({page[1:0], reg_addr_i[6:0]}), 
    .wreb(reg_addr_i[7] && !R_W_n && sd_cs), 
    .dinb(data_i),
    .oceb(1'b1), 
    .doutb(buf_data_o)					
);

// Asynchronous read
always @(*)
    begin
    case(reg_addr_i)
        8'h00: data_o_reg = address[7:0];
        8'h01: data_o_reg = address[15:8];
        8'h02: data_o_reg = address[23:16];
        8'h03: data_o_reg = address[31:24];
        8'h04: data_o_reg = {7'd0, rbusy};
        8'h07: data_o_reg = page;
        8'h08: data_o_reg = {4'd0, card_stat};
        8'h09: data_o_reg = {6'd0, card_type};
        default:
        begin
            if(reg_addr_i[7]) data_o_reg = buf_data_o;
            else data_o_reg = 8'd0;
        end
    endcase
end

// Synchronous write
always @(posedge clk_i or negedge rst_n_i)
begin
    if(rst_n_i == 1'b0)
    begin
        address <= 32'd0;
        rd <= 1'b0;
        wr <= 1'b0;
        page <= 2'd0;
        state <= IDLE;
    end
    else if(state == READING)
    begin
        if(!rbusy) state <= IDLE;
        rd<=1'b0;
        wr<=1'b0;
    end
    else if(state == WRITING)
    begin
        if(!rbusy) state <= IDLE;
        rd<=1'b0;
        wr<=1'b0;
    end
    else if((sd_cs) && (!R_W_n))
    begin
        case(reg_addr_i)
            8'h00:  address[7:0] <= data_i;
            8'h01:  address[15:8] <= data_i;
            8'h02:  address[23:16] <= data_i;
            8'h03:  address[31:24] <= data_i;
            8'h05:  
            begin
                if(!rbusy)
                begin
                    rd <= 1'b1;
                    state <= READING;
                end
            end
            8'h06:  
            begin
                if(!rbusy)
                begin
                    wr <= 1'b1;
                    state <= WRITING;
                end
            end
            8'h07:  page <= data_i;
        endcase
    end
    else
    begin
        rd <= 1'b0;
        wr <= 1'b0;
    end
end

assign data_o = data_o_reg;

sd_rw #(.CLK_DIV(3), .SIMULATE(0)) sd_rw_inst(
        .rstn(rst_n_i),
        .clk(clk_i),
        .sdclk(sdclk),
        .sdcmd(sdcmd),
        .sddat(sddat),
        .card_stat(card_stat),
        .card_type(card_type),
        .rstart(rd),
        .wstart(wr),
        .sector(address),
        .rbusy(rbusy),
        .rdone(rdone),
        .inbyte(sd_data_i),
        .outen(outen),
        .outaddr(outaddr),
        .outbyte(sd_data_o)
);

endmodule