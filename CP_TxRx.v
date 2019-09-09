`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:41:41 02/25/2019 
// Design Name: 
// Module Name:    CP_TxRx 
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
module CP_TxRx(
                         input i_clk,
								 input i_clk_20M,
								 input i_clk_100K,
								 input i_reset_n,
								 input i_start_txCP,
								 input i_WD_DSP_ERR,//DSPι�������ź�
								 input i_XINT_DSP_ERR,//DSP�ж�ִ�й��ϣ���ַ������
								 input i_sumerr_DSP,//FPGA���շ���DSPУ�����λ
								 input [15:0]i_PhaseStaDSP,//DSP����FPGA��״̬��
								 input [15:0]i_VCU_Mode,//���ػ������� 3���һ/����
								 input i_phaselock1_brk,//����������1����
								 input i_phaselock2_brk,//����������2����
								 input i_phaselock1_pulerr,//����������1Ƶ�ʳ���
								 input i_phaselock2_pulerr,//����������2Ƶ�ʳ���
								 input i_OptoPhaseA_sysA,
								 input i_OptoPhaseA_sysB,
								 input i_OptoPhaseB_sysA,
								 input i_OptoPhaseB_sysB,
								 input i_OptoPhaseC_sysA,
								 input i_OptoPhaseC_sysB,								 
								 output o_OptoPhaseA_sysA,
								 output o_OptoPhaseA_sysB,
								 output o_OptoPhaseB_sysA,
								 output o_OptoPhaseB_sysB,
								 output o_OptoPhaseC_sysA,
								 output o_OptoPhaseC_sysB,
								 
								 input i_fastlock1,//���ٷ�����������
								 input i_fastlock2,
								 output o_fastlock_final,//�Ӳ���������������Ӻ�Ŀ��ٷ����ź�
								 output [15:0]o_ComSta_fastlock,//���ٷ���״̬��
								 input i_phaselock1,//������������ķ����ź�
								 input i_phaselock2,
								 
								 input [15:0]i_PhaseA_Udc,//��ƽ��ֱ����ѹ
								 input [15:0]i_PhaseB_Udc,
								 input [15:0]i_PhaseC_Udc,
								 
								 output [15:0]o_ControlWord,//�����жϺ����յĿ���������
								 output signed[31:0]o_TargetVolA,//�����жϺ����յĵ��Ƶ�ѹ
								 output signed[31:0]o_TargetVolB,
								 output signed[31:0]o_TargetVolC,
								 output signed[15:0]o_CosThetA,//�����жϺ����յ�����ֵ
								 output signed[15:0]o_CosThetB,
								 output signed[15:0]o_CosThetC,
								 
								 output [15:0]o_CtrlWord_A,//�ر�A�·�������
								 output [15:0]o_CtrlWord_B,//�ر�B�·�������	
								 output [15:0]o_RenewCntCP_A,//�ر�Aϵͳ���¼�����	
								 output [15:0]o_RenewCntCP_B,//�ر�Bϵͳ���¼�����								 
								 output [15:0]o_ComStaCP_A,//���տر�AϵͳͨѶ״̬��
								 output [15:0]o_ComStaCP_B,//���տر�BϵͳͨѶ״̬��
								 output [15:0]o_CP_MasSla_Sta,//�ر�����״̬��
								 
								 output o_rdint_CP,//�ⲿͬ���ο��ź�
								 output [15:0]o_PhaseStaCP//���ر����յ���״̬��
								 );


wire [15:0]ComStaCP_phaseA_sysA,ComStaCP_phaseB_sysA,ComStaCP_phaseC_sysA;
wire [15:0]ComStaCP_phaseA_sysB,ComStaCP_phaseB_sysB,ComStaCP_phaseC_sysB;
assign o_ComStaCP_A = {i_phaselock2,i_phaselock1,i_phaselock2_pulerr,i_phaselock1_pulerr,i_phaselock2_brk,i_phaselock1_brk,i_sumerr_DSP,
                       ComStaCP_phaseC_sysA[2:0],ComStaCP_phaseB_sysA[2:0],ComStaCP_phaseA_sysA[2:0]};
assign o_ComStaCP_B = {i_phaselock2,i_phaselock1,i_phaselock2_pulerr,i_phaselock1_pulerr,i_phaselock2_brk,i_phaselock1_brk,i_sumerr_DSP,
                       ComStaCP_phaseC_sysB[2:0],ComStaCP_phaseB_sysB[2:0],ComStaCP_phaseA_sysB[2:0]};
wire [15:0]ComSta_fastlock;
assign o_ComSta_fastlock = {6'b0,ComStaCP_phaseC_sysB[3],ComStaCP_phaseC_sysA[3],ComStaCP_phaseB_sysB[3],ComStaCP_phaseB_sysA[3],ComStaCP_phaseA_sysB[3],ComStaCP_phaseA_sysA[3],ComSta_fastlock[3:0]};
//=================================================
//A��ر����շ���ģ��:����ʱĬ��
Man_TxRx_CP Man_TxRx_CP_PhaseA(
                         .i_clk(i_clk),
								 .i_clk_20M(i_clk_20M),
								 .i_clk_100K(i_clk_100K),
								 .i_reset_n(i_reset_n),
								 .i_OptoPhase_sysA(i_OptoPhaseA_sysA),//���չ���
								 .i_OptoPhase_sysB(i_OptoPhaseA_sysB),
								 .o_OptoPhase_sysA(o_OptoPhaseA_sysA),//���͹���
								 .o_OptoPhase_sysB(o_OptoPhaseA_sysB),
								 
								 .i_fastlock1(i_fastlock1),//���ٷ�����������
								 .i_fastlock2(i_fastlock2),
								 .o_fastlock_final(o_fastlock_final),//�Ӳ���������������Ӻ�Ŀ��ٷ����ź�
								 .o_ComSta_fastlock(ComSta_fastlock),//���ٷ���״̬��
								 
								 .i_start_txCP(i_start_txCP),//����ʹ��
								 .i_WD_DSP_ERR(i_WD_DSP_ERR),//DSPι�������ź�
								 .i_XINT_DSP_ERR(i_XINT_DSP_ERR),//DSP�ж�ִ�й��ϣ���ַ������
								 .i_sumerr_DSP(i_sumerr_DSP),//FPGA���շ���DSPУ�����λ
								 .i_PhaseStaDSP(i_PhaseStaDSP),//��״̬��
								 .i_Phase_Udc(i_PhaseA_Udc),//��ƽ��ֱ����ѹ
								 
								 .o_ControlWord(o_ControlWord),//�����жϺ����յĿ���������
								 .o_TargetVol(o_TargetVolA),//�����жϺ����յĵ��Ƶ�ѹ
								 .o_CosThet(o_CosThetA),//�����жϺ����յ�����ֵ
								 
								 .o_CtrlWord_A(o_CtrlWord_A),//�ر�A�·�������
								 .o_CtrlWord_B(o_CtrlWord_B),//�ر�B�·�������		
								 .o_RenewCntCP_A(o_RenewCntCP_A),//�ر�Aϵͳ���¼�����	
								 .o_RenewCntCP_B(o_RenewCntCP_B),//�ر�Bϵͳ���¼�����								 
								 .o_ComStaCP_sysA(ComStaCP_phaseA_sysA),
								 .o_ComStaCP_sysB(ComStaCP_phaseA_sysB),
								 .o_CP_MasSla_Sta(o_CP_MasSla_Sta),//�ر�����״̬��
								 .o_PhaseStaCP(o_PhaseStaCP),//���ر����յ���״̬��
								 .o_rdint_CP(o_rdint_CP)//�ⲿͬ���ο��ź�
                         );
//B��ر����շ���ģ��
Man_TxRx_CP Man_TxRx_CP_PhaseB(
                         .i_clk(i_clk),
								 .i_clk_20M(i_clk_20M),
								 .i_clk_100K(i_clk_100K),
								 .i_reset_n(i_reset_n),
								 .i_OptoPhase_sysA(i_OptoPhaseB_sysA),
								 .i_OptoPhase_sysB(i_OptoPhaseB_sysB),
								 .o_OptoPhase_sysA(o_OptoPhaseB_sysA),
								 .o_OptoPhase_sysB(o_OptoPhaseB_sysB),
								 
								 .i_fastlock1(),//���ٷ�����������
								 .i_fastlock2(),
								 .o_fastlock_final(),//�Ӳ���������������Ӻ�Ŀ��ٷ����ź�
								 .o_ComSta_fastlock(),//���ٷ���״̬��

								 .i_start_txCP(i_start_txCP),
								 .i_WD_DSP_ERR(i_WD_DSP_ERR),
								 .i_XINT_DSP_ERR(i_XINT_DSP_ERR),
								 .i_sumerr_DSP(i_sumerr_DSP),
								 .i_PhaseStaDSP(i_PhaseStaDSP),
								 .i_Phase_Udc(i_PhaseB_Udc),
								 
								 .o_ControlWord(),
								 .o_TargetVol(o_TargetVolB),
								 .o_CosThet(o_CosThetB),
								 
								 .o_CtrlWord_A(),
								 .o_CtrlWord_B(),	
								 .o_RenewCntCP_A(),	
								 .o_RenewCntCP_B(),								 
								 .o_ComStaCP_sysA(ComStaCP_phaseB_sysA),
								 .o_ComStaCP_sysB(ComStaCP_phaseB_sysB),
								 .o_CP_MasSla_Sta(),
								 .o_PhaseStaCP(),
								 .o_rdint_CP()
                         );              
////C��ر����շ���ģ��
Man_TxRx_CP Man_TxRx_CP_PhaseC(
                         .i_clk(i_clk),
								 .i_clk_20M(i_clk_20M),
								 .i_clk_100K(i_clk_100K),
								 .i_reset_n(i_reset_n),
								 .i_OptoPhase_sysA(i_OptoPhaseC_sysA),
								 .i_OptoPhase_sysB(i_OptoPhaseC_sysB),
								 .o_OptoPhase_sysA(o_OptoPhaseC_sysA),
								 .o_OptoPhase_sysB(o_OptoPhaseC_sysB),
								 
								 .i_fastlock1(),//���ٷ�����������
								 .i_fastlock2(),
								 .o_fastlock_final(),//�Ӳ���������������Ӻ�Ŀ��ٷ����ź�
								 .o_ComSta_fastlock(),//���ٷ���״̬��

								 .i_start_txCP(i_start_txCP),
								 .i_WD_DSP_ERR(i_WD_DSP_ERR),
								 .i_XINT_DSP_ERR(i_XINT_DSP_ERR),
								 .i_sumerr_DSP(i_sumerr_DSP),
								 .i_PhaseStaDSP(i_PhaseStaDSP),
								 .i_Phase_Udc(i_PhaseC_Udc),
								 
								 .o_ControlWord(),
								 .o_TargetVol(o_TargetVolC),
								 .o_CosThet(o_CosThetC),
								 
								 .o_CtrlWord_A(),
								 .o_CtrlWord_B(),	
								 .o_RenewCntCP_A(),	
								 .o_RenewCntCP_B(),								 
								 .o_ComStaCP_sysA(ComStaCP_phaseC_sysA),
								 .o_ComStaCP_sysB(ComStaCP_phaseC_sysB),
								 .o_CP_MasSla_Sta(),
								 .o_PhaseStaCP(),
								 .o_rdint_CP()
                         );
//----------------------------------------------------------------------
//wire [35:0] ILAControl;
//wire [656:0] data_chipscp;
//
//assign data_chipscp [15:0] = {12'd0,ComStaCP_phaseA_sysA[2:0],i_OptoPhaseA_sysA};
//assign data_chipscp [31:16] = o_CtrlWord_A;
//assign data_chipscp [47:32] = o_TargetVolA[15:0];
//assign data_chipscp [63:48] = o_TargetVolA[31:16];
////assign data_chipscp [79:64] = o_CtrlVolA_BUS[367:352];
////assign data_chipscp [95:80] = o_CtrlVolA_BUS[351:336];
////assign data_chipscp [111:96] = o_CtrlVolA_BUS[335:320];
////assign data_chipscp [127:112] = o_CtrlVolA_BUS[319:304];
////assign data_chipscp [143:128] = o_CtrlVolA_BUS[303:288];
////assign data_chipscp [159:144] = o_CtrlVolA_BUS[287:272];
////assign data_chipscp [175:160] = o_CtrlVolA_BUS[271:256];
////assign data_chipscp [191:176] = o_CtrlVolA_BUS[255:240];
////assign data_chipscp [207:192] = o_CtrlVolA_BUS[239:224];
////assign data_chipscp [223:208] = o_CtrlVolA_BUS[223:208];
////assign data_chipscp [239:224] = o_CtrlVolA_BUS[207:192];
////assign data_chipscp [255:240] = o_CtrlVolA_BUS[191:176];
////assign data_chipscp [271:256] = o_CtrlVolA_BUS[175:160];
////assign data_chipscp [287:272] = o_CtrlVolA_BUS[159:144];
////assign data_chipscp [303:288] = o_CtrlVolA_BUS[143:128];
////assign data_chipscp [319:304] = o_CtrlVolA_BUS[127:112];
////assign data_chipscp [335:320] = o_CtrlVolA_BUS[111:96];
////assign data_chipscp [351:336] = o_CtrlVolA_BUS[95:80];
////assign data_chipscp [367:352] = o_CtrlVolA_BUS[79:48];
////assign data_chipscp [383:368] = o_CtrlVolA_BUS[47:32];
////assign data_chipscp [399:384] = o_CtrlVolA_BUS[31:16];
////assign data_chipscp [415:400] = o_CtrlVolA_BUS[15:0];
////assign data_chipscp [431:416] = i_TargetVolB[31:16];
////assign data_chipscp [447:432] = i_TargetVolC[15:0];
////assign data_chipscp [463:448] = i_TargetVolC[31:16];
////assign data_chipscp [479:464] = Ave_TargetVolA;
////assign data_chipscp [495:480] = Ave_TargetVolB;
////assign data_chipscp [511:496] = Ave_TargetVolC;
////assign data_chipscp [559:512] = o_PWM_A_BUS;
////assign data_chipscp [607:560] = o_PWM_B_BUS;
////assign data_chipscp [655:608] = o_PWM_C_BUS;
//
//
//new_icon SVG_icon ( 
//     .CONTROL0            ( ILAControl) 
//); 
//
//new_ila SVG_ila ( 
//		.CONTROL            ( ILAControl), 
//		.CLK                ( i_clk_20M), 
//		.DATA               ( data_chipscp), 
//		.TRIG0              (ComStaCP_phaseA_sysA[0]),
//		.TRIG1              (ComStaCP_phaseA_sysA[1]),
//		.TRIG2              (ComStaCP_phaseA_sysA[2]), 
//		.TRIG3              ( )
//		
//);

endmodule
