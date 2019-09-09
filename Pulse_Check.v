`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:23:20 09/22/2017 
// Design Name: 
// Module Name:    Pulse_Check 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
// 检测方波输入周期模块，
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Pulse_Check(
			input clk_100M,
		   input clk_20M,//20M  
			input reset_n,
			input rxd,
			inout [35:0]ILAControl,
			
			output reg sys_Stat,//检测为1M脉冲时输出1
			output reg Pulse_err//检测不到1M和10k脉冲，输出脉冲错误标志
    );

parameter PULSENUM = 2;//实际计算的脉冲周期数为PULSENUM；判断周期数不能小于1个
//此两个参数为1M脉冲信号对应clk_20M时钟个数，1m脉冲对应20个clk_20M时钟，在此取±5%范围
parameter PLLSE1MNUM_L = PULSENUM*19;
parameter PLLSE1MNUM_H = PULSENUM*21;
//此两个参数为10K脉冲信号对应clk_20M时钟个数，10K脉冲对应2000个clk_20M时钟，在此取±5%范围
parameter PLLSE10KNUM_L =PULSENUM*1900;
parameter PLLSE10KNUM_H =PULSENUM*2100;

reg [1:0] rxd_reg;
reg [7:0] cnt1;
reg [17:0] cnt2;

//******************消除抖动和滤波**************//
reg[2:0]Samp_reg;
reg rxd_temp;
reg data_reg;

wire rxd_low   = (Samp_reg[1:0] == 2'b00);
wire rxd_high  = (Samp_reg[1:0] == 2'b11);
always @ (negedge reset_n or posedge clk_100M)
begin
	if(!reset_n) begin
		rxd_temp <= 1'b1;	
		Samp_reg <= 3'b111;
		data_reg <= 1'b1;	
	end
	else begin
		Samp_reg <= {Samp_reg[1:0],rxd};
		if(rxd_low) rxd_temp <= 1'b0;	
		else if(rxd_high)  rxd_temp <= 1'b1;
		else rxd_temp <= rxd_temp;
		data_reg <= rxd_temp;
	end
end
//***********************************************//
always @ (posedge clk_20M)
begin
	if(!reset_n) rxd_reg<=2'b00;
	else rxd_reg<={rxd_reg[0],data_reg};
end

always @ (posedge clk_20M)
begin
	if(!reset_n) begin
		cnt1<=8'd0;
	end
	else if(rxd_reg == 2'b01) begin
		if(cnt1<=PULSENUM)cnt1 <= cnt1+1;
		else cnt1<=8'd0;
	end
	else cnt1<=cnt1;	
end
reg [17:0]cnt3;
always @ (posedge clk_20M)
begin
	if(!reset_n) begin
		cnt2<=18'd0;
		cnt3<=18'd0;
	end
	else if(cnt1==8'd0)begin cnt2<=18'd0;
									 cnt3<=cnt3+18'd1;
								end
	else if((cnt1!=8'd0)&(cnt1<=PULSENUM))begin cnt2 <= cnt2+1;
															  cnt3 <= 18'd0;
														end
	else if(cnt1==(PULSENUM+1)) cnt2 <= cnt2;
	else if(cnt2==18'h3ffff) cnt2 <= cnt2;
	else cnt2<=18'd0;	
end

always @ (posedge clk_20M)
begin
	if(!reset_n) begin
		sys_Stat<=1'b0;
		Pulse_err<=1'b0;
	end
	else if(cnt1==(PULSENUM+1)) begin
		if((cnt2>=PLLSE1MNUM_L)&(cnt2<=PLLSE1MNUM_H)) begin
			sys_Stat<=1'b1;
			Pulse_err<=1'b0;
		end
		else if((cnt2>=PLLSE10KNUM_L)&(cnt2<=PLLSE10KNUM_H)) begin
			sys_Stat<=1'b0;
			Pulse_err<=1'b0;
		end
		else begin
			sys_Stat<=1'b0;
			Pulse_err<=1'b1;
		end
	end
	else if((cnt2==18'h3ffff)|(cnt3==18'h3ffff))begin
		sys_Stat<=1'b0;
		Pulse_err<=1'b1;
	end
	
	else begin
		sys_Stat<=sys_Stat;
		Pulse_err<=Pulse_err;
	end
end
//chipscope
//wire [79:0]data_chipscp;
//assign trig0 = Pulse_err;
//assign trig1 = sys_Stat;
//assign trig2 = (cnt2==18'h3fff0)? 1'b1:1'b0;
//assign trig3 = (cnt2==18'h3ffff)? 1'b1:1'b0;
//
//assign data_chipscp [15:0] = cnt1;
////assign data_chipscp [31:16] = dataRx_KB;
////assign data_chipscp [47:32] = crc_buf;
//
//assign data_chipscp [48] =Pulse_err;
////assign data_chipscp [53:49] =addrRx_KB;
////assign data_chipscp [58:54] =ComSta[4:0];
//assign data_chipscp [59] = rxd;
//assign data_chipscp [60] = sys_Stat;
////assign data_chipscp [63:48] = {ram_w_reg,dsp_w,XINT1,FPGA_rd_done,dsp_addr,XZCS6,XWE};
//assign data_chipscp [79:62] = cnt2;
//////assign data_chipscp [48] = {9'b0,fast_brk,lock3_brk,lock2_brk,FastLock_in,OPTO_IN4,OPTO_IN3,~M22_R};
//
//
//
//ila SVG_ila ( 
//     .CONTROL            ( ILAControl), 
//     .CLK                ( clk_20M), 
//     .DATA               ( data_chipscp), 
//     .TRIG0              ( trig0), 
//	  .TRIG1              ( trig1),
//     .TRIG2              ( trig2), 
//	  .TRIG3              ( trig3)
//);

endmodule
