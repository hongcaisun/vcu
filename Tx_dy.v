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
				input [15:0]ControlWord,//�����жϺ����յĿ���������
				input [15:0]PhaseStaA,//���ر����յ���״̬��
				input discharge,
				input bypass,//A/B/C����λ����
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
								.bypass(bypass),//����
								.discharge(discharge),//����
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
