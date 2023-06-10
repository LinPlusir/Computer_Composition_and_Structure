`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/5/6 20:44:30
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
  input [5:0]op,//ָ��inst �ĸ� 6 λ op
  output memtoreg,//��д������������ ALU ����Ľ��0/�洢����ȡ������1
  output memwrite,//�Ƿ���Ҫд���ݴ洢��
  output regdst,//д��Ĵ����ѵĵ�ַ�� rt ���� rd,0 Ϊ rt,1 Ϊ rd
  output regwrite,//�Ƿ���Ҫд�Ĵ�����
  output alusrc,//���� ALU B �˿ڵ�ֵ���������� 32 λ��չ1/�Ĵ����Ѷ�ȡ��ֵ0
  output branch,//�Ƿ�Ϊ branch ָ������� branch ������
  output jump,//�Ƿ�Ϊ jump ָ��
  output [1:0]aluop//ALU �����źţ�����ͬ����������
    );
    reg [8:0]con;
    assign {regwrite,regdst,alusrc,branch,memwrite,memtoreg,jump,aluop}=con;
    always@(*)
    begin
      case(op)
          6'b000000: con<=9'b110000010;//R-type
          6'b100011: con<=9'b101001000;//lw
          6'b101011: con<=9'b001010000;//sw
          6'b000100: con<=9'b000100001;//beq
          6'b001000: con<=9'b101000000;//addi
          6'b000010: con<=9'b000000100;//j
          default:con<=9'b000000000;
      endcase
    end
   
  
endmodule
