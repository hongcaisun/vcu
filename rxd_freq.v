`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:45:11 07/24/2019 
// Design Name: 
// Module Name:    rxd_freq 
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
module rxd_freq(
					input clk_20M,
					input clr,
					input rxd,
					output reg lock_stat,//检测为1M脉冲时输出1
					output reg pulse_err,//检测不到1M和100k脉冲，输出脉冲错误标志
					output reg phaselock_brk//光纤断线标志位
);
//此参数是计数器的位宽最大值和最小值
parameter NUM_CNT_MAX = 9'd500;
parameter NUM_CNT_MIN = 9'd0;
//此两个参数为1M脉冲信号对应clk_20M时钟个数，1m脉冲对应20个clk_20M时钟，在此取±10%范围
parameter NUM_1M_L = 9'd18;
parameter NUM_1M_H = 9'd22;
//此两个参数为100K脉冲信号对应clk_20M时钟个数，100K脉冲对应200个clk_20M时钟，在此取±5%范围
parameter NUM_100K_L = 9'd190;
parameter NUM_100K_H = 9'd210;

parameter NUM_BRK = 19999;//1ms断线判断

reg [2:0]Samp_reg;
reg rxd_temp;
reg data_reg;

reg [1:0]rxd_reg;
reg [8:0]cnt1;//周期计数器，超过511个20M时钟，认为频率超出范围
reg [8:0]cnt1_reg[1:0];//两级周期计数器寄存器
reg sig_dec;//周期信号判断开始标志位
reg sig_overflow;//周期信号频率超范围标志位

reg phaselock_reg;
reg phaselock_reg_reg;
reg [15:0] cnt3;
//***************消抖**************************//
wire rxd_low = ( Samp_reg[1:0] == 2'b00 );
wire rxd_high = ( Samp_reg[1:0] == 2'b11 );

always @ ( negedge clr or posedge clk_20M )
begin
	if ( !clr ) begin
		rxd_temp <= 1'b1;
		Samp_reg <= 3'b111;
		data_reg <= 1'b1;
	end
	else begin
		Samp_reg <= { Samp_reg[1:0] , rxd };
		if ( rxd_low )
			rxd_temp <= 1'b0;
		else if ( rxd_high )
			rxd_temp <= 1'b1;
		else
			rxd_temp <= rxd_temp;
		data_reg <= rxd_temp;
	end
end
//****************判一个周期的时长*********************//
always @ ( negedge clr or posedge clk_20M )
begin
	if ( !clr )
		rxd_reg <= 2'b00;
	else
		rxd_reg <= { rxd_reg[0] , data_reg };
end

always @ ( negedge clr or posedge clk_20M )
begin
	if ( !clr )begin
		cnt1 <= 9'b0;
		sig_dec <= 1'b0;
		sig_overflow <= 1'b0;
		cnt1_reg[0] <= 9'd0;
		cnt1_reg[1] <= 9'd0;
	end
	else if ( rxd_reg == 2'b01 )begin
		cnt1_reg[0] <= cnt1;
		cnt1_reg[1] <= cnt1_reg[0];
		cnt1 <= 9'd0;
		sig_dec <= 1'b1;
		sig_overflow <= 1'b0;
	end
	else if ( cnt1 == NUM_CNT_MAX )begin
		cnt1 <= cnt1;
		sig_overflow <= 1'b1;
	end
	else begin
		cnt1 <= cnt1 + 9'd1;
		sig_dec <= 1'b0;
		sig_overflow <= sig_overflow;
	end
end
//------------------判解锁封锁和频率异常------------------
reg [1:0]sig_dec_reg;//上升沿寄存器
reg sig_log1,sig_log2,sig_log3,sig_log4,sig_log5,sig_log6;//逻辑判断标志位
always @ ( negedge clr or posedge clk_20M )
begin
	if ( !clr )begin
		lock_stat <= 1'b0;
		pulse_err <= 1'b0;
		sig_dec_reg <= 2'b0;
	end
	else begin
		sig_dec_reg <= {sig_dec_reg[0],sig_dec};
		
		if (sig_dec_reg == 2'b01)begin
			if ( ( cnt1_reg[0] >= NUM_1M_L ) && ( cnt1_reg[0] <= NUM_1M_H ) && ( cnt1_reg[1] >= NUM_1M_L ) && ( cnt1_reg[1] <= NUM_1M_H ) )
				lock_stat <= 1'b1;//闭锁
			else if ( ( cnt1_reg[0] >= NUM_100K_L ) && ( cnt1_reg[0] <= NUM_100K_H ) && ( cnt1_reg[1] >= NUM_100K_L ) && ( cnt1_reg[1] <= NUM_100K_H ) )
				lock_stat <= 1'b0;//解锁
			else
				lock_stat <= lock_stat;
		end
		else
			lock_stat <= lock_stat;
			
		if (sig_overflow)begin
			pulse_err <= 1'b1;
		end
		else if (sig_dec_reg == 2'b01)begin
			sig_log1 <= (cnt1_reg[0] >= NUM_CNT_MIN)&&(cnt1_reg[0] <= (NUM_1M_L-9'd1));
			sig_log2 <= (cnt1_reg[0] >= (NUM_1M_H+9'd1))&&(cnt1_reg[0] <= (NUM_100K_L-9'd1));
			sig_log3 <= (cnt1_reg[0] >= (NUM_100K_H+9'd1))&&(cnt1_reg[0] <= (NUM_CNT_MAX));
			sig_log4 <= (cnt1_reg[1] >= NUM_CNT_MIN)&&(cnt1_reg[1] <= (NUM_1M_L-9'd1));
			sig_log5 <= (cnt1_reg[1] >= (NUM_1M_H+9'd1))&&(cnt1_reg[1] <= (NUM_100K_L-9'd1));
			sig_log6 <= (cnt1_reg[1] >= (NUM_100K_H+9'd1))&&(cnt1_reg[1] <= (NUM_CNT_MAX));
		end
		else begin
			if ((sig_log1|sig_log2|sig_log3) & (sig_log4|sig_log5|sig_log6))
				pulse_err <= 1'b1;
			else
				pulse_err <= 1'b0;
		end
	end
end
//-------------------判光纤断线---------------
//-------------------输入的封锁光纤拍两个时钟-----------------
always @ (posedge clk_20M or negedge clr)
begin
	if(!clr) begin
		phaselock_reg <= 1'b0;
		phaselock_reg_reg	<= 1'b0;
	end
	else begin
		phaselock_reg <= rxd;//封锁光纤输入
		phaselock_reg_reg	<= phaselock_reg;
	end
end
//-------------------电平持续计数器--------------------
always @ (posedge clk_20M or negedge clr)
begin
	if(!clr) cnt3 <= 16'h0;
	else if((phaselock_reg_reg == phaselock_reg) && (phaselock_brk == 1'b0)) begin
		if (cnt3>(NUM_BRK+10)) cnt3 <= cnt3;
		else cnt3 <= cnt3 + 16'h1;
	end
	else if(phaselock_reg_reg != phaselock_reg) cnt3 <= 16'h0;
	else cnt3 <= cnt3;
end
//-------------------------断线判断---------------------
always @ (posedge clk_20M or negedge clr)
begin
	if(!clr) phaselock_brk <= 1'b0;
	else if(cnt3>NUM_BRK) phaselock_brk <= 1'b1;
	else phaselock_brk <= 1'b0;
end
endmodule
