`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: CEPRI
// Engineer:Zhang Dian-qing
// 
// Create Date:    22:07:10 03/13/2019 
// Design Name: 
// Module Name:    CP_switch 
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
module KB_switch(    
					 input clk_20M,
					 input i_clk_100K,
					 input reset_n,
					 input rd_intA,//接收帧数据完成标志
					 input rd_intB,//接收帧数据完成标志
					 input i_WD_DSP_ERR,//DSP喂狗故障信号
					 input i_XINT_DSP_ERR,//DSP中断执行故障（地址操作）
					 input i_sumerr_DSP,//FPGA接收阀控DSP校验错误位
					 input [15:0]i_PhaseStaDSP,//DSP传给FPGA相状态字
					 
					 input [15:0]i_CtrlWord_A,//控保A下发命令字
					 input [15:0]i_CtrlWord_B,//控保B下发命令字	
					 input [31:0]i_TargetVol_CPA,//接收A系统的调制电压
					 input [31:0]i_TargetVol_CPB,//接收B系统的调制电压	 
					 input [15:0]i_CosThet_CPA,//接收A系统的余弦值
					 input [15:0]i_CosThet_CPB,//接收B系统的余弦值
					 
					 input i_fastlock1,//A系统下发快速封锁
					 input i_fastlock2,//B系统下发快速封锁
					 output reg o_fastlock_final,//主从判断后最终发出的快速封锁
					 
					 output reg[15:0]o_ControlWord,//主从判断后最终的控制命令字
					 output reg[31:0]o_TargetVol,//主从判断后最终的调制电压
					 output reg[15:0]o_CosThet,//主从判断后最终的余弦值
					 output [15:0]o_CP_MasSla_Sta,//控保主从状态字
                output [15:0]o_PhaseStaCPA,//相状态字
                output [15:0]o_PhaseStaCPB,//相状态字					 
					 output reg o_rdint_CP//外部同步参考信号
//					 output system,
//					 output [1:0]system_state
					 );
//**********************接收DSP发送控保数据校验和出错，连续6个点，置位相总故障，连续20ms正确，就置0相总故障****//
parameter CHECK_ERR_CNT = 18750;//6个点 156.25us*6
parameter CHECK_RETURN_CNT = 400000;//20ms
reg [15:0]DSP_check_err_cnt;//错误计数器
reg [19:0]DSP_check_right_cnt;//正确计数器
reg check_err;//FPGA接收DSP发送控保数据校验和出错
//信号定义
reg [1:0]system_state,system_state_old;//判断装置级A/B系统主从参数，整理成2bit 
reg system_A_state,system_B_state;
reg start1,start2;//阀控收到装置级A/B系统数据完毕标志拍一个时钟的信号
reg [1:0]comm_state; 
reg system,system_reg;
reg switchBtoA,switchAtoB;
reg sys_Stat_A_final,sys_Stat_B_final;
//----------主从切换使能消抖寄存器----------
reg state_MS_A,state_MS_B;
reg [15:0]state_MS_A_reg,state_MS_B_reg;
//-------------------------给控保的最终的相状态字-----------------
wire DSP_err_total;//DSP总故障：DSP看门狗故障、DSP外部中断故障、FPGA接收DSP校验故障（判断6个点）
assign DSP_err_total = i_WD_DSP_ERR | i_XINT_DSP_ERR | check_err;
assign o_PhaseStaCPA = {DSP_err_total,sys_Stat_B_final,sys_Stat_A_final,i_PhaseStaDSP[12],i_PhaseStaDSP[11],i_PhaseStaDSP[10:0]};
assign o_PhaseStaCPB = {DSP_err_total,sys_Stat_A_final,sys_Stat_B_final,i_PhaseStaDSP[11],i_PhaseStaDSP[12],i_PhaseStaDSP[10:0]};
assign o_CP_MasSla_Sta = {14'd0,sys_Stat_B_final,sys_Stat_A_final};
//-------------FPGA接收阀控DSP校验错误位持续时间计数------------
always @ (posedge clk_20M)
begin
	if(!reset_n) begin 
		DSP_check_err_cnt <= 16'd0;
		DSP_check_right_cnt <= 20'd0;
		end
	else if(i_sumerr_DSP)begin
		DSP_check_err_cnt <= DSP_check_err_cnt + 16'd1;
		DSP_check_right_cnt <= 20'd0;
		end
	else begin 
	   DSP_check_right_cnt <= DSP_check_right_cnt+20'd1;
		DSP_check_err_cnt<= 16'd0;
		end
end
//-----------FPGA接收阀控DSP校验错误位持续时间超过6个点或20ms--------------
always @ (posedge clk_20M)
begin
	if(!reset_n)begin
		check_err <= 1'b0;
	end
	else if(DSP_check_err_cnt >= CHECK_ERR_CNT)begin
		check_err <= 1'b1;
	end
	else if(DSP_check_right_cnt >= CHECK_RETURN_CNT)begin
		check_err <= 1'b0;
	end
	else check_err <= check_err;
end
//-------------------------主从切换使能需要消抖160us----------------------
always @ (posedge i_clk_100K)
begin
	if(!reset_n) begin
		state_MS_A <= 1'b0;
		state_MS_B <= 1'b0;
		state_MS_A_reg <= 16'b0;
		state_MS_B_reg <= 16'b0;
	end
	else begin
		state_MS_A_reg <= {state_MS_A_reg[14:0],i_CtrlWord_A[8]};
		state_MS_B_reg <= {state_MS_B_reg[14:0],i_CtrlWord_B[8]};
		if (state_MS_A_reg == 16'hffff) state_MS_A <= 1'b1;
		else if (state_MS_A_reg == 16'h0) state_MS_A <= 1'b0;
		else state_MS_A <= state_MS_A;
		if (state_MS_B_reg == 16'hffff) state_MS_B <= 1'b1;
		else if (state_MS_B_reg == 16'h0) state_MS_B <= 1'b0;
		else state_MS_B <= state_MS_B;
	end
end
//-------------根据装置级A/B下发的参数判断主从并拍1时钟----------------------
always @ (posedge clk_20M)
begin
	if(!reset_n) begin
		system_state <= 2'b01;
		system_state_old<= 2'b01;
	end
	else begin
		case ({state_MS_B,state_MS_A})//控保下发命令字中的主从系统
			2'b00 : system_state <= 2'b00;//双从
			2'b10 : system_state <= 2'b10;//B主
			2'b01 : system_state <= 2'b01;//A主
			2'b11 : system_state <= 2'b11;//双主
			default : system_state <= 2'b01;//默认A主
		endcase
		system_state_old <= system_state;
	end
end
//----------接收数据帧结束标志信号拍一个时钟----------------
always @ (posedge clk_20M)
begin
	if(!reset_n) start1 <= 1'b0;
	else start1 <= rd_intA;
end
always @ (posedge clk_20M)
begin
	if(!reset_n) start2 <= 1'b0;
	else start2 <= rd_intB;
end
//******************后主为主***************//
always @ (posedge clk_20M)
begin
	if(!reset_n) begin
		system <= 1'b0; 
		sys_Stat_A_final <= 1'b1;
		sys_Stat_B_final <= 1'b0;
	end
	else if (system_state == 2'b01)begin 
		system <= 1'b0;//0为A主
		sys_Stat_A_final <= 1'b1;
		sys_Stat_B_final <= 1'b0;
	end													
	else if (system_state == 2'b10) begin 
		system <= 1'b1;
		sys_Stat_A_final <= 1'b0;
		sys_Stat_B_final <= 1'b1;
	end
	else if(system_state == 2'b00)begin//双从时刻，上传双从的状态
		system <= system; 
		sys_Stat_A_final <= 1'b0;
		sys_Stat_B_final <= 1'b0;
	end
	else if((system_state == 2'b11)&&(system_state_old!=2'b11)) begin //双主的处理
		if(system_state_old==2'b10)begin //原主为B系统，切换到A主
			system <= 1'b0;
			sys_Stat_A_final <= 1'b1;
			sys_Stat_B_final <= 1'b0;
		end
		else if(system_state_old==2'b01)begin //原主为A系统，切换到B主
			system <= 1'b1;
			sys_Stat_A_final <= 1'b0;
			sys_Stat_B_final <= 1'b1;
		end	
		else begin  
			system <= 1'b0;
			sys_Stat_A_final <= 1'b1;
			sys_Stat_B_final <= 1'b0;
		end
	end
	else begin
		system <= system;
		sys_Stat_A_final <= sys_Stat_A_final;
		sys_Stat_B_final <= sys_Stat_B_final;	
	end
end
//-------------system拍一个时钟-----------------
always @ (posedge clk_20M)
begin
	if(!reset_n) system_reg	<= 1'b0;
	else  system_reg	<= system;
end
//--------------------------------------
always @ (posedge clk_20M)
begin
	if(!reset_n) begin
		switchBtoA <= 1'b0;
		switchAtoB <= 1'b0;
	end
	else if((system_reg) && (!system)) switchBtoA <= 1'b1;
	else if((!system_reg) && (system)) switchAtoB <= 1'b1;
	else begin
		switchBtoA <= 1'b0;
		switchAtoB <= 1'b0;
	end
end
//-----------------根据主从选择参数-----------------------
always @ ( * )//敏感变量由综合器根据always里面的输入变量自动添加，不用自己考虑  组合逻辑
begin
	if(!reset_n) begin
		o_ControlWord<= 16'd0;
		o_TargetVol<= 32'd0;
		o_CosThet<= 16'd0;
		o_rdint_CP<=1'b0;
		o_fastlock_final <= 1'b0;
	end
	else if(switchBtoA) begin//切换到A系统
		o_ControlWord<= i_CtrlWord_A;
		o_TargetVol<= i_TargetVol_CPA;
		o_CosThet<= i_CosThet_CPA;
		o_rdint_CP<=start1;
		o_fastlock_final <= i_fastlock1;
	end
	else if(switchAtoB) begin//切换到B系统
		o_ControlWord<= i_CtrlWord_B;
		o_TargetVol<= i_TargetVol_CPB;
		o_CosThet<= i_CosThet_CPB;
		o_rdint_CP<=start2;
		o_fastlock_final <= i_fastlock2;
	end
	else if(system) begin  //B系统
		o_ControlWord<= i_CtrlWord_B;
		o_TargetVol<= i_TargetVol_CPB;
		o_CosThet<= i_CosThet_CPB;
		o_rdint_CP<=start2;
		o_fastlock_final <= i_fastlock2;
	end
	else if(!system) begin //A系统
		o_ControlWord<= i_CtrlWord_A;
		o_TargetVol<= i_TargetVol_CPA;
		o_CosThet<= i_CosThet_CPA;
		o_rdint_CP<=start1;
		o_fastlock_final <= i_fastlock1;
	end

end
//---------------------------------------------
//wire [35:0]ILAControl;
//wire [79:0]data_chipscp; 
//assign data_chipscp[15:0] = i_CtrlWord_A;
//assign data_chipscp [31:16] = i_CtrlWord_B;
//assign data_chipscp [47:32] = o_ControlWord;
//assign data_chipscp [63:48] = {12'b0,i_sumerr_DSP};
////assign data_chipscp [79:64] = PhaseStaCPB;
//
//new_icon svg_icon ( 
//     .CONTROL0            ( ILAControl) 
//); 
//
//new_ila svg_ila ( 
//     .CONTROL            ( ILAControl), 
//     .CLK                ( clk_20M), 
//     .DATA               ( data_chipscp), 
//     .TRIG0              ( i_WD_DSP_ERR ), 
//	  .TRIG1              ( i_XINT_DSP_ERR),
//	  .TRIG2              (  check_err),
//	  .TRIG3              ( )
//);
endmodule
