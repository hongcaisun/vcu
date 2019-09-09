`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:47:16 07/14/2015 
// Design Name: 
// Module Name:    chufaqi 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

(* bram_map = "yes" *)

module Div_shift(clk,dividend,divisor,quotient);

input wire clk;
input wire[31:0] dividend;
input wire[15:0] divisor;
output reg[31:0] quotient = 32'h0000_0000;

reg[31:0] tempa = 32'd0;
reg[31:0] tempb = 32'd0;

reg[63:0] temp_a = 64'h0000_0000_0000_0000;
reg[63:0] temp_b = 64'h0000_0000_0000_0000;

reg flag = 1'b0;
reg[5:0] counter = 6'd0;

always@(posedge clk)	begin
//被除数和除数有一个更新的情况，就重新赋值，并准备计算
if((tempa != dividend) || (tempb != divisor)) begin
	flag = 1'b1;
	tempa = dividend;
	tempb = {16'h0000,divisor};
end
else begin
	flag = 1'b0;
	tempa = dividend;
	tempb = {16'h0000,divisor};
end
//除法计算开始	
if(flag)	begin
	counter = 6'd0;
	flag = 1'b0;
end
else
	case(counter)
		0 : begin
			temp_a = tempa[31] ? {32'h0000_0000, ~tempa + 1} : {32'h0000_0000, tempa};//负数转换成无符号数
			temp_b = {tempb, 32'h0000_0000};
			counter = counter + 1'b1;	
		end
		
		1,2,3,4,5,6,7,8,9,10,
		11,12,13,14,15,16,17,
		18,19,20,21,22,23,24,
		25,26,27,28,29,30,31,
		32 :	begin
			temp_a = {temp_a[62:0], 1'b0};
			if (temp_a[63:32] >= tempb) temp_a = temp_a - temp_b + 1'b1;
			else temp_a = temp_a;
			counter = counter + 1'b1;	
		end

		33 : begin
			counter = 6'd0;
			quotient = tempa[31] ? {~temp_a[31:0] + 1} : temp_a[31:0];
		end
	endcase
end
endmodule







