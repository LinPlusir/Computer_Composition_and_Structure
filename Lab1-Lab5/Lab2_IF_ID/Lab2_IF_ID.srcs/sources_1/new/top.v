`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/21 21:40:08
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
      input clk,
      input rst,
      output [7:0]ans,
      output [6:0]seg,
      output [10:0]led

    );
    
    // ±÷”∑÷∆µ100mhz to 1hz
     //clk_1s
    parameter N=99_999999;
    reg [32:0]count2;
    reg clk_1s;
    always@(posedge clk)
    begin
     clk_1s<=0;
     if(count2<N) count2<=count2+1;
     else
       begin
       count2<=0;
       clk_1s<=1;
       end
    end
    
    wire [31:0]pc;
    wire inst_ce;
    pc b1(.clk(clk_1s),.rst(rst),.inst_ce(inst_ce),.pc(pc));
    wire [31:0]inst;
    inst_ram b2(.clka(clk),.addra(pc[7:0]),.ena(inst_ce),.douta(inst),.dina(32'h00000000),.wea(0));
    wire [5:0]op;
    wire [5:0]funct;
    assign op=inst[31:26];
    assign funct=inst[5:0];
    wire zero;
    wire memtoreg;
    wire jump;
    wire memwrite;
    wire branch;
    wire alusrc;
    wire pcsrc;
    wire regdst;
    wire regwrite;
    wire [2:0]alucontrol;
    controller b3(.op(op),.funct(funct),.zero(zero),.memtoreg(memtoreg),.memwrite(memwrite),.branch(branch),.jump(jump),.alusrc(alusrc),.regdst(regdst),.regwrite(regwrite),.alucontrol(alucontrol),.pcsrc(pcsrc));
    assign led={alucontrol,branch,jump,regwrite,regdst,alusrc,pcsrc,memwrite,memtoreg};
    display b4(.clk(clk),.reset(rst),.s(inst),.seg(seg),.ans(ans));
endmodule
