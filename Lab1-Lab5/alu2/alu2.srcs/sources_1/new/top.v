`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/03/27 22:41:42
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
  input wire [7:0]ins,
  input wire [2:0]op,
  input wire clk,
  input wire reset,
  output wire [6:0]seg,
  output wire [7:0]ans
    );
   wire [31:0] B=32'h00000001;
   wire [31:0] res;
   ALU u1(.num1(ins),.num2(B),.op(op),.res(res));
   display u2(.clk(clk),.reset(reset),.s(res),.seg(seg),.ans(ans));
endmodule
