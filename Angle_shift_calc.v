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
parameter   Freq_Min = 153;//����Ƶ��������153Hz-1Khz
parameter   Freq_Max = 1000;

reg [15:0]  Frequency_reg;
wire [31:0] cnt_Freq;//20Mʱ�Ӽ��ز�1/2���� =10^7���Կ���Ƶ��
wire [31:0] angle_shiftA_temp,angle_shiftB_temp,angle_shiftC_temp;//ABC����ÿ��ģ�������
assign      o_angle_shiftA = angle_shiftA_temp[15:0];
assign      o_angle_shiftB = angle_shiftB_temp[15:0];
assign      o_angle_shiftC = angle_shiftC_temp[15:0];

assign      o_Freqency_cnt  = cnt_Freq[15:0] - 16'd1;
assign      o_temp  = cnt_Freq[15:0]>>1; //�ѵ��Ʋ��ɡ��ز�1/4���ڣ���ת��0-�ز�1/2����
assign      o_temp_long = o_temp; 

//-----------------����Ƶ��������153Hz-1Khz---------------------
always @ (posedge i_clk_20M)
begin
   if(!i_reset_n)
	   Frequency_reg <= 16'd0;
   else if(i_SwitchFreq<=Freq_Min)//153Hz,����ǽӽ�65535����ֹ��������
	   Frequency_reg <= Freq_Min;
	else if(i_SwitchFreq>=Freq_Max)
	   Frequency_reg <= Freq_Max;
	else Frequency_reg <= i_SwitchFreq;
end
/////////////////////////////////////////////////////////////////
//�����ز������ڼ�������----20Mʱ��
//һ���ز����ڣ�T= 1/����Ƶ��---��λ��s
//����ز����ڣ�T1=1/2*����Ƶ��---��λ��s
//20Mʱ�Ӽư���ز���������ʱ�Ӹ�����T1/(1/20M)=20M*T1=10M/����Ƶ��
//                   /|\10M/����Ƶ��
//						  / | \
//						 /  |  \
//						/   |   \
//					  /    |    \
//					 /     |     \
//					/      |      \
//				  /       |       \
//			 0  / _______|______  \ 0
//          0<-------->10M/����Ƶ��
//          (____  ___)
//               \/
//               �ư���ز���������ʱ�Ӹ���,ͬʱ��ʱ�Ӹ�����Ϊ�ز���ֵ
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
