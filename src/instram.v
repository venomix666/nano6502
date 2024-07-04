module instram(clk, adr, adr_w, rwn, cs, data_i, data_o);
	input clk;
	input [15:0] adr;
    input [15:0] adr_w;
    input rwn;
    input cs;
    input [7:0] data_i;
	output [7:0] data_o;
	reg [7:0] data_o; 
    reg [7:0] data_i_delay;

	reg [7:0] mem [65536];
    
	always @(posedge clk) data_o <= mem[adr];

    always @(posedge clk) data_i_delay <= data_i;

    always @(posedge clk)
    begin
        if(!rwn && cs) mem[adr_w] <= data_i_delay;
    end
endmodule