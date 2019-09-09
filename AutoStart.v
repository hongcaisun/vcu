`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:08:55 07/09/2013 
// Design Name: 
// Module Name:    AutoStart 
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

module AutoStart(
    input clk_20M,
    input reset_n,
	 input rdint_CP,
	 output reg start_PWM,start_DPRAM,start_Unit,start_txCP
    );
parameter syn_period = 3124; //每156us产生一个同步 
parameter DELAY_PWM = 290;//接收到帧头后14.4us产生start使能信号 //zy //319  16us  XINT和发送控保
parameter DELAY_DPRAM =1200;
parameter DELAY_UNIT = 290;
parameter DELAY_TXCP = 1270;
parameter PULSE = 10;
reg [15:0] cnt_pwm;
reg [15:0] cnt_dpram;
reg [15:0] cnt_unit;
reg [15:0] cnt_txCP;
 


reg[2:0] i_fs_reg;
reg fs_in,fs_s,prod_fs;
reg[1:0] fs_in_reg,fs_s_reg;
reg[13:0] fs_in_cnt,fs_s_cnt;
reg start_syn;

always @ (posedge clk_20M)
begin
	if(!reset_n)begin
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
		i_fs_reg<={i_fs_reg[1:0],rdint_CP};	
		if(i_fs_reg==3'b000) fs_in<=1'b0;
		else if(i_fs_reg==3'b111) fs_in<=1'b1;
		else fs_in<=fs_in;	
		
		fs_in_reg<={fs_in_reg[0],fs_in};
		if(fs_in_reg==2'b01) fs_in_cnt<=14'd1562;
		else if(fs_in_cnt==syn_period)fs_in_cnt<=14'd0;
		else fs_in_cnt<=fs_in_cnt+1;	
		
		if(fs_in_cnt==14'd0) fs_s<=1'b0;
		else if(fs_in_cnt==14'd3074) fs_s<=1'b1;
		else fs_s<=fs_s;
		fs_s_reg<={fs_s_reg[0],fs_s};
		
		if(fs_s_reg==2'b10) fs_s_cnt<=14'd0;
		else if(fs_s_cnt==syn_period)fs_s_cnt<=syn_period;
		else fs_s_cnt<=fs_s_cnt+1;

		if(fs_s_cnt==14'd1562) start_syn<=1'b1;
		else if(fs_s_cnt==14'd1572) start_syn<=1'b0;
		else start_syn<=start_syn;
	end
end

always @ (posedge clk_20M)
begin
     if(!reset_n)begin
		  cnt_pwm   <= 16'd0;
		  start_PWM <= 1'b0;
	  end
	  else if(start_syn)begin
	     cnt_pwm   <= 16'd0;
		  start_PWM <= 1'b0;
	  end
	  else if(cnt_pwm  == (DELAY_PWM + PULSE))begin
		  cnt_pwm   <= cnt_pwm;
		  start_PWM <= 1'b0;
	  end
	  else if(cnt_pwm >= DELAY_PWM)begin
		  cnt_pwm   <= cnt_pwm + 16'd1;
		  start_PWM <= 1'b1;
	  end
	  else begin
		  cnt_pwm   <= cnt_pwm + 16'd1;
		  start_PWM <= 1'b0;
	  end
end 

always @ (posedge clk_20M)
begin
     if(!reset_n)begin
		  cnt_dpram   <= 16'd0;
		  start_DPRAM <= 1'b0;
	  end
	  else if(start_syn)begin
	     cnt_dpram   <= 16'd0;
		  start_DPRAM <= 1'b0;
	  end
	  else if(cnt_dpram  == (DELAY_DPRAM + PULSE))begin
		  cnt_dpram   <= cnt_dpram;
		  start_DPRAM <= 1'b0;
	  end
	  else if(cnt_dpram >= DELAY_DPRAM)begin
		  cnt_dpram   <= cnt_dpram + 16'd1;
		  start_DPRAM <= 1'b1;
	  end
	  else begin
		  cnt_dpram   <= cnt_dpram + 16'd1;
		  start_DPRAM <= 1'b0;
	  end
end 

always @ (posedge clk_20M)
begin
     if(!reset_n)begin
		  cnt_unit   <= 16'd0;
		  start_Unit <= 1'b0;
	  end
	  else if(start_syn)begin
	     cnt_unit   <= 16'd0;
		  start_Unit <= 1'b0;
	  end
	  else if(cnt_unit  == (DELAY_UNIT + PULSE))begin
		  cnt_unit   <= cnt_unit;
		  start_Unit <= 1'b0;
	  end
	  else if(cnt_unit >= DELAY_UNIT)begin
		  cnt_unit   <= cnt_unit + 16'd1;
		  start_Unit <= 1'b1;
	  end
	  else begin
		  cnt_unit   <= cnt_unit + 16'd1;
		  start_Unit <= 1'b0;
	  end
end 

always @ (posedge clk_20M)
begin
     if(!reset_n)begin
		  cnt_txCP   <= 16'd0;
		  start_txCP <= 1'b0;
	  end
	  else if(start_syn)begin
	     cnt_txCP   <= 16'd0;
		  start_txCP <= 1'b0;
	  end
	  else if(cnt_txCP  == (DELAY_TXCP + PULSE))begin
		  cnt_txCP   <= cnt_txCP;
		  start_txCP <= 1'b0;
	  end
	  else if(cnt_txCP >= DELAY_TXCP)begin
		  cnt_txCP   <= cnt_txCP + 16'd1;
		  start_txCP <= 1'b1;
	  end
	  else begin
		  cnt_txCP   <= cnt_txCP + 16'd1;
		  start_txCP <= 1'b0;
	  end
end 

endmodule

