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
 input memtoreg,//回写的数据来自于 ALU 计算的结果0/存储器读取的数据1
 input regdst,//写入寄存器堆的地址是 rt 还是 rd,0 为 rt,1 为 rd
 input regwrite,//是否需要写寄存器堆
 input alusrc,//送入 ALU B 端口的值是立即数的 32 位扩展1/寄存器堆读取的值0
 input branch,//是否为 branch 指令，且满足 branch 的条件
 input jump,//是否为 jump 指令
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
  assign writedata=rd2;//写入数据存储器
  assign pcsrc=zero&branch;
    
  //立即数符号扩展
  wire [31:0]signimm;
  signext ex(.a(instr[15:0]),.y(signimm));
  
  //alusrc ,alu的第二个输入
  wire [31:0]srcB;
  mux2 #(32) src1(.s(alusrc),.a(rd2),.b(signimm),.res(srcB));
  
  //alu
  alu alu1(.num1(rd1),.num2(srcB),.op(alucontrol),.res(aluout),.overflow(overflow),.zero(zero));
  // regdst,0 为 rt,1 为 rd
  wire [4:0]writeR;
  mux2 #(5)WR(.s(regdst),.a(instr[20:16]),.b(instr[15:11]),.res(writeR));
  
  //memtoreg 
  wire [31:0]wd;//回写寄存器
  mux2 #(32)memdata(.s(memtoreg),.a(aluout),.b(readdata),.res(wd));
  
  //指令左移2位
  wire [31:0]instr_sl2;
  sl2 sl21(.a(instr),.y(instr_sl2));
  //立即数左移2位
  wire [31:0]signimm_sl2;
  sl2 sl22(.a(signimm),.y(signimm_sl2));
  
  //pc
  wire [31:0]pc_add4,pc_next;
  wire [31:0]pc_tmp,pc_branch,pc_j;
  pc pc0(.clk(clk),.rst(rst),.pc_next(pc_next),.pc(pc),.inst_ce(inst_ce)); //存储下一条地址
  adder1 pc1(.a(pc),.b(32'h00000004),.y(pc_add4));
  adder1 pc2(.a(pc_add4),.b(signimm_sl2),.y(pc_branch));
  assign pc_j={pc_add4[31:28],instr_sl2[27:0]};
  //branch,0为pc+4，1为pc_branch
  mux2 #(32) branch0(.a(pc_add4),.b(pc_branch),.s(pcsrc),.res(pc_tmp));
  //
  mux2 #(32) jump0(.a(pc_tmp),.b(pc_j),.s(jump),.res(pc_next));//得到下一条地址
  
  //寄存器
  regfile regfile0(.clk(clk),.we3(regwrite),.ra1(instr[25:21]),.ra2(instr[20:16]),.wa3(writeR),.wd3(wd),.rd1(rd1),.rd2(rd2));
  
endmodule