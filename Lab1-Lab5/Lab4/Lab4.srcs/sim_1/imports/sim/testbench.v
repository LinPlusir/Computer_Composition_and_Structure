`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/07 13:54:42
// Design Name: 
// Module Name: testbench
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


module testbench();
	reg clk;
	reg rst;
    reg [4:0]regfile_address;
	wire[31:0] writedata,aluout;
	wire[31:0] instr,pc,readdata;
	wire memwrite;
	wire [31:0]reg_out;

	top dut(
		.clk(clk),
		.rst(rst),
		.writedata(writedata),
		.aluout(aluout),
		.memwrite(memwrite),
		.instr(instr),
		.pc(pc),
		.readdata(readdata),
		.regfile_address(regfile_address),
		.reg_out(reg_out)
	);

	initial begin 
		rst <= 1;regfile_address<=5'b00000;
		#200;
		rst <= 0;
	end

	always begin
		clk <= 1;
		#10;
		clk <= 0;
		#10;
	end

	always @(negedge clk) begin
		if(memwrite) begin
			/* code */
			if(aluout === 84 & writedata === 7) begin
				/* code */
				$display("===============>Simulation succeeded");
				$stop;
			end else if(aluout !== 80) begin
				/* code */
				$display("===============>Simulation Failed");
				$stop;
			end
		end
	end
endmodule
