`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:14:20 09/21/2017 
// Design Name: 
// Module Name:    KB_TxRx 
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
////////////////////////////////////////////////////////////////////////////////////
module KB_TxRx(clk_100M,clk_20M,reset_n,XZCS6,XWE,XRD,DSP_A,Tx_fs,WD_DSP_ERR,
		 Man_txA,Man_txB,
		 Man_rxA,Man_rxB,
		 
		 Phase_Stat,PhaseA_Udc,PhaseB_Udc,PhaseC_Udc,	
		 Backup1,Backup2,Kb_RenewalCnt,	 		 		 
		 ControlWord,TargetVolA,TargetVolB,TargetVolC,CosTheta,CosThetb,CosThetc,RenewalCntRC,CommStateRC,
		 rdint_CP,DSP_ERR_RST,sumerrKB
    );
input clk_100M,clk_20M,reset_n,XZCS6,XWE,XRD,WD_DSP_ERR;
input Man_rxA,Man_rxB;

input [15:0] DSP_A;
input Tx_fs;//Tx_fs为DSP写完双口ram后使能信号，发送使能
input [15:0] PhaseA_Udc,PhaseB_Udc,PhaseC_Udc;
input [15:0] Phase_Stat,Backup1,Backup2,Kb_RenewalCnt;
output Man_txA,Man_txB,rdint_CP;
output [15:0] ControlWord,TargetVolA,TargetVolB,TargetVolC,CosTheta,CosThetb,CosThetc,RenewalCntRC,CommStateRC;
output DSP_ERR_RST;
input  sumerrKB;

wire rd_intA,rd_intB;
wire [15:0] TargetVolAa,TargetVolBa,TargetVolCa;
wire [15:0] TargetVolAb,TargetVolBb,TargetVolCb;
wire [15:0] CosThetAa,CosThetBa,CosThetCa;
wire [15:0] CosThetAb,CosThetBb,CosThetCb;
wire [15:0] ControlWorda,ControlWordb;
wire [15:0] MSstatea,MSstateb;
wire [15:0] ComStaA,ComStaB;
wire [15:0] phase_staA,phase_staB;//发给A、B系统的相状态字
//需要根据主从切换修改


//=================================================

Man_rxP2_KB Man_RxP2_KBa (
    .clk(clk_100M), 
    .reset_n(reset_n), 
    .rx_d(Man_rxA), 
    .ControlWord(ControlWorda), 
    .TargetVolA(TargetVolAa), 
    .TargetVolB(TargetVolBa), 
    .TargetVolC(TargetVolCa), 
	 .CosTheta(CosThetAa),
    .CosThetb(CosThetBa),
	 .CosThetc(CosThetCa),
    .MSstate(MSstatea), 
    .backup(backupa), 
    .RenewalCnt(RenewalCntA), 
    .ComSta(ComStaA), 
    .rd_int(rd_intA)
    );
//===================================================	 
//Man_rxP2_KB Man_RxP2_KBb (
//    .clk(clk_100M), 
//    .reset_n(reset_n), 
//    .rx_d(Man_rxB), 
//    .ControlWord(ControlWordb), 
//    .TargetVolA(TargetVolAb), 
//    .TargetVolB(TargetVolBb), 
//    .TargetVolC(TargetVolCb), 
//	 .CosTheta(CosThetAb),
//    .CosThetb(CosThetBb),
//	 .CosThetc(CosThetCb),
//    .MSstate(MSstateb), 
//    .backup(backupb), 
//    .RenewalCnt(RenewalCntB), 
//    .ComSta(ComStaB), 
//    .rd_int(rd_intB)
//    );
//===================================================	 

//===================================================	 
Man_txP1_KB Man_TxP1_KBa (
    .i_sys_clk(clk_100M), 
    .clk_20MHz(clk_20M), 
    .reset_n(reset_n), 
    .FS_sys(Tx_fs), 
    .dsptoKB0(phase_staA), //
    .dsptoKB1(PhaseA_Udc), //
    .dsptoKB2(PhaseB_Udc), //
    .dsptoKB3(PhaseC_Udc), //
    .dsptoKB4(Backup1), //
    .dsptoKB5(Backup2),//
    .dsptoKB6(Kb_RenewalCnt), 
    .dsptoKB7(),   	 
    .man_tx(Man_txA) 
    );

//===================================================	
 Man_txP1_KB Man_TxP1_KBb (
    .i_sys_clk(clk_100M), 
    .clk_20MHz(clk_20M), 
    .reset_n(reset_n), 
    .FS_sys(Tx_fs), 
    .dsptoKB0(phase_staB), 
    .dsptoKB1(PhaseA_Udc), 
    .dsptoKB2(PhaseB_Udc), 
    .dsptoKB3(PhaseC_Udc), 
    .dsptoKB4(Backup1), 
    .dsptoKB5(Backup2), 
    .dsptoKB6(Kb_RenewalCnt), 
    .dsptoKB7(),  
    .man_tx(Man_txB) 
    );
//===================================================	 
KB_switch KB_switch(clk_100M,clk_20M,reset_n,WD_DSP_ERR,
			ComStaA,rd_intA,ControlWorda,TargetVolAa,TargetVolBa,TargetVolCa,CosThetAa,CosThetBa,CosThetCa,RenewalCntA,
			ComStaB,rd_intB,ControlWordb,TargetVolAb,TargetVolBb,TargetVolCb,CosThetAb,CosThetBb,CosThetCb,RenewalCntB,
			DSP_A,XZCS6,XWE,
			Phase_Stat,phase_staA,phase_staB,
			ControlWord,TargetVolA,TargetVolB,TargetVolC,CosTheta,CosThetb,CosThetc,RenewalCntRC,CommStateRC,
			rdint_CP,DSP_ERR_RST,sumerrKB
			);	
			
endmodule
