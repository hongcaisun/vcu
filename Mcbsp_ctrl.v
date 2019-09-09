`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:23:18 03/18/2019 
// Design Name: 
// Module Name:    Mcbsp_ctrl 
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
module Mcbsp_ctrl(
						input i_clk,
						input i_clk_mcbsp,
						input i_reset_n,
						input i_Mcbsp_tx_st,//MCBSP发送启动信号
						input [15:0]i_ControlWord,//主系统控制命令字
						input [15:0]i_PhaseSta,//最终给控保的相状态字
						input [15:0]i_PhaseA_Udc,//相平均直流电压		
						input [15:0]i_PhaseB_Udc,		
						input [15:0]i_PhaseC_Udc,
						input [15:0]i_TargetVolA,//相平均调制电压	
						input [15:0]i_TargetVolB,
						input [15:0]i_TargetVolC,
						
						output reg [4:0]ram_addr_udca,
						output reg [4:0]ram_addr_udcb,
						output reg [4:0]ram_addr_udcc,

						input [15:0]ram_data_udca,
						input [15:0]ram_data_udcb,
						input [15:0]ram_data_udcc,
						
						input [383:0]i_CtrlVolA_BUS,
						input [383:0]i_CtrlVolB_BUS,
						input [383:0]i_CtrlVolC_BUS,
						
						input [15:0]i_VCU_Mode,//阀控机箱类型 3相合一/单相
						input [15:0]i_para_grp_TFR,//录波组参数
						input [15:0]backup1,//DSP备用数据
						input [15:0]backup2,
						input [15:0]backup3,
						input [15:0]backup4,
						input [15:0]backup5,
						input [15:0]backup6,
						input [15:0]backup7,
						input [15:0]backup8,
						input [15:0]backup9,
						input [15:0]backup10,
						input [15:0]backup11,
						input [15:0]backup12,
						input [15:0]backup13,
						input [15:0]backup14,
						input [15:0]backup15,
						input [15:0]backup16,
						input [15:0]backup17,
						input [15:0]backup18,

						output reg o_McDXA,//mcbsp帧同步、时钟、数据
						output reg o_McFSXA,
						output reg o_McCLKXA,
						input [863:0]linksta_bus
);
	 
parameter MCBSP_TX_NUM = 8'd122,//mcbsp发送的个数,个数参数要协议的MCBSP数据加1.因为要延后一个字发送，需要加1个字的时间才能发送完。
			NUM_VDC_MOD = 5'd18,
			NUM_TZB = 6'd54;
parameter   STATE0 = 5'd0,
				STATE1 = 5'd1,
				STATE2 = 5'd2,
				STATE3 = 5'd3,
				STATE4 = 5'd4,
				STATE5 = 5'd5,
				STATE6 = 5'd6,
				STATE7 = 5'd7,
				STATE8 = 5'd8,
				STATE9 = 5'd9,
				STATE10 = 5'd10,
				STATE11 = 5'd11,
				STATE12 = 5'd12,
				STATE13 = 5'd13,
				STATE14 = 5'd14,
				STATE15 = 5'd15,
				STATE16 = 5'd16,
				STATE17 = 5'd17,
				STATE18 = 5'd18,
				STATE19 = 5'd19,
				STATE20 = 5'd20,
				STATE21 = 5'd21,
				STATE22 = 5'd22,
				STATE23 = 5'd23,
				STATE24 = 5'd24,
				STATE25 = 5'd25,
				STATE26 = 5'd26,
				STATE27 = 5'd27,
				STATE28 = 5'd28;

wire [15:0]CtrlV [54:1];
wire [15:0]linksta [54:1];
reg [11:0]cnt_spi;//spi计数器
reg [2:0]Mcbsp_tx_st_reg;//mcbsp发送使能信号拍3拍
reg sig_to_ram1,sig_to_ram2,sig_ctrlv;//搬RAM使能信号
assign {linksta[54],linksta[53],linksta[52],linksta[51],linksta[50],linksta[49],linksta[48],linksta[47],linksta[46],linksta[45],linksta[44],
							 linksta[43],linksta[42],linksta[41],linksta[40],linksta[39],linksta[38],linksta[37],linksta[36],linksta[35],linksta[34],
							 linksta[33],linksta[32],linksta[31],linksta[30],linksta[29],linksta[28],linksta[27],linksta[26],linksta[25],linksta[24],
							 linksta[23],linksta[22],linksta[21],linksta[20],linksta[19],linksta[18],linksta[17],linksta[16],linksta[15],linksta[14],
							 linksta[13],linksta[12],linksta[11],linksta[10],linksta[9],linksta[8],linksta[7],linksta[6],linksta[5],linksta[4],
							 linksta[3],linksta[2],linksta[1]} = linksta_bus;
assign {CtrlV[1],CtrlV[2],CtrlV[3],CtrlV[4],CtrlV[5],CtrlV[6],CtrlV[7],CtrlV[8],CtrlV[9],
			CtrlV[10],CtrlV[11],CtrlV[12],CtrlV[13],CtrlV[14],CtrlV[15],CtrlV[16],CtrlV[17],CtrlV[18]} = i_CtrlVolA_BUS[383:96];
assign {CtrlV[19],CtrlV[20],CtrlV[21],CtrlV[22],CtrlV[23],CtrlV[24],CtrlV[25],CtrlV[26],CtrlV[27],
			CtrlV[28],CtrlV[29],CtrlV[30],CtrlV[31],CtrlV[32],CtrlV[33],CtrlV[34],CtrlV[35],CtrlV[36]} = i_CtrlVolB_BUS[383:96];
//assign {CtrlV[37],CtrlV[38],CtrlV[39],CtrlV[40],CtrlV[41],CtrlV[42],CtrlV[43],CtrlV[44],CtrlV[45],
//			CtrlV[46],CtrlV[47],CtrlV[48],CtrlV[49],CtrlV[50],CtrlV[51],CtrlV[52],CtrlV[53],CtrlV[54]} = i_CtrlVolC_BUS[383:96];
assign {CtrlV[37],CtrlV[38],CtrlV[39],CtrlV[40],CtrlV[41],CtrlV[42],CtrlV[43],CtrlV[44],CtrlV[45],
			CtrlV[46],CtrlV[47],CtrlV[48],CtrlV[49],CtrlV[50],CtrlV[51],CtrlV[52],CtrlV[53],CtrlV[54]} = {i_CtrlVolC_BUS[383:224],backup1,backup2,backup3,backup4,backup5,backup6,backup7,backup8};

//--------------------------15M时钟与mcbsp发送使能同步并产生帧同步信号------------------------------
always @ (posedge i_clk_mcbsp or negedge i_reset_n)
begin
	if (!i_reset_n) begin
		Mcbsp_tx_st_reg <= 3'd0;
		o_McFSXA <= 1'b0;
		sig_to_ram1 <= 1'b0;
		sig_to_ram2 <= 1'b0;
		sig_ctrlv <= 1'b0;
		cnt_spi <= 12'd0;
	end
	else begin
		Mcbsp_tx_st_reg <= {Mcbsp_tx_st_reg[1:0],i_Mcbsp_tx_st};
		if ( Mcbsp_tx_st_reg[2:1] == 2'b01 )
			cnt_spi <= 12'd2344;
		else begin
			if ((cnt_spi >= 12'd1790)&&(cnt_spi <= 12'd1800)) begin
				o_McFSXA <= 1'b1;
				cnt_spi <= cnt_spi - 12'd1;
			end
			else if ((cnt_spi >= 12'd1890)&&(cnt_spi <= 12'd1900)) begin
				sig_to_ram2 <= 1'b1;
				cnt_spi <= cnt_spi - 12'd1;
			end
			else if ((cnt_spi >= 12'd2090)&&(cnt_spi <= 12'd2100)) begin
				sig_to_ram1 <= 1'b1;
				cnt_spi <= cnt_spi - 12'd1;
			end
			else if ((cnt_spi >= 12'd2190)&&(cnt_spi <= 12'd2200)) begin
				sig_ctrlv <= 1'b1;
				cnt_spi <= cnt_spi - 12'd1;
			end
			else if (cnt_spi == 12'd1) begin
				o_McFSXA <= 1'b0;
				sig_to_ram1 <= 1'b0;
				sig_to_ram2 <= 1'b0;
				sig_ctrlv <= 1'b0;
				cnt_spi <= 12'd2344;
			end
			else begin
				o_McFSXA <= 1'b0;
				sig_to_ram1 <= 1'b0;
				sig_to_ram2 <= 1'b0;
				sig_ctrlv <= 1'b0;
				cnt_spi <= cnt_spi - 12'd1;
			end
		end
	end
end
//--------------------------------------------------------
reg [1:0]sig_to_ram2_reg;
reg sig_to_ram2_up;
always @ (posedge i_clk or negedge i_reset_n)
begin
	if ( !i_reset_n ) begin
		sig_to_ram2_reg <= 2'b00;
		sig_to_ram2_up <= 1'b0;
	end
	else begin
		sig_to_ram2_reg <= {sig_to_ram2_reg[0],sig_to_ram2};
		if ( sig_to_ram2_reg == 2'b01 )
			sig_to_ram2_up <= 1'b1;
		else
			sig_to_ram2_up <= 1'b0;
	end
end
//--------------------------------------------------------
reg [1:0]fpag_xw_sta,sig_to_ram1_reg;
reg [7:0]ram_sta_addr;
always @ (posedge i_clk or negedge i_reset_n)
begin
	if(!i_reset_n)begin
		fpag_xw_sta<=2'b00;
		sig_to_ram1_reg <= 2'b00;
	end 
	else begin
		sig_to_ram1_reg <= {sig_to_ram1_reg[0],sig_to_ram1};
	end
end
//--------------------------------------------------------
reg ram_sta_we;
reg [15:0]chck_sum,updata_cnt;
reg [15:0]ram_sta_din;
reg [4:0]state;
reg [15:0]sum;
always @ (posedge i_clk)
begin
	if (!i_reset_n) begin
		ram_sta_we <= 1'b0;
		ram_sta_addr <= 8'd0;
		ram_addr_udca <= 5'd0;
		ram_addr_udcb <= 5'd0;
		ram_addr_udcc <= 5'd0;
		ram1_add_o <= 6'd0;
		updata_cnt <= 16'd0;
		sum <= 16'd0;
	end
	else begin
		case (state)
			STATE0: begin
				if (sig_to_ram1_reg==2'b01) begin
					state <= STATE1;
					updata_cnt <= updata_cnt + 16'd1;
					ram_sta_addr <= 8'hff;
				end
				else begin
					state <= STATE0;
					ram_sta_we <= 1'b0;
					ram_sta_addr <= 8'd0;
					ram_addr_udca <= 5'd0;
					ram_addr_udcb <= 5'd0;
					ram_addr_udcc <= 5'd0;
					ram1_add_o <= 6'd0;
				end
			end
			STATE1: begin
				state <= STATE2;
				ram_sta_we <= 1'b1;
				ram_sta_addr <= ram_sta_addr + 8'h1;
				ram_sta_din <= 16'h8000;
			end
			STATE2: begin
				state <= STATE3;
				ram_sta_we <= 1'b1;
				ram_sta_addr <= ram_sta_addr + 8'h1;
				ram_sta_din <= 16'h7fff;
			end
			STATE3: begin
				state <= STATE4;
				ram_sta_we <= 1'b1;
				ram_sta_addr <= ram_sta_addr + 8'h1;
				ram_sta_din <= updata_cnt;
				sum <= updata_cnt;
			end
			STATE4: begin
				state <= STATE5;
				ram_sta_we <= 1'b1;
				ram_sta_addr <= ram_sta_addr + 8'h1;
				ram_sta_din <= i_ControlWord;//控制字
				sum <= sum + i_ControlWord;
			end
			STATE5: begin
				state <= STATE6;
				ram_sta_we <= 1'b1;
				ram_sta_addr <= ram_sta_addr + 8'h1;
				ram_sta_din <= i_TargetVolA;//相调制电压
				sum <= sum + i_TargetVolA;
			end
			STATE6: begin
				state <= STATE7;
				ram_sta_we <= 1'b1;
				ram_sta_addr <= ram_sta_addr + 8'h1;
				ram_sta_din <= i_TargetVolB;//相调制电压
				sum <= sum + i_TargetVolB;
			end
			STATE7: begin
				state <= STATE8;
				ram_sta_we <= 1'b1;
				ram_sta_addr <= ram_sta_addr + 8'h1;
				ram_sta_din <= i_TargetVolC;//相调制电压
				sum <= sum + i_TargetVolC;
			end
			STATE8: begin
				state <= STATE9;
				ram_sta_we <= 1'b1;
				ram_sta_addr <= ram_sta_addr + 8'h1;
				ram_sta_din <= i_PhaseSta;//相状态字
				sum <= sum + i_PhaseSta;
			end
			STATE9: begin
				state <= STATE10;
				ram_sta_we <= 1'b1;
				ram_sta_addr <= ram_sta_addr + 8'h1;
				ram_sta_din <= i_para_grp_TFR;//录波组参数
				sum <= sum + i_para_grp_TFR;
			end
			STATE10: begin
				state <= STATE11;
				ram_sta_we <= 1'b1;
				ram_sta_addr <= ram_sta_addr + 8'h1;
				ram_sta_din <= i_PhaseA_Udc;//相平均直流电压
				sum <= sum + i_PhaseA_Udc;
			end
			STATE11: begin
				state <= STATE12;
				ram_sta_we <= 1'b1;
				ram_sta_addr <= ram_sta_addr + 8'h1;
				ram_sta_din <= i_PhaseB_Udc;//相平均直流电压
				sum <= sum + i_PhaseB_Udc;
			end
			STATE12: begin
				state <= STATE13;
				ram_sta_we <= 1'b1;
				ram_sta_addr <= ram_sta_addr + 8'h1;
				ram_sta_din <= i_PhaseC_Udc;//相平均直流电压
				sum <= sum + i_PhaseC_Udc;
				ram_addr_udca <= 5'd1;
			end
			STATE13: begin
				state <= STATE14;
				ram_addr_udca <= ram_addr_udca + 5'd1;
				ram_sta_addr <= ram_sta_addr;
			end
			STATE14: begin
				state <= STATE15;
				ram_addr_udca <= ram_addr_udca + 5'd1;
				ram_sta_addr <= ram_sta_addr;
			end
			STATE15: begin
				ram_sta_we <= 1'b1;
				ram_sta_addr <= ram_sta_addr + 8'h1;
				ram_addr_udca <= ram_addr_udca + 5'd1;
				ram_sta_din <= ram_data_udca;
				sum <= sum + ram_data_udca;
				if ( ram_addr_udca == (NUM_VDC_MOD+5'd2)) begin
					state <= STATE16;
					ram_addr_udcb <= 5'd1;
				end
				else state <= STATE15;
			end
			STATE16: begin
				state <= STATE17;
				ram_addr_udcb <= ram_addr_udcb + 5'd1;
				ram_sta_addr <= ram_sta_addr;
			end
			STATE17: begin
				state <= STATE18;
				ram_addr_udcb <= ram_addr_udcb + 5'd1;
				ram_sta_addr <= ram_sta_addr;
			end
			STATE18: begin
				ram_sta_we <= 1'b1;
				ram_sta_addr <= ram_sta_addr + 8'h1;
				ram_addr_udcb <= ram_addr_udcb + 5'd1;
				ram_sta_din <= ram_data_udcb;
				sum <= sum + ram_data_udcb;
				if ( ram_addr_udcb == (NUM_VDC_MOD+5'd2)) begin
					state <= STATE19;
					ram_addr_udcc <= 5'd1;
				end
				else state <= STATE18;
			end
			STATE19: begin
				state <= STATE20;
				ram_addr_udcc <= ram_addr_udcc + 5'd1;
				ram_sta_addr <= ram_sta_addr;
			end
			STATE20: begin
				state <= STATE21;
				ram_addr_udcc <= ram_addr_udcc + 5'd1;
				ram_sta_addr <= ram_sta_addr;
			end
			STATE21: begin
				ram_sta_we <= 1'b1;
				ram_sta_addr <= ram_sta_addr + 8'h1;
				ram_addr_udcc <= ram_addr_udcc + 5'd1;
				ram_sta_din <= ram_data_udcc;
				sum <= sum + ram_data_udcc;
				if ( ram_addr_udcc == (NUM_VDC_MOD+5'd2)) begin
					state <= STATE22;
					ram1_add_o <= 6'd1;
				end
				else state <= STATE21;
			end
			STATE22: begin
				state <= STATE23;
				ram_sta_addr <= ram_sta_addr;
				ram1_add_o <= ram1_add_o + 6'd1;
			end
			STATE23: begin
				state <= STATE24;
				ram_sta_addr <= ram_sta_addr;
				ram1_add_o <= ram1_add_o + 6'd1;
			end
			STATE24: begin
				ram_sta_we <= 1'b1;
				ram_sta_addr <= ram_sta_addr + 8'h1;
				ram1_add_o <= ram1_add_o + 6'd1;
				ram_sta_din <= ram1_dat_o;
				sum <= sum + ram1_dat_o;
				if ( ram1_add_o == (NUM_TZB+6'd2)) begin
					state <= STATE25;
				end
				else state <= STATE24;
			end
			STATE25: begin
				ram_sta_we <= 1'b1;
				ram_sta_addr <= ram_sta_addr + 8'h1;
				ram_sta_din <= ~sum;
				state <= STATE26;
			end
			default: begin
				state <= STATE0;
				ram_sta_we <= 1'b0;
				ram_sta_addr <= 8'd0;
				ram_addr_udca <= 5'd0;
				ram_addr_udcb <= 5'd0;
				ram_addr_udcc <= 5'd0;
				ram1_add_o <= 6'd0;
			end
		endcase
	end
end
//------------------------------
reg wea1;
reg [15:0]ram1_dat_i;
wire [15:0]ram1_dat_o;
reg [5:0]ram1_add_i,ram1_add_o;
reg [1:0]sig_ctrlv_reg;
reg [4:0]state1;
RAW_64W ram1(
	.clka(i_clk), // input clka
	.wea(wea1), // input [0 : 0] wea
	.addra(ram1_add_i), // input [5 : 0] addra
	.dina(ram1_dat_i), // input [15 : 0] dina
	.douta(), // output [15 : 0] douta

	.clkb(i_clk), // input clkb
	.web(1'b0), // input [0 : 0] web
	.addrb(ram1_add_o), // input [5 : 0] addrb 
	.dinb(), // input [15 : 0] dinb
	.doutb(ram1_dat_o) 
);

always @ ( posedge i_clk or negedge i_reset_n )
begin
	if (!i_reset_n) begin
		sig_ctrlv_reg <= 2'b00;
		ram1_add_i <= 6'd0;
		ram1_dat_i <= 16'd0;
		wea1 <= 1'b0;
	end
	else begin
		sig_ctrlv_reg <= { sig_ctrlv_reg[0] , sig_ctrlv };
		case ( state1 )
			STATE0: begin
				if ( sig_ctrlv_reg == 2'b01 ) begin
					state1 <= STATE1;
					ram1_add_i <= 6'd1;
				end
				else begin
					state1 <= STATE0;
					ram1_add_i <= 6'd0;
					ram1_dat_i <= 16'd0;
					wea1 <= 1'b0;
				end
			end
			STATE1: begin
				wea1 <= 1'b1;
				ram1_add_i <= ram1_add_i + 6'd1;
				if (i_para_grp_TFR == 16'h0001) ram1_dat_i <= CtrlV[ram1_add_i];
				else if (i_para_grp_TFR == 16'h0002) ram1_dat_i <= linksta[ram1_add_i];
				else ram1_dat_i <= linksta[ram1_add_i];
				if ( ram1_add_i == NUM_TZB ) state1 <= STATE2;
				else state1 <= STATE1;
			end
			default: begin
				state1 <= STATE0;
				ram1_add_i <= 6'd0;
				ram1_dat_i <= 16'd0;
				wea1 <= 1'b0;
			end
		endcase
	end
end
//--------------------------------------------------------
reg [4:0]ram_state;
reg [7:0]rd_addr;
wire[15:0]out_ram;
reg wea1_reg;
reg [7:0]ram1_addr,rd_ram1_addr;
reg[15:0]ram1_data;
wire[15:0]out_ram1_data;
always @ (posedge i_clk or negedge i_reset_n)
begin
	if(!i_reset_n)  begin
		rd_addr<=8'd0;//第1个地址为有效数据
		wea1_reg<=1'b0;
		ram1_addr<=8'd0;
		ram1_data<=16'd0;
	end
	else begin
		case(ram_state)
			STATE0: begin
				if(sig_to_ram2_up) ram_state<=STATE1;
				else ram_state<=STATE0;
				rd_addr<=0;
				wea1_reg<=0;
				ram1_addr<=0;
				ram1_data<=0;
			end
			STATE1:begin 
				rd_addr<=rd_addr+1;
				wea1_reg<=1;
				ram1_addr<=0;
				ram1_data<=out_ram;
				ram_state<=STATE2;
			end
			STATE2:begin 
				rd_addr<=rd_addr+1;
				wea1_reg<=1;
				ram1_addr<=ram1_addr+1;
				ram1_data<=out_ram;
				if(ram1_addr ==( MCBSP_TX_NUM-8'd2))ram_state<=STATE0;
				else ram_state<=STATE2;
			end
			default:  begin
				rd_addr<=0;
				wea1_reg<=0;
				ram1_addr<=0;
				ram1_data<=0;
				ram_state<=STATE0;				
			end
		endcase	  
	end
end
RAM_256W RAM_256W (
  .clka(i_clk), // input clka
  .wea(ram_sta_we), // input [0 : 0] wea
  .addra(ram_sta_addr), // input [5 : 0] addra
  .dina(ram_sta_din), // input [15 : 0] dina
  .douta(), // output [15 : 0] douta
  
  .clkb(i_clk), // input clkb
  .web(1'b0), // input [0 : 0] web
  .addrb(rd_addr), // input [5 : 0] addrb 
  .dinb(), // input [15 : 0] dinb
  .doutb(out_ram) // output [15 : 0] doutb
);
RAM_256W RAM_256W_finish (
  .clka(i_clk), // input clka
  .wea(wea1_reg), // input [0 : 0] wea
  .addra(ram1_addr), // input [5 : 0] addra
  .dina(ram1_data), // input [15 : 0] dina
  .douta(), // output [15 : 0] douta
  
  .clkb(i_clk), // input clkb
  .web(1'b0), // input [0 : 0] web
  .addrb(rd_ram1_addr), // input [5 : 0] addrb 
  .dinb(), // input [15 : 0] dinb
  .doutb(out_ram1_data) // output [15 : 0] doutb
);
//----------------------------------------------------------
reg SPI_CLK;
always @ (posedge i_clk or negedge i_reset_n)//把输出的时钟延后两个时钟，因为实测，如果用FPGA去收MCBSP数据的话，会有帧头错误，因为数据比时钟要靠后
begin
    if ( !i_reset_n ) begin
	 	 SPI_CLK <= 1'b0;
		 o_McCLKXA <= 1'b0;
	 end
	 else  begin
		 SPI_CLK <= i_clk_mcbsp;
		 o_McCLKXA <= SPI_CLK;
	 end
end
//-----------------------------------------------------------
reg [15:0]mcbsp_xd;
reg [3:0]temp_num;
reg [2:0]send_state;
always @ (posedge o_McCLKXA or negedge i_reset_n)
begin
	if(!i_reset_n)begin 
		mcbsp_xd<=16'h8000;
		rd_ram1_addr<=2;//第一个数是8000，因为在发送程序中，8000在开始未取数前就被发送了，所以从地址2，数据7FFF开始取数。
		send_state<=3'd0;
		temp_num<=0;
		o_McDXA<=1;
	end
	else begin
		case(send_state)
		3'd0:begin
			if(o_McFSXA==1'b1)begin
				send_state<=3'd1;
				rd_ram1_addr<=2;
				mcbsp_xd<=16'h8000;
				temp_num<=0;
				o_McDXA<=1;
			end
			else begin
				send_state<=3'd0;
				rd_ram1_addr<=2;
				mcbsp_xd<=16'h8000;
				temp_num<=0;
				o_McDXA<=1;
			end
		end
		3'd1:begin
			if(rd_ram1_addr<=MCBSP_TX_NUM)begin
				temp_num<=temp_num+1;
				if(temp_num==4'b1111)begin
					rd_ram1_addr<=rd_ram1_addr+1;
					mcbsp_xd<=out_ram1_data;
				end
				o_McDXA<=mcbsp_xd[15-temp_num];
			end
			else begin
				send_state<=3'd2;
				rd_ram1_addr<=2;
				o_McDXA<=1;
				temp_num<=4'd0;
				mcbsp_xd<=0;
			end
		end
		default:begin
			send_state<=3'd0;
			rd_ram1_addr<=2;
			o_McDXA<=1;
			temp_num<=4'd0;
			mcbsp_xd<=0;
		end
		endcase
	end
end
//--------------------------------------------------------------
//assign ww = (sig_to_ram1_reg==2'b01)? 1'b1:1'b0;
//assign ww1 = (sig_to_ram2_reg==2'b01)? 1'b1:1'b0;
//
//wire [35:0] ILAControl;
//wire [79:0] data_chipscp; 
//assign data_chipscp [15:0] = {12'b0,o_McCLKXA,o_McFSXA,o_McDXA,o_McFSXA};
//assign data_chipscp [31:16] = {8'b0,rd_ram1_addr};
//assign data_chipscp [47:32] = out_ram1_data;
//assign data_chipscp [63:48] = {3'b0,ram1_add_o,ram1_addr};//{3'b0,i_Mcbsp_tx_st,sig_ctrlv,sig_to_ram1,sig_to_ram2,o_McFSXA,ram1_addr};
//assign data_chipscp [79:64] = ram1_data;//{4'b0,cnt_spi};//ram1_dat_o;//
////assign {data_chipscp [62:61],data_chipscp [15:13]} = state;
//new_icon SVG_icon ( 
//     .CONTROL0            ( ILAControl) 
//); 
//
//new_ila SVG_ila ( 
//     .CONTROL            ( ILAControl), 
//     .CLK                ( i_clk), 
//     .DATA               ( data_chipscp), 
//     .TRIG0              (o_McFSXA),//ww ) ,
//	    .TRIG1              (),//ww1 ),
//     .TRIG2              (sig_to_ram1 ), 
//	    .TRIG3              (sig_to_ram2 )
//);



endmodule
