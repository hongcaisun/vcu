`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: CEPRI
// Engineer: ZDQ
// 
// Create Date:    15:19:44 05/28/2013 
// Design Name: 
// Module Name:    Tx_Unit 
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
module Tx_Unit(

       input i_clk,//      clk_20M
       input i_reset_n,//  i_reset_n,
       input [15:0] i_ControlWord,//主从判断后最终的控制命令字
       input [15:0] i_PhaseSta,//给控保最终的相状态字
       input i_start_Unit,//发送单元模块通信启动信号
       input i_lock,//单元功率模块封锁信号
		 input [15:0]i_Redun_pos1,//A/B/C冗余位置字
		 input [15:0]i_Redun_pos2,
		 input [15:0]i_Redun_pos3,
		 input [15:0]i_Redun_pos4,
		 input [15:0]i_Redun_pos5,
		 input [15:0]i_Redun_pos6,
       input [47:0] i_PWM_A_BUS,
       input [47:0] i_PWM_B_BUS,
       input [47:0] i_PWM_C_BUS,
       output [53:0] o_Module_TX
);	

parameter TXdy_bits = 12;
//-----------------------------PWM总线组转单个模块左右桥PWM---------------------------------//
wire 			MA1_A,MA1_B,MA2_A,MA2_B,MA3_A,MA3_B,MA4_A,MA4_B,MA5_A,MA5_B,MA6_A,
				MA6_B,MA7_A,MA7_B,MA8_A,MA8_B,MA9_A,MA9_B,MA10_A,MA10_B,MA11_A,
				MA11_B,MA12_A,MA12_B,MA13_A,MA13_B,MA14_A,MA14_B,MA15_A,MA15_B,
				MA16_A,MA16_B,MA17_A,MA17_B,MA18_A,MA18_B,MA19_A,MA19_B,MA20_A,
				MA20_B,MA21_A,MA21_B,MA22_A,MA22_B,MA23_A,MA23_B,MA24_A,MA24_B,
				MB1_A,MB1_B,MB2_A,MB2_B,MB3_A,MB3_B,MB4_A,MB4_B,MB5_A,MB5_B,MB6_A,
				MB6_B,MB7_A,MB7_B,MB8_A,MB8_B,MB9_A,MB9_B,MB10_A,MB10_B,MB11_A,
				MB11_B,MB12_A,MB12_B,MB13_A,MB13_B,MB14_A,MB14_B,MB15_A,MB15_B,
				MB16_A,MB16_B,MB17_A,MB17_B,MB18_A,MB18_B,MB19_A,MB19_B,MB20_A,
				MB20_B,MB21_A,MB21_B,MB22_A,MB22_B,MB23_A,MB23_B,MB24_A,MB24_B,								
				MC1_A,MC1_B,MC2_A,MC2_B,MC3_A,MC3_B,MC4_A,MC4_B,MC5_A,MC5_B,MC6_A,
				MC6_B,MC7_A,MC7_B,MC8_A,MC8_B,MC9_A,MC9_B,MC10_A,MC10_B,MC11_A,
				MC11_B,MC12_A,MC12_B,MC13_A,MC13_B,MC14_A,MC14_B,MC15_A,MC15_B,
				MC16_A,MC16_B,MC17_A,MC17_B,MC18_A,MC18_B,MC19_A,MC19_B,MC20_A,
				MC20_B,MC21_A,MC21_B,MC22_A,MC22_B,MC23_A,MC23_B,MC24_A,MC24_B;
				
PWM_BUS_Conv PWM_BUS_Conv(i_PWM_A_BUS,i_PWM_B_BUS,i_PWM_C_BUS,
				MA1_A,MA1_B,MA2_A,MA2_B,MA3_A,MA3_B,MA4_A,MA4_B,MA5_A,MA5_B,MA6_A,
				MA6_B,MA7_A,MA7_B,MA8_A,MA8_B,MA9_A,MA9_B,MA10_A,MA10_B,MA11_A,
				MA11_B,MA12_A,MA12_B,MA13_A,MA13_B,MA14_A,MA14_B,MA15_A,MA15_B,
				MA16_A,MA16_B,MA17_A,MA17_B,MA18_A,MA18_B,MA19_A,MA19_B,MA20_A,
				MA20_B,MA21_A,MA21_B,MA22_A,MA22_B,MA23_A,MA23_B,MA24_A,MA24_B,
				MB1_A,MB1_B,MB2_A,MB2_B,MB3_A,MB3_B,MB4_A,MB4_B,MB5_A,MB5_B,MB6_A,
				MB6_B,MB7_A,MB7_B,MB8_A,MB8_B,MB9_A,MB9_B,MB10_A,MB10_B,MB11_A,
				MB11_B,MB12_A,MB12_B,MB13_A,MB13_B,MB14_A,MB14_B,MB15_A,MB15_B,
				MB16_A,MB16_B,MB17_A,MB17_B,MB18_A,MB18_B,MB19_A,MB19_B,MB20_A,
				MB20_B,MB21_A,MB21_B,MB22_A,MB22_B,MB23_A,MB23_B,MB24_A,MB24_B,								
				MC1_A,MC1_B,MC2_A,MC2_B,MC3_A,MC3_B,MC4_A,MC4_B,MC5_A,MC5_B,MC6_A,
				MC6_B,MC7_A,MC7_B,MC8_A,MC8_B,MC9_A,MC9_B,MC10_A,MC10_B,MC11_A,
				MC11_B,MC12_A,MC12_B,MC13_A,MC13_B,MC14_A,MC14_B,MC15_A,MC15_B,
				MC16_A,MC16_B,MC17_A,MC17_B,MC18_A,MC18_B,MC19_A,MC19_B,MC20_A,
				MC20_B,MC21_A,MC21_B,MC22_A,MC22_B,MC23_A,MC23_B,MC24_A,MC24_B);
//-----------------------------PWM总线组转单个模块左右桥PWM end---------------------------------//
Tx_dy #(TXdy_bits)Tx_dy1(
									.reset_n(i_reset_n),				.clk_20M(i_clk),
									.PWM_L(MA1_A),						.PWM_R(MA1_B),//左右桥PWM
									.ControlWord(i_ControlWord),	.PhaseStaA(i_PhaseSta),
									.discharge(1'b0),					.bypass(i_Redun_pos1[0]),//A/B/C冗余位置字
									.start(i_start_Unit),			.lock(i_lock),
									.M_T(o_Module_TX[0])
);      
Tx_dy #(TXdy_bits)Tx_dy2(
									.reset_n(i_reset_n),				.clk_20M(i_clk),
									.PWM_L(MA2_A),						.PWM_R(MA2_B),
									.ControlWord(i_ControlWord),	.PhaseStaA(i_PhaseSta),
									.discharge(1'b0),					.bypass(i_Redun_pos1[1]),
									.start(i_start_Unit),			.lock(i_lock),
									.M_T(o_Module_TX[1])
);      
Tx_dy #(TXdy_bits)Tx_dy3(
									.reset_n(i_reset_n),				.clk_20M(i_clk),
									.PWM_L(MA3_A),						.PWM_R(MA3_B),
									.ControlWord(i_ControlWord),	.PhaseStaA(i_PhaseSta),
									.discharge(1'b0),					.bypass(i_Redun_pos1[2]),
									.start(i_start_Unit),			.lock(i_lock),
									.M_T(o_Module_TX[2])
);      
Tx_dy #(TXdy_bits)Tx_dy4(
									.reset_n(i_reset_n),				.clk_20M(i_clk),
									.PWM_L(MA4_A),						.PWM_R(MA4_B),
									.ControlWord(i_ControlWord),	.PhaseStaA(i_PhaseSta),
									.discharge(1'b0),					.bypass(i_Redun_pos1[3]),
									.start(i_start_Unit),			.lock(i_lock),
									.M_T(o_Module_TX[3])
);      
Tx_dy #(TXdy_bits)Tx_dy5(
									.reset_n(i_reset_n),				.clk_20M(i_clk),
									.PWM_L(MA5_A),						.PWM_R(MA5_B),
									.ControlWord(i_ControlWord),	.PhaseStaA(i_PhaseSta),
									.discharge(1'b0),					.bypass(i_Redun_pos1[4]),
									.start(i_start_Unit),			.lock(i_lock),
									.M_T(o_Module_TX[4])
);      
Tx_dy #(TXdy_bits)Tx_dy6(
									.reset_n(i_reset_n),				.clk_20M(i_clk),
									.PWM_L(MA6_A),						.PWM_R(MA6_B),
									.ControlWord(i_ControlWord),	.PhaseStaA(i_PhaseSta),
									.discharge(1'b0),					.bypass(i_Redun_pos1[5]),
									.start(i_start_Unit),			.lock(i_lock),
									.M_T(o_Module_TX[5])
);      
Tx_dy #(TXdy_bits)Tx_dy7(
									.reset_n(i_reset_n),				.clk_20M(i_clk),
									.PWM_L(MA7_A),						.PWM_R(MA7_B),
									.ControlWord(i_ControlWord),	.PhaseStaA(i_PhaseSta),
									.discharge(1'b0),					.bypass(i_Redun_pos1[6]),
									.start(i_start_Unit),			.lock(i_lock),
									.M_T(o_Module_TX[6])
);      
Tx_dy #(TXdy_bits)Tx_dy8(
									.reset_n(i_reset_n),				.clk_20M(i_clk),
									.PWM_L(MA8_A),						.PWM_R(MA8_B),
									.ControlWord(i_ControlWord),	.PhaseStaA(i_PhaseSta),
									.discharge(1'b0),					.bypass(i_Redun_pos1[7]),
									.start(i_start_Unit),			.lock(i_lock),
									.M_T(o_Module_TX[7])
);      
Tx_dy #(TXdy_bits)Tx_dy9(
									.reset_n(i_reset_n),				.clk_20M(i_clk),
									.PWM_L(MA9_A),						.PWM_R(MA9_B),
									.ControlWord(i_ControlWord),	.PhaseStaA(i_PhaseSta),
									.discharge(1'b0),					.bypass(i_Redun_pos1[8]),
									.start(i_start_Unit),			.lock(i_lock),
									.M_T(o_Module_TX[8])
);      
Tx_dy #(TXdy_bits)Tx_dy10(
									.reset_n(i_reset_n),				.clk_20M(i_clk),
									.PWM_L(MA10_A),					.PWM_R(MA10_B),
									.ControlWord(i_ControlWord),	.PhaseStaA(i_PhaseSta),
									.discharge(1'b0),					.bypass(i_Redun_pos1[9]),
									.start(i_start_Unit),			.lock(i_lock),
									.M_T(o_Module_TX[9])
);  
Tx_dy #(TXdy_bits)Tx_dy11(
									.reset_n(i_reset_n),				.clk_20M(i_clk),
									.PWM_L(MA11_A),					.PWM_R(MA11_B),
									.ControlWord(i_ControlWord),	.PhaseStaA(i_PhaseSta),
									.discharge(1'b0),					.bypass(i_Redun_pos1[10]),
									.start(i_start_Unit),			.lock(i_lock),
									.M_T(o_Module_TX[10])
);
Tx_dy #(TXdy_bits)Tx_dy12(
									.reset_n(i_reset_n),				.clk_20M(i_clk),
									.PWM_L(MA12_A),					.PWM_R(MA12_B),
									.ControlWord(i_ControlWord),	.PhaseStaA(i_PhaseSta),
									.discharge(1'b0),					.bypass(i_Redun_pos1[11]),
									.start(i_start_Unit),			.lock(i_lock),
									.M_T(o_Module_TX[11])
);
Tx_dy #(TXdy_bits)Tx_dy13(
									.reset_n(i_reset_n),				.clk_20M(i_clk),
									.PWM_L(MA13_A),					.PWM_R(MA13_B),
									.ControlWord(i_ControlWord),	.PhaseStaA(i_PhaseSta),
									.discharge(1'b0),					.bypass(i_Redun_pos1[12]),
									.start(i_start_Unit),			.lock(i_lock),
									.M_T(o_Module_TX[12])
);
Tx_dy #(TXdy_bits)Tx_dy14(
									.reset_n(i_reset_n),				.clk_20M(i_clk),
									.PWM_L(MA14_A),					.PWM_R(MA14_B),
									.ControlWord(i_ControlWord),	.PhaseStaA(i_PhaseSta),
									.discharge(1'b0),					.bypass(i_Redun_pos1[13]),
									.start(i_start_Unit),			.lock(i_lock),
									.M_T(o_Module_TX[13])
);
Tx_dy #(TXdy_bits)Tx_dy15(
									.reset_n(i_reset_n),				.clk_20M(i_clk),
									.PWM_L(MA15_A),					.PWM_R(MA15_B),
									.ControlWord(i_ControlWord),	.PhaseStaA(i_PhaseSta),
									.discharge(1'b0),					.bypass(i_Redun_pos1[14]),
									.start(i_start_Unit),			.lock(i_lock),
									.M_T(o_Module_TX[14])
);
Tx_dy #(TXdy_bits)Tx_dy16(
									.reset_n(i_reset_n),				.clk_20M(i_clk),
									.PWM_L(MA16_A),					.PWM_R(MA16_B),
									.ControlWord(i_ControlWord),	.PhaseStaA(i_PhaseSta),
									.discharge(1'b0),					.bypass(i_Redun_pos1[15]),
									.start(i_start_Unit),			.lock(i_lock),
									.M_T(o_Module_TX[15])
);
Tx_dy #(TXdy_bits)Tx_dy17(
									.reset_n(i_reset_n),				.clk_20M(i_clk),
									.PWM_L(MA17_A),					.PWM_R(MA17_B),
									.ControlWord(i_ControlWord),	.PhaseStaA(i_PhaseSta),
									.discharge(1'b0),					.bypass(i_Redun_pos2[0]),
									.start(i_start_Unit),			.lock(i_lock),
									.M_T(o_Module_TX[16])
); 
Tx_dy #(TXdy_bits)Tx_dy18(
									.reset_n(i_reset_n),				.clk_20M(i_clk),
									.PWM_L(MA18_A),					.PWM_R(MA18_B),
									.ControlWord(i_ControlWord),	.PhaseStaA(i_PhaseSta),
									.discharge(1'b0),					.bypass(i_Redun_pos2[1]),
									.start(i_start_Unit),			.lock(i_lock),
									.M_T(o_Module_TX[17])
); 
Tx_dy #(TXdy_bits)Tx_dy19(
									.reset_n(i_reset_n),				.clk_20M(i_clk),
									.PWM_L(MB1_A),					.PWM_R(MB1_B),
									.ControlWord(i_ControlWord),	.PhaseStaA(i_PhaseSta),
									.discharge(1'b0),					.bypass(i_Redun_pos3[0]),
									.start(i_start_Unit),			.lock(i_lock),
									.M_T(o_Module_TX[18])
); 
Tx_dy #(TXdy_bits)Tx_dy20(
									.reset_n(i_reset_n),				.clk_20M(i_clk),
									.PWM_L(MB2_A),					.PWM_R(MB2_B),
									.ControlWord(i_ControlWord),	.PhaseStaA(i_PhaseSta),
									.discharge(1'b0),					.bypass(i_Redun_pos3[1]),
									.start(i_start_Unit),			.lock(i_lock),
									.M_T(o_Module_TX[19])
); 
Tx_dy #(TXdy_bits)Tx_dy21(
									.reset_n(i_reset_n),				.clk_20M(i_clk),
									.PWM_L(MB3_A),					.PWM_R(MB3_B),
									.ControlWord(i_ControlWord),	.PhaseStaA(i_PhaseSta),
									.discharge(1'b0),					.bypass(i_Redun_pos3[2]),
									.start(i_start_Unit),			.lock(i_lock),
									.M_T(o_Module_TX[20])
); 
Tx_dy #(TXdy_bits)Tx_dy22(
									.reset_n(i_reset_n),				.clk_20M(i_clk),
									.PWM_L(MB4_A),					.PWM_R(MB4_B),
									.ControlWord(i_ControlWord),	.PhaseStaA(i_PhaseSta),
									.discharge(1'b0),					.bypass(i_Redun_pos3[3]),
									.start(i_start_Unit),			.lock(i_lock),
									.M_T(o_Module_TX[21])
); 
Tx_dy #(TXdy_bits)Tx_dy23(
									.reset_n(i_reset_n),				.clk_20M(i_clk),
									.PWM_L(MB5_A),					.PWM_R(MB5_B),
									.ControlWord(i_ControlWord),	.PhaseStaA(i_PhaseSta),
									.discharge(1'b0),					.bypass(i_Redun_pos3[4]),
									.start(i_start_Unit),			.lock(i_lock),
									.M_T(o_Module_TX[22])
); 
Tx_dy #(TXdy_bits)Tx_dy24(
									.reset_n(i_reset_n),				.clk_20M(i_clk),
									.PWM_L(MB6_A),					.PWM_R(MB6_B),
									.ControlWord(i_ControlWord),	.PhaseStaA(i_PhaseSta),
									.discharge(1'b0),					.bypass(i_Redun_pos3[5]),
									.start(i_start_Unit),			.lock(i_lock),
									.M_T(o_Module_TX[23])
);
Tx_dy #(TXdy_bits)Tx_dy25(
									.reset_n(i_reset_n),				.clk_20M(i_clk),
									.PWM_L(MB7_A),						.PWM_R(MB7_B),
									.ControlWord(i_ControlWord),	.PhaseStaA(i_PhaseSta),
									.discharge(1'b0),					.bypass(i_Redun_pos3[6]),
									.start(i_start_Unit),			.lock(i_lock),
									.M_T(o_Module_TX[24])
);      
Tx_dy #(TXdy_bits)Tx_dy26(
									.reset_n(i_reset_n),				.clk_20M(i_clk),
									.PWM_L(MB8_A),						.PWM_R(MB8_B),
									.ControlWord(i_ControlWord),	.PhaseStaA(i_PhaseSta),
									.discharge(1'b0),					.bypass(i_Redun_pos3[7]),
									.start(i_start_Unit),			.lock(i_lock),
									.M_T(o_Module_TX[25])
);
Tx_dy #(TXdy_bits)Tx_dy27(
									.reset_n(i_reset_n),				.clk_20M(i_clk),
									.PWM_L(MB9_A),						.PWM_R(MB9_B),
									.ControlWord(i_ControlWord),	.PhaseStaA(i_PhaseSta),
									.discharge(1'b0),					.bypass(i_Redun_pos3[8]),
									.start(i_start_Unit),			.lock(i_lock),
									.M_T(o_Module_TX[26])
);      
Tx_dy #(TXdy_bits)Tx_dy28(
									.reset_n(i_reset_n),				.clk_20M(i_clk),
									.PWM_L(MB10_A),						.PWM_R(MB10_B),
									.ControlWord(i_ControlWord),	.PhaseStaA(i_PhaseSta),
									.discharge(1'b0),					.bypass(i_Redun_pos3[9]),
									.start(i_start_Unit),			.lock(i_lock),
									.M_T(o_Module_TX[27])
);      
Tx_dy #(TXdy_bits)Tx_dy29(
									.reset_n(i_reset_n),				.clk_20M(i_clk),
									.PWM_L(MB11_A),						.PWM_R(MB11_B),
									.ControlWord(i_ControlWord),	.PhaseStaA(i_PhaseSta),
									.discharge(1'b0),					.bypass(i_Redun_pos3[10]),
									.start(i_start_Unit),			.lock(i_lock),
									.M_T(o_Module_TX[28])
);      
Tx_dy #(TXdy_bits)Tx_dy30(
									.reset_n(i_reset_n),				.clk_20M(i_clk),
									.PWM_L(MB12_A),						.PWM_R(MB12_B),
									.ControlWord(i_ControlWord),	.PhaseStaA(i_PhaseSta),
									.discharge(1'b0),					.bypass(i_Redun_pos3[11]),
									.start(i_start_Unit),			.lock(i_lock),
									.M_T(o_Module_TX[29])
); 
Tx_dy #(TXdy_bits)Tx_dy31(
									.reset_n(i_reset_n),				.clk_20M(i_clk),
									.PWM_L(MB13_A),						.PWM_R(MB13_B),
									.ControlWord(i_ControlWord),	.PhaseStaA(i_PhaseSta),
									.discharge(1'b0),					.bypass(i_Redun_pos3[12]),
									.start(i_start_Unit),			.lock(i_lock),
									.M_T(o_Module_TX[30])
);      
Tx_dy #(TXdy_bits)Tx_dy32(
									.reset_n(i_reset_n),				.clk_20M(i_clk),
									.PWM_L(MB14_A),						.PWM_R(MB14_B),
									.ControlWord(i_ControlWord),	.PhaseStaA(i_PhaseSta),
									.discharge(1'b0),					.bypass(i_Redun_pos3[13]),
									.start(i_start_Unit),			.lock(i_lock),
									.M_T(o_Module_TX[31])
);      
Tx_dy #(TXdy_bits)Tx_dy33(
									.reset_n(i_reset_n),				.clk_20M(i_clk),
									.PWM_L(MB15_A),						.PWM_R(MB15_B),
									.ControlWord(i_ControlWord),	.PhaseStaA(i_PhaseSta),
									.discharge(1'b0),					.bypass(i_Redun_pos3[14]),
									.start(i_start_Unit),			.lock(i_lock),
									.M_T(o_Module_TX[32])
);      
Tx_dy #(TXdy_bits)Tx_dy34(
									.reset_n(i_reset_n),				.clk_20M(i_clk),
									.PWM_L(MB16_A),					.PWM_R(MB16_B),
									.ControlWord(i_ControlWord),	.PhaseStaA(i_PhaseSta),
									.discharge(1'b0),					.bypass(i_Redun_pos3[15]),
									.start(i_start_Unit),			.lock(i_lock),
									.M_T(o_Module_TX[33])
);      
Tx_dy #(TXdy_bits)Tx_dy35(
									.reset_n(i_reset_n),				.clk_20M(i_clk),
									.PWM_L(MB17_A),					.PWM_R(MB17_B),
									.ControlWord(i_ControlWord),	.PhaseStaA(i_PhaseSta),
									.discharge(1'b0),					.bypass(i_Redun_pos4[0]),
									.start(i_start_Unit),			.lock(i_lock),
									.M_T(o_Module_TX[34])
);      
Tx_dy #(TXdy_bits)Tx_dy36(
									.reset_n(i_reset_n),				.clk_20M(i_clk),
									.PWM_L(MB18_A),					.PWM_R(MB18_B),
									.ControlWord(i_ControlWord),	.PhaseStaA(i_PhaseSta),
									.discharge(1'b0),					.bypass(i_Redun_pos4[1]),
									.start(i_start_Unit),			.lock(i_lock),
									.M_T(o_Module_TX[35])
);      
Tx_dy #(TXdy_bits)Tx_dy37(
									.reset_n(i_reset_n),				.clk_20M(i_clk),
									.PWM_L(MC1_A),					.PWM_R(MC1_B),
									.ControlWord(i_ControlWord),	.PhaseStaA(i_PhaseSta),
									.discharge(1'b0),					.bypass(i_Redun_pos5[0]),
									.start(i_start_Unit),			.lock(i_lock),
									.M_T(o_Module_TX[36])
);      
Tx_dy #(TXdy_bits)Tx_dy38(
									.reset_n(i_reset_n),				.clk_20M(i_clk),
									.PWM_L(MC2_A),					.PWM_R(MC2_B),
									.ControlWord(i_ControlWord),	.PhaseStaA(i_PhaseSta),
									.discharge(1'b0),					.bypass(i_Redun_pos5[1]),
									.start(i_start_Unit),			.lock(i_lock),
									.M_T(o_Module_TX[37])
);      
Tx_dy #(TXdy_bits)Tx_dy39(
									.reset_n(i_reset_n),				.clk_20M(i_clk),
									.PWM_L(MC3_A),					.PWM_R(MC3_B),
									.ControlWord(i_ControlWord),	.PhaseStaA(i_PhaseSta),
									.discharge(1'b0),					.bypass(i_Redun_pos5[2]),
									.start(i_start_Unit),			.lock(i_lock),
									.M_T(o_Module_TX[38])
);      
Tx_dy #(TXdy_bits)Tx_dy40(
									.reset_n(i_reset_n),				.clk_20M(i_clk),
									.PWM_L(MC4_A),					.PWM_R(MC4_B),
									.ControlWord(i_ControlWord),	.PhaseStaA(i_PhaseSta),
									.discharge(1'b0),					.bypass(i_Redun_pos5[3]),
									.start(i_start_Unit),			.lock(i_lock),
									.M_T(o_Module_TX[39])
);  
Tx_dy #(TXdy_bits)Tx_dy41(
									.reset_n(i_reset_n),				.clk_20M(i_clk),
									.PWM_L(MC5_A),					.PWM_R(MC5_B),
									.ControlWord(i_ControlWord),	.PhaseStaA(i_PhaseSta),
									.discharge(1'b0),					.bypass(i_Redun_pos5[4]),
									.start(i_start_Unit),			.lock(i_lock),
									.M_T(o_Module_TX[40])
);      
Tx_dy #(TXdy_bits)Tx_dy42(
									.reset_n(i_reset_n),				.clk_20M(i_clk),
									.PWM_L(MC6_A),					.PWM_R(MC6_B),
									.ControlWord(i_ControlWord),	.PhaseStaA(i_PhaseSta),
									.discharge(1'b0),					.bypass(i_Redun_pos5[5]),
									.start(i_start_Unit),			.lock(i_lock),
									.M_T(o_Module_TX[41])
);      
Tx_dy #(TXdy_bits)Tx_dy43(
									.reset_n(i_reset_n),				.clk_20M(i_clk),
									.PWM_L(MC7_A),					.PWM_R(MC7_B),
									.ControlWord(i_ControlWord),	.PhaseStaA(i_PhaseSta),
									.discharge(1'b0),					.bypass(i_Redun_pos5[6]),
									.start(i_start_Unit),			.lock(i_lock),
									.M_T(o_Module_TX[42])
);      
Tx_dy #(TXdy_bits)Tx_dy44(
									.reset_n(i_reset_n),				.clk_20M(i_clk),
									.PWM_L(MC8_A),					.PWM_R(MC8_B),
									.ControlWord(i_ControlWord),	.PhaseStaA(i_PhaseSta),
									.discharge(1'b0),					.bypass(i_Redun_pos5[7]),
									.start(i_start_Unit),			.lock(i_lock),
									.M_T(o_Module_TX[43])
);      
Tx_dy #(TXdy_bits)Tx_dy45(
									.reset_n(i_reset_n),				.clk_20M(i_clk),
									.PWM_L(MC9_A),					.PWM_R(MC9_B),
									.ControlWord(i_ControlWord),	.PhaseStaA(i_PhaseSta),
									.discharge(1'b0),					.bypass(i_Redun_pos5[8]),
									.start(i_start_Unit),			.lock(i_lock),
									.M_T(o_Module_TX[44])
);      
Tx_dy #(TXdy_bits)Tx_dy46(
									.reset_n(i_reset_n),				.clk_20M(i_clk),
									.PWM_L(MC10_A),					.PWM_R(MC10_B),
									.ControlWord(i_ControlWord),	.PhaseStaA(i_PhaseSta),
									.discharge(1'b0),					.bypass(i_Redun_pos5[9]),
									.start(i_start_Unit),			.lock(i_lock),
									.M_T(o_Module_TX[45])
);      
Tx_dy #(TXdy_bits)Tx_dy47(
									.reset_n(i_reset_n),				.clk_20M(i_clk),
									.PWM_L(MC11_A),					.PWM_R(MC11_B),
									.ControlWord(i_ControlWord),	.PhaseStaA(i_PhaseSta),
									.discharge(1'b0),					.bypass(i_Redun_pos5[10]),
									.start(i_start_Unit),			.lock(i_lock),
									.M_T(o_Module_TX[46])
);      
Tx_dy #(TXdy_bits)Tx_dy48(
									.reset_n(i_reset_n),				.clk_20M(i_clk),
									.PWM_L(MC12_A),					.PWM_R(MC12_B),
									.ControlWord(i_ControlWord),	.PhaseStaA(i_PhaseSta),
									.discharge(1'b0),					.bypass(i_Redun_pos5[11]),
									.start(i_start_Unit),			.lock(i_lock),
									.M_T(o_Module_TX[47])
);
Tx_dy #(TXdy_bits)Tx_dy49(
									.reset_n(i_reset_n),				.clk_20M(i_clk),
									.PWM_L(MC13_A),						.PWM_R(MC13_B),
									.ControlWord(i_ControlWord),	.PhaseStaA(i_PhaseSta),
									.discharge(1'b0),					.bypass(i_Redun_pos5[12]),
									.start(i_start_Unit),			.lock(i_lock),
									.M_T(o_Module_TX[48])
);      
Tx_dy #(TXdy_bits)Tx_dy50(
									.reset_n(i_reset_n),				.clk_20M(i_clk),
									.PWM_L(MC14_A),						.PWM_R(MC14_B),
									.ControlWord(i_ControlWord),	.PhaseStaA(i_PhaseSta),
									.discharge(1'b0),					.bypass(i_Redun_pos5[13]),
									.start(i_start_Unit),			.lock(i_lock),
									.M_T(o_Module_TX[49])
);  
Tx_dy #(TXdy_bits)Tx_dy51(
									.reset_n(i_reset_n),				.clk_20M(i_clk),
									.PWM_L(MC15_A),						.PWM_R(MC15_B),
									.ControlWord(i_ControlWord),	.PhaseStaA(i_PhaseSta),
									.discharge(1'b0),					.bypass(i_Redun_pos5[14]),
									.start(i_start_Unit),			.lock(i_lock),
									.M_T(o_Module_TX[50])
);      
Tx_dy #(TXdy_bits)Tx_dy52(
									.reset_n(i_reset_n),				.clk_20M(i_clk),
									.PWM_L(MC16_A),						.PWM_R(MC16_B),
									.ControlWord(i_ControlWord),	.PhaseStaA(i_PhaseSta),
									.discharge(1'b0),					.bypass(i_Redun_pos5[15]),
									.start(i_start_Unit),			.lock(i_lock),
									.M_T(o_Module_TX[51])
); 
Tx_dy #(TXdy_bits)Tx_dy53(
									.reset_n(i_reset_n),				.clk_20M(i_clk),
									.PWM_L(MC17_A),						.PWM_R(MC17_B),
									.ControlWord(i_ControlWord),	.PhaseStaA(i_PhaseSta),
									.discharge(1'b0),					.bypass(i_Redun_pos6[0]),
									.start(i_start_Unit),			.lock(i_lock),
									.M_T(o_Module_TX[52])
);
Tx_dy #(TXdy_bits)Tx_dy54(
									.reset_n(i_reset_n),				.clk_20M(i_clk),
									.PWM_L(MC18_A),						.PWM_R(MC18_B),
									.ControlWord(i_ControlWord),	.PhaseStaA(i_PhaseSta),
									.discharge(1'b0),					.bypass(i_Redun_pos6[1]),
									.start(i_start_Unit),			.lock(i_lock),
									.M_T(o_Module_TX[53])
);
//Tx_dy #(TXdy_bits)Tx_dy55(
//									.reset_n(i_reset_n),				.clk_20M(i_clk),
//									.PWM_L(MC7_A),						.PWM_R(MC7_B),
//									.ControlWord(i_ControlWord),	.PhaseStaA(i_PhaseSta),
//									.discharge(1'b0),					.bypass(i_Redun_pos5[6]),
//									.start(i_start_Unit),			.lock(i_lock),
//									.M_T(o_Module_TX[54])
//);
//Tx_dy #(TXdy_bits)Tx_dy56(
//									.reset_n(i_reset_n),				.clk_20M(i_clk),
//									.PWM_L(MC8_A),						.PWM_R(MC8_B),
//									.ControlWord(i_ControlWord),	.PhaseStaA(i_PhaseSta),
//									.discharge(1'b0),					.bypass(i_Redun_pos5[7]),
//									.start(i_start_Unit),			.lock(i_lock),
//									.M_T(o_Module_TX[55])
//);
//Tx_dy #(TXdy_bits)Tx_dy57(
//									.reset_n(i_reset_n),				.clk_20M(i_clk),
//									.PWM_L(MC9_A),						.PWM_R(MC9_B),
//									.ControlWord(i_ControlWord),	.PhaseStaA(i_PhaseSta),
//									.discharge(1'b0),					.bypass(i_Redun_pos5[8]),
//									.start(i_start_Unit),			.lock(i_lock),
//									.M_T(o_Module_TX[56])
//);
//Tx_dy #(TXdy_bits)Tx_dy58(
//									.reset_n(i_reset_n),				.clk_20M(i_clk),
//									.PWM_L(MC10_A),					.PWM_R(MC10_B),
//									.ControlWord(i_ControlWord),	.PhaseStaA(i_PhaseSta),
//									.discharge(1'b0),					.bypass(i_Redun_pos5[9]),
//									.start(i_start_Unit),			.lock(i_lock),
//									.M_T(o_Module_TX[57])
//);
//Tx_dy #(TXdy_bits)Tx_dy59(
//									.reset_n(i_reset_n),				.clk_20M(i_clk),
//									.PWM_L(MC11_A),					.PWM_R(MC11_B),
//									.ControlWord(i_ControlWord),	.PhaseStaA(i_PhaseSta),
//									.discharge(1'b0),					.bypass(i_Redun_pos5[10]),
//									.start(i_start_Unit),			.lock(i_lock),
//									.M_T(o_Module_TX[58])
//);
//Tx_dy #(TXdy_bits)Tx_dy60(
//									.reset_n(i_reset_n),				.clk_20M(i_clk),
//									.PWM_L(MC12_A),					.PWM_R(MC12_B),
//									.ControlWord(i_ControlWord),	.PhaseStaA(i_PhaseSta),
//									.discharge(1'b0),					.bypass(i_Redun_pos5[11]),
//									.start(i_start_Unit),			.lock(i_lock),
//									.M_T(o_Module_TX[59])
//);
//Tx_dy #(TXdy_bits)Tx_dy61(
//									.reset_n(i_reset_n),				.clk_20M(i_clk),
//									.PWM_L(MC13_A),					.PWM_R(MC13_B),
//									.ControlWord(i_ControlWord),	.PhaseStaA(i_PhaseSta),
//									.discharge(1'b0),					.bypass(i_Redun_pos5[12]),
//									.start(i_start_Unit),			.lock(i_lock),
//									.M_T(o_Module_TX[60])
//);
//Tx_dy #(TXdy_bits)Tx_dy62(
//									.reset_n(i_reset_n),				.clk_20M(i_clk),
//									.PWM_L(MC14_A),					.PWM_R(MC14_B),
//									.ControlWord(i_ControlWord),	.PhaseStaA(i_PhaseSta),
//									.discharge(1'b0),					.bypass(i_Redun_pos5[13]),
//									.start(i_start_Unit),			.lock(i_lock),
//									.M_T(o_Module_TX[61])
//);
//Tx_dy #(TXdy_bits)Tx_dy63(
//									.reset_n(i_reset_n),				.clk_20M(i_clk),
//									.PWM_L(MC15_A),					.PWM_R(MC15_B),
//									.ControlWord(i_ControlWord),	.PhaseStaA(i_PhaseSta),
//									.discharge(1'b0),					.bypass(i_Redun_pos5[14]),
//									.start(i_start_Unit),			.lock(i_lock),
//									.M_T(o_Module_TX[62])
//);
//Tx_dy #(TXdy_bits)Tx_dy64(
//									.reset_n(i_reset_n),				.clk_20M(i_clk),
//									.PWM_L(MC16_A),					.PWM_R(MC16_B),
//									.ControlWord(i_ControlWord),	.PhaseStaA(i_PhaseSta),
//									.discharge(1'b0),					.bypass(i_Redun_pos5[15]),
//									.start(i_start_Unit),			.lock(i_lock),
//									.M_T(o_Module_TX[63])
//);
//Tx_dy #(TXdy_bits)Tx_dy65(
//									.reset_n(i_reset_n),				.clk_20M(i_clk),
//									.PWM_L(MC17_A),					.PWM_R(MC17_B),
//									.ControlWord(i_ControlWord),	.PhaseStaA(i_PhaseSta),
//									.discharge(1'b0),					.bypass(i_Redun_pos6[0]),
//									.start(i_start_Unit),			.lock(i_lock),
//									.M_T(o_Module_TX[64])
//);
//Tx_dy #(TXdy_bits)Tx_dy66(
//									.reset_n(i_reset_n),				.clk_20M(i_clk),
//									.PWM_L(MC18_A),					.PWM_R(MC18_B),
//									.ControlWord(i_ControlWord),	.PhaseStaA(i_PhaseSta),
//									.discharge(1'b0),					.bypass(i_Redun_pos6[1]),
//									.start(i_start_Unit),			.lock(i_lock),
//									.M_T(o_Module_TX[65])
//);
//Tx_dy #(TXdy_bits)Tx_dy67(
//									.reset_n(i_reset_n),				.clk_20M(i_clk),
//									.PWM_L(MC19_A),					.PWM_R(MC19_B),
//									.ControlWord(i_ControlWord),	.PhaseStaA(i_PhaseSta),
//									.discharge(1'b0),					.bypass(i_Redun_pos6[2]),
//									.start(i_start_Unit),			.lock(i_lock),
//									.M_T(o_Module_TX[66])
//);
//Tx_dy #(TXdy_bits)Tx_dy68(
//									.reset_n(i_reset_n),				.clk_20M(i_clk),
//									.PWM_L(MC20_A),					.PWM_R(MC20_B),
//									.ControlWord(i_ControlWord),	.PhaseStaA(i_PhaseSta),
//									.discharge(1'b0),					.bypass(i_Redun_pos6[3]),
//									.start(i_start_Unit),			.lock(i_lock),
//									.M_T(o_Module_TX[67])
//);
//Tx_dy #(TXdy_bits)Tx_dy69(
//									.reset_n(i_reset_n),				.clk_20M(i_clk),
//									.PWM_L(MC21_A),					.PWM_R(MC21_B),
//									.ControlWord(i_ControlWord),	.PhaseStaA(i_PhaseSta),
//									.discharge(1'b0),					.bypass(i_Redun_pos6[4]),
//									.start(i_start_Unit),			.lock(i_lock),
//									.M_T(o_Module_TX[68])
//);
//Tx_dy #(TXdy_bits)Tx_dy70(
//									.reset_n(i_reset_n),				.clk_20M(i_clk),
//									.PWM_L(MC22_A),					.PWM_R(MC22_B),
//									.ControlWord(i_ControlWord),	.PhaseStaA(i_PhaseSta),
//									.discharge(1'b0),					.bypass(i_Redun_pos6[5]),
//									.start(i_start_Unit),			.lock(i_lock),
//									.M_T(o_Module_TX[69])
//);
//Tx_dy #(TXdy_bits)Tx_dy71(
//									.reset_n(i_reset_n),				.clk_20M(i_clk),
//									.PWM_L(MC23_A),					.PWM_R(MC23_B),
//									.ControlWord(i_ControlWord),	.PhaseStaA(i_PhaseSta),
//									.discharge(1'b0),					.bypass(i_Redun_pos6[6]),
//									.start(i_start_Unit),			.lock(i_lock),
//									.M_T(o_Module_TX[70])
//);
//Tx_dy #(TXdy_bits)Tx_dy72(
//									.reset_n(i_reset_n),				.clk_20M(i_clk),
//									.PWM_L(MC24_A),					.PWM_R(MC24_B),
//									.ControlWord(i_ControlWord),	.PhaseStaA(i_PhaseSta),
//									.discharge(1'b0),					.bypass(i_Redun_pos6[7]),
//									.start(i_start_Unit),			.lock(i_lock),
//									.M_T(o_Module_TX[71])
//);   
endmodule
