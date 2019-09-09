`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: CEPRI
// Engineer: Zhang Dian-qing
// 
// Create Date:    21:30:47 03/11/2019 
// Design Name: 
// Module Name:    Man_TxRx_CP 
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
module Man_TxRx_CP(
                         input i_clk,
								 input i_clk_20M,
								 input i_clk_100K,
								 input i_reset_n,
								 input i_OptoPhase_sysA,
								 input i_OptoPhase_sysB,
								 output o_OptoPhase_sysA,
								 output o_OptoPhase_sysB,
								 
								 input i_fastlock1,//���ٷ�����������
								 input i_fastlock2,
								 output o_fastlock_final,//�Ӳ���������������Ӻ�Ŀ��ٷ����ź�
								 output [15:0]o_ComSta_fastlock,//���ٷ���״̬��
								 
								 input i_start_txCP,//����ʹ��
								 input i_WD_DSP_ERR,//DSPι�������ź�
								 input i_XINT_DSP_ERR,//DSP�ж�ִ�й��ϣ���ַ������
								 input i_sumerr_DSP,//FPGA���շ���DSPУ�����λ
								 input [15:0]i_PhaseStaDSP,//DSP����FPGA��״̬��
								 input [15:0]i_Phase_Udc,//��ƽ��ֱ����ѹ
								 
								 output [15:0]o_ControlWord,//�����жϺ����յĿ���������
								 output signed[31:0]o_TargetVol,//�����жϺ����յĵ��Ƶ�ѹ
								 output signed[15:0]o_CosThet,//�����жϺ����յ�����ֵ
								 
								 output [15:0]o_CtrlWord_A,//�ر�A�·�������
								 output [15:0]o_CtrlWord_B,//�ر�B�·�������	
								 output [15:0]o_RenewCntCP_A,//�ر�Aϵͳ���¼�����		
								 output [15:0]o_RenewCntCP_B,//�ر�Bϵͳ���¼�����								 
								 output [15:0]o_ComStaCP_sysA,
								 output [15:0]o_ComStaCP_sysB,
								 output [15:0]o_CP_MasSla_Sta,//�ر�����״̬��
								 output [15:0]o_PhaseStaCP,//���ر����յ���״̬��
								 output o_rdint_CP//�ⲿͬ���ο��ź�
);
//----------------------�źŶ���-----------------------//	 

wire rd_intA,rd_intB;
wire [15:0]backup1_CPA,backup2_CPA;
wire [15:0]backup1_CPB,backup2_CPB;
wire signed[31:0]TargetVol_CPA,TargetVol_CPB;
wire signed[15:0]CosThet_CPA,CosThet_CPB;
wire [15:0]PhaseStaCPA,PhaseStaCPB;
wire o_fastlock1,o_fastlock2,o_fastlock1_pulerr,o_fastlock2_pulerr;
reg [15:0]cnt1,cnt2;
wire o_fastlock1_brk,o_fastlock2_brk;

assign o_ComSta_fastlock = {12'd0,o_fastlock2_pulerr,o_fastlock1_pulerr,o_fastlock2_brk,o_fastlock1_brk};
assign o_PhaseStaCP = PhaseStaCPA;
//----------------------ģ�鶨��-----------------------//
//--------------���տر�A/Bϵͳģ��-------------------// 
Man_rxP2_KB Man_RxP2_CPA (
    .clk(i_clk), 
    .reset_n(i_reset_n), 
    .rx_d(i_OptoPhase_sysA), 
    .ControlWord(o_CtrlWord_A),//�ر�A�·������� 
    .TargetVol(TargetVol_CPA),//����Aϵͳ�ĵ��Ƶ�ѹ 
	 .CosThet(CosThet_CPA),//����Aϵͳ������ֵ
    .backup1(backup1_CPA), 
	 .backup2(backup2_CPA),
    .RenewalCnt(o_RenewCntCP_A),//�ر�Aϵͳ���¼����� 
    .ComSta(o_ComStaCP_sysA),//ͨѶ״̬ 
    .rd_int(rd_intA)
    ); 
Man_rxP2_KB Man_RxP2_CPB (
    .clk(i_clk), 
    .reset_n(i_reset_n), 
    .rx_d(i_OptoPhase_sysB), 
    .ControlWord(o_CtrlWord_B), 
    .TargetVol(TargetVol_CPB), 
	 .CosThet(CosThet_CPB),
    .backup1(backup1_CPB), 
	 .backup2(backup2_CPB),
    .RenewalCnt(o_RenewCntCP_B), 
    .ComSta(o_ComStaCP_sysB), 
    .rd_int(rd_intB)
    );
//--------------------------
//reg rd_reg;
//reg [15:0]ss1,ss2,ss3,ss4;
//always @ (posedge i_clk)
//begin
//	rd_reg <= rd_intA;
//	if ( rd_reg&(~rd_intA)) begin
//		ss4 <= ss3;
//		ss3 <= ss2;
//		ss2 <= ss1;
//		ss1 <= o_RenewCntCP_A;
//	end
//	else begin
//		ss4 <= ss4;
//		ss3 <= ss3;
//		ss2 <= ss2;
//		ss1 <= ss1;
//	end
//end
//assign aa = (ss2 == ss3+1)? 1'b1:1'b0;
//--------------���͸��ر�A/Bϵͳģ��-------------------// 
Man_TxKB Man_TxP1_CPA (
    .i_sys_clk(i_clk), 
    .clk_20MHz(i_clk_20M), 
    .reset_n(i_reset_n), 
    .FS_sys(i_start_txCP), 
    .dsptoKB0(PhaseStaCPA), //��״̬��
    .dsptoKB1(i_Phase_Udc), //��ƽ��ֱ����ѹ
    .dsptoKB2(16'd0),
    .dsptoKB3(16'd0),
    .dsptoKB4(16'd0),
    .dsptoKB5(16'd0),
    .dsptoKB6(16'd0), 
    .dsptoKB7(16'd0),   	 
    .man_tx(o_OptoPhase_sysA) 
    );
Man_TxKB Man_TxP1_CPB (
    .i_sys_clk(i_clk), 
    .clk_20MHz(i_clk_20M), 
    .reset_n(i_reset_n), 
    .FS_sys(i_start_txCP), 
    .dsptoKB0(PhaseStaCPB), 
    .dsptoKB1(i_Phase_Udc), 
    .dsptoKB2(16'd0), 
    .dsptoKB3(16'd0), 
    .dsptoKB4(16'd0), 
    .dsptoKB5(16'd0), 
    .dsptoKB6(16'd0), 
    .dsptoKB7(16'd0),  
    .man_tx(o_OptoPhase_sysB) 
    );
//wire [1:0]system_state;
//wire system;
//---------------------�п��ٹ��˶��ߡ�Ƶ���ź�ʶ���Ƶ�ʲ����ź�------------------------
rxd_freq fastlock1(
				.clk_20M(i_clk_20M),
				.clr(i_reset_n),
				.rxd(i_fastlock1),
				.lock_stat(o_fastlock1),
				.pulse_err(o_fastlock1_pulerr),
				.phaselock_brk(o_fastlock1_brk)
);
rxd_freq fastlock2(
				.clk_20M(i_clk_20M),
				.clr(i_reset_n),
				.rxd(i_fastlock2),
				.lock_stat(o_fastlock2),
				.pulse_err(o_fastlock2_pulerr),
				.phaselock_brk(o_fastlock2_brk)
);
//------------�����л�����ģ��------------------------//
KB_switch CP_switch(
    .clk_20M(i_clk_20M),
	 .i_clk_100K(i_clk_100K),
	 .reset_n(i_reset_n),
	 .rd_intA(rd_intA),//����֡������ɱ�־
	 .rd_intB(rd_intB),//����֡������ɱ�־
	 .i_WD_DSP_ERR(i_WD_DSP_ERR),//DSPι�������ź�
	 .i_XINT_DSP_ERR(i_XINT_DSP_ERR),//DSP�ж�ִ�й��ϣ���ַ������
	 .i_sumerr_DSP(i_sumerr_DSP),//FPGA���շ���DSPУ�����λ
	 .i_PhaseStaDSP(i_PhaseStaDSP),//��״̬��
	 
	 .i_CtrlWord_A(o_CtrlWord_A),//�ر�A�·�������
	 .i_CtrlWord_B(o_CtrlWord_B),//�ر�B�·�������	
    .i_TargetVol_CPA(TargetVol_CPA),//����Aϵͳ�ĵ��Ƶ�ѹ
    .i_TargetVol_CPB(TargetVol_CPB),//����Bϵͳ�ĵ��Ƶ�ѹ	 
	 .i_CosThet_CPA(CosThet_CPA),//����Aϵͳ������ֵ
	 .i_CosThet_CPB(CosThet_CPB),//����Bϵͳ������ֵ
	 
	 .i_fastlock1(o_fastlock1),//Aϵͳ�·����ٷ���
	 .i_fastlock2(o_fastlock2),//Bϵͳ�·����ٷ���
	 .o_fastlock_final(o_fastlock_final),//�����жϺ����շ����Ŀ��ٷ���
	 
	 .o_ControlWord(o_ControlWord),//�����жϺ����յĿ���������
	 .o_TargetVol(o_TargetVol),//�����жϺ����յĵ��Ƶ�ѹ
	 .o_CosThet(o_CosThet),//�����жϺ����յ�����ֵ
	 .o_CP_MasSla_Sta(o_CP_MasSla_Sta),//�ر�����״̬��	
    .o_PhaseStaCPA(PhaseStaCPA),//��״̬��
    .o_PhaseStaCPB(PhaseStaCPB),//��״̬��	 
	 .o_rdint_CP(o_rdint_CP)//�ⲿͬ���ο��ź�
//	 .system(system),
//	 .system_state(system_state)
    );
//---------------------����֡ͬ���������ֵ����Сֵ�ĳ���
//parameter ZHENZHOUQI = 158;
//parameter ZHENZHOUQIMAX = ZHENZHOUQI*20;
//parameter ZHENZHOUQIMIN = (ZHENZHOUQI - 2)*20; 
//reg spi_fs_in_reg,spi_fs_in_reg1,spi_fs_in_reg2;
//reg flag_min,flag_max;
//reg [15:0] cnt_spi;
//reg [15:0] cnt_reg;
//always @ (posedge i_clk_20M )
//begin
//	spi_fs_in_reg2 <= spi_fs_in_reg1;
//	spi_fs_in_reg1 <= spi_fs_in_reg;
//	spi_fs_in_reg <= rd_intA;
//	if (!i_reset_n)
//		cnt_spi <= 16'd0;
//	else if ( (spi_fs_in_reg1==1'b0) && (spi_fs_in_reg==1'b1) )
//	begin
//		cnt_reg <= cnt_spi;
//		cnt_spi <= 16'd0;
//	end		
//	else if (cnt_spi == ZHENZHOUQIMAX )
//		cnt_spi <= ZHENZHOUQIMAX;
//	else
//	begin
//		cnt_spi <= cnt_spi + 16'd1;
//		cnt_reg <= cnt_reg;
//	end
//end
//always @ (posedge i_clk_20M )
//begin	
//	if (!i_reset_n)
//		flag_max <= 1'b0;
//	else if ( cnt_reg == ZHENZHOUQIMAX )
//		flag_max <= 1'b1;
//	else
//		flag_max <= 1'b0;
//end
//always @ (posedge i_clk_20M )
//begin	
//	if (!i_reset_n)
//		flag_min <= 1'b0;
//	else if ( cnt_reg < ZHENZHOUQIMIN )
//		flag_min <= 1'b1;
//	else
//		flag_min <= 1'b0;
//end
//---------------------------	
//--------------------------------------------------------
//wire [35:0]ILAControl;
//wire [656:0]data_chipscp; 
//assign data_chipscp[15:0] = {15'd0,i_OptoPhase_sysA};
//assign data_chipscp [31:16] = o_CtrlWord_A;
//assign data_chipscp [47:32] = TargetVol_CPA[15:0];
//assign data_chipscp [63:48] = TargetVol_CPA[31:16];
//assign data_chipscp [79:64] = CosThet_CPA;
//
//new_icon svg_icon ( 
//     .CONTROL0            ( ILAControl) 
//); 
//
//new_ila svg_ila ( 
//     .CONTROL            ( ILAControl), 
//     .CLK                ( i_clk_20M), 
//     .DATA               ( data_chipscp), 
//     .TRIG0              ( rd_intA ), 
//	  .TRIG1              ( rd_intB),
//	  .TRIG2              (  aa),
//	  .TRIG3              ( )
//);
endmodule
