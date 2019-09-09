`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: CEPRI
// Engineer: Zhang Dian-qing
// 
// Create Date:    15:36:38 03/14/2019 
// Design Name: 
// Module Name:    CSPWM_calc 
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
module CSPWM_calc(
                   input i_clk,
						 input i_clk_20M,
						 input clk_cps,
						 input i_reset_n,
						 input i_start_PWM,
						 input [15:0]i_VCU_Mode,//���ػ������� 3���һ/����
						 input signed[15:0]i_Ave_TargetVolA,//��ƽ�����Ƶ�ѹ
						 input signed[15:0]i_Ave_TargetVolB,
						 input signed[15:0]i_Ave_TargetVolC,
						 input signed[15:0]i_CosThetA,//�����жϺ����յ�����ֵ
						 input signed[15:0]i_CosThetB,
						 input signed[15:0]i_CosThetC,
						 input [383:0]i_LinkUdcA_BUS,//ģ��ֱ����ѹ����
						 input [383:0]i_LinkUdcB_BUS,
						 input [383:0]i_LinkUdcC_BUS,
						 input [15:0]i_PhaseA_Udc,//��ƽ��ֱ����ѹ
						 input [15:0]i_PhaseB_Udc,
						 input [15:0]i_PhaseC_Udc,
						 input [15:0]i_Freqency_cnt,//����Ƶ�ʼ�����20Mʱ��
						 input signed[15:0]i_temp,
						 input signed[31:0]i_temp_long,
						 input i_Carrier_Syn,//�ز�ͬ���ź�
						 input [383:0]i_initi_angleA_BUS,//ģ���ʼ���
						 input [383:0]i_initi_angleB_BUS,
						 input [383:0]i_initi_angleC_BUS,
						 input [15:0]i_Kp_Udc,//ֱ����ѹ�������ز�
						 input [15:0]i_Udc_limit,//ֱ����ѹ�����������޷�
						 output [47:0]o_PWM_A_BUS,//PWM��
						 output [47:0]o_PWM_B_BUS,
						 output [47:0]o_PWM_C_BUS,
						 output [383:0]o_CtrlVolA_BUS,//ģ����Ƶ�ѹ����
						 output [383:0]o_CtrlVolB_BUS,
						 output [383:0]o_CtrlVolC_BUS
                  );
	 	 	 
wire [15:0] PulWidth_Min = 16'd320;//��С�������� 32us=2*320/0.05us
wire [15:0] PulWidth_Max = i_Freqency_cnt - 16'd320;

//-----������ѹ��������*������������
wire signed [31:0] CosThetA_Kp = $signed(i_CosThetA) * $signed(i_Kp_Udc);
wire signed [31:0] CosThetB_Kp = (i_VCU_Mode == 16'h55aa) ? $signed(i_CosThetB) * $signed(i_Kp_Udc) : CosThetA_Kp;
wire signed [31:0] CosThetC_Kp = (i_VCU_Mode == 16'h55aa) ? $signed(i_CosThetC) * $signed(i_Kp_Udc): CosThetA_Kp;

wire signed [15:0] Ave_TargetVolA = i_Ave_TargetVolA;
wire signed [15:0] Ave_TargetVolB = (i_VCU_Mode == 16'h55aa) ?  i_Ave_TargetVolB : i_Ave_TargetVolA;
wire signed [15:0] Ave_TargetVolC = (i_VCU_Mode == 16'h55aa) ?  i_Ave_TargetVolC : i_Ave_TargetVolA;

wire [15:0] PhaseA_Udc = i_PhaseA_Udc;
wire [15:0] PhaseB_Udc = (i_VCU_Mode == 16'h55aa) ?  i_PhaseB_Udc : i_PhaseA_Udc;
wire [15:0] PhaseC_Udc = (i_VCU_Mode == 16'h55aa) ?  i_PhaseC_Udc : i_PhaseA_Udc;

//--------------------����PWM����-------------------------//																																								
PWM_Calc PWM_Calc_A(
            .i_reset_n(i_reset_n),
				.i_clk(i_clk),
				.i_clk_20M(i_clk_20M),
				.i_start_PWM(i_start_PWM),
				.CosThet_Kp(CosThetA_Kp),//������ѹ��������*������������
				.i_Phase_Udc(PhaseA_Udc),//��ƽ��ֱ����ѹ
				.TargetVol(Ave_TargetVolA),//��ƽ�����Ƶ�ѹ
				.Syn(i_Carrier_Syn),//�ز�ͬ���ź�
            .Udc_limit(i_Udc_limit),//ֱ����ѹ�����������޷�
				.Frequency(i_Freqency_cnt),//����Ƶ�ʼ�����20Mʱ��
				.PulWidth_Min(PulWidth_Min),//��С��������
				.PulWidth_Max(PulWidth_Max),
				.temp(i_temp),
				.temp_long(i_temp_long),
				.i_LinkUdc_BUS(i_LinkUdcA_BUS),//ģ��ֱ����ѹ����				
				.i_initi_angle_BUS(i_initi_angleA_BUS),//ģ���ʼ���				
				.o_PWM_BUS(o_PWM_A_BUS),//PWM��
				.o_CtrlVol_BUS(o_CtrlVolA_BUS)//ģ����Ƶ�ѹ����
				);
PWM_Calc PWM_Calc_B(
            .i_reset_n(i_reset_n),
				.i_clk(i_clk),
				.i_clk_20M(i_clk_20M),
				.i_start_PWM(i_start_PWM),
				.CosThet_Kp(CosThetB_Kp),
				.i_Phase_Udc(PhaseB_Udc),
				.TargetVol(Ave_TargetVolB),
				.Syn(i_Carrier_Syn),
            .Udc_limit(i_Udc_limit),
				.Frequency(i_Freqency_cnt),
				.PulWidth_Min(PulWidth_Min),
				.PulWidth_Max(PulWidth_Max),
				.temp(i_temp),
				.temp_long(i_temp_long),
				.i_LinkUdc_BUS(i_LinkUdcB_BUS),				
				.i_initi_angle_BUS(i_initi_angleB_BUS),				
				.o_PWM_BUS(o_PWM_B_BUS),
				.o_CtrlVol_BUS(o_CtrlVolB_BUS)
				);
PWM_Calc PWM_Calc_C(
            .i_reset_n(i_reset_n),
				.i_clk(i_clk),
				.i_clk_20M(i_clk_20M),
				.i_start_PWM(i_start_PWM),
				.CosThet_Kp(CosThetC_Kp),
				.i_Phase_Udc(PhaseC_Udc),
				.TargetVol(Ave_TargetVolC),
				.Syn(i_Carrier_Syn),
            .Udc_limit(i_Udc_limit),
				.Frequency(i_Freqency_cnt),
				.PulWidth_Min(PulWidth_Min),
				.PulWidth_Max(PulWidth_Max),
				.temp(i_temp),
				.temp_long(i_temp_long),
				.i_LinkUdc_BUS(i_LinkUdcC_BUS),				
				.i_initi_angle_BUS(i_initi_angleC_BUS),				
				.o_PWM_BUS(o_PWM_C_BUS),
				.o_CtrlVol_BUS(o_CtrlVolC_BUS)
				);
//wire [35:0] ILAControl;
//wire [79:0] data_chipscp; 
//assign data_chipscp [31:0] = CosThetA_Kp;
//assign data_chipscp [47:32] = i_CosThetA;
//assign data_chipscp [63:48] = i_Kp_Udc;
////assign data_chipscp [63:32] = VOFFSET;
////assign data_chipscp [79:64] = Uout_offset;
//
//
//new_icon SVG_icon ( 
//     .CONTROL0            ( ILAControl) 
//); 
//
//new_ila SVG_ila ( 
//     .CONTROL            ( ILAControl), 
//     .CLK                ( clk_cps), 
//     .DATA               ( data_chipscp), 
//     .TRIG0              ( ) ,
//	    .TRIG1              ( ),
//     .TRIG2              ( ), 
//	    .TRIG3              ( )
//);				
endmodule
