`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:58:29 10/26/2016 
// Design Name: 
// Module Name:    Comm_Check 
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
module Comm_Check_kb(
    input i_clk_100M,
    input i_reset_n,
    input i_rx_d,
    output reg O_opt_brk,
	 output reg O_opt_err,
	 input fs_start
    );
	
	reg data_mid;
	reg brk_mid;
	reg [15:0] cnt1;
	reg [15:0] cnt2;
	
	parameter Optbrk_time=9360;//断线检测时间78us
	parameter Opterr_time=9960;//超过78+5us没接收到帧头
//光纤断线检测
always @ (posedge i_clk_100M)
begin
	if(!i_reset_n) begin
		brk_mid	<= 1'b0;
		data_mid	<= 1'b0;
	  end
	else if(data_mid == i_rx_d) brk_mid	<= 1'b1;
	else begin
		brk_mid	<= 1'b0;
		data_mid	<= i_rx_d;
	  end
end

always @ (posedge i_clk_100M)
begin
	if(!i_reset_n) begin
	  O_opt_brk <= 1'b0;
	  end
	else if (cnt1 == Optbrk_time) begin
	  O_opt_brk <= 1'b1;//125us
	  end
	else begin
	  O_opt_brk <= 1'b0;
	  end	  
end

always @ (posedge i_clk_100M)
begin
	if(!i_reset_n) cnt1 <= 16'h0;
	else if(brk_mid) begin
		if(cnt1 == Optbrk_time) cnt1 <= Optbrk_time;
		else cnt1 <= cnt1+16'b1;
	  end
	else cnt1 <= 16'h0;
end

//光纤异常检测，超过125us+5us未检测出帧头
reg fs_start_old;
always @ (posedge i_clk_100M)
begin
	fs_start_old<=fs_start;
	if(!i_reset_n) cnt2 <= 16'h0;
	else if((~fs_start_old)&&fs_start) cnt2<=16'b0;
	else if(cnt2==Opterr_time)cnt2 <= Opterr_time;
	else cnt2<= cnt2+16'b1;
end
always @ (posedge i_clk_100M)
begin
	if(!i_reset_n) O_opt_err <= 1'b0;
	else if(cnt2==Opterr_time) O_opt_err <= 1'b1;
	else O_opt_err <= 1'b0;
end
endmodule
