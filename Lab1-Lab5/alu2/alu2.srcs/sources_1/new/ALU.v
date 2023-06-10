`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/03/27 22:42:18
// Design Name: 
// Module Name: ALU
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


module ALU(
  input wire [7:0] num1,
  input wire [31:0]num2,
  input wire [2:0] op,
  output reg [31:0] res
    );
    reg [31:0] sign_extend;
    always@ (op)
    begin
    sign_extend={24'h000000,num1[7:0]};
      case(op)
         3'b000: res=sign_extend+num2;
         3'b001: res=sign_extend-num2;
         3'b010: res=sign_extend&num2;
         3'b011: res=sign_extend|num2;
         3'b100: res=~sign_extend;
         3'b101:
         begin
         if(sign_extend<num2)
             res=1;
         else res=0;
         end  
         default:res=32'h00000000;               
      endcase
    end
endmodule
