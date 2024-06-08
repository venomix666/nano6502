// Text mode video generation for the nano6502
//
// Sync generation is based on the example from Gowin Semi.
//
// Registers:
// 00       - Line (selects which line is avaible at FE80-FECF)
// 01       - Cursor X
// 02       - Cursor Y
// 03       - Cursor visible
// 80-CF    - Line data

// 640x480 info:
/*  
    Horizontal Timings
    Active Pixels        640
    Front Porch           16
    Sync Width            96
    Back Porch            48
    Blanking Total       160
    Total Pixels         800
    Sync Polarity        neg

    Vertical Timings
    Active Lines         480
    Front Porch           10
    Sync Width             2
    Back Porch            33
    Blanking Total        45
    Total Lines          525
    Sync Polarity        neg
*/

module video(
    input               clk_i,
	input               rst_n_i,
    input               R_W_n,
	input   [7:0]       reg_addr_i,
    input   [7:0]       data_i,
    input               video_cs,
    output  [7:0]       data_o,
    output              tmds_clk_p_o,
    output              tmds_clk_n_o,
    output [2:0]        tmds_data_p_o,
    output [2:0]        tmds_data_n_o
);

// Parameters for 640x480 60Hz with 25.175 MHz clock
localparam      I_h_total       = 12'd800;
localparam      I_h_sync        = 12'd96;
localparam      I_h_bporch      = 12'd48;
localparam      I_h_res         = 12'd640;
localparam      I_v_total       = 12'd525;
localparam      I_v_sync        = 12'd2;
localparam      I_v_bporch      = 12'd33;
localparam      I_v_res         = 12'd480;
localparam      I_hs_pol        = 1'd0;
localparam      I_vs_pol        = 1'd0;
//localparam      char            = 7'h30;

localparam N = 5; //delay N clocks

reg  [11:0]   V_cnt     ;
reg  [11:0]   H_cnt     ;
              
wire          Pout_de_w    ;                          
wire          Pout_hs_w    ;
wire          Pout_vs_w    ;

reg  [N-1:0]  Pout_de_dn   ;                          
reg  [N-1:0]  Pout_hs_dn   ;
reg  [N-1:0]  Pout_vs_dn   ;

//----------------------------
wire 		  De_pos;
wire 		  De_neg;
wire 		  Vs_pos;
	
reg  [11:0]   De_vcnt     ;
reg  [11:0]   De_hcnt     ;
reg  [11:0]   De_hcnt_d1  ;
reg  [11:0]   De_hcnt_d2  ;

reg dvi_hs;
reg dvi_vs;
reg dvi_oe;

//==============================================================================
//Generate HS, VS, DE signals
always@(posedge clk_i or negedge rst_n_i)
begin
	if(!rst_n_i)
		V_cnt <= 12'd0;
	else     
		begin
			if((V_cnt >= (I_v_total-1'b1)) && (H_cnt >= (I_h_total-1'b1)))
				V_cnt <= 12'd0;
			else if(H_cnt >= (I_h_total-1'b1))
				V_cnt <=  V_cnt + 1'b1;
			else
				V_cnt <= V_cnt;
		end
end

//-------------------------------------------------------------    
always @(posedge clk_i or negedge rst_n_i)
begin
	if(!rst_n_i)
		H_cnt <=  12'd0; 
	else if(H_cnt >= (I_h_total-1'b1))
		H_cnt <=  12'd0 ; 
	else 
		H_cnt <=  H_cnt + 1'b1 ;           
end

//-------------------------------------------------------------
assign  Pout_de_w = ((H_cnt>=(I_h_sync+I_h_bporch))&(H_cnt<=(I_h_sync+I_h_bporch+I_h_res-1'b1)))&
                    ((V_cnt>=(I_v_sync+I_v_bporch))&(V_cnt<=(I_v_sync+I_v_bporch+I_v_res-1'b1))) ;
assign  Pout_hs_w =  ~((H_cnt>=12'd0) & (H_cnt<=(I_h_sync-1'b1))) ;
assign  Pout_vs_w =  ~((V_cnt>=12'd0) & (V_cnt<=(I_v_sync-1'b1))) ;  

//-------------------------------------------------------------
always@(posedge clk_i or negedge rst_n_i)
begin
	if(!rst_n_i)
		begin
			Pout_de_dn  <= {N{1'b0}};                          
			Pout_hs_dn  <= {N{1'b1}};
			Pout_vs_dn  <= {N{1'b1}}; 
		end
	else 
		begin
			Pout_de_dn  <= {Pout_de_dn[N-2:0],Pout_de_w};                          
			Pout_hs_dn  <= {Pout_hs_dn[N-2:0],Pout_hs_w};
			Pout_vs_dn  <= {Pout_vs_dn[N-2:0],Pout_vs_w}; 
		end
end

assign dvi_de = Pout_de_dn[4];

always@(posedge clk_i or negedge rst_n_i)
begin
	if(!rst_n_i)
		begin                        
			dvi_hs  <= 1'b1;
			dvi_vs  <= 1'b1; 
		end
	else 
		begin                         
			dvi_hs  <= I_hs_pol ? ~Pout_hs_dn[3] : Pout_hs_dn[3] ;
			dvi_vs  <= I_vs_pol ? ~Pout_vs_dn[3] : Pout_vs_dn[3] ;
		end
end

// CPU interface
reg     [7:0]   data_o_reg;
reg     [4:0]   line;
reg     [6:0]   cursor_x;
reg     [4:0]   cursor_y;
reg             cursor_visible;
reg     [23:0]  cursor_cnt;

wire            cursor_active;

always @(*)
begin
    if(reg_addr_i == 8'h00) data_o_reg <= {3'd0, line};
    else if(reg_addr_i == 8'h01) data_o_reg <= {1'd0, cursor_x};
    else if(reg_addr_i == 8'h02) data_o_reg <= {3'd0, cursor_y};
    else if(reg_addr_i == 8'h03) data_o_reg <= {7'd0, cursor_visible};
    else if(reg_addr_i[7] && (reg_addr_i[6:0] < 80)) data_o_reg <= charbuf_data_o;
    else data_o_reg <= 8'd0;
end

always @(posedge clk_i or negedge rst_n_i)
begin
    if(rst_n_i == 1'b0)
    begin
        line <= 5'd0;
        cursor_x <= 7'd0;
        cursor_y <= 4'd0;
        cursor_visible <= 1'd1;
    end
    else if(!R_W_n && video_cs)
    begin
        if(reg_addr_i == 8'h00) line <= data_i[4:0];
        else if(reg_addr_i==8'h01) cursor_x <=data_i[6:0];
        else if(reg_addr_i==8'h02) cursor_y <=data_i[4:0];
        else if(reg_addr_i==8'h03) cursor_visible <= data_i[0];
    end
end

assign data_o = data_o_reg;


// Cursor counter
always @(posedge clk_i or negedge rst_n_i)
begin
    if(rst_n_i == 1'b0)
    begin
        cursor_cnt <= 24'd0;
    end
    else if(cursor_cnt == 24'hffffff) cursor_cnt <= 24'd0; 
    else cursor_cnt <= cursor_cnt + 24'd1;

end

assign cursor_active = (cursor_cnt > 24'h800000) && cursor_visible;

// Character addressing
wire    [11:0]  char_x_offset;
wire    [11:0]  char_y_offset;
wire    [6:0]   char_x;
wire    [4:0]   char_y;
wire    [7:0]   char;

wire    [7:0]   charbuf_data_o;
wire    [11:0]  charbuf_addr;
wire    [11:0]  charbuf_waddr;

wire    [7:0]   char_cur;

assign char_x_offset = H_cnt-12'd149;      
assign char_x = char_x_offset[9:3];
assign char_y_offset = V_cnt-12'd35;
assign char_y = char_y_offset[8:4];
//assign char = char_y+char_x;
assign charbuf_addr = {char_y, 4'd0}+{char_y, 6'd0}+char_x;  // Y*80 + X
assign charbuf_waddr = {line, 4'd0}+{line, 6'd0}+reg_addr_i[6:0];

// Character buffer - PORT A connects to CPU, PORT B connector to character generator
charbuf_dpram charbuf(
        .douta(charbuf_data_o), //output [7:0] douta
        .doutb(char), //output [7:0] doutb
        .clka(~clk_i), //input clka
        .ocea(1'b1), //input ocea
        .cea(1'b1), //input cea
        .reseta(1'b0), //input reseta
        .wrea(~R_W_n && video_cs && reg_addr_i[7] && (reg_addr_i[6:0] < 80)), //input wrea
        .clkb(clk_i), //input clkb
        .oceb(1'b1), //input oceb
        .ceb(1'b1), //input ceb
        .resetb(1'b0), //input resetb
        .wreb(1'b0), //input wreb
        .ada(charbuf_waddr), //input [11:0] ada
        .dina(data_i), //input [7:0] dina
        .adb(charbuf_addr), //input [11:0] adb
        .dinb(8'd0) //input [7:0] dinb
    );

// Font drawing
wire    [2:0]   font_x;
wire    [11:0]  y_offset;
wire    [3:0]   font_y;
wire    [10:0]  font_addr;
wire    [7:0]   font_data;
wire            font_out;

assign font_x = H_cnt[2:0]-6;
assign y_offset = V_cnt - 12'd35;
assign font_y = y_offset[3:0]; 
assign font_addr = {char, font_y};
assign char_cur[6:0] = char[6:0];
assign char_cur[7] = (cursor_active && (char_x == cursor_x) && (char_y == cursor_y)) ? ~char[7] : char[7];
assign font_out = char_cur[7] ? ~font_data[7'd7-font_x] : font_data[7'd7-font_x];

fontrom fontrom_inst(
    .clk(clk_i),
    .adr(font_addr),
    .data(font_data)
);

DVI_TX_Top dvi_tx(
		.I_rst_n(rst_n_i), //input I_rst_n
		.I_rgb_clk(clk_i), //input I_rgb_clk
		.I_rgb_vs(dvi_vs), //input I_rgb_vs
		.I_rgb_hs(dvi_hs), //input I_rgb_hs
		.I_rgb_de(dvi_de), //input I_rgb_de
		.I_rgb_r({font_out, 7'd0}), //input [7:0] I_rgb_r
		.I_rgb_g({font_out, 7'd0}), //input [7:0] I_rgb_g
		.I_rgb_b({font_out, 7'd0}), //input [7:0] I_rgb_b
		.O_tmds_clk_p(tmds_clk_p_o), //output O_tmds_clk_p
		.O_tmds_clk_n(tmds_clk_n_o), //output O_tmds_clk_n
		.O_tmds_data_p(tmds_data_p_o), //output [2:0] O_tmds_data_p
		.O_tmds_data_n(tmds_data_n_o) //output [2:0] O_tmds_data_n
	);

endmodule