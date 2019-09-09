`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:44:24 03/14/2019 
// Design Name: 
// Module Name:    Ave_TargetVol_calc 
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
module Ave_TargetVol_calc(
								 input i_clk_20M,
								 input i_reset_n,
								 input [15:0]i_VCU_Mode,	 			 
								 input signed[31:0]i_TargetVolA,
								 input signed[31:0]i_TargetVolB,
								 input signed[31:0]i_TargetVolC,
								 input [15:0]i_LinkNumA_Work,
								 input [15:0]i_LinkNumB_Work,
								 input [15:0]i_LinkNumC_Work,
								 
								 output signed[15:0]o_Ave_TargetVolA,
								 output signed[15:0]o_Ave_TargetVolB,
								 output signed[15:0]o_Ave_TargetVolC
                         );								 

wire signed[31:0]DividendA = i_TargetVolA;	
wire signed[31:0]DividendB = i_TargetVolB;	
wire signed[31:0]DividendC = i_TargetVolC;	

wire signed[31:0]Ave_TargetVolA_temp;
wire signed[31:0]Ave_TargetVolB_temp;
wire signed[31:0]Ave_TargetVolC_temp;
assign o_Ave_TargetVolA = Ave_TargetVolA_temp[15:0];
assign o_Ave_TargetVolB = Ave_TargetVolB_temp[15:0];
assign o_Ave_TargetVolC = Ave_TargetVolC_temp[15:0];

Div_shift divA (
	.clk(i_clk_20M),
	.dividend(DividendA), // Bus [31 : 0] 
	.divisor(i_LinkNumA_Work), // Bus [15 : 0] 
	.quotient(Ave_TargetVolA_temp) // Bus [31 : 0] 
	); // Bus [15 : 0] 
Div_shift divB (
	.clk(i_clk_20M),
	.dividend(DividendB), // Bus [31 : 0] 
	.divisor(i_LinkNumB_Work), // Bus [15 : 0] 
	.quotient(Ave_TargetVolB_temp) // Bus [31 : 0] 
	); // Bus [15 : 0] 
Div_shift divC (
	.clk(i_clk_20M),
	.dividend(DividendC), // Bus [31 : 0] 
	.divisor(i_LinkNumC_Work), // Bus [15 : 0] 
	.quotient(Ave_TargetVolC_temp) // Bus [31 : 0] 
	); // Bus [15 : 0] 

endmodule
