`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/03 12:05:58
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
	output wire [31:0] pc,
	output wire [31:0] writedata,
	output wire [31:0] aluout,
	output wire [31:0] instr,
	output wire memwrite
    );
	wire[31:0] readdata;
	wire inst_ce;

	mips mips(.clk(clk),
	          .rst(rst),
	          .pc(pc),
	          .instr(instr),
	          .memwrite(memwrite),
	          .aluout(aluout),
	          .writedata(writedata),
	          .readdata(readdata),
	          .inst_ce(inst_ce));

	inst_mem imem(
  	.clka(~clk),  
  	.ena(inst_ce),      
  	.wea(4'b0000),      
  	.addra(pc),  
  	.dina(32'b0),    
  	.douta(instr) 
	);

	data_mem dmem(
    .clka(clk),    
  	.ena(1'b1),     
  	.wea({4{memwrite}}),     
  	.addra(aluout),
  	.dina(writedata),   
  	.douta(readdata)  
	);
endmodule
