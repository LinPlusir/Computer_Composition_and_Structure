`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/21 21:41:17
// Design Name: 
// Module Name: pc
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


module pc(
   input clk,
   input rst,
   output reg [31:0]pc,
   output reg inst_ce
    );
    reg [31:0]temp;
    always@(posedge clk)
    begin
    if(rst)
       begin
       inst_ce<=0;
       temp<=0;
       end
    else
      begin
      temp<=temp+1;//����Ϊ��һ��ָ���ַ
      inst_ce<=1;
      pc<=temp;  //���Ϊ��ǰָ���ַ
      end
    end
    
endmodule
