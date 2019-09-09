`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:35:25 02/25/2019 
// Design Name: 
// Module Name:    Reset_watchdog 
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
module Reset_watchdog(
              input i_clk,
              input i_clk_wdi,
				  input clk_100M,
              input i_DcmLock,
				  input i_WDI_dsp,
				  input i_XZCS6,
				  input i_XWE,
				  input i_XRD,
				  input [15:0]i_DSP_A,
				  output o_reset_n1,//主复位信号
				  output o_reset_n2,//复位信号-单元接收模块
				  output o_reset_n3,//复位信号-单元发送模块
				  output o_reset_n4,//复位信号-PWM模块
				  output o_WD_RST,//fpga复位dsp信号
				  output o_DSP_ERR_RST,//DSP中断故障复位信号
				  output o_XRST_F,//光头复位信号
				  output o_WDI,//FPGA给看门狗芯片喂狗信号
				  output o_WD_DSP_ERR,//DSP喂狗故障信号
				  output o_XINT_DSP_ERR//DSP中断执行故障（地址操作）
 );
                      
wire reset1;
wire clk_20M =i_clk;
wire Rst_in =i_DcmLock;
assign o_reset_n1 =reset1;
assign o_reset_n2 =reset1;
assign o_reset_n3 =reset1;
assign o_reset_n4 =reset1;

assign o_WDI =i_clk_wdi; 
assign o_XRST_F = i_DcmLock;

Sys_Rst Sys_Rst1  (
						 .clk_in  (clk_20M	),
						 .rst_in  (Rst_in    ),
						 .reset   (reset1   	)					
					   );
//Sys_Rst Sys_Rst2  (
//						 .clk_in  (clk_20M	),
//						 .rst_in  (Rst_in    ),
//						 .reset   (reset2   	)					
//					   );
//Sys_Rst Sys_Rst3  (
//						 .clk_in  (clk_20M	),
//						 .rst_in  (Rst_in    ),
//						 .reset   (reset3   	)					
//					   );
//Sys_Rst Sys_Rst4  (
//						 .clk_in  (clk_20M	),
//						 .rst_in  (Rst_in    ),
//						 .reset   (reset4   	)					
//					   );
  
//-----------------DSP看门狗监测---------------------//
DspReset dspreset(reset1,clk_20M,i_WDI_dsp,o_WD_RST,o_WD_DSP_ERR);

//-----------------DSP外部中断监测---------------------//
XintDSP_Check  XintDSP_Check(
                   .clk_20M(clk_20M),
						 .clk_100M(clk_100M),
						 .reset_n(reset1),
						 .XZCS6(i_XZCS6),
						 .XWE(i_XWE),
						 .DSP_A(i_DSP_A),
						 .i_WD_DSP_ERR(o_WD_DSP_ERR),//看门狗故障时屏蔽XINT故障
						 .DSP_ERR_RST(o_DSP_ERR_RST),
						 .XINT_DSP_ERR(o_XINT_DSP_ERR)
                  );
//--------------------------------------------------------
//wire [35:0]ILAControl;
//wire [79:0]data_chipscp; 
//assign data_chipscp[15:0] = {4'd0,i_WDI_dsp,i_clk_wdi,o_XINT_DSP_ERR,o_WD_DSP_ERR,o_WDI,o_XRST_F,o_DSP_ERR_RST,o_WD_RST,o_reset_n4,o_reset_n3,o_reset_n2,o_reset_n1};
////assign data_chipscp [31:16] = ram_addr;
////assign data_chipscp [47:32] =ram_dout;
////assign data_chipscp [63:48] =dsp_addr;
////assign data_chipscp [79:64] =dsp_dout;
//
//new_icon svg_icon ( 
//     .CONTROL0            ( ILAControl) 
//); 
//
//new_ila svg_ila ( 
//     .CONTROL            ( ILAControl), 
//     .CLK                ( clk_20M), 
//     .DATA               ( data_chipscp), 
//     .TRIG0              ( i_DcmLock ), 
//	  .TRIG1              ( o_WD_DSP_ERR),
//	  .TRIG2              ( i_WDI_dsp ),
//	  .TRIG3              ( )
//);
endmodule
