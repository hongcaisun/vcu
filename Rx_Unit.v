`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: CEPRI
// Engineer: ZDQ
// 
// Create Date:    16:26:56 05/28/2013 
// Design Name: 
// Module Name:    Rx_Unit 
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
module Rx_Unit(  
       input  i_clk,//100M 120M
       input  i_clk_20M,
       input  i_reset_n,
       input  [53:0]  i_Module_RX,
		 
		 input  start_DPRAM,
		 input start_rxsta,
		 input [9:0]ram_addr_a,
		 input [9:0]ram_addr_b,
		 input [9:0]ram_addr_c,
		 
		 output [15:0]ram_data_a,
		 output [15:0]ram_data_b,
		 output [15:0]ram_data_c,
		 
		 input [4:0]ram_addr_udca,
		 input [4:0]ram_addr_udcb,
		 input [4:0]ram_addr_udcc,
		 
		 output [15:0]ram_data_udca,
		 output [15:0]ram_data_udcb,
		 output [15:0]ram_data_udcc,

       output [383:0] o_LinkUdcA_BUS,
       output [383:0] o_LinkUdcB_BUS,
       output [383:0] o_LinkUdcC_BUS,
							
       output [15:0]	o_Mod_ComSta1,
       output [15:0]	o_Mod_ComSta2,
       output [15:0] o_Mod_ComSta3,
       output [15:0]	o_Mod_ComSta4,
       output [15:0]	o_Mod_ComSta5,
       output [15:0]	o_Mod_ComSta6,
       output [15:0]	o_Mod_ComSta7,
       output [15:0]	o_Mod_ComSta8,
       output [15:0]	o_Mod_ComSta9,
       output [15:0]	o_Mod_ComSta10,
       output [15:0]	o_Mod_ComSta11,
       output [15:0]	o_Mod_ComSta12,
		 output [863:0] linksta_bus
);									
//-----------------------------接收模块通信状态汇总----------------------------------------------------------//					
wire  	               optbrk1,optbrk2,optbrk3,optbrk4,optbrk5,optbrk6,optbrk7,optbrk8,optbrk9,optbrk10,   
								optbrk11,optbrk12,optbrk13,optbrk14,optbrk15,optbrk16,optbrk17,optbrk18,optbrk19,optbrk20,
								optbrk21,optbrk22,optbrk23,optbrk24,optbrk25,optbrk26,optbrk27,optbrk28,optbrk29,optbrk30,
								optbrk31,optbrk32,optbrk33,optbrk34,optbrk35,optbrk36,optbrk37,optbrk38,optbrk39,optbrk40,
								optbrk41,optbrk42,optbrk43,optbrk44,optbrk45,optbrk46,optbrk47,optbrk48,optbrk49,optbrk50,
								optbrk51,optbrk52,optbrk53,optbrk54,optbrk55,optbrk56,optbrk57,optbrk58,optbrk59,optbrk60,
								optbrk61,optbrk62,optbrk63,optbrk64,optbrk65,optbrk66,optbrk67,optbrk68,optbrk69,optbrk70,
								optbrk71,optbrk72,
								crc1,crc2,crc3,crc4,crc5,crc6,crc7,crc8,crc9,crc10,   
								crc11,crc12,crc13,crc14,crc15,crc16,crc17,crc18,crc19,crc20,
								crc21,crc22,crc23,crc24,crc25,crc26,crc27,crc28,crc29,crc30,
								crc31,crc32,crc33,crc34,crc35,crc36,crc37,crc38,crc39,crc40,
								crc41,crc42,crc43,crc44,crc45,crc46,crc47,crc48,crc49,crc50,
								crc51,crc52,crc53,crc54,crc55,crc56,crc57,crc58,crc59,crc60,
								crc61,crc62,crc63,crc64,crc65,crc66,crc67,crc68,crc69,crc70,
								crc71,crc72;
assign o_Mod_ComSta1 = {crc16,crc15,crc14,crc13,crc12,crc11,crc10,crc9,crc8,crc7,crc6,crc5,crc4,crc3,crc2,crc1};
assign o_Mod_ComSta2 = {14'd0,crc18,crc17};
assign o_Mod_ComSta3 = {optbrk16,optbrk15,optbrk14,optbrk13,optbrk12,optbrk11,optbrk10,optbrk9,optbrk8,optbrk7,optbrk6,optbrk5,optbrk4,optbrk3,optbrk2,optbrk1};
assign o_Mod_ComSta4 = {14'd0,optbrk18,optbrk17};

assign o_Mod_ComSta5 = {crc34,crc33,crc32,crc31,crc30,crc29,crc28,crc27,crc26,crc25,crc24,crc23,crc22,crc21,crc20,crc19};
assign o_Mod_ComSta6 = {14'd0,crc36,crc35};
assign o_Mod_ComSta7 = {optbrk34,optbrk33,optbrk32,optbrk31,optbrk30,optbrk29,optbrk28,optbrk27,optbrk26,optbrk25,optbrk24,optbrk23,optbrk22,optbrk21,optbrk20,optbrk19};
assign o_Mod_ComSta8 = {14'd0,optbrk36,optbrk35};

assign o_Mod_ComSta9 = {crc52,crc51,crc50,crc49,crc48,crc47,crc46,crc45,crc44,crc43,crc42,crc41,crc40,crc39,crc38,crc37};
assign o_Mod_ComSta10 = {14'd0,crc54,crc53};
assign o_Mod_ComSta11 = {optbrk52,optbrk51,optbrk50,optbrk49,optbrk48,optbrk47,optbrk46,optbrk45,optbrk44,optbrk43,optbrk42,optbrk41,optbrk40,optbrk39,optbrk38,optbrk37};
assign o_Mod_ComSta12 = {14'd0,optbrk54,optbrk53};
//-----------------------------模块电压转总线----------------------------------------------------------//
wire [15:0] LinkUdc[53:0];
assign o_LinkUdcA_BUS  = {LinkUdc[0],LinkUdc[1],LinkUdc[2],LinkUdc[3],LinkUdc[4],LinkUdc[5],LinkUdc[6],LinkUdc[7],LinkUdc[8],LinkUdc[9],			
                        LinkUdc[10],LinkUdc[11],LinkUdc[12],LinkUdc[13],LinkUdc[14],LinkUdc[15],LinkUdc[16],LinkUdc[17],16'd0,16'd0,
				            16'd0,16'd0,16'd0,16'd0};
assign o_LinkUdcB_BUS  = {LinkUdc[18],LinkUdc[19],LinkUdc[20],LinkUdc[21],LinkUdc[22],LinkUdc[23],LinkUdc[24],LinkUdc[25],LinkUdc[26],LinkUdc[27],			
                        LinkUdc[28],LinkUdc[29],LinkUdc[30],LinkUdc[31],LinkUdc[32],LinkUdc[33],LinkUdc[34],LinkUdc[35],16'd0,16'd0,
				            16'd0,16'd0,16'd0,16'd0};
assign o_LinkUdcC_BUS  = {LinkUdc[36],LinkUdc[37],LinkUdc[38],LinkUdc[39],LinkUdc[40],LinkUdc[41],LinkUdc[42],LinkUdc[43],LinkUdc[44],LinkUdc[45],			
                        LinkUdc[46],LinkUdc[47],LinkUdc[48],LinkUdc[49],LinkUdc[50],LinkUdc[51],LinkUdc[52],LinkUdc[53],16'd0,16'd0,
				            16'd0,16'd0,16'd0,16'd0};		
//-----------------------------模块状态信息转总线----------------------------------------------------------//	
wire   [15:0]           LinkState[107:0];
wire [15:0] linksta[53:0];
assign linksta_bus = {linksta[53],linksta[52],linksta[51],linksta[50],linksta[49],linksta[48],linksta[47],linksta[46],linksta[45],linksta[44],
							 linksta[43],linksta[42],linksta[41],linksta[40],linksta[39],linksta[38],linksta[37],linksta[36],linksta[35],linksta[34],
							 linksta[33],linksta[32],linksta[31],linksta[30],linksta[29],linksta[28],linksta[27],linksta[26],linksta[25],linksta[24],
							 linksta[23],linksta[22],linksta[21],linksta[20],linksta[19],linksta[18],linksta[17],linksta[16],linksta[15],linksta[14],
							 linksta[13],linksta[12],linksta[11],linksta[10],linksta[9],linksta[8],linksta[7],linksta[6],linksta[5],linksta[4],
							 linksta[3],linksta[2],linksta[1],linksta[0]};
//----------------接收链节单元数据缓存--------------------------//
//(* max_fanout = "20" *)reg [9:0]cnt;
(* equivalent_register_removal="{yes|no}" *)reg [9:0]cnt,cnt2,cnt3;
reg ram_w;
reg [15:0]ram_din_a,ram_din_b,ram_din_c;
reg start_DPRAM_reg,start_rxsta_reg;
//------------借用写DPRAM使能信号启动搬ram使能-------
always @ (posedge i_clk)
begin
    if(!i_reset_n) start_DPRAM_reg <= 1'b1;
	 else start_DPRAM_reg <= start_DPRAM;
end
//---------------------------------------
always @ (posedge i_clk)
begin
    if(!i_reset_n) start_rxsta_reg <= 1'b1;
	 else start_rxsta_reg <= start_rxsta;
end//-----------------------------------
always @ (posedge i_clk)
begin
	if(!i_reset_n) begin
		cnt <= 10'h0;
		cnt2 <= cnt;
		cnt3 <= cnt;
		ram_w <= 1'b0;
	end
	else if ((start_rxsta & !start_rxsta_reg) || (cnt!=10'h0)) begin
		if(cnt < 10'd256) begin
         cnt <= cnt + 10'h1;
			cnt2 <= cnt;
			cnt3 <= cnt;
			ram_w <= 1'b1;
		end
		else begin 
			cnt <= 10'h0;
			cnt2 <= cnt;
			cnt3 <= cnt;
			ram_w <= 1'b0;			
		end
	end
	else begin 
		cnt <= 10'h0;
		cnt2 <= cnt;
		cnt3 <= cnt;
	end
end

reg [4:0]cnt1;
reg wea;
always @ (posedge i_clk)
begin
	if(!i_reset_n) begin
		cnt1 <= 5'h0;
		wea <= 1'b0;
	end
	else if ((start_DPRAM & !start_DPRAM_reg) || (cnt1!=5'h0)) begin
		if(cnt1 < 5'd30) begin
         cnt1 <= cnt1 + 5'h1;
			wea <= 1'b1;
		end
		else begin 
			cnt1 <= 5'h0;
			wea <= 1'b0;			
		end
	end
	else begin 
		cnt1 <= 5'h0;
	end
end

reg [15:0]ram_din1,ram_din2,ram_din3;
RAM_32W ram_udca(
	.clka(i_clk), // input clka
	.wea(wea), // input [0 : 0] wea
	.addra(cnt1), // input [9 : 0] addra
	.dina(ram_din1), // input [15 : 0] dina
	.douta(), // output [15 : 0] douta
	.clkb(i_clk), // input clkb
	.web(1'b0), // input [0 : 0] web
	.addrb(ram_addr_udca), // input [9 : 0] addrb
	.dinb(), // input [15 : 0] dinb
	.doutb(ram_data_udca)
);
RAM_32W ram_udcb(
	.clka(i_clk), // input clka
	.wea(wea), // input [0 : 0] wea
	.addra(cnt1), // input [9 : 0] addra
	.dina(ram_din2), // input [15 : 0] dina
	.douta(), // output [15 : 0] douta
	.clkb(i_clk), // input clkb
	.web(1'b0), // input [0 : 0] web
	.addrb(ram_addr_udcb), // input [9 : 0] addrb
	.dinb(), // input [15 : 0] dinb
	.doutb(ram_data_udcb)
);
RAM_32W ram_udcc(
	.clka(i_clk), // input clka
	.wea(wea), // input [0 : 0] wea
	.addra(cnt1), // input [9 : 0] addra
	.dina(ram_din3), // input [15 : 0] dina
	.douta(), // output [15 : 0] douta
	.clkb(i_clk), // input clkb
	.web(1'b0), // input [0 : 0] web
	.addrb(ram_addr_udcc), // input [9 : 0] addrb
	.dinb(), // input [15 : 0] dinb
	.doutb(ram_data_udcc)
);
always @ (posedge i_clk)
begin
	if (!i_reset_n) ram_din1 <= 16'h0;
	else begin
		case (cnt1)
		 5'd1:ram_din1 <= LinkUdc[0];//A相链节直流电压1
		 5'd2:ram_din1 <= LinkUdc[1];//A相链节直流电压2
		 5'd3:ram_din1 <= LinkUdc[2];//A相链节直流电压3
		 5'd4:ram_din1 <= LinkUdc[3];//A相链节直流电压4
		 5'd5:ram_din1 <= LinkUdc[4];//A相链节直流电压5 
		 5'd6:ram_din1 <= LinkUdc[5];//A相链节直流电压6
		 5'd7:ram_din1 <= LinkUdc[6];//A相链节直流电压7 
		 5'd8:ram_din1 <= LinkUdc[7];//A相链节直流电压8 
		 5'd9:ram_din1 <= LinkUdc[8];//A相链节直流电压9
		 5'd10:ram_din1 <= LinkUdc[9];//A相链节直流电压10
		 5'd11:ram_din1 <= LinkUdc[10];//A相链节直流电压11
	    5'd12:ram_din1 <= LinkUdc[11];//A相链节直流电压12
		 5'd13:ram_din1 <= LinkUdc[12];//A相链节直流电压13		  
		 5'd14:ram_din1 <= LinkUdc[13];//A相链节直流电压14		  
		 5'd15:ram_din1 <= LinkUdc[14];//A相链节直流电压15
		 5'd16:ram_din1 <= LinkUdc[15];//A相链节直流电压16
		 5'd17:ram_din1 <= LinkUdc[16];//A相链节直流电压17  
		 5'd18:ram_din1 <= LinkUdc[17];//A相链节直流电压18
		 5'd19:ram_din1 <= 16'd0;//A相链节直流电压19
		 5'd20:ram_din1 <= 16'd0;//A相链节直流电压20
		 5'd21:ram_din1 <= 16'd0;//A相链节直流电压21
		 5'd22:ram_din1 <= 16'd0;//A相链节直流电压22 
		 5'd23:ram_din1 <= 16'd0;//A相链节直流电压23
		 5'd24:ram_din1 <= 16'd0;//A相链节直流电压24
       default:ram_din1 <=16'd0;
		 endcase
		end
end	
always @ (posedge i_clk)
begin
	if (!i_reset_n) ram_din2 <= 16'h0;
	else begin
		case (cnt1)
		 5'd1:ram_din2 <= LinkUdc[18];//A相链节直流电压1
		 5'd2:ram_din2 <= LinkUdc[19];//A相链节直流电压2
		 5'd3:ram_din2 <= LinkUdc[20];//A相链节直流电压3
		 5'd4:ram_din2 <= LinkUdc[21];//A相链节直流电压4
		 5'd5:ram_din2 <= LinkUdc[22];//A相链节直流电压5 
		 5'd6:ram_din2 <= LinkUdc[23];//A相链节直流电压6
		 5'd7:ram_din2 <= LinkUdc[24];//A相链节直流电压7 
		 5'd8:ram_din2 <= LinkUdc[25];//A相链节直流电压8 
		 5'd9:ram_din2 <= LinkUdc[26];//A相链节直流电压9
		 5'd10:ram_din2 <= LinkUdc[27];//A相链节直流电压10
		 5'd11:ram_din2 <= LinkUdc[28];//A相链节直流电压11
	    5'd12:ram_din2 <= LinkUdc[29];//A相链节直流电压12
		 5'd13:ram_din2 <= LinkUdc[30];//A相链节直流电压13		  
		 5'd14:ram_din2 <= LinkUdc[31];//A相链节直流电压14		  
		 5'd15:ram_din2 <= LinkUdc[32];//A相链节直流电压15
		 5'd16:ram_din2 <= LinkUdc[33];//A相链节直流电压16
		 5'd17:ram_din2 <= LinkUdc[34];//A相链节直流电压17  
		 5'd18:ram_din2 <= LinkUdc[35];//A相链节直流电压18
		 5'd19:ram_din2 <= 16'd0;//A相链节直流电压19
		 5'd20:ram_din2 <= 16'd0;//A相链节直流电压20
		 5'd21:ram_din2 <= 16'd0;//A相链节直流电压21
		 5'd22:ram_din2 <= 16'd0;//A相链节直流电压22 
		 5'd23:ram_din2 <= 16'd0;//A相链节直流电压23
		 5'd24:ram_din2 <= 16'd0;//A相链节直流电压24
       default:ram_din2 <=16'd0;
		endcase
		end
end
always @ (posedge i_clk)
begin
	if (!i_reset_n) ram_din3 <= 16'h0;
	else begin
		case (cnt1)
		 5'd1:ram_din3 <= LinkUdc[36];//A相链节直流电压1
		 5'd2:ram_din3 <= LinkUdc[37];//A相链节直流电压2
		 5'd3:ram_din3 <= LinkUdc[38];//A相链节直流电压3
		 5'd4:ram_din3 <= LinkUdc[39];//A相链节直流电压4
		 5'd5:ram_din3 <= LinkUdc[40];//A相链节直流电压5 
		 5'd6:ram_din3 <= LinkUdc[41];//A相链节直流电压6
		 5'd7:ram_din3 <= LinkUdc[42];//A相链节直流电压7 
		 5'd8:ram_din3 <= LinkUdc[43];//A相链节直流电压8 
		 5'd9:ram_din3 <= LinkUdc[44];//A相链节直流电压9
		 5'd10:ram_din3 <= LinkUdc[45];//A相链节直流电压10
		 5'd11:ram_din3 <= LinkUdc[46];//A相链节直流电压11
	    5'd12:ram_din3 <= LinkUdc[47];//A相链节直流电压12
		 5'd13:ram_din3 <= LinkUdc[48];//A相链节直流电压13		  
		 5'd14:ram_din3 <= LinkUdc[49];//A相链节直流电压14		  
		 5'd15:ram_din3 <= LinkUdc[50];//A相链节直流电压15
		 5'd16:ram_din3 <= LinkUdc[51];//A相链节直流电压16
		 5'd17:ram_din3 <= LinkUdc[52];//A相链节直流电压17  
		 5'd18:ram_din3 <= LinkUdc[53];//A相链节直流电压18
		 5'd19:ram_din3 <= 16'd0;//A相链节直流电压19
		 5'd20:ram_din3 <= 16'd0;//A相链节直流电压20
		 5'd21:ram_din3 <= 16'd0;//A相链节直流电压21
		 5'd22:ram_din3 <= 16'd0;//A相链节直流电压22 
		 5'd23:ram_din3 <= 16'd0;//A相链节直流电压23
		 5'd24:ram_din3 <= 16'd0;//A相链节直流电压24
       default:ram_din3 <=16'd0;
		 endcase
		end
end	
DPRAM ram_PhaseA (
  .clka(i_clk), // input clka
  .wea(ram_w), // input [0 : 0] wea
  .addra(cnt), // input [9 : 0] addra
  .dina(ram_din_a), // input [15 : 0] dina
  .douta(), // output [15 : 0] douta
  .clkb(i_clk), // input clkb
  .web(1'b0), // input [0 : 0] web
  .addrb(ram_addr_a), // input [9 : 0] addrb
  .dinb(), // input [15 : 0] dinb
  .doutb(ram_data_a) // output [15 : 0] doutb
);
DPRAM ram_PhaseB (
  .clka(i_clk), // input clka
  .wea(ram_w), // input [0 : 0] wea
  .addra(cnt2), // input [9 : 0] addra
  .dina(ram_din_b), // input [15 : 0] dina
  .douta(), // output [15 : 0] douta
  .clkb(i_clk), // input clkb
  .web(1'b0), // input [0 : 0] web
  .addrb(ram_addr_b), // input [9 : 0] addrb
  .dinb(), // input [15 : 0] dinb
  .doutb(ram_data_b) // output [15 : 0] doutb
);
DPRAM ram_PhaseC (
  .clka(i_clk), // input clka
  .wea(ram_w), // input [0 : 0] wea
  .addra(cnt3), // input [9 : 0] addra
  .dina(ram_din_c), // input [15 : 0] dina
  .douta(), // output [15 : 0] douta
  .clkb(i_clk), // input clkb
  .web(1'b0), // input [0 : 0] web
  .addrb(ram_addr_c), // input [9 : 0] addrb
  .dinb(), // input [15 : 0] dinb
  .doutb(ram_data_c) // output [15 : 0] doutb
);
always @ (posedge i_clk)
begin
	if (!i_reset_n) ram_din_a <= 16'h0;
	else begin
		case (cnt)
		 10'd1:ram_din_a <= o_Mod_ComSta1;//A相通信状态字1_1
		 10'd2:ram_din_a <= o_Mod_ComSta2;//A相通信状态字1_2
		 10'd3:ram_din_a <= o_Mod_ComSta3;//A相通信状态字2_1		
		 10'd4:ram_din_a <= o_Mod_ComSta4;//A相通信状态字2_2
		 
		 10'd5:ram_din_a <= LinkUdc[0];//A相链节直流电压1
		 10'd6:ram_din_a <= LinkUdc[1];//A相链节直流电压2
		 10'd7:ram_din_a <= LinkUdc[2];//A相链节直流电压3
		 10'd8:ram_din_a <= LinkUdc[3];//A相链节直流电压4
		 10'd9:ram_din_a <= LinkUdc[4];//A相链节直流电压5 
		 10'd10:ram_din_a <= LinkUdc[5];//A相链节直流电压6
		 10'd11:ram_din_a <= LinkUdc[6];//A相链节直流电压7 
		 10'd12:ram_din_a <= LinkUdc[7];//A相链节直流电压8 
		 10'd13:ram_din_a <= LinkUdc[8];//A相链节直流电压9
		 10'd14:ram_din_a <= LinkUdc[9];//A相链节直流电压10
		 10'd15:ram_din_a <= LinkUdc[10];//A相链节直流电压11
	    10'd16:ram_din_a <= LinkUdc[11];//A相链节直流电压12
		 10'd17:ram_din_a <= LinkUdc[12];//A相链节直流电压13		  
		 10'd18:ram_din_a <= LinkUdc[13];//A相链节直流电压14		  
		 10'd19:ram_din_a <= LinkUdc[14];//A相链节直流电压15
		 10'd20:ram_din_a <= LinkUdc[15];//A相链节直流电压16
		 10'd21:ram_din_a <= LinkUdc[16];//A相链节直流电压17  
		 10'd22:ram_din_a <= LinkUdc[17];//A相链节直流电压18
		 10'd23:ram_din_a <= 16'd0;//A相链节直流电压19
		 10'd24:ram_din_a <= 16'd0;//A相链节直流电压20
		 10'd25:ram_din_a <= 16'd0;//A相链节直流电压21
		 10'd26:ram_din_a <= 16'd0;//A相链节直流电压22 
		 10'd27:ram_din_a <= 16'd0;//A相链节直流电压23
		 10'd28:ram_din_a <= 16'd0;//A相链节直流电压24
  	 
		 10'd29:ram_din_a <= LinkState[0];//A相链节状态字1_l
		 10'd30:ram_din_a <= LinkState[1];//A相链节状态字1_h
		 10'd31:ram_din_a <= LinkState[2];//A相链节状态字2_
		 10'd32:ram_din_a <= LinkState[3];//A相链节状态字2_
		 10'd33:ram_din_a <= LinkState[4];//A相链节状态字3_
		 10'd34:ram_din_a <= LinkState[5];//A相链节状态字3_
		 10'd35:ram_din_a <= LinkState[6];//A相链节状态字4_
		 10'd36:ram_din_a <= LinkState[7];//A相链节状态字4_
		 10'd37:ram_din_a <= LinkState[8];//A相链节状态字5_
		 10'd38:ram_din_a <= LinkState[9];//A相链节状态字5_
		 10'd39:ram_din_a <= LinkState[10];//A相链节状态字6_
		 10'd40:ram_din_a <= LinkState[11];//A相链节状态字6_
		 10'd41:ram_din_a <= LinkState[12];//A相链节状态字7_	  
		 10'd42:ram_din_a <= LinkState[13];//A相链节状态字7_
		 10'd43:ram_din_a <= LinkState[14];//A相链节状态字8_
		 10'd44:ram_din_a <= LinkState[15];//A相链节状态字8_
		 10'd45:ram_din_a <= LinkState[16];//A相链节状态字9_
		 10'd46:ram_din_a <= LinkState[17];//A相链节状态字9_
		 10'd47:ram_din_a <= LinkState[18];//A相链节状态字10_	  
		 10'd48:ram_din_a <= LinkState[19];//A相链节状态字10_	  
		 10'd49:ram_din_a <= LinkState[20];//A相链节状态字11_	  
		 10'd50:ram_din_a <= LinkState[21];//A相链节状态字11_  
		 10'd51:ram_din_a <= LinkState[22];//A相链节状态字12_
		 10'd52:ram_din_a <= LinkState[23];//A相链节状态字12_
		 10'd53:ram_din_a <= LinkState[24];//A相链节状态字13_  
		 10'd54:ram_din_a <= LinkState[25];//A相链节状态字13_
		 10'd55:ram_din_a <= LinkState[26];//A相链节状态字14_
		 10'd56:ram_din_a <= LinkState[27];//A相链节状态字14_
		 10'd57:ram_din_a <= LinkState[28];//A相链节状态字15_h
		 10'd58:ram_din_a <= LinkState[29];//A相链节状态字15_l
		 10'd59:ram_din_a <= LinkState[30];//A相链节状态字16_h
		 10'd60:ram_din_a <= LinkState[31];//A相链节状态字16_l
		 10'd61:ram_din_a <= LinkState[32];//A相链节状态字17_h
		 10'd62:ram_din_a <= LinkState[33];//A相链节状态字17_l
		 10'd63:ram_din_a <= LinkState[34];//A相链节状态字18_h
		 10'd64:ram_din_a <= LinkState[35];//A相链节状态字18_l
		 10'd65:ram_din_a <= 16'd0;//A相链节状态字19_h
		 10'd66:ram_din_a <= 16'd0;//A相链节状态字19_l
		 10'd67:ram_din_a <= 16'd0;//A相链节状态字20_h
		 10'd68:ram_din_a <= 16'd0;//A相链节状态字20_l
		 10'd69:ram_din_a <= 16'd0;//A相链节状态字21_h
		 10'd70:ram_din_a <= 16'd0;//A相链节状态字21_l
		 10'd71:ram_din_a <= 16'd0;//A相链节状态字22_h
		 10'd72:ram_din_a <= 16'd0;//A相链节状态字22_l
		 10'd73:ram_din_a <= 16'd0;//A相链节状态字23_h
		 10'd74:ram_din_a <= 16'd0;//A相链节状态字23_l
		 10'd75:ram_din_a <= 16'd0;//A相链节状态字24_h
		 10'd76:ram_din_a <= 16'd0;//A相链节状态字24_l 
       default:ram_din_a <=16'd0;
		 endcase
		end
end	
always @ (posedge i_clk)
begin
	if (!i_reset_n) ram_din_b <= 16'h0;
	else begin
		case (cnt2)
		 10'd1:ram_din_b <= o_Mod_ComSta5;//A相通信状态字1_1
		 10'd2:ram_din_b <= o_Mod_ComSta6;//A相通信状态字1_2
		 10'd3:ram_din_b <= o_Mod_ComSta7;//A相通信状态字2_1		
		 10'd4:ram_din_b <= o_Mod_ComSta8;//A相通信状态字2_2
		 
		 10'd5:ram_din_b <= LinkUdc[18];//A相链节直流电压1
		 10'd6:ram_din_b <= LinkUdc[19];//A相链节直流电压2
		 10'd7:ram_din_b <= LinkUdc[20];//A相链节直流电压3
		 10'd8:ram_din_b <= LinkUdc[21];//A相链节直流电压4
		 10'd9:ram_din_b <= LinkUdc[22];//A相链节直流电压5 
		 10'd10:ram_din_b <= LinkUdc[23];//A相链节直流电压6
		 10'd11:ram_din_b <= LinkUdc[24];//A相链节直流电压7 
		 10'd12:ram_din_b <= LinkUdc[25];//A相链节直流电压8 
		 10'd13:ram_din_b <= LinkUdc[26];//A相链节直流电压9
		 10'd14:ram_din_b <= LinkUdc[27];//A相链节直流电压10
		 10'd15:ram_din_b <= LinkUdc[28];//A相链节直流电压11
	    10'd16:ram_din_b <= LinkUdc[29];//A相链节直流电压12
		 10'd17:ram_din_b <= LinkUdc[30];//A相链节直流电压13		  
		 10'd18:ram_din_b <= LinkUdc[31];//A相链节直流电压14		  
		 10'd19:ram_din_b <= LinkUdc[32];//A相链节直流电压15
		 10'd20:ram_din_b <= LinkUdc[33];//A相链节直流电压16
		 10'd21:ram_din_b <= LinkUdc[34];//A相链节直流电压17  
		 10'd22:ram_din_b <= LinkUdc[35];//A相链节直流电压18
		 10'd23:ram_din_b <= 16'd0;//A相链节直流电压19
		 10'd24:ram_din_b <= 16'd0;//A相链节直流电压20
		 10'd25:ram_din_b <= 16'd0;//A相链节直流电压21
		 10'd26:ram_din_b <= 16'd0;//A相链节直流电压22 
		 10'd27:ram_din_b <= 16'd0;//A相链节直流电压23
		 10'd28:ram_din_b <= 16'd0;//A相链节直流电压24
  	 
		 10'd29:ram_din_b <= LinkState[36];//A相链节状态字1_h
		 10'd30:ram_din_b <= LinkState[37];//A相链节状态字1_l
		 10'd31:ram_din_b <= LinkState[38];//A相链节状态字2_h
		 10'd32:ram_din_b <= LinkState[39];//A相链节状态字2_l
		 10'd33:ram_din_b <= LinkState[40];//A相链节状态字3_h
		 10'd34:ram_din_b <= LinkState[41];//A相链节状态字3_l
		 10'd35:ram_din_b <= LinkState[42];//A相链节状态字4_h
		 10'd36:ram_din_b <= LinkState[43];//A相链节状态字4_l
		 10'd37:ram_din_b <= LinkState[44];//A相链节状态字5_h
		 10'd38:ram_din_b <= LinkState[45];//A相链节状态字5_l
		 10'd39:ram_din_b <= LinkState[46];//A相链节状态字6_h
		 10'd40:ram_din_b <= LinkState[47];//A相链节状态字6_l
		 10'd41:ram_din_b <= LinkState[48];//A相链节状态字7_h	  
		 10'd42:ram_din_b <= LinkState[49];//A相链节状态字7_l
		 10'd43:ram_din_b <= LinkState[50];//A相链节状态字8_h
		 10'd44:ram_din_b <= LinkState[51];//A相链节状态字8_l
		 10'd45:ram_din_b <= LinkState[52];//A相链节状态字9_h
		 10'd46:ram_din_b <= LinkState[53];//A相链节状态字9_l 
		 10'd47:ram_din_b <= LinkState[54];//A相链节状态字10_h	  
		 10'd48:ram_din_b <= LinkState[55];//A相链节状态字10_l	  
		 10'd49:ram_din_b <= LinkState[56];//A相链节状态字11_h	  
		 10'd50:ram_din_b <= LinkState[57];//A相链节状态字11_l  
		 10'd51:ram_din_b <= LinkState[58];//A相链节状态字12_h
		 10'd52:ram_din_b <= LinkState[59];//A相链节状态字12_l
		 10'd53:ram_din_b <= LinkState[60];//A相链节状态字13_h  
		 10'd54:ram_din_b <= LinkState[61];//A相链节状态字13_l
		 10'd55:ram_din_b <= LinkState[62];//A相链节状态字14_h
		 10'd56:ram_din_b <= LinkState[63];//A相链节状态字14_l
		 10'd57:ram_din_b <= LinkState[64];//A相链节状态字15_h
		 10'd58:ram_din_b <= LinkState[65];//A相链节状态字15_l
		 10'd59:ram_din_b <= LinkState[66];//A相链节状态字16_h
		 10'd60:ram_din_b <= LinkState[67];//A相链节状态字16_l
		 10'd61:ram_din_b <= LinkState[68];//A相链节状态字17_h
		 10'd62:ram_din_b <= LinkState[69];//A相链节状态字17_l
		 10'd63:ram_din_b <= LinkState[70];//A相链节状态字18_h
		 10'd64:ram_din_b <= LinkState[71];//A相链节状态字18_l
		 10'd65:ram_din_b <= 16'd0;//A相链节状态字19_h
		 10'd66:ram_din_b <= 16'd0;//A相链节状态字19_l
		 10'd67:ram_din_b <= 16'd0;//A相链节状态字20_h
		 10'd68:ram_din_b <= 16'd0;//A相链节状态字20_l
		 10'd69:ram_din_b <= 16'd0;//A相链节状态字21_h
		 10'd70:ram_din_b <= 16'd0;//A相链节状态字21_l
		 10'd71:ram_din_b <= 16'd0;//A相链节状态字22_h
		 10'd72:ram_din_b <= 16'd0;//A相链节状态字22_l
		 10'd73:ram_din_b <= 16'd0;//A相链节状态字23_h
		 10'd74:ram_din_b <= 16'd0;//A相链节状态字23_l
		 10'd75:ram_din_b <= 16'd0;//A相链节状态字24_h
		 10'd76:ram_din_b <= 16'd0;//A相链节状态字24_l 
       default:ram_din_b <=16'd0;
		endcase
		end
end
always @ (posedge i_clk)
begin
	if (!i_reset_n) ram_din_c <= 16'h0;
	else begin
		case (cnt3)
		 10'd1:ram_din_c <= o_Mod_ComSta9;//A相通信状态字1_1
		 10'd2:ram_din_c <= o_Mod_ComSta10;//A相通信状态字1_2
		 10'd3:ram_din_c <= o_Mod_ComSta11;//A相通信状态字2_1		
		 10'd4:ram_din_c <= o_Mod_ComSta12;//A相通信状态字2_2
		 
		 10'd5:ram_din_c <= LinkUdc[36];//A相链节直流电压1
		 10'd6:ram_din_c <= LinkUdc[37];//A相链节直流电压2
		 10'd7:ram_din_c <= LinkUdc[38];//A相链节直流电压3
		 10'd8:ram_din_c <= LinkUdc[39];//A相链节直流电压4
		 10'd9:ram_din_c <= LinkUdc[40];//A相链节直流电压5 
		 10'd10:ram_din_c <= LinkUdc[41];//A相链节直流电压6
		 10'd11:ram_din_c <= LinkUdc[42];//A相链节直流电压7 
		 10'd12:ram_din_c <= LinkUdc[43];//A相链节直流电压8 
		 10'd13:ram_din_c <= LinkUdc[44];//A相链节直流电压9
		 10'd14:ram_din_c <= LinkUdc[45];//A相链节直流电压10
		 10'd15:ram_din_c <= LinkUdc[46];//A相链节直流电压11
	    10'd16:ram_din_c <= LinkUdc[47];//A相链节直流电压12
		 10'd17:ram_din_c <= LinkUdc[48];//A相链节直流电压13		  
		 10'd18:ram_din_c <= LinkUdc[49];//A相链节直流电压14		  
		 10'd19:ram_din_c <= LinkUdc[50];//A相链节直流电压15
		 10'd20:ram_din_c <= LinkUdc[51];//A相链节直流电压16
		 10'd21:ram_din_c <= LinkUdc[52];//A相链节直流电压17  
		 10'd22:ram_din_c <= LinkUdc[53];//A相链节直流电压18
		 10'd23:ram_din_c <= 16'd0;//A相链节直流电压19
		 10'd24:ram_din_c <= 16'd0;//A相链节直流电压20
		 10'd25:ram_din_c <= 16'd0;//A相链节直流电压21
		 10'd26:ram_din_c <= 16'd0;//A相链节直流电压22 
		 10'd27:ram_din_c <= 16'd0;//A相链节直流电压23
		 10'd28:ram_din_c <= 16'd0;//A相链节直流电压24
  	 
		 10'd29:ram_din_c <= LinkState[72];//A相链节状态字1_h
		 10'd30:ram_din_c <= LinkState[73];//A相链节状态字1_l
		 10'd31:ram_din_c <= LinkState[74];//A相链节状态字2_h
		 10'd32:ram_din_c <= LinkState[75];//A相链节状态字2_l
		 10'd33:ram_din_c <= LinkState[76];//A相链节状态字3_h
		 10'd34:ram_din_c <= LinkState[77];//A相链节状态字3_l
		 10'd35:ram_din_c <= LinkState[78];//A相链节状态字4_h
		 10'd36:ram_din_c <= LinkState[79];//A相链节状态字4_l
		 10'd37:ram_din_c <= LinkState[80];//A相链节状态字5_h
		 10'd38:ram_din_c <= LinkState[81];//A相链节状态字5_l
		 10'd39:ram_din_c <= LinkState[82];//A相链节状态字6_h
		 10'd40:ram_din_c <= LinkState[83];//A相链节状态字6_l
		 10'd41:ram_din_c <= LinkState[84];//A相链节状态字7_h	  
		 10'd42:ram_din_c <= LinkState[85];//A相链节状态字7_l
		 10'd43:ram_din_c <= LinkState[86];//A相链节状态字8_h
		 10'd44:ram_din_c <= LinkState[87];//A相链节状态字8_l
		 10'd45:ram_din_c <= LinkState[88];//A相链节状态字9_h
		 10'd46:ram_din_c <= LinkState[89];//A相链节状态字9_l 
		 10'd47:ram_din_c <= LinkState[90];//A相链节状态字10_h	  
		 10'd48:ram_din_c <= LinkState[91];//A相链节状态字10_l	  
		 10'd49:ram_din_c <= LinkState[92];//A相链节状态字11_h	  
		 10'd50:ram_din_c <= LinkState[93];//A相链节状态字11_l  
		 10'd51:ram_din_c <= LinkState[94];//A相链节状态字12_h
		 10'd52:ram_din_c <= LinkState[95];//A相链节状态字12_l
		 10'd53:ram_din_c <= LinkState[96];//A相链节状态字13_h  
		 10'd54:ram_din_c <= LinkState[97];//A相链节状态字13_l
		 10'd55:ram_din_c <= LinkState[98];//A相链节状态字14_h
		 10'd56:ram_din_c <= LinkState[99];//A相链节状态字14_l
		 10'd57:ram_din_c <= LinkState[100];//A相链节状态字15_h
		 10'd58:ram_din_c <= LinkState[101];//A相链节状态字15_l
		 10'd59:ram_din_c <= LinkState[102];//A相链节状态字16_h
		 10'd60:ram_din_c <= LinkState[103];//A相链节状态字16_l
		 10'd61:ram_din_c <= LinkState[104];//A相链节状态字17_h
		 10'd62:ram_din_c <= LinkState[105];//A相链节状态字17_l
		 10'd63:ram_din_c <= LinkState[106];//A相链节状态字18_h
		 10'd64:ram_din_c <= LinkState[107];//A相链节状态字18_l
		 10'd65:ram_din_c <= 16'd0;//A相链节状态字19_h
		 10'd66:ram_din_c <= 16'd0;//A相链节状态字19_l
		 10'd67:ram_din_c <= 16'd0;//A相链节状态字20_h
		 10'd68:ram_din_c <= 16'd0;//A相链节状态字20_l
		 10'd69:ram_din_c <= 16'd0;//A相链节状态字21_h
		 10'd70:ram_din_c <= 16'd0;//A相链节状态字21_l
		 10'd71:ram_din_c <= 16'd0;//A相链节状态字22_h
		 10'd72:ram_din_c <= 16'd0;//A相链节状态字22_l
		 10'd73:ram_din_c <= 16'd0;//A相链节状态字23_h
		 10'd74:ram_din_c <= 16'd0;//A相链节状态字23_l
		 10'd75:ram_din_c <= 16'd0;//A相链节状态字24_h
		 10'd76:ram_din_c <= 16'd0;//A相链节状态字24_l 
       default:ram_din_c <=16'd0;
		 endcase
		end
end
//---------------------拆分合并状态字----------------------------
modl_32to16 modl1(
					.clk(i_clk),
					.i_sta_l(LinkState[0]),
					.i_sta_h(LinkState[1]),
					.o_sta(linksta[0])
);
modl_32to16 modl2(
					.clk(i_clk),
					.i_sta_l(LinkState[2]),
					.i_sta_h(LinkState[3]),
					.o_sta(linksta[1])
);
modl_32to16 modl3(
					.clk(i_clk),
					.i_sta_l(LinkState[4]),
					.i_sta_h(LinkState[5]),
					.o_sta(linksta[2])
);
modl_32to16 modl4(
					.clk(i_clk),
					.i_sta_l(LinkState[6]),
					.i_sta_h(LinkState[7]),
					.o_sta(linksta[3])
);
modl_32to16 modl5(
					.clk(i_clk),
					.i_sta_l(LinkState[8]),
					.i_sta_h(LinkState[9]),
					.o_sta(linksta[4])
);
modl_32to16 modl6(
					.clk(i_clk),
					.i_sta_l(LinkState[10]),
					.i_sta_h(LinkState[11]),
					.o_sta(linksta[5])
);
modl_32to16 modl7(
					.clk(i_clk),
					.i_sta_l(LinkState[12]),
					.i_sta_h(LinkState[13]),
					.o_sta(linksta[6])
);
modl_32to16 modl8(
					.clk(i_clk),
					.i_sta_l(LinkState[14]),
					.i_sta_h(LinkState[15]),
					.o_sta(linksta[7])
);
modl_32to16 modl9(
					.clk(i_clk),
					.i_sta_l(LinkState[16]),
					.i_sta_h(LinkState[17]),
					.o_sta(linksta[8])
);
modl_32to16 modl10(
					.clk(i_clk),
					.i_sta_l(LinkState[18]),
					.i_sta_h(LinkState[19]),
					.o_sta(linksta[9])
);
modl_32to16 modl11(
					.clk(i_clk),
					.i_sta_l(LinkState[20]),
					.i_sta_h(LinkState[21]),
					.o_sta(linksta[10])
);
modl_32to16 modl12(
					.clk(i_clk),
					.i_sta_l(LinkState[22]),
					.i_sta_h(LinkState[23]),
					.o_sta(linksta[11])
);
modl_32to16 modl13(
					.clk(i_clk),
					.i_sta_l(LinkState[24]),
					.i_sta_h(LinkState[25]),
					.o_sta(linksta[12])
);
modl_32to16 modl14(
					.clk(i_clk),
					.i_sta_l(LinkState[26]),
					.i_sta_h(LinkState[27]),
					.o_sta(linksta[13])
);
modl_32to16 modl15(
					.clk(i_clk),
					.i_sta_l(LinkState[28]),
					.i_sta_h(LinkState[29]),
					.o_sta(linksta[14])
);
modl_32to16 modl16(
					.clk(i_clk),
					.i_sta_l(LinkState[30]),
					.i_sta_h(LinkState[31]),
					.o_sta(linksta[15])
);
modl_32to16 modl17(
					.clk(i_clk),
					.i_sta_l(LinkState[32]),
					.i_sta_h(LinkState[33]),
					.o_sta(linksta[16])
);
modl_32to16 modl18(
					.clk(i_clk),
					.i_sta_l(LinkState[34]),
					.i_sta_h(LinkState[35]),
					.o_sta(linksta[17])
);
modl_32to16 modl19(
					.clk(i_clk),
					.i_sta_l(LinkState[36]),
					.i_sta_h(LinkState[37]),
					.o_sta(linksta[18])
);
modl_32to16 modl20(
					.clk(i_clk),
					.i_sta_l(LinkState[38]),
					.i_sta_h(LinkState[39]),
					.o_sta(linksta[19])
);
modl_32to16 modl21(
					.clk(i_clk),
					.i_sta_l(LinkState[40]),
					.i_sta_h(LinkState[41]),
					.o_sta(linksta[20])
);
modl_32to16 modl22(
					.clk(i_clk),
					.i_sta_l(LinkState[42]),
					.i_sta_h(LinkState[43]),
					.o_sta(linksta[21])
);
modl_32to16 modl23(
					.clk(i_clk),
					.i_sta_l(LinkState[44]),
					.i_sta_h(LinkState[45]),
					.o_sta(linksta[22])
);
modl_32to16 modl24(
					.clk(i_clk),
					.i_sta_l(LinkState[46]),
					.i_sta_h(LinkState[47]),
					.o_sta(linksta[23])
);
modl_32to16 modl25(
					.clk(i_clk),
					.i_sta_l(LinkState[48]),
					.i_sta_h(LinkState[49]),
					.o_sta(linksta[24])
);
modl_32to16 modl26(
					.clk(i_clk),
					.i_sta_l(LinkState[50]),
					.i_sta_h(LinkState[51]),
					.o_sta(linksta[25])
);
modl_32to16 modl27(
					.clk(i_clk),
					.i_sta_l(LinkState[52]),
					.i_sta_h(LinkState[53]),
					.o_sta(linksta[26])
);
modl_32to16 modl28(
					.clk(i_clk),
					.i_sta_l(LinkState[54]),
					.i_sta_h(LinkState[55]),
					.o_sta(linksta[27])
);
modl_32to16 modl29(
					.clk(i_clk),
					.i_sta_l(LinkState[56]),
					.i_sta_h(LinkState[57]),
					.o_sta(linksta[28])
);
modl_32to16 modl30(
					.clk(i_clk),
					.i_sta_l(LinkState[58]),
					.i_sta_h(LinkState[59]),
					.o_sta(linksta[29])
);
modl_32to16 modl31(
					.clk(i_clk),
					.i_sta_l(LinkState[60]),
					.i_sta_h(LinkState[61]),
					.o_sta(linksta[30])
);
modl_32to16 modl32(
					.clk(i_clk),
					.i_sta_l(LinkState[62]),
					.i_sta_h(LinkState[63]),
					.o_sta(linksta[31])
);
modl_32to16 modl33(
					.clk(i_clk),
					.i_sta_l(LinkState[64]),
					.i_sta_h(LinkState[65]),
					.o_sta(linksta[32])
);
modl_32to16 modl34(
					.clk(i_clk),
					.i_sta_l(LinkState[66]),
					.i_sta_h(LinkState[67]),
					.o_sta(linksta[33])
);
modl_32to16 modl35(
					.clk(i_clk),
					.i_sta_l(LinkState[68]),
					.i_sta_h(LinkState[69]),
					.o_sta(linksta[34])
);
modl_32to16 modl36(
					.clk(i_clk),
					.i_sta_l(LinkState[70]),
					.i_sta_h(LinkState[71]),
					.o_sta(linksta[35])
);
modl_32to16 modl37(
					.clk(i_clk),
					.i_sta_l(LinkState[72]),
					.i_sta_h(LinkState[73]),
					.o_sta(linksta[36])
);
modl_32to16 modl38(
					.clk(i_clk),
					.i_sta_l(LinkState[74]),
					.i_sta_h(LinkState[75]),
					.o_sta(linksta[37])
);
modl_32to16 modl39(
					.clk(i_clk),
					.i_sta_l(LinkState[76]),
					.i_sta_h(LinkState[77]),
					.o_sta(linksta[38])
);
modl_32to16 modl40(
					.clk(i_clk),
					.i_sta_l(LinkState[78]),
					.i_sta_h(LinkState[79]),
					.o_sta(linksta[39])
);
modl_32to16 modl41(
					.clk(i_clk),
					.i_sta_l(LinkState[80]),
					.i_sta_h(LinkState[81]),
					.o_sta(linksta[40])
);
modl_32to16 modl42(
					.clk(i_clk),
					.i_sta_l(LinkState[82]),
					.i_sta_h(LinkState[83]),
					.o_sta(linksta[41])
);
modl_32to16 modl43(
					.clk(i_clk),
					.i_sta_l(LinkState[84]),
					.i_sta_h(LinkState[85]),
					.o_sta(linksta[42])
);
modl_32to16 modl44(
					.clk(i_clk),
					.i_sta_l(LinkState[86]),
					.i_sta_h(LinkState[87]),
					.o_sta(linksta[43])
);
modl_32to16 modl45(
					.clk(i_clk),
					.i_sta_l(LinkState[88]),
					.i_sta_h(LinkState[89]),
					.o_sta(linksta[44])
);
modl_32to16 modl46(
					.clk(i_clk),
					.i_sta_l(LinkState[90]),
					.i_sta_h(LinkState[91]),
					.o_sta(linksta[45])
);
modl_32to16 modl47(
					.clk(i_clk),
					.i_sta_l(LinkState[92]),
					.i_sta_h(LinkState[93]),
					.o_sta(linksta[46])
);
modl_32to16 modl48(
					.clk(i_clk),
					.i_sta_l(LinkState[94]),
					.i_sta_h(LinkState[95]),
					.o_sta(linksta[47])
);
modl_32to16 modl49(
					.clk(i_clk),
					.i_sta_l(LinkState[96]),
					.i_sta_h(LinkState[97]),
					.o_sta(linksta[48])
);
modl_32to16 modl50(
					.clk(i_clk),
					.i_sta_l(LinkState[98]),
					.i_sta_h(LinkState[99]),
					.o_sta(linksta[49])
);
modl_32to16 modl51(
					.clk(i_clk),
					.i_sta_l(LinkState[100]),
					.i_sta_h(LinkState[101]),
					.o_sta(linksta[50])
);
modl_32to16 modl52(
					.clk(i_clk),
					.i_sta_l(LinkState[102]),
					.i_sta_h(LinkState[103]),
					.o_sta(linksta[51])
);
modl_32to16 modl53(
					.clk(i_clk),
					.i_sta_l(LinkState[104]),
					.i_sta_h(LinkState[105]),
					.o_sta(linksta[52])
);
modl_32to16 modl54(
					.clk(i_clk),
					.i_sta_l(LinkState[106]),
					.i_sta_h(LinkState[107]),
					.o_sta(linksta[53])
);
//---------------------------------------------------------------------------------------//							
Rx_Dy Rx1(
			.reset_n(i_reset_n),
			.clk(i_clk),
			.clk_20M(i_clk_20M),
			.M_R(i_Module_RX[0]),
			.LinkUdc(LinkUdc[0]),
			.LinkStaa(LinkState[0]),//L
			.LinkStab(LinkState[1]),//H
			.optbrk_o(optbrk1),
			.crconce_o(crc1)
);         
Rx_Dy Rx2(
			.reset_n(i_reset_n),
			.clk(i_clk),
			.clk_20M(i_clk_20M),
			.M_R(i_Module_RX[1]),
			.LinkUdc(LinkUdc[1]),
			.LinkStaa(LinkState[2]),
			.LinkStab(LinkState[3]),
			.optbrk_o(optbrk2),
			.crconce_o(crc2)
);         
Rx_Dy Rx3(
			.reset_n(i_reset_n),
			.clk(i_clk),
			.clk_20M(i_clk_20M),
			.M_R(i_Module_RX[2]),
			.LinkUdc(LinkUdc[2]),
			.LinkStaa(LinkState[4]),
			.LinkStab(LinkState[5]),
			.optbrk_o(optbrk3),
			.crconce_o(crc3)
);         
Rx_Dy Rx4(
			.reset_n(i_reset_n),
			.clk(i_clk),
			.clk_20M(i_clk_20M),
			.M_R(i_Module_RX[3]),
			.LinkUdc(LinkUdc[3]),
			.LinkStaa(LinkState[6]),
			.LinkStab(LinkState[7]),
			.optbrk_o(optbrk4),
			.crconce_o(crc4)
);         
Rx_Dy Rx5(
			.reset_n(i_reset_n),
			.clk(i_clk),
			.clk_20M(i_clk_20M),
			.M_R(i_Module_RX[4]),
			.LinkUdc(LinkUdc[4]),
			.LinkStaa(LinkState[8]),
			.LinkStab(LinkState[9]),
			.optbrk_o(optbrk5),
			.crconce_o(crc5)
);         
Rx_Dy Rx6(
			.reset_n(i_reset_n),
			.clk(i_clk),
			.clk_20M(i_clk_20M),
			.M_R(i_Module_RX[5]),
			.LinkUdc(LinkUdc[5]),
			.LinkStaa(LinkState[10]),
			.LinkStab(LinkState[11]),
			.optbrk_o(optbrk6),
			.crconce_o(crc6)
);         
Rx_Dy Rx7(
			.reset_n(i_reset_n),
			.clk(i_clk),
			.clk_20M(i_clk_20M),
			.M_R(i_Module_RX[6]),
			.LinkUdc(LinkUdc[6]),
			.LinkStaa(LinkState[12]),
			.LinkStab(LinkState[13]),
			.optbrk_o(optbrk7),
			.crconce_o(crc7)
);         
Rx_Dy Rx8(
			.reset_n(i_reset_n),
			.clk(i_clk),
			.clk_20M(i_clk_20M),
			.M_R(i_Module_RX[7]),
			.LinkUdc(LinkUdc[7]),
			.LinkStaa(LinkState[14]),
			.LinkStab(LinkState[15]),
			.optbrk_o(optbrk8),
			.crconce_o(crc8)
);         
Rx_Dy Rx9(
			.reset_n(i_reset_n),
			.clk(i_clk),
			.clk_20M(i_clk_20M),
			.M_R(i_Module_RX[8]),
			.LinkUdc(LinkUdc[8]),
			.LinkStaa(LinkState[16]),
			.LinkStab(LinkState[17]),
			.optbrk_o(optbrk9),
			.crconce_o(crc9)
);         
Rx_Dy Rx10(
			.reset_n(i_reset_n),
			.clk(i_clk),
			.clk_20M(i_clk_20M),
			.M_R(i_Module_RX[9]),
			.LinkUdc(LinkUdc[9]),
			.LinkStaa(LinkState[18]),
			.LinkStab(LinkState[19]),
			.optbrk_o(optbrk10),
			.crconce_o(crc10)
);  
Rx_Dy Rx11(
			.reset_n(i_reset_n),
			.clk(i_clk),
			.clk_20M(i_clk_20M),
			.M_R(i_Module_RX[10]),
			.LinkUdc(LinkUdc[10]),
			.LinkStaa(LinkState[20]),
			.LinkStab(LinkState[21]),
			.optbrk_o(optbrk11),
			.crconce_o(crc11)
); 
Rx_Dy Rx12(
			.reset_n(i_reset_n),
			.clk(i_clk),
			.clk_20M(i_clk_20M),
			.M_R(i_Module_RX[11]),
			.LinkUdc(LinkUdc[11]),
			.LinkStaa(LinkState[22]),
			.LinkStab(LinkState[23]),
			.optbrk_o(optbrk12),
			.crconce_o(crc12)
); 
Rx_Dy Rx13(
			.reset_n(i_reset_n),
			.clk(i_clk),
			.clk_20M(i_clk_20M),
			.M_R(i_Module_RX[12]),
			.LinkUdc(LinkUdc[12]),
			.LinkStaa(LinkState[24]),
			.LinkStab(LinkState[25]),
			.optbrk_o(optbrk13),
			.crconce_o(crc13)
); 
Rx_Dy Rx14(
			.reset_n(i_reset_n),
			.clk(i_clk),
			.clk_20M(i_clk_20M),
			.M_R(i_Module_RX[13]),
			.LinkUdc(LinkUdc[13]),
			.LinkStaa(LinkState[26]),
			.LinkStab(LinkState[27]),
			.optbrk_o(optbrk14),
			.crconce_o(crc14)
); 
Rx_Dy Rx15(
			.reset_n(i_reset_n),
			.clk(i_clk),
			.clk_20M(i_clk_20M),
			.M_R(i_Module_RX[14]),
			.LinkUdc(LinkUdc[14]),
			.LinkStaa(LinkState[28]),
			.LinkStab(LinkState[29]),
			.optbrk_o(optbrk15),
			.crconce_o(crc15)
); 
Rx_Dy Rx16(
			.reset_n(i_reset_n),
			.clk(i_clk),
			.clk_20M(i_clk_20M),
			.M_R(i_Module_RX[15]),
			.LinkUdc(LinkUdc[15]),
			.LinkStaa(LinkState[30]),
			.LinkStab(LinkState[31]),
			.optbrk_o(optbrk16),
			.crconce_o(crc16)
); 
Rx_Dy Rx17(
			.reset_n(i_reset_n),
			.clk(i_clk),
			.clk_20M(i_clk_20M),
			.M_R(i_Module_RX[16]),
			.LinkUdc(LinkUdc[16]),
			.LinkStaa(LinkState[32]),
			.LinkStab(LinkState[33]),
			.optbrk_o(optbrk17),
			.crconce_o(crc17)
); 
Rx_Dy Rx18(
			.reset_n(i_reset_n),
			.clk(i_clk),
			.clk_20M(i_clk_20M),
			.M_R(i_Module_RX[17]),
			.LinkUdc(LinkUdc[17]),
			.LinkStaa(LinkState[34]),
			.LinkStab(LinkState[35]),
			.optbrk_o(optbrk18),
			.crconce_o(crc18)
); 
Rx_Dy Rx19(
			.reset_n(i_reset_n),
			.clk(i_clk),
			.clk_20M(i_clk_20M),
			.M_R(i_Module_RX[18]),
			.LinkUdc(LinkUdc[18]),
			.LinkStaa(LinkState[36]),
			.LinkStab(LinkState[37]),
			.optbrk_o(optbrk19),
			.crconce_o(crc19)
); 
Rx_Dy Rx20(
			.reset_n(i_reset_n),
			.clk(i_clk),
			.clk_20M(i_clk_20M),
			.M_R(i_Module_RX[19]),
			.LinkUdc(LinkUdc[19]),
			.LinkStaa(LinkState[38]),
			.LinkStab(LinkState[39]),
			.optbrk_o(optbrk20),
			.crconce_o(crc20)
); 
Rx_Dy Rx21(
			.reset_n(i_reset_n),
			.clk(i_clk),
			.clk_20M(i_clk_20M),
			.M_R(i_Module_RX[20]),
			.LinkUdc(LinkUdc[20]),
			.LinkStaa(LinkState[40]),
			.LinkStab(LinkState[41]),
			.optbrk_o(optbrk21),
			.crconce_o(crc21)
); 
Rx_Dy Rx22(
			.reset_n(i_reset_n),
			.clk(i_clk),
			.clk_20M(i_clk_20M),
			.M_R(i_Module_RX[21]),
			.LinkUdc(LinkUdc[21]),
			.LinkStaa(LinkState[42]),
			.LinkStab(LinkState[43]),
			.optbrk_o(optbrk22),
			.crconce_o(crc22)
); 
Rx_Dy Rx23(
			.reset_n(i_reset_n),
			.clk(i_clk),
			.clk_20M(i_clk_20M),
			.M_R(i_Module_RX[22]),
			.LinkUdc(LinkUdc[22]),
			.LinkStaa(LinkState[44]),
			.LinkStab(LinkState[45]),
			.optbrk_o(optbrk23),
			.crconce_o(crc23)
); 
Rx_Dy Rx24(
			.reset_n(i_reset_n),
			.clk(i_clk),
			.clk_20M(i_clk_20M),
			.M_R(i_Module_RX[23]),
			.LinkUdc(LinkUdc[23]),
			.LinkStaa(LinkState[46]),
			.LinkStab(LinkState[47]),
			.optbrk_o(optbrk24),
			.crconce_o(crc24)
);
Rx_Dy Rx25(
			.reset_n(i_reset_n),
			.clk(i_clk),
			.clk_20M(i_clk_20M),
			.M_R(i_Module_RX[24]),
			.LinkUdc(LinkUdc[24]),
			.LinkStaa(LinkState[48]),
			.LinkStab(LinkState[49]),
			.optbrk_o(optbrk25),
			.crconce_o(crc25)
); 
Rx_Dy Rx26(
			.reset_n(i_reset_n),
			.clk(i_clk),
			.clk_20M(i_clk_20M),
			.M_R(i_Module_RX[25]),
			.LinkUdc(LinkUdc[25]),
			.LinkStaa(LinkState[50]),
			.LinkStab(LinkState[51]),
			.optbrk_o(optbrk26),
			.crconce_o(crc26)
); 
Rx_Dy Rx27(
			.reset_n(i_reset_n),
			.clk(i_clk),
			.clk_20M(i_clk_20M),
			.M_R(i_Module_RX[26]),
			.LinkUdc(LinkUdc[26]),
			.LinkStaa(LinkState[52]),
			.LinkStab(LinkState[53]),
			.optbrk_o(optbrk27),
			.crconce_o(crc27)
); 
Rx_Dy Rx28(
			.reset_n(i_reset_n),
			.clk(i_clk),
			.clk_20M(i_clk_20M),
			.M_R(i_Module_RX[27]),
			.LinkUdc(LinkUdc[27]),
			.LinkStaa(LinkState[54]),
			.LinkStab(LinkState[55]),
			.optbrk_o(optbrk28),
			.crconce_o(crc28)
); 
Rx_Dy Rx29(
			.reset_n(i_reset_n),
			.clk(i_clk),
			.clk_20M(i_clk_20M),
			.M_R(i_Module_RX[28]),
			.LinkUdc(LinkUdc[28]),
			.LinkStaa(LinkState[56]),
			.LinkStab(LinkState[57]),
			.optbrk_o(optbrk29),
			.crconce_o(crc29)
); 
Rx_Dy Rx30(
			.reset_n(i_reset_n),
			.clk(i_clk),
			.clk_20M(i_clk_20M),
			.M_R(i_Module_RX[29]),
			.LinkUdc(LinkUdc[29]),
			.LinkStaa(LinkState[58]),
			.LinkStab(LinkState[59]),
			.optbrk_o(optbrk30),
			.crconce_o(crc30)
); 
Rx_Dy Rx31(
			.reset_n(i_reset_n),
			.clk(i_clk),
			.clk_20M(i_clk_20M),
			.M_R(i_Module_RX[30]),
			.LinkUdc(LinkUdc[30]),
			.LinkStaa(LinkState[60]),
			.LinkStab(LinkState[61]),
			.optbrk_o(optbrk31),
			.crconce_o(crc31)
); 
Rx_Dy Rx32(
			.reset_n(i_reset_n),
			.clk(i_clk),
			.clk_20M(i_clk_20M),
			.M_R(i_Module_RX[31]),
			.LinkUdc(LinkUdc[31]),
			.LinkStaa(LinkState[62]),
			.LinkStab(LinkState[63]),
			.optbrk_o(optbrk32),
			.crconce_o(crc32)
); 
Rx_Dy Rx33(
			.reset_n(i_reset_n),
			.clk(i_clk),
			.clk_20M(i_clk_20M),
			.M_R(i_Module_RX[32]),
			.LinkUdc(LinkUdc[32]),
			.LinkStaa(LinkState[64]),
			.LinkStab(LinkState[65]),
			.optbrk_o(optbrk33),
			.crconce_o(crc33)
); 
Rx_Dy Rx34(
			.reset_n(i_reset_n),
			.clk(i_clk),
			.clk_20M(i_clk_20M),
			.M_R(i_Module_RX[33]),
			.LinkUdc(LinkUdc[33]),
			.LinkStaa(LinkState[66]),
			.LinkStab(LinkState[67]),
			.optbrk_o(optbrk34),
			.crconce_o(crc34)
); 
Rx_Dy Rx35(
			.reset_n(i_reset_n),
			.clk(i_clk),
			.clk_20M(i_clk_20M),
			.M_R(i_Module_RX[34]),
			.LinkUdc(LinkUdc[34]),
			.LinkStaa(LinkState[68]),
			.LinkStab(LinkState[69]),
			.optbrk_o(optbrk35),
			.crconce_o(crc35)
); 
Rx_Dy Rx36(
			.reset_n(i_reset_n),
			.clk(i_clk),
			.clk_20M(i_clk_20M),
			.M_R(i_Module_RX[35]),
			.LinkUdc(LinkUdc[35]),
			.LinkStaa(LinkState[70]),
			.LinkStab(LinkState[71]),
			.optbrk_o(optbrk36),
			.crconce_o(crc36)
); 
Rx_Dy Rx37(
			.reset_n(i_reset_n),
			.clk(i_clk),
			.clk_20M(i_clk_20M),
			.M_R(i_Module_RX[36]),
			.LinkUdc(LinkUdc[36]),
			.LinkStaa(LinkState[72]),
			.LinkStab(LinkState[73]),
			.optbrk_o(optbrk37),
			.crconce_o(crc37)
); 
Rx_Dy Rx38(
			.reset_n(i_reset_n),
			.clk(i_clk),
			.clk_20M(i_clk_20M),
			.M_R(i_Module_RX[37]),
			.LinkUdc(LinkUdc[37]),
			.LinkStaa(LinkState[74]),
			.LinkStab(LinkState[75]),
			.optbrk_o(optbrk38),
			.crconce_o(crc38)
); 
Rx_Dy Rx39(
			.reset_n(i_reset_n),
			.clk(i_clk),
			.clk_20M(i_clk_20M),
			.M_R(i_Module_RX[38]),
			.LinkUdc(LinkUdc[38]),
			.LinkStaa(LinkState[76]),
			.LinkStab(LinkState[77]),
			.optbrk_o(optbrk39),
			.crconce_o(crc39)
);
Rx_Dy Rx40(
			.reset_n(i_reset_n),
			.clk(i_clk),
			.clk_20M(i_clk_20M),
			.M_R(i_Module_RX[39]),
			.LinkUdc(LinkUdc[39]),
			.LinkStaa(LinkState[78]),
			.LinkStab(LinkState[79]),
			.optbrk_o(optbrk40),
			.crconce_o(crc40)
);  
Rx_Dy Rx41(
			.reset_n(i_reset_n),
			.clk(i_clk),
			.clk_20M(i_clk_20M),
			.M_R(i_Module_RX[40]),
			.LinkUdc(LinkUdc[40]),
			.LinkStaa(LinkState[80]),
			.LinkStab(LinkState[81]),
			.optbrk_o(optbrk41),
			.crconce_o(crc41)
);
Rx_Dy Rx42(
			.reset_n(i_reset_n),
			.clk(i_clk),
			.clk_20M(i_clk_20M),
			.M_R(i_Module_RX[41]),
			.LinkUdc(LinkUdc[41]),
			.LinkStaa(LinkState[82]),
			.LinkStab(LinkState[83]),
			.optbrk_o(optbrk42),
			.crconce_o(crc42)
);
Rx_Dy Rx43(
			.reset_n(i_reset_n),
			.clk(i_clk),
			.clk_20M(i_clk_20M),
			.M_R(i_Module_RX[42]),
			.LinkUdc(LinkUdc[42]),
			.LinkStaa(LinkState[84]),
			.LinkStab(LinkState[85]),
			.optbrk_o(optbrk43),
			.crconce_o(crc43)
);
Rx_Dy Rx44(
			.reset_n(i_reset_n),
			.clk(i_clk),
			.clk_20M(i_clk_20M),
			.M_R(i_Module_RX[43]),
			.LinkUdc(LinkUdc[43]),
			.LinkStaa(LinkState[86]),
			.LinkStab(LinkState[87]),
			.optbrk_o(optbrk44),
			.crconce_o(crc44)
);
Rx_Dy Rx45(
			.reset_n(i_reset_n),
			.clk(i_clk),
			.clk_20M(i_clk_20M),
			.M_R(i_Module_RX[44]),
			.LinkUdc(LinkUdc[44]),
			.LinkStaa(LinkState[88]),
			.LinkStab(LinkState[89]),
			.optbrk_o(optbrk45),
			.crconce_o(crc45)
);
Rx_Dy Rx46(
			.reset_n(i_reset_n),
			.clk(i_clk),
			.clk_20M(i_clk_20M),
			.M_R(i_Module_RX[45]),
			.LinkUdc(LinkUdc[45]),
			.LinkStaa(LinkState[90]),
			.LinkStab(LinkState[91]),
			.optbrk_o(optbrk46),
			.crconce_o(crc46)
);
Rx_Dy Rx47(
			.reset_n(i_reset_n),
			.clk(i_clk),
			.clk_20M(i_clk_20M),
			.M_R(i_Module_RX[46]),
			.LinkUdc(LinkUdc[46]),
			.LinkStaa(LinkState[92]),
			.LinkStab(LinkState[93]),
			.optbrk_o(optbrk47),
			.crconce_o(crc47)
);
Rx_Dy Rx48(
			.reset_n(i_reset_n),
			.clk(i_clk),
			.clk_20M(i_clk_20M),
			.M_R(i_Module_RX[47]),
			.LinkUdc(LinkUdc[47]),
			.LinkStaa(LinkState[94]),
			.LinkStab(LinkState[95]),
			.optbrk_o(optbrk48),
			.crconce_o(crc48)
);
Rx_Dy Rx49(
			.reset_n(i_reset_n),
			.clk(i_clk),
			.clk_20M(i_clk_20M),
			.M_R(i_Module_RX[48]),
			.LinkUdc(LinkUdc[48]),
			.LinkStaa(LinkState[96]),
			.LinkStab(LinkState[97]),
			.optbrk_o(optbrk49),
			.crconce_o(crc49)
);
Rx_Dy Rx50(
			.reset_n(i_reset_n),
			.clk(i_clk),
			.clk_20M(i_clk_20M),
			.M_R(i_Module_RX[49]),
			.LinkUdc(LinkUdc[49]),
			.LinkStaa(LinkState[98]),
			.LinkStab(LinkState[99]),
			.optbrk_o(optbrk50),
			.crconce_o(crc50)
);
Rx_Dy Rx51(
			.reset_n(i_reset_n),
			.clk(i_clk),
			.clk_20M(i_clk_20M),
			.M_R(i_Module_RX[50]),
			.LinkUdc(LinkUdc[50]),
			.LinkStaa(LinkState[100]),
			.LinkStab(LinkState[101]),
			.optbrk_o(optbrk51),
			.crconce_o(crc51)
);
Rx_Dy Rx52(
			.reset_n(i_reset_n),
			.clk(i_clk),
			.clk_20M(i_clk_20M),
			.M_R(i_Module_RX[51]),
			.LinkUdc(LinkUdc[51]),
			.LinkStaa(LinkState[102]),
			.LinkStab(LinkState[103]),
			.optbrk_o(optbrk52),
			.crconce_o(crc52)
);
Rx_Dy Rx53(
			.reset_n(i_reset_n),
			.clk(i_clk),
			.clk_20M(i_clk_20M),
			.M_R(i_Module_RX[52]),
			.LinkUdc(LinkUdc[52]),
			.LinkStaa(LinkState[104]),
			.LinkStab(LinkState[105]),
			.optbrk_o(optbrk53),
			.crconce_o(crc53)
); 
Rx_Dy Rx54(
			.reset_n(i_reset_n),
			.clk(i_clk),
			.clk_20M(i_clk_20M),
			.M_R(i_Module_RX[53]),
			.LinkUdc(LinkUdc[53]),
			.LinkStaa(LinkState[106]),
			.LinkStab(LinkState[107]),
			.optbrk_o(optbrk54),
			.crconce_o(crc54)
); 
//Rx_Dy Rx55(
//			.reset_n(i_reset_n),
//			.clk(i_clk),
//			.clk_20M(i_clk_20M),
//			.M_R(i_Module_RX[54]),
//			.LinkUdc(LinkUdcC7),
//			.LinkStaa(LinkStateC7_l),
//			.LinkStab(LinkStateC7_h),
//			.optbrk_o(optbrk55),
//			.crconce_o(crc55)
//); 
//Rx_Dy Rx56(
//			.reset_n(i_reset_n),
//			.clk(i_clk),
//			.clk_20M(i_clk_20M),
//			.M_R(i_Module_RX[55]),
//			.LinkUdc(LinkUdcC8),
//			.LinkStaa(LinkStateC8_l),
//			.LinkStab(LinkStateC8_h),
//			.optbrk_o(optbrk56),
//			.crconce_o(crc56)
//); 
//Rx_Dy Rx57(
//			.reset_n(i_reset_n),
//			.clk(i_clk),
//			.clk_20M(i_clk_20M),
//			.M_R(i_Module_RX[56]),
//			.LinkUdc(LinkUdcC9),
//			.LinkStaa(LinkStateC9_l),
//			.LinkStab(LinkStateC9_h),
//			.optbrk_o(optbrk57),
//			.crconce_o(crc57)
//); 
//Rx_Dy Rx58(
//			.reset_n(i_reset_n),
//			.clk(i_clk),
//			.clk_20M(i_clk_20M),
//			.M_R(i_Module_RX[57]),
//			.LinkUdc(LinkUdcC10),
//			.LinkStaa(LinkStateC10_l),
//			.LinkStab(LinkStateC10_h),
//			.optbrk_o(optbrk58),
//			.crconce_o(crc58)
//); 
//Rx_Dy Rx59(
//			.reset_n(i_reset_n),
//			.clk(i_clk),
//			.clk_20M(i_clk_20M),
//			.M_R(i_Module_RX[58]),
//			.LinkUdc(LinkUdcC11),
//			.LinkStaa(LinkStateC11_l),
//			.LinkStab(LinkStateC11_h),
//			.optbrk_o(optbrk59),
//			.crconce_o(crc59)
//);
//Rx_Dy Rx60(
//			.reset_n(i_reset_n),
//			.clk(i_clk),
//			.clk_20M(i_clk_20M),
//			.M_R(i_Module_RX[59]),
//			.LinkUdc(LinkUdcC12),
//			.LinkStaa(LinkStateC12_l),
//			.LinkStab(LinkStateC12_h),
//			.optbrk_o(optbrk60),
//			.crconce_o(crc60)
//);  
//Rx_Dy Rx61(
//			.reset_n(i_reset_n),
//			.clk(i_clk),
//			.clk_20M(i_clk_20M),
//			.M_R(i_Module_RX[60]),
//			.LinkUdc(LinkUdcC13),
//			.LinkStaa(LinkStateC13_l),
//			.LinkStab(LinkStateC13_h),
//			.optbrk_o(optbrk61),
//			.crconce_o(crc61)
//);
//Rx_Dy Rx62(
//			.reset_n(i_reset_n),
//			.clk(i_clk),
//			.clk_20M(i_clk_20M),
//			.M_R(i_Module_RX[61]),
//			.LinkUdc(LinkUdcC14),
//			.LinkStaa(LinkStateC14_l),
//			.LinkStab(LinkStateC14_h),
//			.optbrk_o(optbrk62),
//			.crconce_o(crc62)
//);
//Rx_Dy Rx63(
//			.reset_n(i_reset_n),
//			.clk(i_clk),
//			.clk_20M(i_clk_20M),
//			.M_R(i_Module_RX[62]),
//			.LinkUdc(LinkUdcC15),
//			.LinkStaa(LinkStateC15_l),
//			.LinkStab(LinkStateC15_h),
//			.optbrk_o(optbrk63),
//			.crconce_o(crc63)
//);
//Rx_Dy Rx64(
//			.reset_n(i_reset_n),
//			.clk(i_clk),
//			.clk_20M(i_clk_20M),
//			.M_R(i_Module_RX[63]),
//			.LinkUdc(LinkUdcC16),
//			.LinkStaa(LinkStateC16_l),
//			.LinkStab(LinkStateC16_h),
//			.optbrk_o(optbrk64),
//			.crconce_o(crc64)
//);
//Rx_Dy Rx65(
//			.reset_n(i_reset_n),
//			.clk(i_clk),
//			.clk_20M(i_clk_20M),
//			.M_R(i_Module_RX[64]),
//			.LinkUdc(LinkUdcC17),
//			.LinkStaa(LinkStateC17_l),
//			.LinkStab(LinkStateC17_h),
//			.optbrk_o(optbrk65),
//			.crconce_o(crc65)
//);
//Rx_Dy Rx66(
//			.reset_n(i_reset_n),
//			.clk(i_clk),
//			.clk_20M(i_clk_20M),
//			.M_R(i_Module_RX[65]),
//			.LinkUdc(LinkUdcC18),
//			.LinkStaa(LinkStateC18_l),
//			.LinkStab(LinkStateC18_h),
//			.optbrk_o(optbrk66),
//			.crconce_o(crc66)
//);
//Rx_Dy Rx67(
//			.reset_n(i_reset_n),
//			.clk(i_clk),
//			.clk_20M(i_clk_20M),
//			.M_R(i_Module_RX[66]),
//			.LinkUdc(LinkUdcC19),
//			.LinkStaa(LinkStateC19_l),
//			.LinkStab(LinkStateC19_h),
//			.optbrk_o(optbrk67),
//			.crconce_o(crc67)
//);
//Rx_Dy Rx68(
//			.reset_n(i_reset_n),
//			.clk(i_clk),
//			.clk_20M(i_clk_20M),
//			.M_R(i_Module_RX[67]),
//			.LinkUdc(LinkUdcC20),
//			.LinkStaa(LinkStateC20_l),
//			.LinkStab(LinkStateC20_h),
//			.optbrk_o(optbrk68),
//			.crconce_o(crc68)
//);
//Rx_Dy Rx69(
//			.reset_n(i_reset_n),
//			.clk(i_clk),
//			.clk_20M(i_clk_20M),
//			.M_R(i_Module_RX[68]),
//			.LinkUdc(LinkUdcC21),
//			.LinkStaa(LinkStateC21_l),
//			.LinkStab(LinkStateC21_h),
//			.optbrk_o(optbrk69),
//			.crconce_o(crc69)
//);
//Rx_Dy Rx70(
//			.reset_n(i_reset_n),
//			.clk(i_clk),
//			.clk_20M(i_clk_20M),
//			.M_R(i_Module_RX[69]),
//			.LinkUdc(LinkUdcC22),
//			.LinkStaa(LinkStateC22_l),
//			.LinkStab(LinkStateC22_h),
//			.optbrk_o(optbrk70),
//			.crconce_o(crc70)
//);
//Rx_Dy Rx71(
//			.reset_n(i_reset_n),
//			.clk(i_clk),
//			.clk_20M(i_clk_20M),
//			.M_R(i_Module_RX[70]),
//			.LinkUdc(LinkUdcC23),
//			.LinkStaa(LinkStateC23_l),
//			.LinkStab(LinkStateC23_h),
//			.optbrk_o(optbrk71),
//			.crconce_o(crc71)
//);
//Rx_Dy Rx72(
//			.reset_n(i_reset_n),
//			.clk(i_clk),
//			.clk_20M(i_clk_20M),
//			.M_R(i_Module_RX[71]),
//			.LinkUdc(LinkUdcC24),
//			.LinkStaa(LinkStateC24_l),
//			.LinkStab(LinkStateC24_h),
//			.optbrk_o(optbrk72),
//			.crconce_o(crc72)
//);
//---------------------------------------
//wire cc = (o_Mod_ComSta1!=16'd0) || (o_Mod_ComSta5!=16'd0) || (o_Mod_ComSta9!=16'd0) || crc54 || crc53 || crc36||crc35||crc18||crc17;
//wire cc = (o_Mod_ComSta3!=16'd0) || (o_Mod_ComSta7!=16'd0) || (o_Mod_ComSta11!=16'd0)||optbrk17||optbrk18||optbrk35||optbrk36||optbrk53||optbrk54;
//wire [35:0] ILAControl;
//wire [79:0] data_chipscp;

//assign data_chipscp [15:0] = o_Mod_ComSta1;
//assign data_chipscp [31:16] = o_Mod_ComSta5;
//assign data_chipscp [47:32] = o_Mod_ComSta9;
//assign data_chipscp [63:48] = {10'd0,crc54,crc53,crc36,crc35,crc18,crc17};
//
//assign data_chipscp [15:0] = o_Mod_ComSta3;
//assign data_chipscp [31:16] = o_Mod_ComSta7;
//assign data_chipscp [47:32] = o_Mod_ComSta11;
//assign data_chipscp [63:48] = {10'd0,optbrk54,optbrk53,optbrk36,optbrk35,optbrk18,optbrk17};


//assign data_chipscp [15:0] = LinkUdc[12];
//assign data_chipscp [31:16] = LinkState[25];
//assign data_chipscp [47:32] = LinkState[24];
//assign data_chipscp [63:48] = LinkUdc[13];
//assign data_chipscp [79:64] = LinkState[27];
//assign data_chipscp [95:80] = LinkState[26];
//assign data_chipscp [111:96] = LinkUdc[14];
//assign data_chipscp [127:112] = LinkState[29];
//assign data_chipscp [143:128] = LinkState[28];
//assign data_chipscp [159:144] = LinkUdc[15];
//assign data_chipscp [175:160] = LinkState[31];
//assign data_chipscp [191:176] = LinkState[30];
//assign data_chipscp [207:192] = LinkUdc[16];
//assign data_chipscp [223:208] = LinkState[33];
//assign data_chipscp [239:224] = LinkState[32];
//assign data_chipscp [255:240] = LinkUdc[17];
//assign data_chipscp [271:256] = LinkState[35];
//assign data_chipscp [287:272] = LinkState[34];
//
//assign data_chipscp [303:288] = LinkUdc[18];
//assign data_chipscp [319:304] = LinkState[37];
//assign data_chipscp [335:320] = LinkState[36];
//assign data_chipscp [351:336] = LinkUdc[19];
//assign data_chipscp [367:352] = LinkState[39];
//assign data_chipscp [383:368] = LinkState[38];
//assign data_chipscp [399:384] = LinkUdc[20];
//assign data_chipscp [415:400] = LinkState[41];
//assign data_chipscp [431:416] = LinkState[40];
//assign data_chipscp [447:432] = LinkUdc[21];
//assign data_chipscp [463:448] = LinkState[43];
//assign data_chipscp [479:464] = LinkState[42];


//new_icon SVG_icon ( 
//     .CONTROL0            ( ILAControl) 
//); 
//
//new_ila SVG_ila ( 
//		.CONTROL            ( ILAControl), 
//		.CLK                ( i_clk), 
//		.DATA               ( data_chipscp), 
//		.TRIG0              (cc),
//		.TRIG1              (),
//		.TRIG2              (), 
//		.TRIG3              ( )
//		
//);
//--------------------------------------------------------
endmodule
