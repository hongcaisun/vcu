`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: CEPRI
// Engineer: Zhang Dian-qing
// 
// Create Date:    15:15:01 03/14/2019 
// Design Name: 
// Module Name:    SpwmGen 
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
module SpwmGen(
					input i_clk,
					input i_clk_20M,
					input clk_100K,
					input clk_1M,
					input i_reset_n,
					input i_start_PWM,
					input signed[31:0]i_TargetVolA,i_TargetVolB,i_TargetVolC,//�����жϺ����յĵ��Ƶ�ѹ
               input signed[15:0]i_CosThetA,i_CosThetB,i_CosThetC,//�����жϺ����յ�����ֵ					
               input [15:0]i_LinkNum_Total,//����ģ���ܸ���
					input [15:0]i_SwitchFreq,//����Ƶ��
					input [15:0]i_Kp_Udc,//ֱ����ѹ�������ز�
					input [15:0]i_Udc_limit,//ֱ����ѹ�����������޷�
					input [15:0]i_Redun_pos1,i_Redun_pos2,i_Redun_pos3,i_Redun_pos4,i_Redun_pos5,i_Redun_pos6,//A/B/C����λ����
					input [15:0]i_VCU_Mode,//���ػ������� 3���һ/����				
					input [383:0]i_LinkUdcA_BUS,i_LinkUdcB_BUS,i_LinkUdcC_BUS,//ģ��ֱ����ѹ����
					output [15:0]o_PhaseA_Udc,o_PhaseB_Udc,o_PhaseC_Udc,//��ƽ��ֱ����ѹ	
					output signed [15:0] Ave_TargetVolA,Ave_TargetVolB,Ave_TargetVolC,//����ƽ�����Ƶ�ѹ
					output [47:0]o_PWM_A_BUS,o_PWM_B_BUS,o_PWM_C_BUS,//PWM��
					output [383:0]o_CtrlVolA_BUS,o_CtrlVolB_BUS,o_CtrlVolC_BUS//ģ����Ƶ�ѹ����
					);						
//-------------------------------Main Program Starts---------------------------------------------//					
//warning!Ŀǰ��72��ģ���Ϊ54��ģ�飬����Ӧ�ı���������
parameter TOTAL_NUM_MODEL = 6'd18;
parameter BIT_NUM = 18'd0;//18'd0 54��ģ�� 24'd0 72��ģ��
wire [15:0]i_Redun_pos2_ini = {14'h3f,i_Redun_pos2[1:0]};//18��ģ�飬����6��ȫ�����࣬�ò�����Ҫ���PWM�����ʼ��Ǽ���ģ��
wire [15:0]i_Redun_pos4_ini = {14'h3f,i_Redun_pos4[1:0]};
wire [15:0]i_Redun_pos6_ini = {14'h3f,i_Redun_pos6[1:0]};
//------------------------------------------------------------
wire  [15:0] LinkNumA_Work,LinkNumB_Work,LinkNumC_Work;//ABC��������������û�������������Ŀ
wire  redun_Syn;//��������һ���ز�ͬ���ź�
wire  carrier_syn_out;//�ز�����ͬ���ź�
wire  Carrier_Syn = redun_Syn | carrier_syn_out;//�ز�ͬ���ź�

wire [15:0]angle_shiftA,angle_shiftB,angle_shiftC;//ABC��������ģ�������ز������
wire [383:0]initi_angleA_BUS,initi_angleB_BUS,initi_angleC_BUS;//ģ���ʼ���
wire [15:0]Freqency_cnt;//����Ƶ�ʼ�����20Mʱ��
wire signed [15:0] temp; 
wire signed [31:0] temp_long; 
//----------------ʵ�ʹ�������ģ��������ģ��-----------------//
WorkNum_calc #(
					.TOTAL_NUM_MODEL(TOTAL_NUM_MODEL),
					.BIT_NUM(BIT_NUM)
)
WorkNum_calc(
          .i_clk_20M(i_clk_20M),
			 .i_reset_n(i_reset_n),
			 .i_LinkNum_Total(i_LinkNum_Total),//����ģ���ܸ���
			 .i_VCU_Mode(i_VCU_Mode),//���ػ������� 3���һ/����
			 .i_Redun_pos1(i_Redun_pos1),//A/B/C����λ����
			 .i_Redun_pos2(i_Redun_pos2),
			 .i_Redun_pos3(i_Redun_pos3),
			 .i_Redun_pos4(i_Redun_pos4),
			 .i_Redun_pos5(i_Redun_pos5),
			 .i_Redun_pos6(i_Redun_pos6),
			 .o_LinkNumA_Work(LinkNumA_Work),//ABC��������������û�������������Ŀ
			 .o_LinkNumB_Work(LinkNumB_Work),
			 .o_LinkNumC_Work(LinkNumC_Work),
			 .redun_Syn(redun_Syn)//��������һ���ز�ͬ���ź�
			 );
//----------------��ƽ��ֱ����ѹָ�����ģ��-----------------//
Ave_phaseUdc_calc  Ave_phaseUdc_calc(
          .i_clk_20M(i_clk_20M),
			 .i_reset_n(i_reset_n),
			 .i_VCU_Mode(i_VCU_Mode),//���ػ������� 3���һ/����	 			 
			 .i_LinkUdcA_BUS(i_LinkUdcA_BUS),//ģ��ֱ����ѹ����
			 .i_LinkUdcB_BUS(i_LinkUdcB_BUS),
			 .i_LinkUdcC_BUS(i_LinkUdcC_BUS),
			 .i_LinkNumA_Work(LinkNumA_Work),//ABC��������������û�������������Ŀ
			 .i_LinkNumB_Work(LinkNumB_Work),
			 .i_LinkNumC_Work(LinkNumC_Work),
			 
			 .o_PhaseA_Udc(o_PhaseA_Udc),//��ƽ��ֱ����ѹ	
			 .o_PhaseB_Udc(o_PhaseB_Udc),
			 .o_PhaseC_Udc(o_PhaseC_Udc)			 			 
			 );
//----------------ÿ��ģ��ƽ�����ڵ�ѹָ�����ģ��-----------------//
Ave_TargetVol_calc  Ave_TargetVol_calc(
          .i_clk_20M(i_clk_20M),
			 .i_reset_n(i_reset_n),
			 .i_VCU_Mode(i_VCU_Mode),//���ػ������� 3���һ/����	 			 
			 .i_TargetVolA(i_TargetVolA),//�����жϺ����յĵ��Ƶ�ѹ
			 .i_TargetVolB(i_TargetVolB),
			 .i_TargetVolC(i_TargetVolC),
			 .i_LinkNumA_Work(LinkNumA_Work),//ABC��������������û�������������Ŀ
			 .i_LinkNumB_Work(LinkNumB_Work),
			 .i_LinkNumC_Work(LinkNumC_Work),
			 
			 .o_Ave_TargetVolA(Ave_TargetVolA),//��ƽ�����Ƶ�ѹ	
			 .o_Ave_TargetVolB(Ave_TargetVolB),
			 .o_Ave_TargetVolC(Ave_TargetVolC)			 			 
			 );

//----------------���ڹ���ģ��PWM�����ز�����Ǽ���ģ��-----------------//
Angle_shift_calc Angle_shift_calc(
          .i_clk_20M(i_clk_20M),
			 .i_reset_n(i_reset_n),
			 .i_VCU_Mode(i_VCU_Mode),//���ػ������� 3���һ/����
			 .i_SwitchFreq(i_SwitchFreq),//����Ƶ��
			 .i_LinkNumA_Work(LinkNumA_Work),//ABC��������������û�������������Ŀ
			 .i_LinkNumB_Work(LinkNumB_Work),
			 .i_LinkNumC_Work(LinkNumC_Work),
			 .o_Freqency_cnt(Freqency_cnt),//����Ƶ�ʼ�����20Mʱ��
			 .o_temp(temp),
			 .o_temp_long(temp_long),
          .o_angle_shiftA(angle_shiftA),//ABC��������ģ�������ز������
			 .o_angle_shiftB(angle_shiftB),
			 .o_angle_shiftC(angle_shiftC)
          );
//----------------�����ز�ͬ������ģ��-----------------//
Carrier_Syn_gen Carrier_Syn_gen(
          .i_clk_20M(i_clk_20M),
			 .i_reset_n(i_reset_n),
			 .i_Freqency_cnt(Freqency_cnt),//����Ƶ�ʼ�����20Mʱ��
			 .o_syn_out(carrier_syn_out)//�ز�����ͬ���ź�
          );
//----------------PWM�����ʼ��Ǽ���ģ��-----------------//
Initial_Angle_calc  Initial_Angle_calc(
          .i_clk_20M(i_clk_20M),
			 .i_reset_n(i_reset_n),
			 .i_VCU_Mode(i_VCU_Mode),//���ػ������� 3���һ/����
          .i_angle_shiftA(angle_shiftA),//ABC��������ģ�������ز������
			 .i_angle_shiftB(angle_shiftB),
			 .i_angle_shiftC(angle_shiftC),
			 .i_Redun_pos1(i_Redun_pos1),//A/B/C����λ����
			 .i_Redun_pos2(i_Redun_pos2_ini),
			 .i_Redun_pos3(i_Redun_pos3),
			 .i_Redun_pos4(i_Redun_pos4_ini),
			 .i_Redun_pos5(i_Redun_pos5),
			 .i_Redun_pos6(i_Redun_pos6_ini),
          .o_initi_angleA_BUS(initi_angleA_BUS),//ģ���ʼ���
			 .o_initi_angleB_BUS(initi_angleB_BUS),
			 .o_initi_angleC_BUS(initi_angleC_BUS)
          );
//----------------�ز�����CSPWM����ģ��-----------------//
CSPWM_calc  CSPWM_calc(
          .i_clk(i_clk),
          .i_clk_20M(i_clk_20M),
			 .clk_cps(clk_100K),
			 .i_reset_n(i_reset_n),
			 .i_start_PWM(i_start_PWM),
			 .i_VCU_Mode(i_VCU_Mode),//���ػ������� 3���һ/����
			 .i_Ave_TargetVolA(Ave_TargetVolA),//��ƽ�����Ƶ�ѹ	
			 .i_Ave_TargetVolB(Ave_TargetVolB),
			 .i_Ave_TargetVolC(Ave_TargetVolC),
			 .i_CosThetA(i_CosThetA),//�����жϺ����յ�����ֵ
			 .i_CosThetB(i_CosThetB),
			 .i_CosThetC(i_CosThetC),
			 .i_LinkUdcA_BUS(i_LinkUdcA_BUS),//ģ��ֱ����ѹ����
			 .i_LinkUdcB_BUS(i_LinkUdcB_BUS),
			 .i_LinkUdcC_BUS(i_LinkUdcC_BUS),
			 .i_PhaseA_Udc(o_PhaseA_Udc),//��ƽ��ֱ����ѹ	
			 .i_PhaseB_Udc(o_PhaseB_Udc),
			 .i_PhaseC_Udc(o_PhaseC_Udc),	
			 .i_Freqency_cnt(Freqency_cnt),//����Ƶ�ʼ�����20Mʱ��
			 .i_temp(temp),
			 .i_temp_long(temp_long),
			 .i_Carrier_Syn(Carrier_Syn),//�ز�ͬ���ź�
          .i_initi_angleA_BUS(initi_angleA_BUS),//ģ���ʼ���
			 .i_initi_angleB_BUS(initi_angleB_BUS),
			 .i_initi_angleC_BUS(initi_angleC_BUS),
			 .i_Kp_Udc(i_Kp_Udc),//ֱ����ѹ�������ز�
			 .i_Udc_limit(i_Udc_limit),//ֱ����ѹ�����������޷�
			 .o_PWM_A_BUS(o_PWM_A_BUS),//PWM��
			 .o_PWM_B_BUS(o_PWM_B_BUS),
			 .o_PWM_C_BUS(o_PWM_C_BUS),
			 .o_CtrlVolA_BUS(o_CtrlVolA_BUS),//ģ����Ƶ�ѹ����
			 .o_CtrlVolB_BUS(o_CtrlVolB_BUS),
			 .o_CtrlVolC_BUS(o_CtrlVolC_BUS)
          );
//---------------------------------------
//reg[2:0] clk_10k_cnt;
//reg clk_10k;
//always @ (posedge clk_100K) 
//begin
//	if(!i_reset_n)begin
//		clk_10k_cnt<=3'd0;
//		clk_10k<=1'b0;
//	end
//	else begin 
//		if(clk_10k_cnt == 3'd5) clk_10k_cnt<=3'd0;
//		else clk_10k_cnt<=clk_10k_cnt+1;
//		if(clk_10k_cnt == 3'd5) clk_10k<=~clk_10k;
//		else clk_10k<=clk_10k;
//	end
//end
//-------------------------------------------------------------------
//wire [35:0] ILAControl;
//wire [671:0] data_chipscp;

//assign data_chipscp [15:0] = LinkNumA_Work;
//assign data_chipscp [31:16] = LinkNumB_Work;
//assign data_chipscp [47:32] = LinkNumC_Work;
//assign data_chipscp [63:48] = initi_angleA_BUS[383:368];
//assign data_chipscp [79:64] = initi_angleA_BUS[367:352];
//assign data_chipscp [95:80] = initi_angleA_BUS[351:336];
//assign data_chipscp [111:96] = initi_angleA_BUS[335:320];
//assign data_chipscp [127:112] = initi_angleA_BUS[319:304];
//assign data_chipscp [143:128] = initi_angleA_BUS[303:288];
//assign data_chipscp [159:144] = initi_angleA_BUS[287:272];
//assign data_chipscp [175:160] = initi_angleA_BUS[271:256];
//assign data_chipscp [191:176] = initi_angleA_BUS[255:240];
//assign data_chipscp [207:192] = initi_angleA_BUS[239:224];
//assign data_chipscp [223:208] = initi_angleA_BUS[223:208];
//assign data_chipscp [239:224] = initi_angleA_BUS[207:192];
//assign data_chipscp [255:240] = initi_angleA_BUS[191:176];
//assign data_chipscp [271:256] = initi_angleA_BUS[175:160];
//assign data_chipscp [287:272] = initi_angleA_BUS[159:144];
//assign data_chipscp [303:288] = initi_angleA_BUS[143:128];
//assign data_chipscp [319:304] = initi_angleA_BUS[127:112];
//assign data_chipscp [335:320] = initi_angleA_BUS[111:96];
//assign data_chipscp [351:336] = initi_angleA_BUS[95:80];
//assign data_chipscp [367:352] = initi_angleA_BUS[79:64];
//assign data_chipscp [383:368] = initi_angleA_BUS[63:48];
//assign data_chipscp [399:384] = initi_angleA_BUS[47:32];
//assign data_chipscp [415:400] = initi_angleA_BUS[31:16];
//assign data_chipscp [431:416] = initi_angleA_BUS[15:0];
//assign data_chipscp [447:432] = o_PhaseA_Udc;
//assign data_chipscp [463:448] = o_PhaseB_Udc;
//assign data_chipscp [479:464] = o_PhaseC_Udc;
//assign data_chipscp [495:480] = Ave_TargetVolA;
//assign data_chipscp [511:496] = Ave_TargetVolB;
//assign data_chipscp [559:512] = {angle_shiftB,angle_shiftA,Ave_TargetVolC};
//assign data_chipscp [607:560] = {32'b0,angle_shiftC};
//assign data_chipscp [655:608] = {};

//assign data_chipscp [15:0] = i_TargetVolA[15:0];
//assign data_chipscp [31:16] = i_TargetVolA[31:16];
//assign data_chipscp [47:32] = i_TargetVolB[15:0];
//assign data_chipscp [63:48] = o_CtrlVolA_BUS[383:368];
//assign data_chipscp [79:64] = o_CtrlVolA_BUS[367:352];
//assign data_chipscp [95:80] = o_CtrlVolA_BUS[351:336];
//assign data_chipscp [111:96] = o_CtrlVolA_BUS[335:320];
//assign data_chipscp [127:112] = o_CtrlVolA_BUS[319:304];
//assign data_chipscp [143:128] = o_CtrlVolA_BUS[303:288];
//assign data_chipscp [159:144] = o_CtrlVolA_BUS[287:272];
//assign data_chipscp [175:160] = o_CtrlVolA_BUS[271:256];
//assign data_chipscp [191:176] = o_CtrlVolA_BUS[255:240];
//assign data_chipscp [207:192] = o_CtrlVolA_BUS[239:224];
//assign data_chipscp [223:208] = o_CtrlVolA_BUS[223:208];
//assign data_chipscp [239:224] = o_CtrlVolA_BUS[207:192];
//assign data_chipscp [255:240] = o_CtrlVolA_BUS[191:176];
//assign data_chipscp [271:256] = o_CtrlVolA_BUS[175:160];
//assign data_chipscp [287:272] = o_CtrlVolA_BUS[159:144];
//assign data_chipscp [303:288] = o_CtrlVolA_BUS[143:128];
//assign data_chipscp [319:304] = o_CtrlVolA_BUS[127:112];
//assign data_chipscp [335:320] = o_CtrlVolA_BUS[111:96];
//assign data_chipscp [351:336] = o_CtrlVolA_BUS[95:80];
//assign data_chipscp [367:352] = o_CtrlVolA_BUS[79:64];
//assign data_chipscp [671:656] = o_CtrlVolA_BUS[63:48];
//assign data_chipscp [383:368] = o_CtrlVolA_BUS[47:32];
//assign data_chipscp [399:384] = o_CtrlVolA_BUS[31:16];
//assign data_chipscp [415:400] = o_CtrlVolA_BUS[15:0];
//assign data_chipscp [431:416] = i_TargetVolB[31:16];
//assign data_chipscp [447:432] = i_TargetVolC[15:0];
//assign data_chipscp [463:448] = i_TargetVolC[31:16];
//assign data_chipscp [479:464] = Ave_TargetVolA;
//assign data_chipscp [495:480] = Ave_TargetVolB;
//assign data_chipscp [511:496] = Ave_TargetVolC;
//assign data_chipscp [559:512] = o_PWM_A_BUS;
//assign data_chipscp [607:560] = o_PWM_B_BUS;
//assign data_chipscp [655:608] = o_PWM_C_BUS;
//
//
//new_icon SVG_icon ( 
//     .CONTROL0            ( ILAControl) 
//); 
//
//new_ila SVG_ila ( 
//		.CONTROL            ( ILAControl), 
//		.CLK                ( clk_1M), 
//		.DATA               ( data_chipscp), 
//		.TRIG0              (i_start_PWM),
//		.TRIG1              (),
//		.TRIG2              (), 
//		.TRIG3              ( )
//		
//);
//--------------------------------------------------------
	
endmodule
