`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/07 13:58:49
// Design Name: 
// Module Name: debkey
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


module debkey(  //按键消抖
    input clk, //防抖模块的内置时钟信号
    input reset,
    input key1,
    output debkey1
    );
    //100hz分频
    parameter T100Hz=249999;
    integer cnt_100HZ;
    reg clk_100Hz;
    always@(posedge clk or negedge reset)
      begin
        if(!reset)
            cnt_100HZ<=32'b0;
        else
          begin
           cnt_100HZ<=cnt_100HZ+1'b1;
           if(cnt_100HZ==T100Hz)
             begin
             cnt_100HZ<=32'b0;
             clk_100Hz<=~ clk_100Hz;    
             end        
          end
      end
     //去抖
     reg [1:0]key_rrr,key_rr,key_r;
     always@(posedge clk_100Hz or negedge reset)
      begin
        if(!reset)
          begin
           key_rrr<=1'b1;
           key_rr<=1'b1;
           key_r<=1'b1;      
           end
        else
          begin
           key_rrr[0]<=key_rr[0];
           key_rr[0]<=key_r[0];
           key_r[0]<=key1; 
          end
      end
      assign debkey1=key_rrr[0]&key_rr[0]&key_r[0];

endmodule
