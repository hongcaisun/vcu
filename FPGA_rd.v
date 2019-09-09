`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:47:05 09/14/2017 
// Design Name: 
// Module Name:    FPGA_rd 
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

////////////////////////////////////////////////////////////////////////////////
module FPGA_rd(
					input clk_100M,
					input reset_n,
					output reg [9:0]addr_r,
					input XINT1,
					input [15:0]ram_dout,
					input XWE,
					input dsp_w,
					output reg [15:0]Phase_sta,			output reg [15:0]LinkNum_Total,
					output reg [15:0]F_switch,				output reg [15:0]Kp_Udc,
					output reg [15:0]UdcThirdCtrlLim,
					output reg sumerrKB,
					output reg [15:0]Redun_pos1,			output reg [15:0]Redun_pos2,
					output reg [15:0]Redun_pos3,			output reg [15:0]Redun_pos4,
					output reg [15:0]Redun_pos5,			output reg [15:0]Redun_pos6,
					output reg [15:0]VCU_Mode,				output reg [15:0]para_grp_TFR,
					output reg[15:0]backup1,//DSP备用数据
					output reg[15:0]backup2,
					output reg[15:0]backup3,
					output reg[15:0]backup4,
					output reg[15:0]backup5,
					output reg[15:0]backup6,
					output reg[15:0]backup7,
					output reg[15:0]backup8,
					output reg[15:0]backup9,
					output reg[15:0]backup10,
					output reg[15:0]backup11,
					output reg[15:0]backup12,
					output reg[15:0]backup13,
					output reg[15:0]backup14,
					output reg[15:0]backup15,
					output reg[15:0]backup16,
					output reg[15:0]backup17,
					output reg[15:0]backup18
); 
parameter DELAY_TIME = 100;//中断产生延时1us后FPGA再去读ram中数据  需要核对时序图
parameter STATE0 = 4'd0;
parameter STATE1 = 4'd1;
parameter STATE2 = 4'd2;
parameter STATE3 = 4'd3;
parameter STATE4 = 4'd4;
parameter NUM = 8'd32;

reg [7:0]cnt1;
reg [15:0]resum_KB;
reg [15:0]dataFdsp [31:0]; 
reg [4:0]data_refesh_reg;
reg data_refesh_s,data_refesh_old,data_refesh;

reg wea;
reg [4:0]data_addr,ram0_addr;
reg [15:0]data_in;
wire [15:0]ram0_data;
reg [3:0]ram_state;
reg [15:0]data_sum;

reg sig_ass;
reg [3:0]cnt_ass;
reg [5:0]re_state;
//-------------------DSP中断拍下降沿有效------------------
always @ (posedge clk_100M)
begin 
	if(!reset_n) begin
		data_refesh_reg <=5'b11111;
		data_refesh_s<=1;
		data_refesh_old<=1;
		data_refesh<=0;
	end	
	else begin	
		data_refesh_old<=data_refesh_s;
		data_refesh_reg   <= {data_refesh_reg[3:0],XINT1};
		if(data_refesh_reg==5'b00000) data_refesh_s<=0;
		else if(data_refesh_reg==5'b11111) data_refesh_s<=1;
		else	data_refesh_s<=data_refesh_s;
		data_refesh<=(data_refesh_old)&(~data_refesh_s);//下降沿有效
	end
end
//------------------DSP中断拍下降沿后延时100个时钟------------
reg data_refesh_delay;
reg [15:0] cnt_delay;

always @ (posedge clk_100M)
begin 
	if(!reset_n) begin
		data_refesh_delay<=0;
		cnt_delay<=0;
	end	
	else begin	
		if(data_refesh) begin
			cnt_delay <= 16'd1;
			data_refesh_delay <= 1'b0;
		end
		else if((cnt_delay != 16'd0)&&(cnt_delay < DELAY_TIME)) begin
			cnt_delay <= cnt_delay + 16'd1;
			data_refesh_delay <= 1'b0;
		end
		else if(cnt_delay == DELAY_TIME) begin
			cnt_delay <= 16'd0;
			data_refesh_delay <= 1'b1;
		end
		else begin
			cnt_delay <= 16'd0;
			data_refesh_delay <= 1'b0;
		end	
	end
end
//------------------------------------------
RAM_32W data_ram0 (
  .clka(clk_100M), // input clka
  .wea(wea), // input [0 : 0] wea
  .addra(data_addr), // input [4 : 0] addra
  .dina(data_in), // input [15 : 0] dina
  .douta(), // output [15 : 0] douta
  
  .clkb(clk_100M), 
  .web(1'b0),
  .addrb(ram0_addr), 
  .dinb(), 
  .doutb(ram0_data) 
);

always @ ( posedge clk_100M )
begin
	if (!reset_n) begin
		addr_r <= 10'h010;
		wea <= 1'b0;
		data_addr <= 5'd0;
		data_in <= 16'd0;
		data_sum <= 16'd0;
		sumerrKB <= 1'b0;
	end
	else begin
		case ( ram_state )
			STATE0: begin
				if (data_refesh_delay) begin
					ram_state <= STATE1;
				end
				else begin
					ram_state <= STATE0;
					addr_r <= 10'h010;
					wea <= 1'b0;
					data_addr <= 5'd0;
					data_in <= 16'd0;
					data_sum <= 16'd0;
				end
			end
			STATE1: begin
				if (dsp_w) begin
					ram_state <= STATE1;
					addr_r <= 10'h010;
					wea <= 1'b0;
					data_addr <= 5'd0;
					data_in <= 16'd0;
				end
				else begin
					ram_state <= STATE2;
					addr_r <= addr_r + 10'h001;
					wea <= 1'b1;
					data_addr <= 5'd0;
					data_in <= ram_dout;
				end
			end
			STATE2: begin
				ram_state <= STATE3;
				addr_r <= addr_r + 10'h001;
				wea <= 1'b1;
				data_addr <= 5'd0;
				data_in <= ram_dout;
				data_sum <= ram_dout;
			end
			STATE3: begin
				addr_r <= addr_r + 10'h001;
				wea <= 1'b1;
				data_addr <= data_addr + 5'd1;
				data_in <= ram_dout;
				if ( data_addr == (NUM-2) ) begin
					if (data_sum == ~ram_dout) sumerrKB <= 1'b0;
					else sumerrKB <= 1'b1;
				end
				else data_sum <= data_sum + ram_dout;
				if ( data_addr == (NUM-2) ) ram_state <= STATE4;
				else ram_state <= STATE3;
			end
			default: begin
				ram_state <= STATE0;
				addr_r <= 10'h010;
				wea <= 1'b0;
				data_addr <= 5'd0;
				data_in <= 16'd0;
				data_sum <= 16'd0;
			end
		endcase
	end
end
//-------------------------------
always @ (posedge clk_100M)
begin
	if (!reset_n) begin
		sig_ass <= 1'b0;
		cnt_ass <= 4'd0;
	end
	else if ( ram_state == STATE4 ) begin
		cnt_ass <= cnt_ass + 4'd1;
		sig_ass <= 1'b0;
	end
	else if ( cnt_ass == 4'd5 ) begin
		cnt_ass <= 4'd0;
		sig_ass <= 1'b1;
	end
	else if ( cnt_ass != 4'd0 ) begin
		cnt_ass <= cnt_ass + 4'd1;
		sig_ass <= 1'b0;
	end
	else begin
		cnt_ass <= cnt_ass;
		sig_ass <= 1'b0;
	end
end
//-------------------------------
always @ (posedge clk_100M)
begin
	if (!reset_n) begin
		Phase_sta <= 16'h0;
		LinkNum_Total <= 16'h0;
		F_switch <= 16'h0;
		Kp_Udc <= 16'h0;			
		UdcThirdCtrlLim <= 16'h0;				
		Redun_pos1 <= 16'h0;
		Redun_pos2 <= 16'h0;
		Redun_pos3 <= 16'h0;
		Redun_pos4 <= 16'h0;
		Redun_pos5 <= 16'h0;
		Redun_pos6 <= 16'h0;
		VCU_Mode <= 16'h0;
		para_grp_TFR <= 16'h0;
		re_state <= 6'd0;
		backup1 <= 16'd0;//DSP备用数据
		backup2 <= 16'd0;
		backup3 <= 16'd0;
		backup4 <= 16'd0;
		backup5 <= 16'd0;
		backup6 <= 16'd0;
		backup7 <= 16'd0;
		backup8 <= 16'd0;
		backup9 <= 16'd0;
		backup10 <= 16'd0;
		backup11 <= 16'd0;
		backup12 <= 16'd0;
		backup13 <= 16'd0;
		backup14 <= 16'd0;
		backup15 <= 16'd0;
		backup16 <= 16'd0;
		backup17 <= 16'd0;
		backup18 <= 16'd0;
	end
	else if ( sig_ass & (!sumerrKB) ) begin
		re_state <= 6'd1;
		ram0_addr <= 5'd0;
	end
	else if (re_state == 6'd1) begin
		ram0_addr <= ram0_addr + 5'd1;
		Phase_sta <= Phase_sta;
		re_state <= 6'd2;
	end
	else if (re_state == 6'd2) begin
		ram0_addr <= ram0_addr + 5'd1;
		Phase_sta <= ram0_data;
		re_state <= 6'd3;
	end
	else if (re_state == 6'd3) begin
		ram0_addr <= ram0_addr + 5'd1;
		LinkNum_Total <= ram0_data;
		re_state <= 6'd4;
	end
	else if (re_state == 6'd4) begin
		ram0_addr <= ram0_addr + 5'd1;
		F_switch <= ram0_data;
		re_state <= 6'd5;
	end
	else if (re_state == 6'd5) begin
		ram0_addr <= ram0_addr + 5'd1;
		Kp_Udc <= ram0_data;
		re_state <= 6'd6;
	end
	else if (re_state == 6'd6) begin
		ram0_addr <= ram0_addr + 5'd1;
		UdcThirdCtrlLim <= ram0_data;
		re_state <= 6'd7;
	end
	else if (re_state == 6'd7) begin
		ram0_addr <= ram0_addr + 5'd1;
		Redun_pos1 <= ram0_data;
		re_state <= 6'd8;
	end
	else if (re_state == 6'd8) begin
		ram0_addr <= ram0_addr + 5'd1;
		Redun_pos2 <= ram0_data;
		re_state <= 6'd9;
	end
	else if (re_state == 6'd9) begin
		ram0_addr <= ram0_addr + 5'd1;
		Redun_pos3 <= ram0_data;
		re_state <= 6'd10;
	end
	else if (re_state == 6'd10) begin
		ram0_addr <= ram0_addr + 5'd1;
		Redun_pos4 <= ram0_data;
		re_state <= 6'd11;
	end
	else if (re_state == 6'd11) begin
		ram0_addr <= ram0_addr + 5'd1;
		Redun_pos5 <= ram0_data;
		re_state <= 6'd12;
	end
	else if (re_state == 6'd12) begin
		ram0_addr <= ram0_addr + 5'd1;
		Redun_pos6 <= ram0_data;
		re_state <= 6'd13;
	end
	else if (re_state == 6'd13) begin
		ram0_addr <= ram0_addr + 5'd1;
		VCU_Mode <= ram0_data;
		re_state <= 6'd14;
	end
	else if (re_state == 6'd14) begin
		ram0_addr <= ram0_addr + 5'd1;
		para_grp_TFR <= ram0_data;
		re_state <= 6'd15;
	end
	//-----------------------
	else if (re_state == 6'd15) begin
		ram0_addr <= ram0_addr + 5'd1;
		backup1 <= ram0_data;
		re_state <= 6'd16;
	end
	else if (re_state == 6'd16) begin
		ram0_addr <= ram0_addr + 5'd1;
		backup2 <= ram0_data;
		re_state <= 6'd17;
	end
	else if (re_state == 6'd17) begin
		ram0_addr <= ram0_addr + 5'd1;
		backup3 <= ram0_data;
		re_state <= 6'd18;
	end
	else if (re_state == 6'd18) begin
		ram0_addr <= ram0_addr + 5'd1;
		backup4 <= ram0_data;
		re_state <= 6'd19;
	end
	else if (re_state == 6'd19) begin
		ram0_addr <= ram0_addr + 5'd1;
		backup5 <= ram0_data;
		re_state <= 6'd20;
	end
	else if (re_state == 6'd20) begin
		ram0_addr <= ram0_addr + 5'd1;
		backup6 <= ram0_data;
		re_state <= 6'd21;
	end
	else if (re_state == 6'd21) begin
		ram0_addr <= ram0_addr + 5'd1;
		backup7 <= ram0_data;
		re_state <= 6'd22;
	end
	else if (re_state == 6'd22) begin
		ram0_addr <= ram0_addr + 5'd1;
		backup8 <= ram0_data;
		re_state <= 6'd23;
	end
	else if (re_state == 6'd23) begin
		ram0_addr <= ram0_addr + 5'd1;
		backup9 <= ram0_data;
		re_state <= 6'd24;
	end
	else if (re_state == 6'd24) begin
		ram0_addr <= ram0_addr + 5'd1;
		backup10 <= ram0_data;
		re_state <= 6'd25;
	end
	else if (re_state == 6'd25) begin
		ram0_addr <= ram0_addr + 5'd1;
		backup11 <= ram0_data;
		re_state <= 6'd26;
	end
	else if (re_state == 6'd26) begin
		ram0_addr <= ram0_addr + 5'd1;
		backup12 <= ram0_data;
		re_state <= 6'd27;
	end
	else if (re_state == 6'd27) begin
		ram0_addr <= ram0_addr + 5'd1;
		backup13 <= ram0_data;
		re_state <= 6'd28;
	end
	else if (re_state == 6'd28) begin
		ram0_addr <= ram0_addr + 5'd1;
		backup14 <= ram0_data;
		re_state <= 6'd29;
	end
	else if (re_state == 6'd29) begin
		ram0_addr <= ram0_addr + 5'd1;
		backup15 <= ram0_data;
		re_state <= 6'd30;
	end
	else if (re_state == 6'd30) begin
		ram0_addr <= ram0_addr + 5'd1;
		backup16 <= ram0_data;
		re_state <= 6'd31;
	end
	else if (re_state == 6'd31) begin
		ram0_addr <= ram0_addr + 5'd1;
		backup17 <= ram0_data;
		re_state <= 6'd32;
	end
	else if (re_state == 6'd32) begin
		ram0_addr <= ram0_addr + 5'd1;
		backup18 <= ram0_data;
		re_state <= 6'd33;
	end
	else begin
		Phase_sta <= Phase_sta;
		LinkNum_Total <= LinkNum_Total;
		F_switch <= F_switch;
		Kp_Udc <= Kp_Udc;			
		UdcThirdCtrlLim <= UdcThirdCtrlLim;				
		Redun_pos1 <= Redun_pos1;
		Redun_pos2 <= Redun_pos2;
		Redun_pos3 <= Redun_pos3;
		Redun_pos4 <= Redun_pos4;
		Redun_pos5 <= Redun_pos5;
		Redun_pos6 <= Redun_pos6;
		VCU_Mode <= VCU_Mode;
		para_grp_TFR <= para_grp_TFR;
		backup1 <= backup1;//DSP备用数据
		backup2 <= backup2;
		backup3 <= backup3;
		backup4 <= backup4;
		backup5 <= backup5;
		backup6 <= backup6;
		backup7 <= backup7;
		backup8 <= backup8;
		backup9 <= backup9;
		backup10 <= backup10;
		backup11 <= backup11;
		backup12 <= backup12;
		backup13 <= backup13;
		backup14 <= backup14;
		backup15 <= backup15;
		backup16 <= backup16;
		backup17 <= backup17;
		backup18 <= backup18;
		re_state <= 6'd0;
		ram0_addr <= 5'd0;
	end
end
//------------------------------------------------------------------
//wire [35:0] ILAControl;
//wire [79:0] data_chipscp; 
//assign data_chipscp [15:0] = {re_state,sumerrKB,data_addr,ram0_addr};
//assign data_chipscp [31:16] = data_in;
//assign data_chipscp [47:32] = ram_dout;
//assign data_chipscp [63:48] = data_sum;
//assign data_chipscp [79:64] = para_grp_TFR;
//
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
//     .TRIG0              ( sumerrKB), 
//	  .TRIG1              ( sig_ass),
//     .TRIG2              ( data_refesh_delay), 
//	  .TRIG3              ( )
//);
endmodule
