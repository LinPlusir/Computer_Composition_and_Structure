`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/03 10:25:35
// Design Name: 
// Module Name: datapath
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
module datapath(
 input clk,
 input rst,
 input memtoreg,//��д������������ ALU ����Ľ��0/�洢����ȡ������1
 input regdst,//д��Ĵ����ѵĵ�ַ�� rt ���� rd,0 Ϊ rt,1 Ϊ rd
 input regwrite,//�Ƿ���Ҫд�Ĵ�����
 input alusrc,//���� ALU B �˿ڵ�ֵ���������� 32 λ��չ1/�Ĵ����Ѷ�ȡ��ֵ0
 input branch,//�Ƿ�Ϊ branch ָ������� branch ������
 input jump,//�Ƿ�Ϊ jump ָ��
 input [2:0]alucontrol,
 input [31:0]instr,
 input  [31:0]readdata,
 output [31:0]pc,
 output [31:0]aluout,
 output [31:0]writedata,
 output inst_ce
    );
 wire [31:0]rd1,rd2;
 wire pcsrc,zero;
 wire overflow;
  assign writedata=rd2;//д�����ݴ洢��
  assign pcsrc=zero&branch;
    
  //������������չ
  wire [31:0]signimm;
  signext ex(.a(instr[15:0]),.y(signimm));
  
  //alusrc ,alu�ĵڶ�������
  wire [31:0]srcB;
  mux2 #(32) src1(.s(alusrc),.a(rd2),.b(signimm),.res(srcB));
  
  //alu
  alu alu1(.num1(rd1),.num2(srcB),.op(alucontrol),.res(aluout),.overflow(overflow),.zero(zero));
  // regdst,0 Ϊ rt,1 Ϊ rd
  wire [4:0]writeR;
  mux2 #(5)WR(.s(regdst),.a(instr[20:16]),.b(instr[15:11]),.res(writeR));
  
  //memtoreg 
  wire [31:0]wd;//��д�Ĵ���
  mux2 #(32)memdata(.s(memtoreg),.a(aluout),.b(readdata),.res(wd));
  
  //ָ������2λ
  wire [31:0]instr_sl2;
  sl2 sl21(.a(instr),.y(instr_sl2));
  //����������2λ
  wire [31:0]signimm_sl2;
  sl2 sl22(.a(signimm),.y(signimm_sl2));
  
  //pc
  wire [31:0]pc_add4,pc_next;
  wire [31:0]pc_tmp,pc_branch,pc_j;
  pc pc0(.clk(clk),.rst(rst),.pc_next(pc_next),.pc(pc),.inst_ce(inst_ce)); //�洢��һ����ַ
  adder1 pc1(.a(pc),.b(32'h00000004),.y(pc_add4));
  adder1 pc2(.a(pc_add4),.b(signimm_sl2),.y(pc_branch));
  assign pc_j={pc_add4[31:28],instr_sl2[27:0]};
  //branch,0Ϊpc+4��1Ϊpc_branch
  mux2 #(32) branch0(.a(pc_add4),.b(pc_branch),.s(pcsrc),.res(pc_tmp));
  //
  mux2 #(32) jump0(.a(pc_tmp),.b(pc_j),.s(jump),.res(pc_next));//�õ���һ����ַ
  
  //�Ĵ���
  regfile regfile0(.clk(clk),.we3(regwrite),.ra1(instr[25:21]),.ra2(instr[20:16]),.wa3(writeR),.wd3(wd),.rd1(rd1),.rd2(rd2));
  
endmodule