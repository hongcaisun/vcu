`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:28:19 03/15/2019 
// Design Name: 
// Module Name:    DspReset 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
// RST 复位DSP wdi给706喂狗1M
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module DspReset(reset_n,clk_20M,GPIO4,WD_RST,WD_DSP_ERR);


parameter WatchdogTime1 = 1999; //100us
parameter WatchdogTime2 = 999; //100us计数1000次
parameter ResetTime = 19999; //复位时长1ms

input reset_n,clk_20M,GPIO4;
output reg WD_RST,WD_DSP_ERR;

reg [2:0] GPIOreg;
reg wd;
reg [15:0] cnt;
reg [15:0] cnt2;
reg startreset; 
reg [15:0] cnt1; 

always @ (posedge clk_20M)
begin
	if(!reset_n) GPIOreg <= 3'b000;
	else begin
		GPIOreg[2] <= GPIOreg[1];
		GPIOreg[1] <= GPIOreg[0];
		GPIOreg[0] <= GPIO4;
	  end
end

always @ (posedge clk_20M)
begin
	if(!reset_n) wd <= 1'b0;
	else if(GPIOreg[2] == GPIOreg[1]) wd <= 1'b1;
	else wd <= 1'b0;
end

always @ (posedge clk_20M)
begin
	if(!reset_n) begin 
		cnt <= 16'd0;
		cnt2 <= 16'd0;
		startreset <= 1'b0;
	end
	else if(wd) begin
	  if(cnt2 == WatchdogTime1)begin
	    	if(cnt > WatchdogTime2) begin //100us计数1000次超时
			   startreset <= 1'b1;
				cnt <= 16'd0;//重新100ms检测
				cnt2 <= 16'd0;
				end
	      else begin
			   startreset <= 1'b0;
	         cnt <= cnt + 16'd1;
		      cnt2 <= 16'd0;
				end
		end
	  else  begin
	        cnt2 <= cnt2 + 16'd1; 
			  startreset <= 1'b0;
     end			  
   end	  
	else begin 
	   cnt <= 16'd0;
		cnt2 <= 16'd0;
		startreset <= 1'b0;
		end
end
//----------------DSP跑飞了置故障位-----------------
always @ (posedge clk_20M)
begin
   if(!reset_n)begin
		WD_DSP_ERR  <= 1'b0;
	end
   else if (!wd)begin
		WD_DSP_ERR  <= 1'b0;
	end
   else if(startreset==1'b1) begin
	   WD_DSP_ERR  <= 1'b1;
	end
	else begin
	   WD_DSP_ERR  <= WD_DSP_ERR;
	end
end
//--------------------FPGA给DSP复位信号------------
always @ (posedge clk_20M)
begin
	if(!reset_n) begin
		WD_RST <= 1'b0;
		cnt1  <= 16'd0;
	  end
	else if((startreset==1'b1) || (cnt1 != 16'd0)) begin
		if(cnt1 == ResetTime) begin
			cnt1  <= 16'd0;
		  end
		else begin
		  cnt1  <= cnt1 + 16'd1;
		  WD_RST <= 1'b1;
		  end
	  end
	else begin
		WD_RST <= 1'b0;
		cnt1  <= 16'd0;
	  end
end
//-----------------------------
//wire [35:0]ILAControl;
//wire [79:0]data_chipscp; 
//assign data_chipscp[15:0] = {13'd0,WD_RST,WD_DSP_ERR,GPIO4};
//assign data_chipscp [31:16] = cnt;
//assign data_chipscp [47:32] =cnt2;
////assign data_chipscp [63:48] =dsp_addr;
////assign data_chipscp [79:64] =dsp_dout;
//
//new_icon svg_icon ( 
//     .CONTROL0            ( ILAControl) 
//); 
//
//new_ila svg_ila ( 
//     .CONTROL            ( ILAControl), 
//     .CLK                ( clk_20M), 
//     .DATA               ( data_chipscp), 
//     .TRIG0              ( WD_DSP_ERR ), 
//	  .TRIG1              ( startreset ),
//	  .TRIG2              ( GPIO4 ),
//	  .TRIG3              (  )
//);
endmodule
