`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:01:57 03/18/2019 
// Design Name: 
// Module Name:    PWM_Calc 
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
module PWM_Calc_cps(
						 input i_reset_n, 
                   input i_clk,
						 input i_clk_20M,
						 input clk_cps,
						 input i_start_PWM,
						 input signed[31:0]CosThet_Kp,//������ѹ��������*������������
						 input [15:0]i_Phase_Udc,//��ƽ��ֱ����ѹ
						 input signed[15:0]TargetVol,//��ƽ�����Ƶ�ѹ
						 input Syn,//�ز�ͬ���ź�
						 input [15:0]Udc_limit,//ֱ����ѹ�����������޷�
						 input [15:0]Frequency,//����Ƶ�ʼ�����20Mʱ��
						 input [15:0]PulWidth_Min,//��С��������
						 input [15:0]PulWidth_Max,						
						 input signed[15:0]temp,
						 input signed[31:0]temp_long,						 
						 input [383:0]i_LinkUdc_BUS,//ģ��ֱ����ѹ����
						 input [383:0]i_initi_angle_BUS,//ģ���ʼ���
						 output [47:0]o_PWM_BUS,//PWM��
						 output [383:0]o_CtrlVol_BUS//ģ����Ƶ�ѹ����
                   );
//-----------------------------Udc������ת����ֱ����ѹ---------------------------------//
wire  [15:0] LinkUdc1,LinkUdc2,LinkUdc3,LinkUdc4,LinkUdc5,LinkUdc6,LinkUdc7,LinkUdc8,LinkUdc9,LinkUdc10,
				 LinkUdc11,LinkUdc12,LinkUdc13,LinkUdc14,LinkUdc15,LinkUdc16,LinkUdc17,LinkUdc18,LinkUdc19,LinkUdc20,
				 LinkUdc21,LinkUdc22,LinkUdc23,LinkUdc24;
				 
UdcBUS_Conv_Phase UdcBUS_Conv_PhaseA(i_LinkUdc_BUS,LinkUdc1,LinkUdc2,LinkUdc3,LinkUdc4,LinkUdc5,LinkUdc6,LinkUdc7,LinkUdc8,LinkUdc9,LinkUdc10,
				 LinkUdc11,LinkUdc12,LinkUdc13,LinkUdc14,LinkUdc15,LinkUdc16,LinkUdc17,LinkUdc18,LinkUdc19,LinkUdc20,
				 LinkUdc21,LinkUdc22,LinkUdc23,LinkUdc24);

//-----------------------------��ʼ���������ת����ģ�������---------------------------------//
wire [15:0]  initi_1,initi_2,initi_3,initi_4,initi_5,initi_6,initi_7,initi_8,initi_9,initi_10,
             initi_11,initi_12,initi_13,initi_14,initi_15,initi_16,initi_17,initi_18,initi_19,initi_20,
             initi_21,initi_22,initi_23,initi_24;//A��ģ�������	

UdcBUS_Conv_Phase initi_Conv_PhaseA(i_initi_angle_BUS,initi_1,initi_2,initi_3,initi_4,initi_5,initi_6,initi_7,initi_8,initi_9,initi_10,
             initi_11,initi_12,initi_13,initi_14,initi_15,initi_16,initi_17,initi_18,initi_19,initi_20,
             initi_21,initi_22,initi_23,initi_24);	

//-----------------------------��ģ��������PWMת����---------------------------------//
wire         PWM_L1,PWM_R1,PWM_L2,PWM_R2,PWM_L3,PWM_R3,PWM_L4,PWM_R4,PWM_L5,PWM_R5,
             PWM_L6,PWM_R6,PWM_L7,PWM_R7,PWM_L8,PWM_R8,PWM_L9,PWM_R9,PWM_L10,PWM_R10,
				 PWM_L11,PWM_R11,PWM_L12,PWM_R12,PWM_L13,PWM_R13,PWM_L14,PWM_R14,PWM_L15,
				 PWM_R15,PWM_L16,PWM_R16,PWM_L17,PWM_R17,PWM_L18,PWM_R18,PWM_L19,PWM_R19,
				 PWM_L20,PWM_R20,PWM_L21,PWM_R21,PWM_L22,PWM_R22,PWM_L23,PWM_R23,PWM_L24,PWM_R24;

assign o_PWM_BUS = {PWM_L1,PWM_R1,PWM_L2,PWM_R2,PWM_L3,PWM_R3,PWM_L4,PWM_R4,PWM_L5,PWM_R5,
             PWM_L6,PWM_R6,PWM_L7,PWM_R7,PWM_L8,PWM_R8,PWM_L9,PWM_R9,PWM_L10,PWM_R10,
				 PWM_L11,PWM_R11,PWM_L12,PWM_R12,PWM_L13,PWM_R13,PWM_L14,PWM_R14,PWM_L15,
				 PWM_R15,PWM_L16,PWM_R16,PWM_L17,PWM_R17,PWM_L18,PWM_R18,PWM_L19,PWM_R19,
				 PWM_L20,PWM_R20,PWM_L21,PWM_R21,PWM_L22,PWM_R22,PWM_L23,PWM_R23,PWM_L24,PWM_R24}; 

//-----------------------------��ģ����Ʋ�ת����---------------------------------//
wire [15:0]  TargetVol1,TargetVol2,TargetVol3,TargetVol4,TargetVol5,TargetVol6,TargetVol7,TargetVol8,TargetVol9,TargetVol10,TargetVol11,TargetVol12,				
				 TargetVol13,TargetVol14,TargetVol15,TargetVol16,TargetVol17,TargetVol18,TargetVol19,TargetVol20,TargetVol21,TargetVol22,TargetVol23,TargetVol24;

assign o_CtrlVol_BUS = {TargetVol1,TargetVol2,TargetVol3,TargetVol4,TargetVol5,TargetVol6,TargetVol7,TargetVol8,TargetVol9,TargetVol10,TargetVol11,TargetVol12,				
				 TargetVol13,TargetVol14,TargetVol15,TargetVol16,TargetVol17,TargetVol18,TargetVol19,TargetVol20,TargetVol21,TargetVol22,TargetVol23,TargetVol24};

//------------------------------------------------------------------------------------------//

//-----------------------------1-24ģ��PWM��ʱ���ü���---------------------------------//
CSPWM_cps PWM1(
				.reset_n(i_reset_n),
				.clk_50M(i_clk),
				.clk_20M(i_clk_20M),
				.clk_cps(clk_cps),
				.start(i_start_PWM),
				.CosTheta(CosThet_Kp),//������ѹ��������*������������
				.phaseUdc(i_Phase_Udc),//��ƽ��ֱ����ѹ
				.TargetVol(TargetVol),//��ƽ�����Ƶ�ѹ
				.Syn(Syn),//�ز�ͬ���ź�
				.Udc_limit(Udc_limit),//ֱ����ѹ�����������޷�
            .LinkUdcA(LinkUdc1),//ģ��ֱ����ѹ
				.LinkUdcB(LinkUdc2),
				.LinkUdcC(LinkUdc3),
				.Frequency(Frequency),//����Ƶ�ʼ�����20Mʱ��
				.PulWidth_Min(PulWidth_Min),//��С��������
				.PulWidth_Max(PulWidth_Max),
				.temp(temp),
				.temp_long(temp_long),
				.Angle_initialA(initi_1),//ģ���ʼ���
				.Angle_initialB(initi_2),
				.Angle_initialC(initi_3),
				.PWM_leftA(PWM_L1),//PWM��
				.PWM_rightA(PWM_R1),
				.PWM_leftB(PWM_L2),
				.PWM_rightB(PWM_R2),
				.PWM_leftC(PWM_L3),
				.PWM_rightC(PWM_R3),
				.TargetVolA(TargetVol1),//ģ����Ƶ�ѹ
				.TargetVolB(TargetVol2),
				.TargetVolC(TargetVol3)
);
CSPWM PWM2(
				.reset_n(i_reset_n),
				.clk_50M(i_clk),
				.clk_20M(i_clk_20M),
				.start(i_start_PWM),
				.CosTheta(CosThet_Kp),
				.phaseUdc(i_Phase_Udc),
				.TargetVol(TargetVol),
				.Syn(Syn),
				.Udc_limit(Udc_limit),
            .LinkUdcA(LinkUdc4),
				.LinkUdcB(LinkUdc5),
				.LinkUdcC(LinkUdc6),
				.Frequency(Frequency),
				.PulWidth_Min(PulWidth_Min),
				.PulWidth_Max(PulWidth_Max),
				.temp(temp),
				.temp_long(temp_long),
				.Angle_initialA(initi_4),
				.Angle_initialB(initi_5),
				.Angle_initialC(initi_6),
				.PWM_leftA(PWM_L4),
				.PWM_rightA(PWM_R4),
				.PWM_leftB(PWM_L5),
				.PWM_rightB(PWM_R5),
				.PWM_leftC(PWM_L6),
				.PWM_rightC(PWM_R6),
				.TargetVolA(TargetVol4),
				.TargetVolB(TargetVol5),
				.TargetVolC(TargetVol6)
);
CSPWM PWM3(
				.reset_n(i_reset_n),
				.clk_50M(i_clk),
				.clk_20M(i_clk_20M),
				.start(i_start_PWM),
				.CosTheta(CosThet_Kp),
				.phaseUdc(i_Phase_Udc),
				.TargetVol(TargetVol),
				.Syn(Syn),
				.Udc_limit(Udc_limit),
            .LinkUdcA(LinkUdc7),
				.LinkUdcB(LinkUdc8),
				.LinkUdcC(LinkUdc9),
				.Frequency(Frequency),
				.PulWidth_Min(PulWidth_Min),
				.PulWidth_Max(PulWidth_Max),
				.temp(temp),
				.temp_long(temp_long),
				.Angle_initialA(initi_7),
				.Angle_initialB(initi_8),
				.Angle_initialC(initi_9),
				.PWM_leftA(PWM_L7),
				.PWM_rightA(PWM_R7),
				.PWM_leftB(PWM_L8),
				.PWM_rightB(PWM_R8),
				.PWM_leftC(PWM_L9),
				.PWM_rightC(PWM_R9),
				.TargetVolA(TargetVol7),
				.TargetVolB(TargetVol8),
				.TargetVolC(TargetVol9)
);
CSPWM PWM4(
				.reset_n(i_reset_n),
				.clk_50M(i_clk),
				.clk_20M(i_clk_20M),
				.start(i_start_PWM),
				.CosTheta(CosThet_Kp),
				.phaseUdc(i_Phase_Udc),
				.TargetVol(TargetVol),
				.Syn(Syn),
				.Udc_limit(Udc_limit),
            .LinkUdcA(LinkUdc10),
				.LinkUdcB(LinkUdc11),
				.LinkUdcC(LinkUdc12),
				.Frequency(Frequency),
				.PulWidth_Min(PulWidth_Min),
				.PulWidth_Max(PulWidth_Max),
				.temp(temp),
				.temp_long(temp_long),
				.Angle_initialA(initi_10),
				.Angle_initialB(initi_11),
				.Angle_initialC(initi_12),
				.PWM_leftA(PWM_L10),
				.PWM_rightA(PWM_R10),
				.PWM_leftB(PWM_L11),
				.PWM_rightB(PWM_R11),
				.PWM_leftC(PWM_L12),
				.PWM_rightC(PWM_R12),
				.TargetVolA(TargetVol10),
				.TargetVolB(TargetVol11),
				.TargetVolC(TargetVol12)
);
CSPWM PWM5(
				.reset_n(i_reset_n),
				.clk_50M(i_clk),
				.clk_20M(i_clk_20M),
				.start(i_start_PWM),
				.CosTheta(CosThet_Kp),
				.phaseUdc(i_Phase_Udc),
				.TargetVol(TargetVol),
				.Syn(Syn),
				.Udc_limit(Udc_limit),
            .LinkUdcA(LinkUdc13),
				.LinkUdcB(LinkUdc14),
				.LinkUdcC(LinkUdc15),
				.Frequency(Frequency),
				.PulWidth_Min(PulWidth_Min),
				.PulWidth_Max(PulWidth_Max),
				.temp(temp),
				.temp_long(temp_long),
				.Angle_initialA(initi_13),
				.Angle_initialB(initi_14),
				.Angle_initialC(initi_15),
				.PWM_leftA(PWM_L13),
				.PWM_rightA(PWM_R13),
				.PWM_leftB(PWM_L14),
				.PWM_rightB(PWM_R14),
				.PWM_leftC(PWM_L15),
				.PWM_rightC(PWM_R15),
				.TargetVolA(TargetVol13),
				.TargetVolB(TargetVol14),
				.TargetVolC(TargetVol15)
);
CSPWM PWM6(
				.reset_n(i_reset_n),
				.clk_50M(i_clk),
				.clk_20M(i_clk_20M),
				.start(i_start_PWM),
				.CosTheta(CosThet_Kp),
				.phaseUdc(i_Phase_Udc),
				.TargetVol(TargetVol),
				.Syn(Syn),
				.Udc_limit(Udc_limit),
            .LinkUdcA(LinkUdc16),
				.LinkUdcB(LinkUdc17),
				.LinkUdcC(LinkUdc18),
				.Frequency(Frequency),
				.PulWidth_Min(PulWidth_Min),
				.PulWidth_Max(PulWidth_Max),
				.temp(temp),
				.temp_long(temp_long),
				.Angle_initialA(initi_16),
				.Angle_initialB(initi_17),
				.Angle_initialC(initi_18),
				.PWM_leftA(PWM_L16),
				.PWM_rightA(PWM_R16),
				.PWM_leftB(PWM_L17),
				.PWM_rightB(PWM_R17),
				.PWM_leftC(PWM_L18),
				.PWM_rightC(PWM_R18),
				.TargetVolA(TargetVol16),
				.TargetVolB(TargetVol17),
				.TargetVolC(TargetVol18)
);
//CSPWM PWM7(i_reset_n,i_clk,i_clk_20M,i_start_PWM,CosThet_Kp,i_Phase_Udc,TargetVol,Syn,Udc_limit,	
//				LinkUdc19,LinkUdc20,LinkUdc21,Frequency,PulWidth_Min,PulWidth_Max,temp,temp_long,
//				initi_19,initi_20,initi_21,PWM_L19,PWM_R19,PWM_L20,PWM_R20,PWM_L21,PWM_R21,TargetVol19,TargetVol20,TargetVol21);
//CSPWM PWM8(i_reset_n,i_clk,i_clk_20M,i_start_PWM,CosThet_Kp,i_Phase_Udc,TargetVol,Syn,Udc_limit,				
//				LinkUdc22,LinkUdc23,LinkUdc24,Frequency,PulWidth_Min,PulWidth_Max,temp,temp_long,
//				initi_22,initi_23,initi_24,PWM_L22,PWM_R22,PWM_L23,PWM_R23,PWM_L24,PWM_R24,TargetVol22,TargetVol23,TargetVol24);

endmodule
