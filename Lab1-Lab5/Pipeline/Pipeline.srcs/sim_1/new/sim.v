`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/03/28 00:05:09
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
    reg [31:0] cin_a;
    reg [31:0] cin_b;
    reg clk;
    reg rst;
    reg cin;
    reg stop;
    wire cout;
    wire [31:0] sum;
initial begin 
    clk=1;
    rst=0;
    stop=0;
    cin_a=32'h0000_0000;cin_b=32'h0000_0000;cin=1'b0;
    @(posedge clk) cin_a=32'h0000_0001;cin_b=32'h0000_0001;cin=1'b0;
    @(posedge clk) cin_a=32'h0000_0001;cin_b=32'h0000_0001;cin=1'b0;
    @(posedge clk) cin_a=32'h0000_0010;cin_b=32'h0000_0001;cin=1'b0;
    @(posedge clk) cin_a=32'h0000_0100;cin_b=32'h0000_0001;cin=1'b0;
    @(posedge clk) cin_a=32'h0000_1000;cin_b=32'h0000_0001;cin=1'b0;
    @(posedge clk) cin_a=32'h0001_0000;cin_b=32'h0000_0001;cin=1'b0;
    @(posedge clk) cin_a=32'h0010_0000;cin_b=32'h0000_0001;cin=1'b0;
    @(posedge clk) cin_a=32'h0100_0000;cin_b=32'h0000_0001;cin=1'b0;
    @(posedge clk) cin_a=32'h1000_0000;cin_b=32'h0000_0001;cin=1'b0;
    @(posedge clk) stop=1;cin_a=32'h1000_0001;cin_b=32'h0000_0001;cin=1'b0;
    @(posedge clk) cin_a=32'h1000_0010;cin_b=32'h0000_0001;cin=1'b0;
    @(posedge clk) stop=0;cin_a=32'h0100_1111;cin_b=32'h0000_0001;cin=1'b0;
    @(posedge clk) cin_a=32'h1000_0001;cin_b=32'h0000_0001;cin=1'b0;
    @(posedge clk) rst=1;cin_a=32'h1000_0001;cin_b=32'h0000_0001;cin=1'b0;
    @(posedge clk) cin_a=32'h1000_0011;cin_b=32'h0000_0001;cin=1'b0;
    @(posedge clk) cin_a=32'h1000_1011;cin_b=32'h0000_0001;cin=1'b0;
    @(posedge clk) cin_a=32'h1000_0111;cin_b=32'h0000_0001;cin=1'b0;
    repeat(10) @(posedge clk);
    $finish;
end
always #10 clk=~clk;
stallable_pipeline_adder u(cin_a,cin_b,rst,clk,stop,cin,cout,sum);
endmodule
