`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:55:18 02/18/2019 
// Design Name: 
// Module Name:    Int_Ena_ctrl 
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
module Int_Ena_ctrl(
    input i_clk,
    input i_reset_n,
	 input i_syn_ref,//主控每78.12us一个周期同步信号 
	 output reg o_xint_st,
	 output reg o_PWM_calc_st,
	 output reg o_Module_tx_st,
	 output reg o_CP_tx_st,
	 output reg o_Mcbsp_tx_st,
	 output reg o_rxstaram
    );
 
parameter syn_period = 7812; //每78.12us产生一个同步 
parameter double_period = 15624;
parameter DELAY_PWM = 1850;//接收到帧头后18.5us产生o_PWM_calc_st使能信号
parameter DELAY_DPRAM =4550;//45.5us启动写DPRAM使能
parameter DELAY_UNIT = 15599;//156us周期产生o_Module_tx_st使能信号
parameter DELAY_TXCP = 100;//1us启动发送装置级数据使能,周期78us
parameter DELAY_Mcbsp = 5000;//50us启动mcbsp使能
parameter PULSE = 50;
parameter DELAY_RXSTARAM = 4000;//子单元状态字搬RAM的使能

reg [15:0] cnt_pwm;
reg [15:0] cnt_dpram;
reg [15:0] cnt_unit;
reg [15:0] cnt_txCP;
reg [15:0] cnt_mcbsp;
reg start_syn;
reg Doubstart_syn;	 
	 
reg[2:0] i_fs_reg,double_cnt;
reg fs_in,fs_s,prod_fs;
reg[1:0] fs_in_reg,fs_s_reg,start_syn_reg,Doubstart_syn_reg;
reg[13:0] fs_in_cnt,fs_s_cnt,start_syn_cnt;

//****产生start_syn和Doubstart_syn，当主控i_syn_ref信号丢失后仍能继续按照78/156us继续工作****//
always @ (posedge i_clk)
begin
	if(!i_reset_n)begin
		i_fs_reg<=3'b000;
		fs_in<=1'b0;
		fs_in_reg<=2'b00;
		fs_in_cnt<=14'd0;
		fs_s<=1'b1;
		fs_s_reg<=2'b00;
		fs_s_cnt<=14'd0;
		start_syn<=1'b0;
	end
	else begin
		i_fs_reg<={i_fs_reg[1:0],i_syn_ref};	//检测i_syn_ref完全是高电平时，去掉干扰；
		if(i_fs_reg==3'b000) fs_in<=1'b0;
		else if(i_fs_reg==3'b111) fs_in<=1'b1;//得到fs_in信号 周期和i_syn_ref是同一个周期
		else fs_in<=fs_in;	
		
		fs_in_reg<={fs_in_reg[0],fs_in};  //拍两拍  检测上升沿
		if(fs_in_reg==2'b01) fs_in_cnt<=14'd781;   //只要上升沿到了，计数器赋值为1562，如果阀控CPU板自己复位了，则
		else if(fs_in_cnt==syn_period)fs_in_cnt<=14'd0;//
		else fs_in_cnt<=fs_in_cnt+1;	
		
		if(fs_in_cnt==14'd0) fs_s<=1'b0;
		else if(fs_in_cnt==14'd1512) fs_s<=1'b1;//计数不考虑 得出新的fs_s信号 上升沿和fs_in 
		else fs_s<=fs_s;
		fs_s_reg<={fs_s_reg[0],fs_s};  //fs_s拍两拍  得出fs_s_reg
		
		if(fs_s_reg==2'b10) fs_s_cnt<=14'd0; //下降沿时fs_s_cnt复位
		else if(fs_s_cnt==syn_period)fs_s_cnt<=syn_period;//计数到7812时 保持不变 直到清零
		else fs_s_cnt<=fs_s_cnt+1;

		if(fs_s_cnt==14'd781) start_syn<=1'b1;     //  对齐
		else if(fs_s_cnt==14'd791) start_syn<=1'b0;//  对齐
		else start_syn<=start_syn;
	end
end

always @ (posedge i_clk) 
begin
	if(!i_reset_n)begin
		start_syn_reg<=2'b00;
		double_cnt<=2'd0;
		start_syn_cnt<=14'd0;
		Doubstart_syn <= 1'b0;
    end
	 else begin
		start_syn_reg<={start_syn_reg[0],start_syn};
		if(double_cnt==3'd2)double_cnt<=3'd0;
		else if(start_syn_reg==2'b01) double_cnt<=double_cnt+1;
		else double_cnt<=double_cnt;

		if(double_cnt==3'd2) start_syn_cnt<=14'd0;
		else if(start_syn_cnt==double_period) start_syn_cnt<=start_syn_cnt;
		else start_syn_cnt<=start_syn_cnt+1;

		if(double_cnt==3'd2) Doubstart_syn<=1'b1;
		else if(start_syn_cnt==PULSE) Doubstart_syn<=1'b0;
		else Doubstart_syn<=Doubstart_syn;
	end
end

always @ (posedge i_clk) 
begin
	if(!i_reset_n)begin
		Doubstart_syn_reg<=2'b00;
    end
	 else begin
		Doubstart_syn_reg<={Doubstart_syn_reg[0],Doubstart_syn};
	end
end

//****************************78.12us产生o_PWM_calc_st****************************//
always @ (posedge i_clk)
begin
     if(!i_reset_n)begin
		  cnt_pwm   <= 16'd0;
		  o_PWM_calc_st <= 1'b0;
	  end
	  else if(start_syn_reg==2'b01)begin
	     cnt_pwm   <= 16'd0;
		  o_PWM_calc_st <= 1'b0;
	  end
	  else if(cnt_pwm  == (DELAY_PWM + PULSE))begin
		  cnt_pwm   <= cnt_pwm;
		  o_PWM_calc_st <= 1'b0;
	  end
	  else if(cnt_pwm >= DELAY_PWM)begin
		  cnt_pwm   <= cnt_pwm + 16'd1;
		  o_PWM_calc_st <= 1'b1;
	  end
	  else begin
		  cnt_pwm   <= cnt_pwm + 16'd1;
		  o_PWM_calc_st <= 1'b0;
	  end
end 
//****************************产生o_Module_tx_st****************************//
always @ (posedge i_clk)
begin
     if(!i_reset_n)begin
		  cnt_unit   <= 16'd0;
		  o_Module_tx_st <= 1'b0;
	  end
	  else if(cnt_unit  == DELAY_UNIT)begin 
		  cnt_unit <= 16'd0;
		  o_Module_tx_st <= 1'b1;
	  end
	  else if(cnt_unit == PULSE)begin
		  cnt_unit   <= cnt_unit + 16'd1;
		  o_Module_tx_st <= 1'b0;
	  end
	  else begin
		  cnt_unit   <= cnt_unit + 16'd1;
		  o_Module_tx_st <= o_Module_tx_st;
	  end
end 
//****************************产生o_xint_st****************************//
always @ (posedge i_clk)
begin
     if(!i_reset_n)begin
		  cnt_dpram   <= 16'd0;
		  o_xint_st <= 1'b0;
	  end
	  else if(Doubstart_syn_reg==2'b01)begin
	     cnt_dpram   <= 16'd0;
		  o_xint_st <= 1'b0;
	  end
	  else if(cnt_dpram  == (DELAY_DPRAM + PULSE))begin 
		  cnt_dpram   <= cnt_dpram;
		  o_xint_st <= 1'b0;
	  end
	  else if(cnt_dpram >= DELAY_DPRAM)begin
		  cnt_dpram   <= cnt_dpram + 16'd1;
		  o_xint_st <= 1'b1;
	  end
	  else begin
		  cnt_dpram   <= cnt_dpram + 16'd1;
		  o_xint_st <= 1'b0;
	  end
end
//****************************产生o_rxstaram****************************//
reg [15:0]cnt_rx;
always @ (posedge i_clk)
begin
     if(!i_reset_n)begin
		  cnt_rx   <= 16'd0;
		  o_rxstaram <= 1'b0;
	  end
	  else if(Doubstart_syn_reg==2'b01)begin
	     cnt_rx   <= 16'd0;
		  o_rxstaram <= 1'b0;
	  end
	  else if(cnt_rx  == (DELAY_RXSTARAM + PULSE))begin 
		  cnt_rx   <= cnt_rx;
		  o_rxstaram <= 1'b0;
	  end
	  else if(cnt_rx >= DELAY_RXSTARAM)begin
		  cnt_rx   <= cnt_rx + 16'd1;
		  o_rxstaram <= 1'b1;
	  end
	  else begin
		  cnt_rx   <= cnt_rx + 16'd1;
		  o_rxstaram <= 1'b0;
	  end
end 
//****************************产生o_CP_tx_st****************************//
always @ (posedge i_clk)
begin
     if(!i_reset_n)begin
		  cnt_txCP   <= 16'd0;
		  o_CP_tx_st <= 1'b0;
	  end
	  else if(start_syn_reg==2'b01)begin
	     cnt_txCP   <= 16'd0;
		  o_CP_tx_st <= 1'b0;
	  end
	  else if(cnt_txCP  == (DELAY_TXCP + PULSE))begin
		  cnt_txCP   <= cnt_txCP;
		  o_CP_tx_st <= 1'b0;
	  end
	  else if(cnt_txCP >= DELAY_TXCP)begin
		  cnt_txCP   <= cnt_txCP + 16'd1;
		  o_CP_tx_st <= 1'b1;
	  end
	  else begin
		  cnt_txCP   <= cnt_txCP + 16'd1;
		  o_CP_tx_st <= 1'b0;
	  end
end  
//****************************产生o_Mcbsp_tx_st****************************//
always @ (posedge i_clk)
begin
     if(!i_reset_n)begin
		  cnt_mcbsp   <= 16'd0;
		  o_Mcbsp_tx_st <= 1'b0;
	  end
	  else if(Doubstart_syn_reg==2'b01)begin
	     cnt_mcbsp   <= 16'd0;
		  o_Mcbsp_tx_st <= 1'b0;
	  end
	  else if(cnt_mcbsp  == (DELAY_Mcbsp + PULSE))begin
		  cnt_mcbsp   <= cnt_mcbsp;
		  o_Mcbsp_tx_st <= 1'b0;
	  end
	  else if(cnt_mcbsp >= DELAY_Mcbsp)begin
		  cnt_mcbsp   <= cnt_mcbsp + 16'd1;
		  o_Mcbsp_tx_st <= 1'b1;
	  end
	  else begin
		  cnt_mcbsp   <= cnt_mcbsp + 16'd1;
		  o_Mcbsp_tx_st <= 1'b0;
	  end
end 


//////-----------------------------------Test---------------------------------//
////chipscope 
//wire [35:0] ILAControl;
//wire [79:0] data_chipscp; 
//assign data_chipscp [0] = {i_syn_ref};
//assign data_chipscp [1] = {fs_in};
//assign data_chipscp [2] = {fs_s};
//assign data_chipscp [3] = {start_syn};
//assign data_chipscp [6:4] = {double_cnt};
//assign data_chipscp [7] = {Doubstart_syn};
//assign data_chipscp [8] = {o_PWM_calc_st};
//assign data_chipscp [9] = {o_Module_tx_st};
//assign data_chipscp [10] = {o_xint_st};
//assign data_chipscp [11] = {o_CP_tx_st};
//assign data_chipscp [12] = {o_Mcbsp_tx_st};
//assign data_chipscp [13] = {o_rxstaram};
////assign data_chipscp [47:32] = {M48_T,M47_T,M46_T,M45_T,M44_T,M43_T,M42_T,M41_T,M40_T,M39_T,M38_T,M37_T,M36_T,M35_T,M34_T,M33_T};
////assign data_chipscp [63:48] = {M64_T,M63_T,M62_T,M61_T,M60_T,M59_T,M58_T,M57_T,M56_T,M55_T,M54_T,M53_T,M52_T,M51_T,M50_T,M49_T};
////assign data_chipscp [79:64] = {8'b0,M72_T,M71_T,M70_T,M69_T,M68_T,M67_T,M66_T,M65_T};
//
//
//new_icon SVG_icon ( 
//     .CONTROL0            ( ILAControl) 
//); 
//
//new_ila SVG_ila ( 
//     .CONTROL            ( ILAControl), 
//     .CLK                ( i_clk), 
//     .DATA               ( data_chipscp), 
//     .TRIG0              (i_syn_ref ) ,
//	    .TRIG1              ( ),
//     .TRIG2              ( ), 
//	    .TRIG3              ( )
//);


endmodule
