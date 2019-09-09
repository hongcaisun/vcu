`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:18:50 04/07/2013 
// Design Name: 
// Module Name:    Rx_Dy 
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
module Rx_Dy(
				input reset_n,
				input clk,
				input clk_20M,
				input M_R,
				output [15:0]LinkUdc,
				output [15:0]LinkStaa,
				output [15:0]LinkStab,
				output optbrk_o,
				output crconce_o
);

parameter data_num = 64;
parameter optbrk_time = 6240; //2*156us断线判断
parameter crc_num = 48;
parameter clk_div = 24;//100M 24  120M 29	 
parameter rx_num = 66; 

reg data_in;
reg data_in_reg;

wire [15:0] crc_cal;
wire [data_num-1:0] data;
wire [data_num-17:0] data_o;
wire start,non_frame;
wire [rx_num-1:0] data_q;

assign data = data_q[rx_num-1:1];
assign LinkUdc = data_o[15:0];
assign LinkStaa = data_o[31:16];
assign LinkStab = data_o[47:32];

reg cnt_start;
reg start_reg;

Man_RxDy #(crc_num,clk_div,rx_num) Man_Rx_module 
(
							.clk(clk),
							.reset_n(reset_n),
							.rxd(~data_in),//接收的数据
							.data_q(data_q),
							.start(start),
							.crc(crc_cal),
							.non_frame(non_frame)//收到不完整数据帧，1是有效
);//约定单元到阀控：无光为1，光接口板接收无光时，传给CPU板为0，所以data_in取反~data_in
Comm_Dy #(data_num,optbrk_time) chack_module 
(
							.clk_20M(clk_20M),
							.reset_n(reset_n),
							.data_in(data),
							.crc_cal(crc_cal),
							.start(start_reg),
							.Serial_data(data_in),
							.data_o(data_o),
							.optbrk_o(optbrk_o),
							.crconce(crconce_o),
							.non_frame(non_frame)
);
//------接收数据拍一个时钟-------------------
always @ (posedge clk)
begin
	if(!reset_n) begin
		data_in		 <= 1'b1;
		data_in_reg <= 1'b1;
	  end
	else begin
		data_in		 <= data_in_reg;
		data_in_reg <= M_R;
	  end
end

always @ (negedge reset_n or posedge clk_20M)
begin
	if(!reset_n) begin 
	   start_reg <= 1'b0;
	   cnt_start <= 1'b0;
	end
	else if( start && (cnt_start == 1'b0)) begin
		start_reg <= 1'b1;
		cnt_start <= 1'b1;
	end
	else if(start)begin
		start_reg <= 1'b0;
		cnt_start <= cnt_start;
	end
	else begin
		start_reg <= 1'b0;
		cnt_start <= 1'b0;
	end
end

endmodule
