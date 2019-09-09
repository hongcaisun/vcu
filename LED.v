`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:43:51 11/17/2014 
// Design Name: 
// Module Name:    LED 
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
module LED(clk_20M,reset_n,dsp_err,optolock,fastlock,LED2,LED3,LED4
    );
    input clk_20M,reset_n,dsp_err,optolock,fastlock;
	 output reg LED2,LED3,LED4;
	 
always @ (negedge reset_n or posedge clk_20M )
begin
    if(!reset_n) begin
	    LED2 <= 1'b0;
	 end
    else if(dsp_err)LED2 <= 1'b1;
	 else LED2 <= LED2;
end

always @ (negedge reset_n or posedge clk_20M )
begin
    if(!reset_n) begin
		 LED3 <= 1'b0;
	 end
    else if(optolock)LED3 <= 1'b1;
	 else LED3 <= LED3;
end
always @ (negedge reset_n or posedge clk_20M )
begin
    if(!reset_n) begin
		 LED4 <= 1'b0;
	 end
    else if(fastlock)LED4 <= 1'b1;
	 else LED4 <= LED4;
end

endmodule
