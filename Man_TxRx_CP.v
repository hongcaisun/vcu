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
								 
								 input i_fastlock1,//快速封锁光纤输入
								 input i_fastlock2,
								 output o_fastlock_final,//从测量机箱过来判主从后的快速封锁信号
								 output [15:0]o_ComSta_fastlock,//快速封锁状态字
								 
								 input i_start_txCP,//发送使能
								 input i_WD_DSP_ERR,//DSP喂狗故障信号
								 input i_XINT_DSP_ERR,//DSP中断执行故障（地址操作）
								 input i_sumerr_DSP,//FPGA接收阀控DSP校验错误位
								 input [15:0]i_PhaseStaDSP,//DSP传给FPGA相状态字
								 input [15:0]i_Phase_Udc,//相平均直流电压
								 
								 output [15:0]o_ControlWord,//主从判断后最终的控制命令字
								 output signed[31:0]o_TargetVol,//主从判断后最终的调制电压
								 output signed[15:0]o_CosThet,//主从判断后最终的余弦值
								 
								 output [15:0]o_CtrlWord_A,//控保A下发命令字
								 output [15:0]o_CtrlWord_B,//控保B下发命令字	
								 output [15:0]o_RenewCntCP_A,//控保A系统更新计数器		
								 output [15:0]o_RenewCntCP_B,//控保B系统更新计数器								 
								 output [15:0]o_ComStaCP_sysA,
								 output [15:0]o_ComStaCP_sysB,
								 output [15:0]o_CP_MasSla_Sta,//控保主从状态字
								 output [15:0]o_PhaseStaCP,//给控保最终的相状态字
								 output o_rdint_CP//外部同步参考信号
);
//----------------------信号定义-----------------------//	 

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
//----------------------模块定义-----------------------//
//--------------接收控保A/B系统模块-------------------// 
Man_rxP2_KB Man_RxP2_CPA (
    .clk(i_clk), 
    .reset_n(i_reset_n), 
    .rx_d(i_OptoPhase_sysA), 
    .ControlWord(o_CtrlWord_A),//控保A下发命令字 
    .TargetVol(TargetVol_CPA),//接收A系统的调制电压 
	 .CosThet(CosThet_CPA),//接收A系统的余弦值
    .backup1(backup1_CPA), 
	 .backup2(backup2_CPA),
    .RenewalCnt(o_RenewCntCP_A),//控保A系统更新计数器 
    .ComSta(o_ComStaCP_sysA),//通讯状态 
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
//--------------发送给控保A/B系统模块-------------------// 
Man_TxKB Man_TxP1_CPA (
    .i_sys_clk(i_clk), 
    .clk_20MHz(i_clk_20M), 
    .reset_n(i_reset_n), 
    .FS_sys(i_start_txCP), 
    .dsptoKB0(PhaseStaCPA), //相状态字
    .dsptoKB1(i_Phase_Udc), //相平均直流电压
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
//---------------------判快速光纤断线、频率信号识别和频率不对信号------------------------
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
//------------主从切换处理模块------------------------//
KB_switch CP_switch(
    .clk_20M(i_clk_20M),
	 .i_clk_100K(i_clk_100K),
	 .reset_n(i_reset_n),
	 .rd_intA(rd_intA),//接收帧数据完成标志
	 .rd_intB(rd_intB),//接收帧数据完成标志
	 .i_WD_DSP_ERR(i_WD_DSP_ERR),//DSP喂狗故障信号
	 .i_XINT_DSP_ERR(i_XINT_DSP_ERR),//DSP中断执行故障（地址操作）
	 .i_sumerr_DSP(i_sumerr_DSP),//FPGA接收阀控DSP校验错误位
	 .i_PhaseStaDSP(i_PhaseStaDSP),//相状态字
	 
	 .i_CtrlWord_A(o_CtrlWord_A),//控保A下发命令字
	 .i_CtrlWord_B(o_CtrlWord_B),//控保B下发命令字	
    .i_TargetVol_CPA(TargetVol_CPA),//接收A系统的调制电压
    .i_TargetVol_CPB(TargetVol_CPB),//接收B系统的调制电压	 
	 .i_CosThet_CPA(CosThet_CPA),//接收A系统的余弦值
	 .i_CosThet_CPB(CosThet_CPB),//接收B系统的余弦值
	 
	 .i_fastlock1(o_fastlock1),//A系统下发快速封锁
	 .i_fastlock2(o_fastlock2),//B系统下发快速封锁
	 .o_fastlock_final(o_fastlock_final),//主从判断后最终发出的快速封锁
	 
	 .o_ControlWord(o_ControlWord),//主从判断后最终的控制命令字
	 .o_TargetVol(o_TargetVol),//主从判断后最终的调制电压
	 .o_CosThet(o_CosThet),//主从判断后最终的余弦值
	 .o_CP_MasSla_Sta(o_CP_MasSla_Sta),//控保主从状态字	
    .o_PhaseStaCPA(PhaseStaCPA),//相状态字
    .o_PhaseStaCPB(PhaseStaCPB),//相状态字	 
	 .o_rdint_CP(o_rdint_CP)//外部同步参考信号
//	 .system(system),
//	 .system_state(system_state)
    );
//---------------------测试帧同步周期最大值和最小值的程序
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
