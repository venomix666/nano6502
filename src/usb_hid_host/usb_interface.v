// USB HID interface for the nano6502
//
// Very rudimentary for now, add translation of keyboard to ASCII later...
// Will latching of all data be necessary due to different clock domains?
//
// Registers:
// 00       -   Data available
// 01       -   Key 1
// 02       -   Key 2
// 03       -   Key 3
// 04       -   Key 4
// 05       -   Key modifiers
// 06       -   Mouse button
// 07       -   Mouse dx
// 08       -   Mouse dy
// 09       -   {4'b0000, game_d, game_u, game_r, game_l}
// 0a       -   {2'b00, game_sta, game_sel, game_y, game_x, game_b, game_a}
// 0b       -   Device type - 0: no device, 1: keyboard, 2: mouse, 3: gamepad
// 0c       -   Error signal 

module usb_interface(
	input               clk_i,
    input               clkusb_i,
	input               rst_n_i,
    input               R_W_n,
	input   [7:0]       reg_addr_i,
    input   [7:0]       reg_addr_r_i,
    input   [7:0]       data_i,
    input               usb_cs,
    output  [7:0]       data_o,
    inout               usb_dm,          // USB D+   
    inout               usb_dp           // USB D-
    
);

wire            [1:0]   typ;        // Device type
wire                    report;     // Pulse after report - is this for all data or only new connection?
wire                    conerr;     // Error signal
wire            [7:0]   key_modifiers;
wire            [7:0]   key1, key2, key3, key4;
wire            [7:0]   mouse_btn;
wire    signed  [7:0]   mouse_dx;
wire    signed  [7:0]   mouse_dy;
wire                    game_l, game_r, game_u, game_d;
wire                    game_a, game_b, game_x, game_y, game_sel, game_sta;

reg             [7:0]   data_o_reg;
reg                     report_reg;

// Asynchronous read
always @(*)
begin
    case(reg_addr_i)
        8'h00: data_o_reg = {7'd0, report_reg};
        8'h01: data_o_reg = key1;
        8'h02: data_o_reg = key2;
        8'h03: data_o_reg = key3;
        8'h04: data_o_reg = key4;
        8'h05: data_o_reg = key_modifiers;
        8'h06: data_o_reg = mouse_btn;
        8'h07: data_o_reg = mouse_dx;
        8'h08: data_o_reg = mouse_dy;
        8'h09: data_o_reg = {4'b0000, game_d, game_u, game_r, game_l};
        8'h0a: data_o_reg = {2'b00, game_sta, game_sel, game_y, game_x, game_b, game_a};
        8'h0b: data_o_reg = {6'd0, typ};
        8'h0c: data_o_reg = {7'd0, conerr};
        default:
        begin
            data_o_reg = 8'd0;
        end
    endcase
end

assign data_o = data_o_reg;

// Latch the report pulse and clear on read
always @(posedge clk_i or negedge rst_n_i)
begin
    if(rst_n_i == 1'b0)
    begin
        report_reg = 1'b0;
    end
    else if(report == 1'b1) report_reg = 1'b1;
    else if((usb_cs == 1'b1) && (reg_addr_i == 8'h00)) report_reg = 1'b0;
end



usb_hid_host usb_hid_host_inst(
    .usbclk(clkusb_i),
    .usbrst_n(rst_n_i),
    .usb_dm(usb_dm),
    .usb_dp(usb_dp),
    .typ(typ),
    .report(report),
    .conerr(conerr),
    .key_modifiers(key_modifiers),
    .key1(key1),
    .key2(key2),
    .key3(key3),
    .key4(key4),
    .mouse_btn(mouse_btn),
    .mouse_dx(mouse_dx),
    .mouse_dy(mouse_dy),
    .game_l(game_l),
    .game_r(game_r),
    .game_u(game_u),
    .game_d(game_d),
    .game_a(game_a),
    .game_b(game_b),
    .game_x(game_x),
    .game_y(game_y),
    .game_sel(game_sel),
    .game_sta(game_sta),
    .dbg_hid_report()
);

endmodule