`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:21:01 04/07/2013 
// Design Name: 
// Module Name:    TriangleWave 
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
module TriangleWave(
							input reset_n,
							input clk_20M,
							input Syn,//载波同步信号
							input [15:0]Frequency,//开关频率计数器20M时钟
							input [15:0]Angle_initial,//模块初始相角
							output reg AngleDir,
							output reg [15:0]Angle
);

//parameter Angle_initial = 0;
//parameter Frequency = 22222;

reg 	Syn_reg;
reg 	Syn_reg_reg;
//--------------载波同步信号拍两拍----------------------
always @ (posedge clk_20M or negedge reset_n ) 
begin
	if (!reset_n) begin
	  Syn_reg_reg  <= 1'b0;
	  Syn_reg      <= 1'b0;
	end
	else begin
	  Syn_reg 		<= Syn ;
	  Syn_reg_reg  <= Syn_reg ;
	end
end
//---------------三角载波生成，整体三角载波在水平0轴以上--------------------------
always @ (posedge clk_20M or negedge reset_n )
begin
	if (!reset_n) begin
		Angle 			<= Angle_initial;
		AngleDir 		<= 1'b0;
	end
	else begin
		if (Syn_reg_reg == 1'b0 && Syn_reg == 1'b1) begin
			AngleDir 	<= 1'b1;
			Angle 		<= Angle_initial;
		end
		else begin
			if (Angle > Frequency) begin
				Angle <= Angle - 16'b1;
				AngleDir <= 1'b1;
			end
			else if (Angle==16'd0) begin
				Angle <= Angle + 16'b1;
				AngleDir <= 1'b0;
			end
			else if (AngleDir == 1'b1) Angle <= Angle - 16'b1;
			else Angle <= Angle + 16'b1;
		end			 
	end
end

endmodule
