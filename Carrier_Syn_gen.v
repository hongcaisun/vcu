`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:57:55 03/14/2019 
// Design Name: 
// Module Name:    Carrier_Syn_gen 
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
module Carrier_Syn_gen(
                      input i_clk_20M,
							 input i_reset_n,
							 input [15:0]i_Freqency_cnt,
							 output o_syn_out
                       );

reg [15:0] syn_cnt;
reg syn_out;

assign o_syn_out = syn_out;

always @ ( posedge i_clk_20M or negedge i_reset_n )
  begin
    if (!i_reset_n)
	   begin
		  syn_out <= 1'b1;
		  syn_cnt <= 16'd0;
		end
	 else
	   begin
		  if (syn_cnt==i_Freqency_cnt)
		    begin
			   syn_cnt <= 16'd0;
				syn_out <= ~ syn_out;
			 end
		  else
		    begin
			   syn_cnt <= syn_cnt + 16'd1;
			 end
		end
  end	
endmodule
