`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: CEPRI
// Engineer: ZHANG DIANQING
// 
// Create Date:    09:41:16 11/05/2015 
// Design Name: 
// Module Name:    SPWM_Test 
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
module SPWM_Test(clk_20M,reset_n,Openloop_Udc,TargetVol_Test
    );
input clk_20M,reset_n;
input [15:0] Openloop_Udc;
output signed [15:0] TargetVol_Test;



parameter  PARA_78us = 1559;
reg [10:0] Cnt_78us;
reg [7:0] Cnt_256points;
wire signed [15:0] douta;
wire signed [31:0] TargetVol_long = Openloop_Udc * douta >> 12;
assign TargetVol_Test = TargetVol_long[15:0];
//----------- Begin Cut here for INSTANTIATION Template ---// INST_TAG
ROM_SineWave_256_4096 ROM_SineWave (
  .clka(clk_20M), // input clka
  .addra(Cnt_256points), // input [7 : 0] addra
  .douta(douta) // output [15 : 0] douta
);
// INST_TAG_END ------ End INSTANTIATION Template ---------

always @ (posedge clk_20M)
begin
  if(!reset_n)begin
     Cnt_78us <= 11'd0;
	  Cnt_256points <= 8'd0;
  end
  else begin
     if(Cnt_78us < PARA_78us)begin
	     Cnt_78us <= Cnt_78us + 11'd1;
	  end
	  else begin
	     if(Cnt_256points < 255)begin
		     Cnt_256points <= Cnt_256points + 8'd1;
			  Cnt_78us      <= 11'd0;
		  end
		  else begin
		     Cnt_256points <= 8'd0;
			  Cnt_78us      <= 11'd0;
		  end
	  end
  end
end
////chipscope 
//wire [35:0] ILAControl;
//wire [79:0] data_chipscp; 
//assign data_chipscp [15:0] = Cnt_256points;
//assign data_chipscp [31:16] = douta;
//assign data_chipscp [47:32] = TargetVol_Test;
//assign data_chipscp [63:48] = Openloop_Udc;
//
//
//icon SVG_icon ( 
//     .CONTROL0            ( ILAControl) 
//); 
//
//u_ila SVG_ila ( 
//     .CONTROL            ( ILAControl), 
//     .CLK                ( clk_20M), 
//     .DATA               ( data_chipscp), 
//     .TRIG0              ( Cnt_256points[7]^Cnt_256points[6]^Cnt_256points[5]^Cnt_256points[4]^Cnt_256points[3]^Cnt_256points[2]^Cnt_256points[1]^Cnt_256points[0]), 
//	  .TRIG1              ( Cnt_256points[5]^Cnt_256points[4]^Cnt_256points[3]^Cnt_256points[2]^Cnt_256points[1]^Cnt_256points[0])
//);
endmodule
