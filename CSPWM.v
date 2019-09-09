`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:32:47 05/22/2015 
// Design Name: 
// Module Name:    CSPWM 
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
module CSPWM(
					input reset_n,
					input clk_50M,
					input clk_20M,
					input start,
					input signed [31:0]CosTheta,//������ѹ��������*������������
					input [15:0]phaseUdc,//��ƽ��ֱ����ѹ
					input signed [15:0]TargetVol,//��ƽ�����Ƶ�ѹ
					input Syn,//�ز�ͬ���ź�
					input [15:0]Udc_limit,//ֱ����ѹ�����������޷�
					input [15:0]LinkUdcA,//ģ��ֱ����ѹ
					input [15:0]LinkUdcB,
					input [15:0]LinkUdcC,
					input [15:0]Frequency,//����Ƶ�ʼ�����20Mʱ��
					input [15:0]PulWidth_Min,//��С��������
					input [15:0]PulWidth_Max,
					input signed [15:0]temp,
					input signed [31:0]temp_long,
					input [15:0]Angle_initialA,//ģ���ʼ���
					input [15:0]Angle_initialB,
					input [15:0]Angle_initialC,
					output PWM_leftA,//PWM��
					output PWM_rightA,
					output PWM_leftB,
					output PWM_rightB,
					output PWM_leftC,
					output PWM_rightC,
					output [15:0]TargetVolA,//ģ����Ƶ�ѹ
					output [15:0]TargetVolB,
					output [15:0]TargetVolC
);
//wire signed [15:0] Uout_offsetA,Uout_offsetB,Uout_offsetC,Uout_offsetD,Uout_offsetE;
wire AngleDirA,AngleDirB,AngleDirC;
wire [15:0] AngleA,AngleB,AngleC;

TriangleWave   Tri_moduleA(
									.reset_n(reset_n),
									.clk_20M(clk_20M),
									.Syn(Syn),//�ز�ͬ���ź�
									.Frequency(Frequency),//����Ƶ�ʼ�����20Mʱ��
									.Angle_initial(Angle_initialA),//ģ���ʼ���
									.AngleDir(AngleDirA),
									.Angle(AngleA)
);
TriangleWave   Tri_moduleB(
									.reset_n(reset_n),
									.clk_20M(clk_20M),
									.Syn(Syn),
									.Frequency(Frequency),
									.Angle_initial(Angle_initialB),
									.AngleDir(AngleDirB),
									.Angle(AngleB)
);
TriangleWave   Tri_moduleC(
									.reset_n(reset_n),
									.clk_20M(clk_20M),
									.Syn(Syn),
									.Frequency(Frequency),
									.Angle_initial(Angle_initialC),
									.AngleDir(AngleDirC),
									.Angle(AngleC)
);
//TriangleWave   Tri_moduleD(reset_n,clk_20M,Syn,Frequency,Angle_initialD,AngleDirD,AngleD);
//TriangleWave   Tri_moduleE(reset_n,clk_20M,Syn,Frequency,Angle_initialE,AngleDirE,AngleE);
//PWM_TDM        PWM_module(clk_20M,reset_n,start,TargetVol,Uout_offsetA,Uout_offsetB,Uout_offsetC,
//                          LinkUdcA,LinkUdcB,LinkUdcC,PulWidth_Min,PulWidth_Max,temp,temp_long,
//								  AngleDirA,AngleA,PWM_leftA,PWM_rightA,
//								  AngleDirB,AngleB,PWM_leftB,PWM_rightB,
//								  AngleDirC,AngleC,PWM_leftC,PWM_rightC);
PWM_TDM PWM_module(
						.clk_50M(clk_50M),
						.clk_20M(clk_20M),
						.reset_n(reset_n),
						.start(start),
						.TargetVol(TargetVol),//��ƽ�����Ƶ�ѹ
						.CosTheta(CosTheta),//������ѹ��������*������������
						.phaseUdc(phaseUdc),//��ƽ��ֱ����ѹ
						.LinkUdcA(LinkUdcA),//ģ��ֱ����ѹ
						.LinkUdcB(LinkUdcB),
						.LinkUdcC(LinkUdcC),
						.Udc_limit(Udc_limit),//ֱ����ѹ�����������޷�
						.PulWidth_Min(PulWidth_Min),//��С��������
						.PulWidth_Max(PulWidth_Max),
						.temp(temp),
						.temp_long(temp_long),
						.AngleDirA(AngleDirA),
						.AngleA(AngleA),
						.PWM_leftA(PWM_leftA),//PWM��
						.PWM_rightA(PWM_rightA),
						.AngleDirB(AngleDirB),
						.AngleB(AngleB),
						.PWM_leftB(PWM_leftB),
						.PWM_rightB(PWM_rightB),
						.AngleDirC(AngleDirC),
						.AngleC(AngleC),
						.PWM_leftC(PWM_leftC),
						.PWM_rightC(PWM_rightC),																			
//						.AngleDirD(AngleDirD),
//						.AngleD(AngleD),
//						.PWM_leftD(PWM_leftD),
//						.PWM_rightD(PWM_rightD),
//						.AngleDirE(AngleDirE),
//						.AngleE(AngleE),
//						.PWM_leftE(PWM_leftE),
//						.PWM_rightE(PWM_rightE),
						.TargetVolA(TargetVolA),//ģ����Ƶ�ѹ
						.TargetVolB(TargetVolB),
						.TargetVolC(TargetVolC)
);
endmodule
