`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:44:57 03/18/2019 
// Design Name: 
// Module Name:    XintDSP_Check 
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
module XintDSP_Check(
                   input clk_20M,
						 input clk_100M,
						 input reset_n,
						 input XZCS6,
						 input XWE,
						 input [15:0]DSP_A,
						 input i_WD_DSP_ERR,
						 output reg DSP_ERR_RST,
						 output XINT_DSP_ERR
                   );

parameter para_DSP_ERR  = 16'd599;//DSP故障检测时间参数-3ms
parameter para_DSP_Rst  = para_DSP_ERR + 16'd200;//DSP故障复位时间参数-1ms
parameter para_DSP_init = para_DSP_Rst + 16'd20_000;//DSP故障复位后初始化时间参数-100ms

wire sig_dsp_addr;
reg sig_dsp_addr0, sig_dsp_addr1;
reg [7:0] cnt1_DSP;
reg [15:0] cnt2_DSP;
reg XINT_ERR;//DSP 156us中断信号故障,DSP写故障地址
reg DSP_ERR;//DSP超过3ms不写两个特定地址,认为DSP故障
assign XINT_DSP_ERR = XINT_ERR | DSP_ERR;
assign sig_dsp_addr = ((XZCS6==1'b0) && (XWE==1'b0) && ((DSP_A[15:0]==16'h035A) || (DSP_A[15:0]==16'h03A5))) ? 1'b1 : 1'b0;

always @ (posedge clk_20M)
begin
	if(!reset_n) XINT_ERR <= 1'b0;
	else if((XZCS6 == 1'b0) && (XWE == 1'b0)) begin
		if(DSP_A[15:0]==16'h035A) XINT_ERR <= 1'b1;//DSP 156us中断信号故障
		else if(DSP_A[15:0]==16'h03A5) XINT_ERR <= 1'b0;//DSP 156us中断信号故障恢复
		else XINT_ERR <= XINT_ERR;
	end
	else XINT_ERR <= XINT_ERR;
end
//-------------DSP不操作地址线汇报中断情况及看门狗没故障情况下---------------------
always @ (negedge clk_20M)
begin
	if (!reset_n) begin
		sig_dsp_addr0 <= 1'b0;
		sig_dsp_addr1 <= 1'b0;
	end
	else begin
		sig_dsp_addr0 <= sig_dsp_addr;
		sig_dsp_addr1 <= sig_dsp_addr0;
	end
end

always @ (posedge clk_20M)
begin
	if(!reset_n) begin
		DSP_ERR <= 1'b0;
		DSP_ERR_RST <=1'b0;
		cnt1_DSP <= 8'd0;
		cnt2_DSP <= 16'd0;
	end
	else if ( i_WD_DSP_ERR ==1'b1 ) begin//看门狗故障时屏蔽XINT故障
		DSP_ERR <= 1'b0;
		DSP_ERR_RST <= 1'b0;
		cnt1_DSP <= 8'd0;
		cnt2_DSP <= 16'd0;
	end
	else if( sig_dsp_addr1 == 1'b1 ) begin
		DSP_ERR <= 1'b0;
		DSP_ERR_RST <= 1'b0;
		cnt1_DSP <= 8'd0;
		cnt2_DSP <= 16'd0;
	end
	else begin		
		if(cnt1_DSP >= 8'd99) begin
			if(cnt2_DSP == para_DSP_ERR) begin//3ms后,DSP中断执行故障置位上报装置级控保,DSP中断故障复位信号置位持续电平1ms,复位DSP
				DSP_ERR <= 1'b1;
				DSP_ERR_RST <= 1'b1;
				cnt1_DSP <= 8'd0;
				cnt2_DSP <= cnt2_DSP + 16'd1;
			end
			else if(cnt2_DSP == para_DSP_Rst) begin
				DSP_ERR <= 1'b1;
				DSP_ERR_RST <= 1'b0;
				cnt1_DSP <= 8'd0;
				cnt2_DSP <= cnt2_DSP + 16'd1;
			end
			else if(cnt2_DSP == para_DSP_init) begin
				DSP_ERR <= 1'b1;
				DSP_ERR_RST <= 1'b0;
				cnt1_DSP <= 8'd0;
				cnt2_DSP <= 16'd0; 
			end  
			else begin
				DSP_ERR <= DSP_ERR;
				DSP_ERR_RST <= DSP_ERR_RST;
				cnt1_DSP <= 8'd0;
				cnt2_DSP <= cnt2_DSP + 16'd1; 
			end
		end   
		else begin
			DSP_ERR <= DSP_ERR;
			DSP_ERR_RST <= DSP_ERR_RST;
			cnt1_DSP <= cnt1_DSP + 8'd1;
			cnt2_DSP <= cnt2_DSP;
		end
	end
end
//-------------------------------------------------------------------
//wire [35:0] ILAControl;
//wire [79:0] data_chipscp; 
//assign data_chipscp [14:0] ={10'd0,DSP_ERR_RST,i_WD_DSP_ERR,XINT_ERR,XWE,XZCS6};
//assign data_chipscp [15] = DSP_ERR;
//assign data_chipscp [31:16] = DSP_A[15:0];
//assign data_chipscp [55:32] = cnt1_DSP;
////assign data_chipscp [63:48] = cnt2_DSP;
////assign data_chipscp [79:64] = ;
//
//new_icon u_icon ( 
//     .CONTROL0            ( ILAControl) 
//); 
//
//
//new_ila u_ila (
//     .CONTROL            ( ILAControl), 
//     .CLK                ( clk_100M), 
//     .DATA               ( data_chipscp), 
//     .TRIG0              ( XINT_ERR), 
//	  .TRIG1              ( DSP_ERR),
//     .TRIG2              ( DSP_ERR_RST), 
//	  .TRIG3              ( DSP_ERR_RST)
//);
endmodule
