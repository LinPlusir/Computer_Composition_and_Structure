`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/06 19:54:22
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
	input wire clk,rst,
	input wire [4:0]regfile_address,
	//IF
	output wire[31:0] pcF,
	input wire[31:0] instrF,

	//ID
	input wire branchD,
	input wire jumpD,
	output wire[5:0] opD,functD,
    output wire [31:0]reg_out,//regs输出值
	//EX
	input wire memtoregE,
	input wire alusrcE,
	input wire regdstE,
	input wire regwriteE,
	input wire[2:0] alucontrolE,
	output wire flushE,

	//MEM
	input wire memtoregM,
	input wire regwriteM,
	output wire[31:0] aluoutM,
	output wire[31:0]writedataM,
	input wire[31:0] readdataM,

	//WB
	input wire memtoregW,
	input wire regwriteW
);
	

	
	

wire [4:0] writeregW;
wire [31:0] aluoutW,readdataW,resultW;


//IF
wire stallF;
//pc也是一个触发器
wire [31:0]pc_next,pcplus4F;

 pc pc0(clk,rst,~stallF,pc_next,pcF);
 adder pcadd(pcF,32'b100,pcplus4F);
 

//F-D
wire pcsrcD,equalD;
wire [31:0] pcplus4D,instrD;
wire forwardAD,forwardBD;
wire [4:0] rsD,rtD,rdD;
wire flushD,stallD;
flopenr #(32) fd1(clk,rst,~stallD,pcplus4F,pcplus4D);
flopenrc #(32) fd2(clk,rst,~stallD,flushD,instrF,instrD);


//ID
assign opD = instrD[31:26];
assign functD = instrD[5:0];
assign rsD = instrD[25:21];
assign rtD = instrD[20:16];
assign rdD = instrD[15:11];

//符号扩展
wire [31:0] signimmD,signimmD_sl2;
signext signext0(instrD[15:0],signimmD);
sl2 sll(signimmD,signimmD_sl2);
wire [31:0]pcbranchD;

//pcbranch
adder pcadd2(pcplus4D,signimmD_sl2,pcbranchD);

//regfile 
wire [31:0]rd1D,rd2D;
regfile rf(clk,regwriteW,rsD,rtD,writeregW,resultW,regfile_address,reg_out,rd1D,rd2D);


//equalD
wire [31:0] srcAD,srcBD;
mux2 #(32) mux1(rd1D,aluoutM,forwardAD,srcAD);
mux2 #(32) mux2(rd2D,aluoutM,forwardBD,srcBD);
eqcmp comp(srcAD,srcBD,equalD);
assign pcsrcD = branchD & equalD;

 //pc_jump&pc_next
wire [31:0]pc_tmp,pc_jump;
mux2 #(32) mux3(pcplus4F,pcbranchD,pcsrcD,pc_tmp);
assign pc_jump={pcplus4D[31:28],instrD[25:0],2'b00};
mux2 #(32) pcmux(pc_tmp,pc_jump,jumpD,pc_next);
	
//D-E
wire [31:0] rd1E,rd2E;
wire [4:0] rsE,rtE,rdE;
wire [31:0] signimmE;
floprc #(32) de1(clk,rst,flushE,rd1D,rd1E);
floprc #(32) de2(clk,rst,flushE,rd2D,rd2E);
floprc #(32) de3(clk,rst,flushE,signimmD,signimmE);
floprc #(5) de4(clk,rst,flushE,rsD,rsE);
floprc #(5) de5(clk,rst,flushE,rtD,rtE);
floprc #(5) de6(clk,rst,flushE,rdD,rdE);

	
//EX
wire [31:0]srcAE,srcBE,writedataE;
wire [31:0] aluoutE;
wire [4:0] writeregE;
wire [1:0] forwardAE,forwardBE;
mux3 #(32) mux_3(rd1E,resultW,aluoutM,forwardAE,srcAE);
mux3 #(32) mux4(rd2E,resultW,aluoutM,forwardBE,writedataE);
mux2 #(32) mux5(writedataE,signimmE,alusrcE,srcBE);	
mux2 #(5) mux6(rtE,rdE,regdstE,writeregE);
alu alu(srcAE,srcBE,alucontrolE,aluoutE);

//E-M
wire [4:0] writeregM;
flopr #(32) em1(clk,rst,aluoutE,aluoutM);
flopr #(32) em2(clk,rst,writedataE,writedataM);
flopr #(5) em3(clk,rst,writeregE,writeregM);


//M-W
flopr #(32) mw1(clk,rst,readdataM,readdataW);	
flopr #(32) mw2(clk,rst,aluoutM,aluoutW);
flopr #(5) mw3(clk,rst,writeregM,writeregW);
mux2 #(32) mux7(aluoutW,readdataW,memtoregW,resultW);
		
//冒险
	hazard hazard0(
		.stallF(stallF),
		.rsD(rsD),
		.rtD(rtD),
		.branchD(branchD), 
		.forwardAD(forwardAD),
		.forwardBD(forwardBD),
		.stallD(stallD),
		.rsE(rsE),
		.rtE(rtE),
		.writeregE(writeregE),
		.regwriteE(regwriteE),
		.memtoregE(memtoregE),
		.forwardAE(forwardAE),
		.forwardBE(forwardBE),
		.flushE(flushE),
		.writeregM(writeregM),
		.regwriteM(regwriteM),
		.memtoregM(memtoregM),
		.writeregW(writeregW),
		.regwriteW(regwriteW)
	);
endmodule
