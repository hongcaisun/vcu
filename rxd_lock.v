`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:29:06 04/13/2018 
// Design Name: 
// Module Name:    rxd_Man_lock 
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
module rxd_Man_lock(clk_20M,clr,rxd,lock_stat,pulse_err
    );
	 input clk_20M;
	 input clr;
	 input rxd;
	 output reg lock_stat;//检测为1M脉冲时输出1
	 output reg pulse_err;//检测不到1M和100k脉冲，输出脉冲错误标志
	 
	 parameter NUM_PULSE = 2; //实际计算的脉冲周期数为PULSENUM；判断周期数不能小于1个
	 //此两个参数为1M脉冲信号对应clk_20M时钟个数，1m脉冲对应20个clk_20M时钟，在此取±10%范围
	 parameter NUM_1M_L = 18'd18;
	 parameter NUM_1M_H = 18'd22;
	 //此两个参数为100K脉冲信号对应clk_20M时钟个数，100K脉冲对应200个clk_20M时钟，在此取±5%范围
	 parameter NUM_100K_L = 18'd190;
	 parameter NUM_100K_H = 18'd210;
	 
	 //***************消抖**************************//
	 reg [2:0] Samp_reg;
	 reg rxd_temp;
	 reg data_reg;
	 
	 wire rxd_low = ( Samp_reg[1:0] == 2'b00 );
	 wire rxd_high = ( Samp_reg[1:0] == 2'b11 );
	 
	 always @ ( negedge clr or posedge clk_20M )
	 begin
		if ( !clr )
			begin
				rxd_temp <= 1'b1;
				Samp_reg <= 3'b111;
				data_reg <= 1'b1;
			end
		else
			begin
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
	 //****************方波上升沿开始计数,计2周期*********************//
	 reg [1:0] rxd_reg;
	 reg [7:0] cnt1;
	 
	 always @ ( negedge clr or posedge clk_20M )
	 begin
		if ( !clr )
			rxd_reg <= 2'b00;
		else
			rxd_reg <= { rxd_reg[0] , data_reg };
	 end
	 
	 always @ ( negedge clr or posedge clk_20M )
	 begin
		if ( !clr )
			cnt1 <= 8'b0;
		else if ( rxd_reg == 2'b01 )
			begin
				if ( cnt1 <= 8'd2 )
					cnt1 <= cnt1 + 1'd1;
				else
					cnt1 <= 8'd0;
			end
		 else
			cnt1 <= cnt1;
	 end
	 //*******************1M和100k开始计数******************//
	 reg [17:0] cnt2;
	 reg [17:0] cnt3;//此计数器是防止拔插光纤cnt1正好停在0的时候，导致出错
	 reg [17:0] cnt4;//cnt2是第一个周期，cnt4第二个周期计数
	 always @ ( negedge clr or posedge clk_20M )
	 begin
		if ( !clr )
			begin
			cnt2 <= 18'd0;
			cnt3 <= 18'd0;
			cnt4 <= 18'd0;
			end
		else if ( cnt1 == 8'd0 )
			begin
			cnt2 <= 18'd0;
			cnt3 <= cnt3 + 18'd1;
			cnt4 <= 18'd0;
			end
		else if ( cnt1 == 8'd1 )
			begin
			cnt2 <= cnt2 + 18'd1;
			cnt3 <= 18'd0;
			cnt4 <= 18'd0;
			end
		else if ( cnt1 == 8'd2 )
			begin
			cnt2 <= cnt2;
			cnt3 <= 18'd0;
			cnt4 <= cnt4 + 18'd1;
			end
		else if ( cnt1 == 8'd3 )
			begin
			cnt2 <= cnt2;
			cnt3 <= 18'd0;
			cnt4 <= cnt4;
			end
		else if ( ( cnt2 == 18'h3ffff ) | ( cnt4 == 18'h3ffff ) | ( cnt3 == 18'h3ffff ) )
			begin
			cnt2 <= cnt2;
			cnt3 <= cnt3;
			cnt4 <= cnt4;
			end
		else
			begin
			cnt2 <= 18'd0;
			cnt3 <= 18'd0;
			cnt4 <= 18'd0;
			end
	 end
	 
	 //****************置有效位和错误位*****************//
	 always @ ( negedge clr or posedge clk_20M )
	 begin
		if ( !clr )
			begin
			lock_stat <= 1'b0;
			pulse_err <= 1'b0;
			end
		else if ( cnt1 == ( NUM_PULSE +1 ) )
			begin
			if ( ( cnt2 >= NUM_1M_L ) & ( cnt2 <= NUM_1M_H ) & ( cnt4 >= NUM_1M_L ) & ( cnt4 <= NUM_1M_H ) )
				begin
				lock_stat <= 1'b1;//闭锁
				pulse_err <= 1'b0;
				end
			else if ( ( cnt2 >= NUM_100K_L ) & ( cnt2 <= NUM_100K_H ) & ( cnt4 >= NUM_100K_L ) & ( cnt4 <= NUM_100K_H ) )
				begin
				lock_stat <= 1'b0;//解锁
				pulse_err <= 1'b0;
				end
			else
				begin
				lock_stat <= 1'b0;
				pulse_err <= 1'b1;
				end
			end
		else if ( ( cnt2 == 18'h3ffff ) | ( cnt3 == 18'h3ffff ) | ( cnt4 == 18'h3ffff ) )
			begin
			lock_stat <= 1'b0;
			pulse_err <= 1'b1;
			end
		else
			begin
			lock_stat <= lock_stat;
			pulse_err <= pulse_err;
			end
	end

			
endmodule
