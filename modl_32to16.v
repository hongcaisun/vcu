`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:20:48 06/30/2019 
// Design Name: 
// Module Name:    modl_32to16 
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
module modl_32to16(
						input clk,
						input [15:0]i_sta_l,
						input [15:0]i_sta_h,
						output reg[15:0]o_sta
);
reg t0,t15,t0_1,t0_2,t0_3;
always @ (posedge clk)
begin
	t0_1 <= i_sta_l[0]|i_sta_l[1]|i_sta_l[2]|i_sta_l[3]|i_sta_l[4];
	t0_2 <= i_sta_l[5]|i_sta_l[6]|i_sta_l[7]|i_sta_l[8]|i_sta_l[9];
	t0_3 <= i_sta_l[11]|i_sta_l[15]|i_sta_h[3]|i_sta_h[4];
	t0 <= t0_1 | t0_2 | t0_3;
	t15 <= i_sta_h[15]|i_sta_h[5]|i_sta_h[6]|i_sta_h[7];
	o_sta <= {t15,i_sta_h[14:8],i_sta_h[2:0],i_sta_l[14:12],i_sta_l[10],t0};
end
endmodule
