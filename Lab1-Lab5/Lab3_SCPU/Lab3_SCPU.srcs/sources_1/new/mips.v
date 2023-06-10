`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/05/06 19:54:06
// Design Name: 
// Module Name: mips
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


module mips(
	input wire clk,
	input wire rst,
	input wire[31:0] instr,
	input wire[31:0] readdata,
	output wire[31:0] pc,
	output wire inst_ce,
	output wire memwrite,
	output wire[31:0] aluout,
	output wire[31:0] writedata	
    );
	
	
	wire memtoreg,alusrc,regdst,regwrite,jump,pcsrc,branch;
	wire[2:0] alucontrol;

	controller c(
	.op(instr[31:26]),
	.funct(instr[5:0]),
	.memtoreg(memtoreg),
	.memwrite(memwrite),
	.alusrc(alusrc),
	.regdst(regdst),
	.regwrite(regwrite),
	.jump(jump),
	.branch(branch),
	.alucontrol(alucontrol)
	);


	datapath dp(
	.clk(clk),
	.rst(rst),
	.memtoreg(memtoreg),
	.alusrc(alusrc),
	.jump(jump),
	.regdst(regdst),
	.branch(branch),
	.regwrite(regwrite),
	.alucontrol(alucontrol),
	.pc(pc),
	.instr(instr),
	.aluout(aluout),
	.writedata(writedata),
	.readdata(readdata),
	.inst_ce(inst_ce)
	);
	
endmodule
