`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:38:39 02/05/2018 
// Design Name: 
// Module Name:    clk_sig 
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
module clk_sig(
	input   CLK_IN1,     // IN
   output  clk_20M,     // OUT
   output  clk_100M,    // OUT
	output  clk_120M,
   output  clk_50M,     // OUT
   output  clk_15M,     // OUT
   output  clk_4M,      // OUT
   output reg clk_1M,      // OUT
   output  clk_100K,    // OUT
   output  DcmLock
    );
	 
reg  clk_50Mhz;
reg  clk_4Mhz;
reg  clk_15Mhz;
reg  clk_100Khz;
reg  clk_2M;
reg [2:0]cnt1,cnt2;
reg clk_1,clk_2;

wire DcmLock1,DcmLock2,clk_in,clk_in_buf;

IBUFG IBUFG_clk_in
(
	.I(CLK_IN1),
	.O(clk_in)
);
BUFG BUFG_clk_in
(
	.I(clk_in),
	.O(clk_in_buf)
);

 sys_clk u1_DCM_CLK
   (
    .CLK_IN1(clk_in_buf),      // IN
    .CLK_OUT1(clk_120M),    // OUT
    .LOCKED(DcmLock2)); // OUT    
//	 
 sys_clk_120M DCM_CLK
   (
    .CLK_IN1(clk_in_buf),      // IN
    .CLK_OUT1(clk_100M),    // OUT
	 .CLK_OUT2(clk_20M),    // OUT
    .LOCKED(DcmLock1)); // OUT     
assign DcmLock = DcmLock1 & DcmLock2;
assign clk_50M=clk_50Mhz;	  
assign clk_15M=clk_15Mhz; 
assign clk_100K=clk_100Khz;

//BUFG          BUFG_clk20M       (
//                                 .I   (clk_20Mhz ),
//                                 .O   (clk_20M )
//                                 );
//BUFG          BUFG_clk4M       (
//                                 .I   (clk_4Mhz ),
//                                 .O   (clk_4M )
//                                 );
//--------50M时钟--------//
always @ (posedge clk_100M) 
begin
   if(!DcmLock1)clk_50Mhz<=1'b0;
   else clk_50Mhz <= ~clk_50Mhz;
end
 
//--------15M时钟--------//
reg[2:0] clk_15M_cnt;
always @ (posedge clk_120M) 
begin
	if(!DcmLock2)begin
		clk_15M_cnt<=3'd0;
		clk_15Mhz<=1'b0;
	end
	else begin 
		if(clk_15M_cnt == 3'd3) clk_15M_cnt<=3'd0;
		else clk_15M_cnt<=clk_15M_cnt+1;
		
		if(clk_15M_cnt == 3'd3) clk_15Mhz<=~clk_15Mhz;
		else clk_15Mhz<=clk_15Mhz;

	end
end

//--------4M时钟--------//
always@(posedge clk_20M)        //上升沿分频，占空比2:3
begin
	if(!DcmLock1) begin
		cnt1<=3'd0;
		clk_1<=1'b0;
	end
	else if(cnt1==3'b100) cnt1<=3'd0;
	else begin
		cnt1<=cnt1+3'd1;
		if(cnt1==3'b000) clk_1<=1'b1;
		if(cnt1==3'b010) clk_1<=1'b0;
	end
end
			
always@(negedge clk_20M)        //下升沿分频，占空比2:3
begin
	if(!DcmLock1)  begin
		cnt2<=3'd0;
		clk_2<=1'b0;
	end
	else if(cnt2==3'b100) cnt2<=3'd0;
	else begin
		cnt2<=cnt2+3'd1;
		if(cnt2==3'b000) clk_2<=1'b1;
		if(cnt2==3'b010) clk_2<=1'b0;
	end
end 
		 
assign clk_4M = clk_1 || clk_2;  //错位相或 

always@(posedge clk_4M) //上升沿分频
begin
     if(!DcmLock1)clk_2M<=1'b0;
     else clk_2M<=~clk_2M;
end
     

always@(posedge clk_2M) //上升沿分频
begin
     if(!DcmLock1)clk_1M<=1'b0;
     else clk_1M<=~clk_1M;
end

reg[3:0] clk_100K_cnt;
always @ (posedge clk_1M) 
begin
	if(!DcmLock1)begin
		clk_100K_cnt<=4'd0;
		clk_100Khz<=1'b0;
		
	end
	else begin 
		if(clk_100K_cnt == 4'd4) clk_100K_cnt<=4'd0;
		else clk_100K_cnt<=clk_100K_cnt+1;
		
		if(clk_100K_cnt==4'd4) clk_100Khz<=~clk_100Khz;
		else clk_100Khz<=clk_100Khz;

	end
end
//--------------------------
//wire [35:0]ILAControl;
//wire [79:0]data_chipscp; 
//assign data_chipscp[15:0] = {10'd0,clk_100K,clk_1M,clk_4M,clk_15M,clk_20M,clk_50M};
////assign data_chipscp [31:16] = ram_addr;
////assign data_chipscp [47:32] =ram_dout;
////assign data_chipscp [63:48] =dsp_addr;
////assign data_chipscp [79:64] =dsp_dout;
//
//new_icon svg_icon ( 
//     .CONTROL0            ( ILAControl) 
//); 
//
//new_ila svg_ila ( 
//     .CONTROL            ( ILAControl), 
//     .CLK                ( clk_100M), 
//     .DATA               ( data_chipscp), 
//     .TRIG0              ( clk_100M), 
//	  .TRIG1              ( ),
//	  .TRIG2              ( ),
//	  .TRIG3              ( )
//);


     

endmodule
