`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/03 11:23:01
// Design Name: 
// Module Name: aludec
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


module aludec(
     input [1:0]aluop,
     input [5:0]funct,
     output [2:0]alucontrol
    );
    reg [2:0] a;
    always@(*)
    begin
    if(aluop==2'b00)//sw,lw,addi
       begin
       a<=3'b010;
       end
    else if(aluop==2'b01)//beq
       begin
       a<=3'b110;
       end
    else if(aluop==2'b10) //R-type
        begin
        if(funct==6'b100000) a<=3'b010; //add
        else if(funct==6'b100010) a<=3'b110;//sub
        else if(funct==6'b100100) a<=3'b000;//and
        else if(funct==6'b100101) a<=3'b001;//or
        else if(funct==6'b101010) a<=3'b111;//slt
        end
    end
    assign alucontrol=a;
endmodule
