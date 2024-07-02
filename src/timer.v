// Simple timer core for the nano6502
//
// Registers:
// 00       Timer idle - 1 is idle, 0 is running
// 01       Timer start strobe
// 02       Timer centiseconds LSB
// 03       Times centiseconds MSB

module timer(
	input               clk_i,
	input               rst_n_i,
    input               R_W_n,
	input   [1:0]       reg_addr_i,
    input   [7:0]       data_i,
    input               timer_cs,
    output  [7:0]       data_o
);
parameter CLK_FRE               = 25_175_000; 
parameter TIMER_MS_DELAY        = (CLK_FRE / 1_000); // Millisecond delay

localparam [1:0]    IDLE = 2'd0,
                    RUNNING = 2'd1;

reg [14:0]  ms_cnt;
reg [18:0]  cs_cnt; // Actually counts milliseconds, but skips lowest bit on compare


reg [15:0]  cs_set;


reg         timer_idle;
reg         timer_start;

reg [7:0]   data_o_reg;

reg [1:0]   timer_state;

always @(*)
begin
    case(reg_addr_i)
        2'b00: data_o_reg = {7'd0, timer_idle};
        2'b01: data_o_reg = 8'd0;
        2'b10: data_o_reg = cs_set[7:0];
        2'b11: data_o_reg = cs_set[15:8];
        default: data_o_reg = 8'd0;
    endcase
end

assign data_o = data_o_reg;

always @(posedge clk_i or negedge rst_n_i)
begin
    if(rst_n_i == 1'b0)
    begin
        cs_set <= 16'd0;
        timer_start <= 1'd0;
    end
    else if((timer_cs) && (!R_W_n))
    begin
        case(reg_addr_i)
            2'b01:
            begin
                timer_start <= 1'd1;             
            end
            2'b10:
            begin
                cs_set[7:0] <= data_i;
            end
            2'b11:
            begin
                cs_set[15:8] <= data_i;
            end
            default: timer_start <= 1'd0;
        endcase
    end
    else
        timer_start <= 1'd0;
end

always @(posedge clk_i or negedge rst_n_i)
begin
    if(rst_n_i == 1'b0)
    begin
        ms_cnt <= 15'd0;
        cs_cnt <= 19'd0;
        timer_state <= IDLE;
    end
    else
    begin
        case(timer_state)
            IDLE:
            begin
                ms_cnt <= 15'd0;
                cs_cnt <= 19'd0;
                if(timer_start) begin
                    cs_cnt <= {cs_set, 1'b0} + {cs_set, 3'b000}; // Multiply by 10
                    timer_state <= RUNNING;
                end
                else timer_state <= IDLE;
            end
            RUNNING:
            begin
                
                if(ms_cnt >= TIMER_MS_DELAY) 
                begin
                    ms_cnt <= 15'd0;
                    cs_cnt <= cs_cnt - 1;
                end
                else ms_cnt <= ms_cnt + 1;

                if(cs_cnt == 19'd0) timer_state <= IDLE;
                else timer_state <= RUNNING;

            end
        endcase
    end
end 

assign timer_idle = (timer_state == IDLE);

endmodule