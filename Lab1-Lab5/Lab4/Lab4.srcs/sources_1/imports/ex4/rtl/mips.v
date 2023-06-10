`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/06 20:48:34
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
	input wire clk,rst,
	output wire[31:0] pcF,
	input wire[31:0] instrF,
	output wire memwriteM,
	output wire[31:0] aluoutM,writedataM,
	input wire[31:0] readdataM ,
	input wire [4:0]regfile_address,
	output wire [31:0]reg_out
);
	
	wire [5:0] opD,functD;
	wire regdstE,alusrcE,pcsrcD,memtoregE,memtoregM,memtoregW,jumpD,branchD;
	wire regwriteE,regwriteM,regwriteW;
	wire [2:0] alucontrolE;
	wire flushE,equalD;

	controller con(
	.clk(clk),
	.rst(rst),
	.opD(opD),
	.functD(functD),
	.jumpD(jumpD),
	.branchD(branchD),
	.memtoregE(memtoregE),
	.alusrcE(alusrcE),
	.regdstE(regdstE),
	.flushE(flushE),
	.regwriteE(regwriteE),
	.alucontrolE(alucontrolE),
	.memwriteM(memwriteM),
	.memtoregM(memtoregM),
	.regwriteM(regwriteM),
	.regwriteW(regwriteW),
	.memtoregW(memtoregW)
	);

	datapath dp(
	.clk(clk),
	.rst(rst),
	.regfile_address(regfile_address),
	.pcF(pcF),
	.instrF(instrF),
	.opD(opD),
	.functD(functD),
	.branchD(branchD),
	.jumpD(jumpD),
	.memtoregE(memtoregE),
	.alusrcE(alusrcE),
	.regdstE(regdstE),
	.alucontrolE(alucontrolE),
	.regwriteE(regwriteE),
	.flushE(flushE),
	.aluoutM(aluoutM),
	.memtoregM(memtoregM),
	.writedataM(writedataM),
	.readdataM(readdataM),
    .regwriteM(regwriteM),
	.memtoregW(memtoregW),
	.regwriteW(regwriteW),
	.reg_out(reg_out)
	);
	
endmodule
