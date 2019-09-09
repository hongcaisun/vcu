`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:44:04 03/14/2019 
// Design Name: 
// Module Name:    Ave_phaseUdc_calc 
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
module Ave_phaseUdc_calc(
								 input i_clk_20M,
								 input i_reset_n,
								 input [15:0]i_VCU_Mode,	 			 
								 input [383:0]i_LinkUdcA_BUS,
								 input [383:0]i_LinkUdcB_BUS,
								 input [383:0]i_LinkUdcC_BUS,
								 input [15:0]i_LinkNumA_Work,
								 input [15:0]i_LinkNumB_Work,
								 input [15:0]i_LinkNumC_Work,
								 
								 output [15:0]o_PhaseA_Udc,
								 output [15:0]o_PhaseB_Udc,
								 output [15:0]o_PhaseC_Udc
                         );

reg [31:0]sum_LinkUdc_temp;
reg [31:0]sum_LinkUdcA;
reg [31:0]sum_LinkUdcB;
reg [31:0]sum_LinkUdcC;
reg [9:0]sum_cnt;	
reg [383:0]LinkUdc_BUS_temp;

wire[31:0]DividendA = sum_LinkUdcA;	
wire[31:0]DividendB = sum_LinkUdcB;	
wire[31:0]DividendC = sum_LinkUdcC;	

wire[31:0]o_PhaseA_Udc_temp;
wire[31:0]o_PhaseB_Udc_temp;
wire[31:0]o_PhaseC_Udc_temp;
assign o_PhaseA_Udc = o_PhaseA_Udc_temp[15:0];	
assign o_PhaseB_Udc = o_PhaseB_Udc_temp[15:0];
assign o_PhaseC_Udc = o_PhaseC_Udc_temp[15:0];
				 
always @ (posedge i_clk_20M)
begin
	if(!i_reset_n)begin
	   sum_cnt<=0;
		sum_LinkUdcA<=0;
	   sum_LinkUdc_temp<=0;
		LinkUdc_BUS_temp<=0;
	end
	else begin
	   if(sum_cnt==0)begin
		   LinkUdc_BUS_temp<=i_LinkUdcA_BUS;
			sum_cnt<=sum_cnt+1;
			sum_LinkUdc_temp<=0;
		end
		else if(sum_cnt<=24)begin
		   LinkUdc_BUS_temp <= LinkUdc_BUS_temp >> 16;
			sum_cnt<=sum_cnt+1;
			sum_LinkUdc_temp<=sum_LinkUdc_temp + LinkUdc_BUS_temp[15:0];
		end
		else if(sum_cnt==25)begin
		   LinkUdc_BUS_temp <= i_LinkUdcB_BUS;
			sum_cnt<=sum_cnt+1;
			if(i_VCU_Mode==16'h55aa)begin//三相合一时不再累加,A相计算完成
			  sum_LinkUdc_temp<=0;
			  sum_LinkUdcA<=sum_LinkUdc_temp;//A相累加和	
         end
         else begin
			  sum_LinkUdc_temp<=sum_LinkUdc_temp;
         end			
		end
		else if(sum_cnt<=49)begin
		   LinkUdc_BUS_temp <= LinkUdc_BUS_temp >> 16;
			sum_cnt<=sum_cnt+1;
			sum_LinkUdc_temp<=sum_LinkUdc_temp + LinkUdc_BUS_temp[15:0];
		end
		else if(sum_cnt==50)begin
		   LinkUdc_BUS_temp <= i_LinkUdcC_BUS;
			sum_cnt<=sum_cnt+1;
			if(i_VCU_Mode==16'h55aa)begin//三相合一时不再累加,B相计算完成
			  sum_LinkUdc_temp<=0;
			  sum_LinkUdcB<=sum_LinkUdc_temp;//B相累加和	
         end
         else begin
			  sum_LinkUdc_temp<=sum_LinkUdc_temp;
         end			
		end 
		else if(sum_cnt<=74)begin
		   LinkUdc_BUS_temp <= LinkUdc_BUS_temp >> 16;
			sum_cnt<=sum_cnt+1;
			sum_LinkUdc_temp<=sum_LinkUdc_temp + LinkUdc_BUS_temp[15:0];
		end
		else if(sum_cnt==75)begin
		   LinkUdc_BUS_temp <= 0;
			sum_cnt<=0;//重新开始计算
			if(i_VCU_Mode==16'h55aa)begin//三相合一时不再累加,C相计算完成
			  sum_LinkUdc_temp<=0;
			  sum_LinkUdcC<=sum_LinkUdc_temp;	//C相累加和
         end
         else begin
			  sum_LinkUdcA<=sum_LinkUdc_temp;//单相时，3个累加和最终赋给A相
         end			
		end 
	end
end

Div_shift divA (
	.clk(i_clk_20M),
	.dividend(DividendA), // Bus [31 : 0]被除数 
	.divisor(i_LinkNumA_Work), // Bus [15 : 0]除数 
	.quotient(o_PhaseA_Udc_temp) // Bus [31 : 0] 商
	); // Bus [15 : 0] 
Div_shift divB (
	.clk(i_clk_20M),
	.dividend(DividendB), // Bus [31 : 0] 
	.divisor(i_LinkNumB_Work), // Bus [15 : 0] 
	.quotient(o_PhaseB_Udc_temp) // Bus [31 : 0] 
	); // Bus [15 : 0] 
Div_shift divC (
	.clk(i_clk_20M),
	.dividend(DividendC), // Bus [31 : 0] 
	.divisor(i_LinkNumC_Work), // Bus [15 : 0] 
	.quotient(o_PhaseC_Udc_temp) // Bus [31 : 0] 
	); // Bus [15 : 0] 
endmodule
