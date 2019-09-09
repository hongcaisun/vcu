`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: CEPRI
// Engineer: ZHANG Dianqing
// 
// Create Date:    15:00:07 07/24/2015 
// Design Name: 
// Module Name:    CLK20M 
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
module Clk_Div2(
    input clk,
    input reset_n,
    output clk_buf
    );

reg clk_out;
BUFG          BUFG_clk50M       (
                                 .I   (clk_out ),
                                 .O   (clk_buf )
                                 );

always@(posedge clk) //上升沿分频，占空比2:3
begin
	if(!reset_n)
	begin
		clk_out<=0;
	end
	else clk_out<=~clk_out;
end


endmodule
