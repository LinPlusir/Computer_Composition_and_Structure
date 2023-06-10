`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/06 23:21:20
// Design Name: 
// Module Name: top_display
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


module top_display(
  input clk,
  input rst,
  input [9:0]seat,
  input [1:0]control,
  output [7:0]ans,
  output [6:0]seg
    );
   
      //时钟分频
    //时钟分频100mhz to 0.25hz
     //clk_4s
    parameter N=399_999999;
    parameter M=N/2;
    reg [32:0]count2;
    reg clk_4s;
    always@(posedge clk)
    begin
     clk_4s<=0;
     if(count2<M) count2<=count2+1;
     else
       begin
       count2<=0;
       clk_4s<=1;
       end
    end
    
    wire[31:0] writedata,aluout;
	wire[31:0] instr,pc,readdata;
	wire memwrite;
	
	wire [4:0]regfile_address;
	wire [31:0]reg_out;
	assign regfile_address=seat[4:0];
	
	mips mips1(
	.clk(clk_4s),
	.rst(rst),
	.pcF(pc),
	.instrF(instr),
	.memwriteM(memwrite),
	.aluoutM(aluout),
	.writedataM(writedata),
	.readdataM(readdata),
	.regfile_address(regfile_address),
	.reg_out(reg_out)
);

inst_ram inst_ram1 (
  .clka(~clk),    
  .ena(1'b1),      
  .wea(),      
  .addra(pc), 
  .dina(32'b0),    
  .douta(instr)  
);
wire [9:0]addra;
assign addra=(control[0]==1)?seat:aluout;
data_ram data_ram1 (
  .clka(~clk),  
  .ena(memwrite),      
  .wea({4{memwrite}}),   
  .addra(aluout),  
  .dina(writedata),    
  .douta(readdata)  
);
reg [31:0]dataram[0:100];
always@(*)
begin
if((seat==aluout)&memwrite)
begin
dataram[seat]<=readdata;
end
end

wire [31:0]s;

assign s=(control[1]==0)?reg_out:dataram[seat];

display b4(.clk(clk),.reset(rst),.s(s),.seg(seg),.ans(ans));
endmodule
