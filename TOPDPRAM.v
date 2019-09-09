`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:28:06 04/09/2013 
// Design Name: 
// Module Name:    DPRAM 
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
module TOPDPRAM( 
                        input  i_clk, 
					 			input  i_reset_n,
								input	 i_xint_st,
								input[15:0] i_DSP_A,
								input[15:0] io_DSP_D,
								input  i_XZCS6,
								input  i_XWE,
								input  i_XRD,
								input[15:0] i_CtrlWord_A,
								input[15:0] i_CtrlWord_B,			
								input[15:0] i_RenewCntCP_A,	
								input[15:0] i_RenewCntCP_B,								 
								input[15:0] i_ComStaCP_A,
								input[15:0] i_ComStaCP_B,
								input[15:0] i_CP_MasSla_Sta,			

								input[15:0] i_Mod_ComSta1,
								input[15:0] i_Mod_ComSta2,
							   input[15:0] i_Mod_ComSta3,
								input[15:0] i_Mod_ComSta4,
								input[15:0] i_Mod_ComSta5,
								input[15:0] i_Mod_ComSta6,
								input[15:0] i_Mod_ComSta7,
								input[15:0] i_Mod_ComSta8,
								input[15:0] i_Mod_ComSta9,
								input[15:0] i_Mod_ComSta10,
								input[15:0] i_Mod_ComSta11,
								input[15:0] i_Mod_ComSta12,	
										
								input[383:0] i_LinkUdcA_BUS,
								input[383:0] i_LinkUdcB_BUS,				
								input[383:0] i_LinkUdcC_BUS,				
      						
								input[767:0] i_LinkStaA_BUS,	
								input[767:0] i_LinkStaB_BUS,		
								input[767:0] i_LinkStaC_BUS,
												 
								input[15:0] i_PhaseA_Udc,	
								input[15:0] i_PhaseB_Udc,
								input[15:0] i_PhaseC_Udc,									 
										
								output[15:0] o_PhaseStaDSP,		
								output[15:0] o_LinkNum_Total,		
								output[15:0] o_SwitchFreq,		
								output[15:0] o_Kp_Udc,		
								output[15:0] o_Udc_limit,
								output[15:0] o_Redun_pos1,
								output[15:0] o_Redun_pos2,
								output[15:0] o_Redun_pos3,
								output[15:0] o_Redun_pos4,
								output[15:0] o_Redun_pos5,
								output[15:0] o_Redun_pos6,
								output[15:0] o_VCU_Mode,//阀控机箱类型 3相合一/单相
								output[15:0] o_para_grp_TFR,//录波组参数	
								output o_XINT1,
								output o_sumerr_DSP
);
																
DPRAM1  DPRAM1 (
						.clk_100M(i_clk),				.reset_n(i_reset_n),
						.start_DPRAM(i_xint_st),			.DSP_A(i_DSP_A),
						.DSP_D(io_DSP_D),					.XZCS6(i_XZCS6),
						.XWE(i_XWE),						.XRD(i_XRD),
						
						.i_CtrlWord_A(i_CtrlWord_A),			.i_CtrlWord_B(i_CtrlWord_B),
						.i_RenewCntCP_A(i_RenewCntCP_A),		.i_RenewCntCP_B(i_RenewCntCP_B),
						.i_ComStaCP_A(i_ComStaCP_A),			.i_ComStaCP_B(i_ComStaCP_B),
						.i_CP_MasSla_Sta(i_CP_MasSla_Sta),	
    		
						.CommStateA1_1(i_Mod_ComSta1),		.CommStateA1_2(i_Mod_ComSta2),
						.CommStateA2_1(i_Mod_ComSta3),		.CommStateA2_2(i_Mod_ComSta4),
						.CommStateB1_1(i_Mod_ComSta5),		.CommStateB1_2(i_Mod_ComSta6),
						.CommStateB2_1(i_Mod_ComSta7),		.CommStateB2_2(i_Mod_ComSta8),
						.CommStateC1_1(i_Mod_ComSta9),		.CommStateC1_2(i_Mod_ComSta10),
						.CommStateC2_1(i_Mod_ComSta11),		.CommStateC2_2(i_Mod_ComSta12),		

						.LinkUdcA_BUS(i_LinkUdcA_BUS),		.LinkUdcB_BUS(i_LinkUdcB_BUS),			.LinkUdcC_BUS(i_LinkUdcC_BUS),				
						.LinkStaA_BUS(i_LinkStaA_BUS),		.LinkStaB_BUS(i_LinkStaB_BUS),			.LinkStaC_BUS(i_LinkStaC_BUS),
						.Phase_udcA(i_PhaseA_Udc),			   .Phase_udcB(i_PhaseB_Udc),			      .Phase_udcC(i_PhaseC_Udc),
				
						.Phase_sta(o_PhaseStaDSP),				.LinkNum_Total(o_LinkNum_Total),
						.F_switch(o_SwitchFreq),				.Kp_Udc(o_Kp_Udc),
						.UdcThirdCtrlLim(o_Udc_limit),		.o_Redun_pos1(o_Redun_pos1),
						.o_Redun_pos2(o_Redun_pos2),			.o_Redun_pos3(o_Redun_pos3),
						.o_Redun_pos4(o_Redun_pos4),			.o_Redun_pos5(o_Redun_pos5),
						.o_Redun_pos6(o_Redun_pos6),			.o_VCU_Mode(o_VCU_Mode),
						.o_para_grp_TFR(o_para_grp_TFR),		.XINT1(o_XINT1),
						.sumerrKB(o_sumerr_DSP)				
//			????????			.Backup1(Backup1),
//						.Backup2(Backup2),						.Kb_RenewalCnt(Kb_RenewalCnt)	
);
				  
////chipscope 
//wire [35:0] ILAControl;
//wire [79:0] data_chipscp; 
//assign data_chipscp [15:0] = {15'd0,o_XINT1};
//assign data_chipscp [31:16] = DSP_A;
//assign data_chipscp [47:32] =DSP_D;
////assign data_chipscp [63:48] = ;
////assign data_chipscp [79:64] = {11'b0,M48_R,M47_R,M30_R,M29_R,M28_R};
//////assign data_chipscp [48] = {9'b0,fast_brk,lock3_brk,lock2_brk,FastLock_in,OPTO_IN4,OPTO_IN3,~M22_R};
//
//
//ICON_GL SVG_icon ( 
//     .CONTROL0            ( ILAControl) 
//); 
//
//ILA_GL SVG_ila ( 
//     .CONTROL            ( ILAControl), 
//     .CLK                ( clk_100M), 
//     .DATA               ( data_chipscp), 
//     .TRIG0              ( start_DPRAM), 
//	  .TRIG1              (  ),
//	  .TRIG2              (  ),
//	  .TRIG3              ( )
//);

endmodule
