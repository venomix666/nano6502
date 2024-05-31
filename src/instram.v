module instram(clk, adr, rwn, cs, data_i, data_o);
	input clk;
	input [15:0] adr;
    input rwn;
    input cs;
    input [7:0] data_i;
	output [7:0] data_o;
	reg [7:0] data_o; 
	reg [7:0] mem [65536];
	always @(negedge clk) data_o <= mem[adr];

    always @(posedge clk)
    begin
        if(!rwn && cs) mem[adr] <= data_i;
    end
endmodule