`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/03 11:40:59
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


module pc (
	input wire clk,rst,en,
	input wire[31:0] d,
	output reg[31:0] q
    );
	always @(posedge clk,posedge rst) begin
		if(rst) begin
			q <= 32'h00000000;
		end else if(en) begin
			q <= d;
		end
	end
endmodule