`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:35:51 09/21/2017 
// Design Name: 
// Module Name:    Man_rxP1_KB 
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
module Man_rxP2_KB(
                  input clk,
						input reset_n,
						input rx_d,
	               output reg [15:0] ControlWord,//输出数据为进行完CRC判断的数据，CRC错误则输出上一帧数据
			         output reg [31:0] TargetVol,
			         output reg [15:0] CosThet,						
						output reg [15:0] backup1,//未使用
						output reg [15:0] backup2,
						output reg [15:0] RenewalCnt,
						output [15:0]ComSta,//通信状态
						output rd_int  //接收帧数据完成标志 1us有效高电平，建议下降沿触发中断
);
	parameter DATA_CYC_T				= 9;	  //120M:11;100M:9
//	parameter RX_W_num				= 27;  //FT3协议P1:27 Words	
	parameter RX_W_num				= 9;  //FT3协议P2:9 Words	
//	parameter RX_W_num				= 18;  //FT3协议P2:18 Words	
//   parameter RX_W_num            = 21; //FT3协议P3:21 Words

   parameter FS_DATA1_NUM        = 9;
	parameter FS_DATA2_NUM        = 18;
	parameter FS_DATA3_NUM        = 27;
	
	parameter DATA_CYC_HT      =DATA_CYC_T/2;
	parameter SYNC_HEAD 			=16'h0564;
	parameter FS_LENTH			=RX_W_num*16+1;
	parameter CRC_NUM=8'd128;
	parameter CRC_CODE_NUM=8'd144;
	
	parameter STATE0		=4'b0000;
	parameter STATE1		=4'b0001;
	parameter STATE2		=4'b0010;
	parameter STATE3		=4'b0011;
	parameter STATE4		=4'b0100;
	parameter STATE5		=4'b0101;
	parameter STATE6		=4'b0110;
	parameter STATE7		=4'b0111;
	parameter STATE8		=4'b1000;
	parameter STATE9		=4'b1001;
	parameter STATE10		=4'b1010;
	parameter STATE11		=4'b1011;
	parameter STATE12		=4'b1100;
	parameter STATE13		=4'b1101;
	parameter STATE14		=4'b1110;
	parameter STATE15		=4'b1111;

reg sumerr;
wire crc_err;
reg[2:0] crc_err_reg;
wire [15:0] dataRx_KB;
reg [4:0] addrRx_KB;

reg [5:0] rxd_clk_div;
reg data_reg,rxd_temp,rxd_man;
reg [2:0]Samp_reg;

reg[4:0] data_addr;
reg[15:0] data_in;
reg data_wea;

assign	ComSta = {12'd0,sumerr,O_opt_brk,O_opt_err,crc_err};
//====================================================================  
reg rx_d_reg;
wire rx_din;
always @ (posedge clk)
begin
	 rx_d_reg <= rx_d;
end 
assign rx_din = rx_d_reg|rx_d;
//====================================================================  
//====================================================================  
wire[15:0] Sync_headf;
wire[31:0] SyncHead_man;
assign Sync_headf=SYNC_HEAD;
assign SyncHead_man[31:30]=(Sync_headf[15]==1'b1)? 2'b01:2'b10;
assign SyncHead_man[29:28]=(Sync_headf[14]==1'b1)? 2'b01:2'b10;
assign SyncHead_man[27:26]=(Sync_headf[13]==1'b1)? 2'b01:2'b10;
assign SyncHead_man[25:24]=(Sync_headf[12]==1'b1)? 2'b01:2'b10;
assign SyncHead_man[23:22]=(Sync_headf[11]==1'b1)? 2'b01:2'b10;
assign SyncHead_man[21:20]=(Sync_headf[10]==1'b1)? 2'b01:2'b10;
assign SyncHead_man[19:18]=(Sync_headf[9]== 1'b1)? 2'b01:2'b10;
assign SyncHead_man[17:16]=(Sync_headf[8]== 1'b1)? 2'b01:2'b10;
assign SyncHead_man[15:14]=(Sync_headf[7]== 1'b1)? 2'b01:2'b10;
assign SyncHead_man[13:12]=(Sync_headf[6]== 1'b1)? 2'b01:2'b10;
assign SyncHead_man[11:10]=(Sync_headf[5]== 1'b1)? 2'b01:2'b10;
assign SyncHead_man[9:8]  =(Sync_headf[4]== 1'b1)? 2'b01:2'b10;
assign SyncHead_man[7:6]  =(Sync_headf[3]== 1'b1)? 2'b01:2'b10;
assign SyncHead_man[5:4]  =(Sync_headf[2]== 1'b1)? 2'b01:2'b10;
assign SyncHead_man[3:2]  =(Sync_headf[1]== 1'b1)? 2'b01:2'b10;
assign SyncHead_man[1:0]  =(Sync_headf[0]== 1'b1)? 2'b01:2'b10;

//------------------------------------------------------
//wire rxd_low   = (Samp_reg[2:0] == 3'b000);
//wire rxd_high  = (Samp_reg[2:0] == 3'b111);
wire rxd_low   = (Samp_reg[1:0] == 2'b00);
wire rxd_high  = (Samp_reg[1:0] == 2'b11);
//--------------------------------------------------------
always @ (negedge reset_n or posedge clk)
begin
	if(!reset_n) begin
		rxd_temp <= 1'b1;	
		Samp_reg <= 3'b111;
		data_reg <= 1'b1;	
	end
	else begin
		Samp_reg <= {Samp_reg[1:0],rx_din};
		if(rxd_low) rxd_temp <= 1'b0;	
		else if(rxd_high)  rxd_temp <= 1'b1;
		else rxd_temp <= rxd_temp;
//		rxd_temp <= rx_d;
		data_reg <= rxd_temp;
		
	end
end
//-------------------------------------------------------------------
reg [5:0] rxd_cyc_wt;
reg [5:0] rxd_edge_cyc;
always @ (negedge reset_n or posedge clk)
begin
	if(!reset_n)  begin
			rxd_cyc_wt <= 6'h0;
			rxd_clk_div <= 6'h0;
			rxd_edge_cyc <= 6'h0;
	end
	else begin
			if((data_reg ^ rxd_temp) ||(rxd_cyc_wt >= DATA_CYC_T)) rxd_clk_div <= 6'h0;
			else  rxd_clk_div <= rxd_clk_div + 6'h1;
			
			if(data_reg ^ rxd_temp)begin
				if(rxd_clk_div<(DATA_CYC_HT-1))rxd_cyc_wt <= DATA_CYC_HT;
				else rxd_cyc_wt <= rxd_clk_div+1;
			end 
			else if(rxd_cyc_wt >= DATA_CYC_T )rxd_cyc_wt <= 6'h0;
			else  rxd_cyc_wt <= rxd_cyc_wt + 6'h1;
			
			if(data_reg ^ rxd_temp) rxd_edge_cyc <= 6'h0;
			else if(rxd_edge_cyc>=DATA_CYC_T)rxd_edge_cyc <= DATA_CYC_T+ 6'h1;
			else  rxd_edge_cyc <= rxd_edge_cyc + 6'h1;
			
	end
end

//----------------------------------------------------------
reg man_pulse;
reg[15:0]man_num;
reg fs_start;
reg data_flag;
always @ (negedge reset_n or posedge clk)
begin
	if(reset_n==0)  begin
			man_pulse <= 1'b0;
			man_num<=0;
	end
	else begin
			if((rxd_clk_div==1)&&(rxd_edge_cyc<DATA_CYC_T)) man_pulse <= 1'b1;
			else man_pulse <= 1'b0;
			if(data_flag)man_num<=man_num+1;
			else if(!fs_start) man_num<=0;
			else man_num<=man_num;
			
	end
end
//----------------------------------------------------------
reg[31:0] syn_char;

always @ (negedge reset_n or posedge clk)
begin
	if(!reset_n)  begin
			syn_char <= 32'd0;
	end
	else begin
			if((man_pulse)&&(!fs_start)) syn_char[31:0] <= {syn_char[30:0],data_reg};
			else if(fs_start) syn_char <=32'd0;
			else syn_char <= syn_char;
	end
end
//--------------------------------------------------------------
//assign fs_start=(!reset_n)? 1'b0 : ((man_num==FS_LENTH)? 1'b0 : ((syn_char==SyncHead_man)? 1'b1 : fs_start));
//always @ (reset_n or syn_char or man_num)
always @ (negedge reset_n or posedge clk)
begin
	if(!reset_n)  begin
			fs_start <= 1'b0;
	end
	else begin
			if(man_num==FS_LENTH)  fs_start<= 1'b0;
			else if(syn_char==SyncHead_man) fs_start<= 1'b1;	 
			else fs_start<= fs_start;
	end
end
//-----------------------------------------------------------------
wire dat_pul;
assign dat_pul = fs_start & man_pulse;
//--------------------------------------------------------------
reg[1:0] man_data;
always @ (negedge reset_n or posedge clk)
begin
	if(!reset_n)  man_data <= 2'b00;
	else begin
		if(dat_pul) man_data <= {man_data[0],data_reg};
		else man_data <= man_data;
	end
end
//-------------------------------------------------------------
reg rx_data;
reg man_flag;
reg dat_pre;
always @ (negedge reset_n or posedge clk)
begin
	if(!reset_n) begin
		man_flag <= 1'b0;
		dat_pre<= 1'b0;
		rx_data<= rx_data;
		data_flag<= 1'b0;
	end 
	else begin
		if(dat_pul) man_flag <=1'b1;
		else man_flag <= 1'b0;
		if((man_flag)&&(dat_pre)) begin
			data_flag<= 1'b1;
			if(man_data == 2'b01) rx_data<= 1;
			else if(man_data == 2'b10) rx_data<= 0;
			else rx_data<= rx_data;
		end
		else  begin 
			rx_data<= rx_data;
			data_flag<= 1'b0;
		end
		if(!fs_start) dat_pre<= 1'b0;
		else if(man_flag) dat_pre<= dat_pre+1;
		else  dat_pre<= dat_pre;
	end
end
//-------------------------------------------------------------
reg data_wflag;
reg[15:0] rx_data_w;
always @ (negedge reset_n or posedge clk)
begin
	if(!reset_n)begin
		rx_data_w<=0;
		data_wflag<=0;
	end
	else begin
		if(data_flag)begin
			rx_data_w<={rx_data_w[14:0],rx_data};
			data_wflag<=1;
		 end 
		 else begin
			rx_data_w<=rx_data_w;
			data_wflag<=0;
		 end
	end
end
//-----------------------------------------------------------------
reg[3:0] bit_cnt;
always @ (negedge reset_n or posedge clk)
begin
	if(!reset_n)  begin
		bit_cnt<=0;
		data_wea<=0;
		data_in<=0;				
		data_addr<=0;
	end
	else begin
		if(data_wflag)begin
			bit_cnt<=bit_cnt+1;
			if(bit_cnt==4'b1111) begin	
				data_wea<=1;
				data_in<=rx_data_w;				
				data_addr<=data_addr+1;
		  end 
		  else begin
				data_wea<=0;
				data_in<=data_in;				
				data_addr<=data_addr;
		  end	
		end 
		else if(!fs_start) begin
			bit_cnt<=0;
			data_wea<=0;
			data_in<=data_in;				
			data_addr<=0;
		end
		else begin
			bit_cnt<=bit_cnt;
			data_wea<=0;
			data_in<=data_in;				
			data_addr<=data_addr;
		end
	end
end
//=======================================
reg[7:0] crc_num;
reg[15:0] CRC_out;
wire temp;
assign  temp = rx_data ^ CRC_out[15]; 
always @ (posedge clk)
begin
	if(!fs_start) crc_num<=0;
	else if((crc_num>=CRC_CODE_NUM-1)&&(data_flag)) crc_num<=0;
	else if(data_flag) crc_num<=crc_num+1;
	else crc_num<=crc_num;
	if((data_flag)&&(crc_num<CRC_NUM))  begin   //x16+x13+x12+x11+x10+x8+x6+x5+x2+1
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
	else if((!fs_start)||(crc_num>CRC_NUM))begin
		CRC_out<=16'h0000;
	end
	else begin
		CRC_out<=CRC_out;
	end
end   
//----------------------------------------------------------

reg[15:0] crc_buf;
always @ (negedge reset_n or posedge clk)
begin
	if(!reset_n)  begin
		crc_buf<=0;
		crc_err_reg<=3'b000;
	end
	else begin
		if((data_flag)&&(crc_num==CRC_NUM))	crc_buf<=~CRC_out;
		else crc_buf<=crc_buf;
		if((data_wea==1)&&(data_addr==9)) begin
			if(crc_buf==data_in) crc_err_reg[0]<=0;
			else crc_err_reg[0]<=1;
		end
		if((data_wea==1)&&(data_addr==18)) begin
			if(crc_buf==data_in) crc_err_reg[1]<=0;
			else crc_err_reg[1]<=1;
		end
		if((data_wea==1)&&(data_addr==27)) begin
			if(crc_buf==data_in) crc_err_reg[2]<=0;
			else crc_err_reg[2]<=1;
		end
	end
end  
assign crc_err= crc_err_reg[0] ;//| crc_err_reg[1] | crc_err_reg[2];
//===========================================================
reg[15:0] fs_cnt;
reg fs_start_old;
reg finish_man;
always @ (negedge reset_n or posedge clk)
begin
	if(!reset_n)  begin
		fs_start_old<=0;
		finish_man<=0;
	end
	else begin
		fs_start_old<=fs_start;
		if((fs_start_old)&&(!fs_start)) begin
			finish_man<=1;
			fs_cnt<=fs_cnt+1;
		end
		else begin
			finish_man<=0;
			fs_cnt<=fs_cnt;
		end 
	end
end
//===========================================================
reg[4:0] ram0_addr;
reg ram1_wea;
reg[4:0] ram1_addr;
reg[15:0]ram1_data;
wire[15:0]ram0_data;
reg[3:0]ram_state;
reg [15:0]data_sum;

reg sig_reg,sig_reg_l;
always @ (posedge clk)
begin
	if (!reset_n) begin
		sig_reg <= 1'b0;
	end
	else begin
		if (ram_state == STATE4) sig_reg <= 1'b1;
		else sig_reg <= 1'b0;
	end
end
//**************标准的三段式FT3格式的地址和数据的配合-by gl*****//
always @ (negedge reset_n or posedge clk)//数据比地址要延迟两拍，当addr==3的时候，赋值为data1的数据
begin
	if(!reset_n)  begin
		ram0_addr<=1;//第2个地址为有效数据
		ram1_wea<=0;
		ram1_addr<=0;
		ram1_data<=0;
		data_sum<=0;
		sumerr<=0;
	end
	else begin
		case(ram_state)
				STATE0: begin  
					if(finish_man) ram_state<=STATE1;
					else ram_state<=STATE0;
					ram0_addr<=1;
					ram1_wea<=0;
					ram1_addr<=0;
					ram1_data<=0;
					data_sum<=0;
				end
				STATE1: begin  
					ram_state<=STATE2;
					ram0_addr<=ram0_addr+1;// ram0 1->2
					ram1_wea<=1;
					ram1_addr<=0;
					ram1_data<=ram0_data;//ram0 data1
				end
				STATE2:begin 
					ram0_addr<=ram0_addr+1; //ram0 2->3 输出data2
					ram1_wea<=1;
					ram1_addr<=0;
					ram1_data<=ram0_data;//给ram1 data1
					data_sum<=ram0_data;
					ram_state<=STATE3;
				end
				STATE3:begin 
					ram0_addr<=ram0_addr+1;//ram0 addr 3~10 输出CRC
					ram1_wea<=1;
					ram1_addr<=ram1_addr+1; //ram1 addr0~7
					ram1_data<=ram0_data;// 输入ram1 data2~8
					if(ram1_addr<=(FS_DATA1_NUM-4))data_sum<=data_sum + ram0_data;//计算控保下发的数据累加和
					else if(ram1_addr==(FS_DATA1_NUM-3))begin
								  if(data_sum == ~ram0_data)sumerr<=0;
								  else sumerr<=1;
							end
					if(ram1_addr==(FS_DATA1_NUM-2))ram_state<=STATE4;
					else ram_state<=STATE3;
				end
				default:  begin
					ram0_addr<=1;
					ram1_wea<=0;
					ram1_addr<=0;
					ram1_data<=0;
					data_sum<=0;
					ram_state<=STATE0;			
				end
			endcase	  
	end
end
//=======================================================================
reg[7:0] finish_cnt;
always @ (negedge reset_n or posedge clk)
begin
	if(!reset_n)  begin
		finish_cnt<=0;
//		rd_int<=0;
	end
	else begin
		if(finish_man==1) finish_cnt<=1;
		else if((finish_cnt>0)&&(finish_cnt<100)) finish_cnt<=finish_cnt+1;
		else finish_cnt<=0;
//		if(finish_cnt>0)rd_int<=1;
//		else rd_int<=0;
	end
end
assign rd_int =fs_start;
//=====================================================================
reg rd_intold;
reg [4:0] rd_state;

always @ (posedge clk)
begin 
	if(!reset_n) begin
		rd_state<=0;
		rd_intold<=0;
		addrRx_KB <= 5'd0;
		ControlWord <= 16'd0;
		TargetVol <= 32'd0;
      CosThet <= 16'd0;				
		backup1 <= 16'd0;
		backup2 <= 16'd0;
		RenewalCnt <= 16'd0;		
	end
	else begin
//	  rd_intold<=rd_int;
//	  if((~rd_intold)&(rd_int))begin
	  sig_reg_l<=sig_reg;
	  if((~sig_reg_l)&(sig_reg))begin
        if((crc_err==1'b0) && (sumerr==1'b0))begin
			  addrRx_KB <= 1;
			  rd_state<=1;
		  end
		  else rd_state<=0;
	  end 
	  else if(rd_state==1)  begin
		  ControlWord <= dataRx_KB;
		  addrRx_KB <= addrRx_KB + 1;
		  rd_state<=2;
	  end 
	  else if(rd_state==2)  begin
		  TargetVol[15:0] <= dataRx_KB;
		  addrRx_KB <= addrRx_KB + 1;
		  rd_state<=3;
	  end 
	  else if(rd_state==3)  begin
		  TargetVol[31:16] <= dataRx_KB;
		  addrRx_KB <= addrRx_KB + 1;
		  rd_state<=4;
	  end 
	  else if(rd_state==4)  begin
		  CosThet <= dataRx_KB;
		  addrRx_KB <= addrRx_KB + 1;
		  rd_state<=5;
	  end
 	  else if(rd_state==5)  begin
		  backup1 <= dataRx_KB;
		  addrRx_KB <= addrRx_KB + 1;
		  rd_state<=6;
	  end 
 	  else if(rd_state==6)  begin
		  backup2 <= dataRx_KB;
		  addrRx_KB <= addrRx_KB + 1;
		  rd_state<=7;
	  end
  	  else if(rd_state==7)  begin
		  RenewalCnt <= dataRx_KB;
		  addrRx_KB <= addrRx_KB + 1;
		  rd_state<=8;
	  end
//	  else if(rd_state==8)  begin
//		  sumKB <= dataRx_KB;//控保下发校验和
//		  addrRx_KB <= addrRx_KB + 1;
//		  resumKB <= ~resumKB;
//		  rd_state<=9;
//	  end 
	  else begin
			addrRx_KB <= 5'd0;
			ControlWord <= ControlWord;
			TargetVol <= TargetVol;
			CosThet <= CosThet;
			backup1 <= backup1;
			backup2 <= backup2;
			RenewalCnt <= RenewalCnt;
			rd_state<=0;
	  end
	end
end

//=====================================================================
wire[15:0] ram1_data_out;

RAM_32W data_Ram0 (
  .clka(clk), // input clka
  .wea(data_wea), // input [0 : 0] wea
  .addra(data_addr), // input [4 : 0] addra
  .dina(data_in), // input [15 : 0] dina
  .douta(), // output [15 : 0] douta
  
  .clkb(clk), 
  .web(1'b0),
  .addrb(ram0_addr), 
  .dinb(), 
  .doutb(ram0_data) 
);
RAM_32W data_Ram1 ( //28335 read ram
  .clka(clk), 
  .wea(ram1_wea), 
  .addra(ram1_addr), 
  .dina(ram1_data), 
  .douta(), 
  
  .clkb(clk), 
  .web(1'b0), 
  .addrb(addrRx_KB), 
  .dinb(), 
  .doutb(dataRx_KB) 
);

Comm_Check_kb Comm_Check_kb(
    .i_clk_100M(clk), 
    .i_reset_n(reset_n), 
    .i_rx_d(rx_d), 
    .O_opt_brk(O_opt_brk), 
    .O_opt_err(O_opt_err), 
    .fs_start(fs_start)
    );
	 
	 
//-------------------------------------------------------------------
//wire [35:0] ILAControl;
//wire [79:0] data_chipscp; 
//assign data_chipscp [15:0] ={13'd0,crc_err,fs_start,rx_d};
//assign data_chipscp [31:16] = data_in;
//assign data_chipscp [47:32] = {1'b0,ram1_addr,data_addr,ram0_addr};
//assign data_chipscp [63:48] = ram0_data;
//assign data_chipscp [79:64] = data_sum;
//
//new_icon u_icon ( 
//     .CONTROL0            ( ILAControl) 
//); 
//
//
//new_ila u_ila (
//     .CONTROL            ( ILAControl), 
//     .CLK                ( clk), 
//     .DATA               ( data_chipscp), 
//     .TRIG0              ( crc_err), 
//	  .TRIG1              ( fs_start),
//     .TRIG2              ( sumerr), 
//	  .TRIG3              ( )
//);
endmodule



