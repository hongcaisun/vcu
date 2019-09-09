`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:04:25 07/27/2012 
// Design Name: 
// Module Name:    Sys_Rst 
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
module Sys_Rst(
						input	clk_in,
						input rst_in,
						output reset					
					);
					
reg	rst_reg;
reg	rst_reg_reg;
assign	reset = rst_reg_reg;
assign	rst = rst_in ;

always @ (posedge clk_in or negedge rst)
begin
	if(!rst) rst_reg <= 1'b0;
	else rst_reg <= 1'b1;
end

always @ (posedge clk_in or negedge rst)
begin
	if(!rst) rst_reg_reg	<= 1'b0;
	else rst_reg_reg <= rst_reg;
end

endmodule
