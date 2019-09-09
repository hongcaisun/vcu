`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:27:51 09/21/2017 
// Design Name: 
// Module Name:    Man_txKB 
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
module Man_TxKB(
   input i_sys_clk,//100M
	input clk_20MHz,    
   input reset_n,
	input FS_sys,
	input [15:0] dsptoKB0,
	input [15:0] dsptoKB1,
	input [15:0] dsptoKB2,
	input [15:0] dsptoKB3,
	input [15:0] dsptoKB4,
	input [15:0] dsptoKB5,
	input [15:0] dsptoKB6,
	input [15:0] dsptoKB7,
	output reg  man_tx

    );
	//=============================================================
	parameter FS_WORD1_NUM = 9;
	parameter FS_WORD2_NUM = 18;
	parameter FS_WORD3_NUM = 27;
//	parameter FS_SUM_BIT=13'd448;//P1协议长度 帧头 + 数据*8*3 + 3*CRC = 28字
	parameter FS_SUM_BIT=13'd160;//P2协议长度 帧头 + 数据*8 + CRC = 10字 
	parameter CRC_NUM=8'd144;
	
	
	parameter CRC1_START_BIT=9*16;
	parameter CRC1_STOP_BIT=CRC1_START_BIT+16;
	parameter CRC2_START_BIT=18*16;
	parameter CRC2_STOP_BIT=CRC2_START_BIT+16;
	parameter CRC3_START_BIT=27*16;
	parameter CRC3_STOP_BIT=CRC3_START_BIT+16;
	//=============================================================

	reg clk_10MHz;
	reg[12:0] fs_cnt;
	reg tx_en_flag;
	reg[2:0] fs_buf;
	reg[7:0] tx_num;
	reg[4:0]data_word_num;
	reg data_tx;
	reg[15:0] buf_word;
	reg[15:0] CRC_out;
	reg[15:0] crc_word;
	reg tx_en;
	reg[1:0] man_data;
	reg man_cnt;
	reg[15:0] state1_word;
	reg[15:0] state2_word;
	reg[15:0] fs_Counter;
	reg[3:0]temp_num;
	wire temp;
	reg [15:0] resum;
	//----------------------------------------------
	
	always @(posedge clk_20MHz)
	begin
		clk_10MHz<=~clk_10MHz;
	end
	always @(posedge clk_10MHz)
	begin
		fs_buf[2:0]<={fs_buf[1:0],FS_sys};
	end
	//------------------------------------------------
	always @(posedge clk_10MHz) begin
		if(fs_buf[2:0]==3'b011)  fs_Counter<=fs_Counter+1;
		else  fs_Counter<=fs_Counter;
	end
	reg word_flash;
	always @(posedge clk_10MHz) begin
		if(fs_buf[2:0]==3'b011)  tx_en_flag<=1;
		else if(fs_cnt>=FS_SUM_BIT-1)tx_en_flag<=0;
		else tx_en_flag<=tx_en_flag;
		word_flash<=tx_en_flag;
	end
	
	always @(posedge clk_10MHz) begin
		if(tx_en_flag==1'b1)  fs_cnt<=fs_cnt+1;
		else fs_cnt<=1'b0;
	end

	reg crc_en;
	always @(negedge clk_10MHz)
	begin
			if((fs_cnt>=CRC1_START_BIT)&&(fs_cnt<CRC1_STOP_BIT)) crc_en <= 1;
			else if((fs_cnt>=CRC2_START_BIT)&&(fs_cnt<CRC2_STOP_BIT)) crc_en <= 1;
			else if((fs_cnt>=CRC3_START_BIT)&&(fs_cnt<CRC3_STOP_BIT)) crc_en <= 1;
			else  crc_en <= 0;
	end
//============================================================================
always @(negedge clk_10MHz) begin
   if(!reset_n)begin
			data_word_num<=5'd0;
			temp_num<=0;
			buf_word<=16'h0564;//16'h0564;
			resum<=16'd0;
	end
	else if(fs_buf[2:0]==3'b011)  begin
			data_word_num<=5'd0;
			temp_num<=0;
			buf_word<=16'h0564;//16'h0564;
			resum<=16'd0;
	end
	else begin
		if(word_flash)begin
			temp_num<=temp_num+1;
			if(temp_num==4'b1111) begin
					data_word_num<=data_word_num+1;
//					if(data_word_num < (FS_WORD1_NUM-2))begin
//					   ram0_addr <= ram0_addr + 5'd1;
//						buf_word  <= ram0_data;
//						sum_data  <= sum_data + ram0_data;
//					end
//					else if(data_word_num == (FS_WORD1_NUM-2))begin
//					   ram0_addr <= ram0_addr + 5'd1;
//						buf_word  <= ram0_data;
//						if(ram0_data == ~sum_data)sum_err1<=1'b0;
//						else sum_err1 <= 1'b1;
//					end
					case(data_word_num)
						5'd0 : begin
							buf_word<=dsptoKB0;
							resum <= dsptoKB0;
							end
						5'd1 : begin
							buf_word<=dsptoKB1;
							resum <= resum+dsptoKB1;
							end
						5'd2 : begin
							buf_word<=dsptoKB2;
							resum <= resum+dsptoKB2;
							end
						5'd3 : begin
							buf_word<=dsptoKB3;
							resum <= resum+dsptoKB3;
							end
						5'd4 : begin
							buf_word<=dsptoKB4;
							resum <= resum+dsptoKB4;
							end
						5'd5 : begin
							buf_word<=dsptoKB5;
							resum <= resum+dsptoKB5;
							end
						5'd6 : begin
							buf_word<=fs_Counter;
						   resum <= resum+fs_Counter;
							end
						5'd7 : begin
							buf_word <= ~resum;//FPGA计算累加和
							resum <= resum;
							end						
						default : buf_word<=buf_word;
					endcase
			end
			else begin 
				data_word_num<=data_word_num;
				buf_word<=buf_word;
			end
		end
		else begin
			data_word_num<=5'd0;
			temp_num<=0;
			buf_word<=16'h0564;
		end
	end
end
//------------------------------------------------

always @(posedge clk_10MHz) begin
	if(tx_en_flag) begin
		if(crc_en)data_tx<=crc_word[15-temp_num];
		else data_tx<=buf_word[15-temp_num];
		if(tx_num>=CRC_NUM)tx_num<=1;
		else tx_num<=tx_num+1;
	end
	else begin
		data_tx<=1;
		tx_num<=0;
	end
end
//=======================================
assign  temp = data_tx ^ CRC_out[15]; 
always @ (negedge clk_10MHz)
begin
	if((tx_num>8'd16) && (tx_num<=CRC_NUM)) begin   //x16+x13+x12+x11+x10+x8+x6+x5+x2+1
		CRC_out[15] <= CRC_out[14];
		CRC_out[14] <= CRC_out[13];
		CRC_out[13] <= temp ^ CRC_out[12];
		CRC_out[12] <= temp ^ CRC_out[11];
		CRC_out[11] <= temp ^ CRC_out[10];
		CRC_out[10] <= temp ^ CRC_out[9];
		CRC_out[9] <= CRC_out[8];
		CRC_out[8] <= temp ^ CRC_out[7];
		CRC_out[7] <= CRC_out[6];
		CRC_out[6] <= temp ^ CRC_out[5];
		CRC_out[5] <= temp ^ CRC_out[4];
		CRC_out[4] <= CRC_out[3];
		CRC_out[3] <= CRC_out[2];
		CRC_out[2] <= temp ^ CRC_out[1];
		CRC_out[1] <= CRC_out[0];
		CRC_out[0] <= temp;
	  end
	else CRC_out<=16'h0000;
end   
//----------------------------------------------------------
always @ (CRC_out)
begin
	if(tx_num==CRC_NUM)  crc_word <= ~CRC_out;
	else crc_word <= crc_word;	
end   
//=====================================================
always @(negedge clk_10MHz) begin
	if(data_tx) man_data[1:0]<=2'b01;
	else man_data[1:0]<=2'b10;
	tx_en<=1;
end
//=====================================================
//发送10M
always @ (posedge clk_20MHz)
begin
		if(clk_10MHz) man_cnt<=1;
		else man_cnt<=0;
end
always @ (negedge clk_20MHz)
begin
		if(man_cnt)man_tx<= man_data[1];
		else man_tx<= man_data[0];
end
//=====================================================

//wire [35:0] ILAControl;
//wire [79:0] data_chipscp; 
//assign data_chipscp[15:0] = {3'd0,data0_wea,man_tx,sum_err1,iv_xa_H,iv_xa_L,i_xwe_n,i_xzcs7_n};
//assign data_chipscp[31:16] = data0_in;
//assign data_chipscp [47:32] = ram0_data;
//assign data_chipscp [63:48] = {1'b0,ram0_addr,data_word_num};
//
//
//icon SVG_icon ( 
//     .CONTROL0            ( ILAControl) 
//); 
//
//u_ila SVG_ila ( 
//     .CONTROL            ( ILAControl), 
//     .CLK                ( i_sys_clk), 
//     .DATA               ( data_chipscp), 
//     .TRIG0              ( data0_wea), 
//	  .TRIG1              ( word_flash),
//     .TRIG2              ( sum_err1), 
//	  .TRIG3              ( sum_err1)	  
//);
endmodule
