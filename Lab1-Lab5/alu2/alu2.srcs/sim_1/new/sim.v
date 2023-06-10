`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/03/27 22:43:59
// Design Name: 
// Module Name: sim
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


module sim(


    );
    reg [7:0]num1;
    reg [31:0]num2;
    reg [2:0] op;
    wire [31:0]res;
    ALU u(.num1(num1),.num2(num2),.op(op),.res(res));
    initial begin
    num1=8'b00000011;num2=32'h00000001;op=3'b000;
    #10 op=3'b001;
    #10 op=3'b010;
    #10 op=3'b011;
    #10 op=3'b100;
    #10 op=3'b101;
    end 
endmodule
