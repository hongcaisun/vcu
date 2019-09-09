`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:44:41 03/14/2019 
// Design Name: 
// Module Name:    Angle_shift_calc 
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
module Angle_shift_calc(
								 input i_clk_20M,
								 input i_reset_n,
								 input [15:0]i_VCU_Mode,
								 input [15:0]i_SwitchFreq,
								 input [15:0]i_LinkNumA_Work,
								 input [15:0]i_LinkNumB_Work,
								 input [15:0]i_LinkNumC_Work,
								 output [15:0]o_Freqency_cnt,
								 output signed[15:0]o_temp,
								 output signed[31:0]o_temp_long,
								 output [15:0]o_angle_shiftA,
								 output [15:0]o_angle_shiftB,
								 output [15:0]o_angle_shiftC
                       );
							  
parameter   Dividend = 10_000_000;//10^7
parameter   Freq_Min = 153;//开关频率限制在153Hz-1Khz
parameter   Freq_Max = 1000;

reg [15:0]  Frequency_reg;
wire [31:0] cnt_Freq;//20M时钟计载波1/2周期 =10^7除以开关频率
wire [31:0] angle_shiftA_temp,angle_shiftB_temp,angle_shiftC_temp;//ABC三相每个模块移相角
assign      o_angle_shiftA = angle_shiftA_temp[15:0];
assign      o_angle_shiftB = angle_shiftB_temp[15:0];
assign      o_angle_shiftC = angle_shiftC_temp[15:0];

assign      o_Freqency_cnt  = cnt_Freq[15:0] - 16'd1;
assign      o_temp  = cnt_Freq[15:0]>>1; //把调制波由±载波1/4周期，翻转到0-载波1/2周期
assign      o_temp_long = o_temp; 

//-----------------开关频率限制在153Hz-1Khz---------------------
always @ (posedge i_clk_20M)
begin
   if(!i_reset_n)
	   Frequency_reg <= 16'd0;
   else if(i_SwitchFreq<=Freq_Min)//153Hz,移相角接近65535，防止移相角溢出
	   Frequency_reg <= Freq_Min;
	else if(i_SwitchFreq>=Freq_Max)
	   Frequency_reg <= Freq_Max;
	else Frequency_reg <= i_SwitchFreq;
end
/////////////////////////////////////////////////////////////////
//计算载波半周期计数个数----20M时钟
//一个载波周期：T= 1/开关频率---单位：s
//半个载波周期：T1=1/2*开关频率---单位：s
//20M时钟计半个载波周期所需时钟个数：T1/(1/20M)=20M*T1=10M/开关频率
//                   /|\10M/开关频率
//						  / | \
//						 /  |  \
//						/   |   \
//					  /    |    \
//					 /     |     \
//					/      |      \
//				  /       |       \
//			 0  / _______|______  \ 0
//          0<-------->10M/开关频率
//          (____  ___)
//               \/
//               计半个载波周期所需时钟个数,同时把时钟个数作为载波幅值
//////////////////////////////////////////////////////////////////
Div_shift div1 (
	.clk(i_clk_20M),
	.dividend(Dividend), // Bus [31 : 0] 
	.divisor(Frequency_reg), // Bus [15 : 0] 
	.quotient(cnt_Freq) // Bus [31 : 0] 
	); // Bus [15 : 0] 
	
Div_shift divA (
	.clk(i_clk_20M),
	.dividend(cnt_Freq), // Bus [31 : 0] 
	.divisor(i_LinkNumA_Work), // Bus [15 : 0] 
	.quotient(angle_shiftA_temp) // Bus [31 : 0] 
   ); // Bus [15 : 0] 
Div_shift divB (
	.clk(i_clk_20M),
	.dividend(cnt_Freq), // Bus [31 : 0] 
	.divisor(i_LinkNumB_Work), // Bus [15 : 0] 
	.quotient(angle_shiftB_temp) // Bus [31 : 0] 
   ); // Bus [15 : 0] 	
Div_shift divC (
	.clk(i_clk_20M),
	.dividend(cnt_Freq), // Bus [31 : 0] 
	.divisor(i_LinkNumC_Work), // Bus [15 : 0] 
	.quotient(angle_shiftC_temp) // Bus [31 : 0] 
   ); // Bus [15 : 0] 	
endmodule
