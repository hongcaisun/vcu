`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:18:56 03/26/2013 
// Design Name: 
// Module Name:    Comm_chack 
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
//////////////////////////////////////////////////////////////////////////////////
module Comm_Dy(
					input	clk_20M,
					input	reset_n,
					input	[data_num:0]data_in,
					input [15:0]crc_cal,
					input start,
					input Serial_data,
					output reg [data_num-17:0]data_o,
					output reg optbrk_o,
					output crconce,
					input non_frame
);

parameter data_num = 64;
parameter optbrk_time = 6240; //2*156us断线判断

reg [15:0] cnt1;
reg [15:0] cnt2;
reg  brk_mid;
reg  data_mid;
reg  crconce_o;
//reg [data_num-17:0] data_o;
reg crconce_1;
reg crc_frame;
assign crconce = crconce_o | crc_frame;

//always @ (posedge clk_20M)
//begin 
//	if(!reset_n) begin
////		xint_1    <= 1'b0;
//		crconce_1 <= 1'b0;
//		data_1	 <= 0;
//	  end
//	else begin
////		xint_1    <= xint_o;
//		crconce_1 <= crconce_o;
//		data_1	 <= data_o;
//	  end
//end

always @ (posedge clk_20M)
begin
   if(!reset_n) begin
	   cnt2 <= 16'd0;
		crc_frame<= 1'b0;
	end
	else if(optbrk_o)begin
	   cnt2 <= 16'd0;
		crc_frame<= 1'b0;
	  end	
	else if(non_frame)begin
	   if(cnt2 <optbrk_time)begin//不完整数据帧2个点
		   cnt2 <= cnt2 + 16'd1;
			crc_frame<= 1'b0;
		end
		else begin
		  	cnt2 <= cnt2;
			crc_frame<= 1'b1;
		end
	end
	else begin
		cnt2 <= 16'd0;
		crc_frame<= 1'b0;
	end
end


//判断2次校验错误标志
always @ (posedge clk_20M)
begin
	if(!reset_n) begin
		crconce_o	<= 1'b0;
//		xint_o		<= 1'b0;
		data_o	   <= 0;
	  end
	else if(optbrk_o)begin
		crconce_o <= 1'b0;	
	end
	else if (start) begin
//		xint_o		<= 1'b1;
      if((crc_cal == data_in[data_num-1:data_num-16]) && (data_in[data_num]==1'b0)) begin
			crconce_o <= 1'b0;
			data_o	 <= data_in[data_num-17:0];
		  end
		else begin//1个点校验错误
			crconce_o <= 1'b1;
			data_o	 <= data_o;
		  end
	  end 
	else begin
		crconce_o <= crconce_o;
//		xint_o	 <= 1'b0;
		data_o	 <= data_o;
	  end
end

//断线判断
always @ (posedge clk_20M)
begin
	if(!reset_n) begin
		brk_mid	<= 1'b0;
		data_mid	<= 1'b0;
	  end
	else if(data_mid == Serial_data) brk_mid	<= 1'b1;
	else begin
		brk_mid	<= 1'b0;
		data_mid	<= Serial_data;
	  end
end

always @ (posedge clk_20M)
begin
	if(!reset_n) optbrk_o <= 1'b0;
	else if (cnt1 == optbrk_time) optbrk_o	<= 1'b1;
	else optbrk_o <= 1'b0;
end

always @ (posedge clk_20M)
begin
	if(!reset_n) cnt1 <= 16'h0;
	else if(brk_mid) begin
		if(cnt1 == optbrk_time) cnt1 <= optbrk_time;
		else cnt1 <= cnt1+16'b1;
	  end
	else cnt1 <= 16'h0;
end



endmodule
