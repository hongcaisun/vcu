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
								 input i_WD_DSP_ERR,//DSP喂狗故障信号
								 input i_XINT_DSP_ERR,//DSP中断执行故障（地址操作）
								 input i_sumerr_DSP,//FPGA接收阀控DSP校验错误位
								 input [15:0]i_PhaseStaDSP,//DSP传给FPGA相状态字
								 input [15:0]i_VCU_Mode,//阀控机箱类型 3相合一/单相
								 input i_phaselock1_brk,//相间封锁光纤1断线
								 input i_phaselock2_brk,//相间封锁光纤2断线
								 input i_phaselock1_pulerr,//相间封锁光纤1频率出错
								 input i_phaselock2_pulerr,//相间封锁光纤2频率出错
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
								 
								 input i_fastlock1,//快速封锁光纤输入
								 input i_fastlock2,
								 output o_fastlock_final,//从测量机箱过来判主从后的快速封锁信号
								 output [15:0]o_ComSta_fastlock,//快速封锁状态字
								 input i_phaselock1,//其他两相过来的封锁信号
								 input i_phaselock2,
								 
								 input [15:0]i_PhaseA_Udc,//相平均直流电压
								 input [15:0]i_PhaseB_Udc,
								 input [15:0]i_PhaseC_Udc,
								 
								 output [15:0]o_ControlWord,//主从判断后最终的控制命令字
								 output signed[31:0]o_TargetVolA,//主从判断后最终的调制电压
								 output signed[31:0]o_TargetVolB,
								 output signed[31:0]o_TargetVolC,
								 output signed[15:0]o_CosThetA,//主从判断后最终的余弦值
								 output signed[15:0]o_CosThetB,
								 output signed[15:0]o_CosThetC,
								 
								 output [15:0]o_CtrlWord_A,//控保A下发命令字
								 output [15:0]o_CtrlWord_B,//控保B下发命令字	
								 output [15:0]o_RenewCntCP_A,//控保A系统更新计数器	
								 output [15:0]o_RenewCntCP_B,//控保B系统更新计数器								 
								 output [15:0]o_ComStaCP_A,//接收控保A系统通讯状态字
								 output [15:0]o_ComStaCP_B,//接收控保B系统通讯状态字
								 output [15:0]o_CP_MasSla_Sta,//控保主从状态字
								 
								 output o_rdint_CP,//外部同步参考信号
								 output [15:0]o_PhaseStaCP//给控保最终的相状态字
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
//A相控保接收发送模块:单相时默认
Man_TxRx_CP Man_TxRx_CP_PhaseA(
                         .i_clk(i_clk),
								 .i_clk_20M(i_clk_20M),
								 .i_clk_100K(i_clk_100K),
								 .i_reset_n(i_reset_n),
								 .i_OptoPhase_sysA(i_OptoPhaseA_sysA),//接收光纤
								 .i_OptoPhase_sysB(i_OptoPhaseA_sysB),
								 .o_OptoPhase_sysA(o_OptoPhaseA_sysA),//发送光纤
								 .o_OptoPhase_sysB(o_OptoPhaseA_sysB),
								 
								 .i_fastlock1(i_fastlock1),//快速封锁光纤输入
								 .i_fastlock2(i_fastlock2),
								 .o_fastlock_final(o_fastlock_final),//从测量机箱过来判主从后的快速封锁信号
								 .o_ComSta_fastlock(ComSta_fastlock),//快速封锁状态字
								 
								 .i_start_txCP(i_start_txCP),//发送使能
								 .i_WD_DSP_ERR(i_WD_DSP_ERR),//DSP喂狗故障信号
								 .i_XINT_DSP_ERR(i_XINT_DSP_ERR),//DSP中断执行故障（地址操作）
								 .i_sumerr_DSP(i_sumerr_DSP),//FPGA接收阀控DSP校验错误位
								 .i_PhaseStaDSP(i_PhaseStaDSP),//相状态字
								 .i_Phase_Udc(i_PhaseA_Udc),//相平均直流电压
								 
								 .o_ControlWord(o_ControlWord),//主从判断后最终的控制命令字
								 .o_TargetVol(o_TargetVolA),//主从判断后最终的调制电压
								 .o_CosThet(o_CosThetA),//主从判断后最终的余弦值
								 
								 .o_CtrlWord_A(o_CtrlWord_A),//控保A下发命令字
								 .o_CtrlWord_B(o_CtrlWord_B),//控保B下发命令字		
								 .o_RenewCntCP_A(o_RenewCntCP_A),//控保A系统更新计数器	
								 .o_RenewCntCP_B(o_RenewCntCP_B),//控保B系统更新计数器								 
								 .o_ComStaCP_sysA(ComStaCP_phaseA_sysA),
								 .o_ComStaCP_sysB(ComStaCP_phaseA_sysB),
								 .o_CP_MasSla_Sta(o_CP_MasSla_Sta),//控保主从状态字
								 .o_PhaseStaCP(o_PhaseStaCP),//给控保最终的相状态字
								 .o_rdint_CP(o_rdint_CP)//外部同步参考信号
                         );
//B相控保接收发送模块
Man_TxRx_CP Man_TxRx_CP_PhaseB(
                         .i_clk(i_clk),
								 .i_clk_20M(i_clk_20M),
								 .i_clk_100K(i_clk_100K),
								 .i_reset_n(i_reset_n),
								 .i_OptoPhase_sysA(i_OptoPhaseB_sysA),
								 .i_OptoPhase_sysB(i_OptoPhaseB_sysB),
								 .o_OptoPhase_sysA(o_OptoPhaseB_sysA),
								 .o_OptoPhase_sysB(o_OptoPhaseB_sysB),
								 
								 .i_fastlock1(),//快速封锁光纤输入
								 .i_fastlock2(),
								 .o_fastlock_final(),//从测量机箱过来判主从后的快速封锁信号
								 .o_ComSta_fastlock(),//快速封锁状态字

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
////C相控保接收发送模块
Man_TxRx_CP Man_TxRx_CP_PhaseC(
                         .i_clk(i_clk),
								 .i_clk_20M(i_clk_20M),
								 .i_clk_100K(i_clk_100K),
								 .i_reset_n(i_reset_n),
								 .i_OptoPhase_sysA(i_OptoPhaseC_sysA),
								 .i_OptoPhase_sysB(i_OptoPhaseC_sysB),
								 .o_OptoPhase_sysA(o_OptoPhaseC_sysA),
								 .o_OptoPhase_sysB(o_OptoPhaseC_sysB),
								 
								 .i_fastlock1(),//快速封锁光纤输入
								 .i_fastlock2(),
								 .o_fastlock_final(),//从测量机箱过来判主从后的快速封锁信号
								 .o_ComSta_fastlock(),//快速封锁状态字

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
