module fontrom(clk, adr, data);
	input clk;
	input [10:0] adr;
	output [7:0] data;
	reg [7:0] data; 
	reg [7:0] mem [2048];
	initial $readmemh("fontrom.hex", mem);
	always @(posedge clk) data <= mem[adr];
endmodule
