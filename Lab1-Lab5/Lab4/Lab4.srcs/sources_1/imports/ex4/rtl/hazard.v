`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/06 20:23:13
// Design Name: 
// Module Name: hazard
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


module hazard(

	
	input wire[4:0] rsD,rtD,
	input wire branchD,
	input wire[4:0] rsE,rtE,
	input wire[4:0] writeregE,
	input wire regwriteE,
	input wire memtoregE,
	input wire[4:0] writeregM,
	input wire regwriteM,
	input wire memtoregM,
	input wire[4:0] writeregW,
	input wire regwriteW,
	
	output wire stallF,
	output wire forwardAD,forwardBD,
	output wire stallD,
	output reg[1:0] forwardAE,forwardBE,
	output wire flushE
);

	wire lwstallD,branchstallD;

	//branch_数据前推 ID
	assign forwardAD = (rsD != 0 & rsD == writeregM & regwriteM);
	assign forwardBD = (rtD != 0 & rtD == writeregM & regwriteM);
	
	
    //数据前推：判断读的是否为0号寄存器，判断寄存器号是否相同，判断依赖的指令是否在回写寄存器堆
    //00为rd1,01为resultW,10为aluoutM
  always @(*) begin
		forwardAE = 2'b00;
		forwardBE = 2'b00;
		if(rsE != 0) 
		begin
			if(rsE == writeregM & regwriteM)
			 begin
				forwardAE = 2'b10;
			end 
			else if(rsE == writeregW & regwriteW)
			 begin
				forwardAE = 2'b01;
			end
		end
		if(rtE != 0) 
		begin
			if(rtE == writeregM & regwriteM)
			 begin
				forwardBE = 2'b10;
			end 
			else if(rtE == writeregW & regwriteW) 
			begin
				forwardBE = 2'b01;
			end
		end
	end

	//stalls
	assign #1 lwstallD = memtoregE & (rtE == rsD | rtE == rtD);
	assign #1 branchstallD=(branchD&regwriteE&((writeregE==rsD)|(writeregM==rtD)))
                       |(branchD&memtoregM&((writeregM==rsD)|(writeregM==rtD)));
	assign #1 stallD = lwstallD | branchstallD;
	assign #1 stallF = lwstallD | branchstallD;
	assign #1 flushE = lwstallD | branchstallD;

endmodule
