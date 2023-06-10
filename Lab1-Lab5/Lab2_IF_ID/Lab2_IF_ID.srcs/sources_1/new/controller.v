`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/21 21:41:57
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
   input [5:0]op,
   input [5:0]funct,
   input zero,
   output [2:0]alucontrol,
   output memtoreg,
   output memwrite,
   output branch,
   output alusrc,
   output regdst,
   output regwrite,
   output jump,
   output pcsrc//下一个 PC 值是 PC+4/跳转的新地址
    );
    wire [1:0]aluop;
    maindec u1(.op(op),.aluop(aluop),.memtoreg(memtoreg),.memwrite(memwrite),.branch(branch),.jump(jump),.alusrc(alusrc),.regdst(regdst),.regwrite(regwrite));
    aludec u2(.funct(funct),.aluop(aluop),.alucontrol(alucontrol));
    assign pcsrc=zero&branch;
endmodule
