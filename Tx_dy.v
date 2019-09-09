`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:48:15 04/01/2013 
// Design Name: 
// Module Name:    Tx_dy 
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


module Tx_dy(
				input reset_n,
				input clk_20M,
				input PWM_L,
				input PWM_R,
				input [15:0]ControlWord,//主从判断后最终的控制命令字
				input [15:0]PhaseStaA,//给控保最终的相状态字
				input discharge,
				input bypass,//A/B/C冗余位置字
				input start,
				input lock,
				output M_T
);

parameter txd_num = 12;

wire tx_en;
wire [txd_num-1:0] module_con;

Controlprior conmodule (
								.reset_n(reset_n),
								.clk_20M(clk_20M),
								.PWM_L(PWM_L),
								.PWM_R(PWM_R),
								.ControlWord(ControlWord),
								.PhaseStaA(PhaseStaA),
								.bypass(bypass),//调换
								.discharge(discharge),//调换
								.start(start),
								.lock(lock),
								.module_con(module_con),
								.tx_en(tx_en)
);
Man_Txdy #(txd_num) Man_Txmodule (
								
								.clk_20M(clk_20M),
								.reset_n(reset_n),
								.txd_en(tx_en),
								.data_in(module_con),
								.txd(M_T)
);



endmodule
