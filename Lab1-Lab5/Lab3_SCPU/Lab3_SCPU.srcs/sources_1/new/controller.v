`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/03 10:32:50
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
   output [2:0]alucontrol,
   output memtoreg,
   output memwrite,
   output branch,
   output alusrc,
   output regdst,
   output regwrite,
   output jump
    );
    wire [1:0]aluop;
    maindec u1(.op(op),.aluop(aluop),.memtoreg(memtoreg),.memwrite(memwrite),.branch(branch),.jump(jump),.alusrc(alusrc),.regdst(regdst),.regwrite(regwrite));
    aludec u2(.funct(funct),.aluop(aluop),.alucontrol(alucontrol));
endmodule
