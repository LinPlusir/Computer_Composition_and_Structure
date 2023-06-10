`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/03 11:25:34
// Design Name: 
// Module Name: maindec
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


module maindec(
  input [5:0]op,//指令inst 的高 6 位 op
  output memtoreg,//回写的数据来自于 ALU 计算的结果0/存储器读取的数据1
  output memwrite,//是否需要写数据存储器
  output regdst,//写入寄存器堆的地址是 rt 还是 rd,0 为 rt,1 为 rd
  output regwrite,//是否需要写寄存器堆
  output alusrc,//送入 ALU B 端口的值是立即数的 32 位扩展1/寄存器堆读取的值0
  output branch,//是否为 branch 指令，且满足 branch 的条件
  output jump,//是否为 jump 指令
  output [1:0]aluop//ALU 控制信号，代表不同的运算类型
    );
    reg [8:0]con;
    assign {regwrite,regdst,alusrc,branch,memwrite,memtoreg,aluop,jump}=con;
    always@(*)
    begin
      case(op)
          6'b000000: con<=9'b110000100;//R-type
          6'b100011: con<=9'b101001000;//lw
          6'b101011: con<=9'b0X101X000;//sw
          6'b000100: con<=9'b0X010X010;//beq
          6'b001000: con<=9'b101000000;//addi
          6'b000010: con<=9'b0XXX0XXX1;//j
          default:con<=9'bXXXXXXXX;
      endcase
    end
   
  
endmodule
