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


module pc(
input wire clk,rst,
input wire [31:0] pc_next,
output reg [31:0] pc,
output reg inst_ce);
reg start;
always@(posedge clk or posedge rst) begin
    if(rst) begin
        inst_ce<=0;
        pc <= 32'h00000000;
        start <= 0;
    end
    else begin
        if(start == 0) begin
           start <= 1;
           inst_ce<=1;
           pc <= 32'h00000000;
        end
        else begin
            inst_ce<=1;
            if(clk) begin
               pc<=pc_next;
            end               
        end
    end
end

endmodule

