`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/5/6 20:21:30
// Design Name: 
// Module Name: controller
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


module controller(
	input wire clk,rst,
	//ID
	input wire[5:0] opD,functD,
	output wire branchD,jumpD,
	//EX
	input wire flushE,
	output wire memtoregE,alusrcE,
	output wire regdstE,regwriteE,	
	output wire[2:0] alucontrolE,
	//MEM
	output wire memtoregM,memwriteM,regwriteM,
	//WB
	output wire memtoregW,regwriteW

);
	//ID
	wire[1:0] aluopD;
	wire memtoregD,memwriteD,alusrcD,regdstD,regwriteD;
	wire[2:0] alucontrolD;

	maindec maindec0(
		.op(opD),
		.memtoreg(memtoregD),
		.memwrite(memwriteD),
		.branch(branchD),
		.alusrc(alusrcD),
		.regdst(regdstD),
		.regwrite(regwriteD),
		.jump(jumpD),
		.aluop(aluopD)
	);
   
  
   
	aludec aludec0(
	           .funct(functD),
	           .aluop(aluopD),
	           .alucontrol(alucontrolD)
	           );
	           
	//EX
	wire memwriteE;
	
	//D-E
	floprc #(8) regE(
		clk,
		rst,
		flushE,
		{memtoregD,memwriteD,alusrcD,regdstD,regwriteD,alucontrolD},
		{memtoregE,memwriteE,alusrcE,regdstE,regwriteE,alucontrolE}
	);

   //E-M
	flopr #(3) regM(
		clk,rst,
		{memtoregE,memwriteE,regwriteE},
		{memtoregM,memwriteM,regwriteM}
	);

  //M-W
	flopr #(2) regW(
		clk,rst,
		{memtoregM,regwriteM},
		{memtoregW,regwriteW}
	);

endmodule
