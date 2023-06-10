`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/07 13:50:53
// Design Name: 
// Module Name: top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top(
	input wire clk,rst,
	input wire [4:0]regfile_address,
	output wire[31:0] writedata,aluout,
	output wire memwrite,
	output wire [31:0] instr,pc,readdata,reg_out
);



mips mips(
	.clk(clk),
	.rst(rst),
	.regfile_address(regfile_address),
	.pcF(pc),
	.instrF(instr),
	.memwriteM(memwrite),
	.aluoutM(aluout),
	.writedataM(writedata),
	.readdataM(readdata),
	.reg_out(reg_out)
);

inst_ram inst_ram (
  .clka(~clk),    
  .ena(1'b1),      
  .wea(),      
  .addra(pc), 
  .dina(32'b0),    
  .douta(instr)  
);


data_ram data_ram (
  .clka(~clk),  
  .ena(memwrite),      
  .wea({4{memwrite}}),   
  .addra(aluout),  
  .dina(writedata),    
  .douta(readdata)  
);
endmodule
