module bootrom(clk, adr, data);
	input clk;
	input [12:0] adr;
	output [7:0] data;
	reg [7:0] data; 
	reg [7:0] mem [8192];
	initial $readmemh("nano6502.hex", mem);
	always @(posedge clk) data <= mem[adr];
endmodule