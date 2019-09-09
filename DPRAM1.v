`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:07:49 04/08/2013 
// Design Name: 
// Module Name:    DPRAM1 
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
// 控保下发的信息传给DSP
//////////////////////////////////////////////////////////////////////////////////
module DPRAM1(
					input clk_100M,
					input reset_n,
					input start_DPRAM,
					input [15:0] DSP_A,
					inout [15:0] DSP_D,
					input XZCS6,
					input XWE,
					input XRD,
					
					input [15:0]i_CtrlWord_A,			
					input [15:0]i_CtrlWord_B,
					input [15:0]i_RenewCntCP_A,		
					input [15:0]i_RenewCntCP_B,
					input [15:0]i_ComStaCP_A,			
					input [15:0]i_ComStaCP_B,
					input [15:0]i_CP_MasSla_Sta,
					input [15:0]i_ComSta_fastlock,//快速封锁状态字
					
					input [15:0]Phase_udcA,          
					input [15:0]Phase_udcB,          
					input [15:0]Phase_udcC,

					 output [9:0]ram_addr_a,
					 output [9:0]ram_addr_b,
					 output [9:0]ram_addr_c,
					 
					 input [15:0]ram_data_a,
					 input [15:0]ram_data_b,
					 input [15:0]ram_data_c,
					
					output [15:0]Phase_sta,				
					output [15:0]LinkNum_Total,
					output [15:0]F_switch,				
					output [15:0]Kp_Udc,
					output [15:0]UdcThirdCtrlLim,
					output [15:0]o_Redun_pos1,			
					output [15:0]o_Redun_pos2,
					output [15:0]o_Redun_pos3,			
					output [15:0]o_Redun_pos4,
					output [15:0]o_Redun_pos5,			
					output [15:0]o_Redun_pos6,
					output [15:0]o_VCU_Mode,			
					output [15:0]o_para_grp_TFR,
					output [15:0]backup1,//DSP备用数据
					output [15:0]backup2,
					output [15:0]backup3,
					output [15:0]backup4,
					output [15:0]backup5,
					output [15:0]backup6,
					output [15:0]backup7,
					output [15:0]backup8,
					output [15:0]backup9,
					output [15:0]backup10,
					output [15:0]backup11,
					output [15:0]backup12,
					output [15:0]backup13,
					output [15:0]backup14,
					output [15:0]backup15,
					output [15:0]backup16,
					output [15:0]backup17,
					output [15:0]backup18,
					
					output XINT1,							
					output sumerrKB
);	

//DPRAM
wire [15:0] dsp_din;
wire [ 9:0] dsp_addr;
wire [15:0] dsp_dout;
wire dsp_w;
wire [15:0] ram_dout; //FPGA读RAM数据
wire [15:0] ram_din; //FPGA写RAM数据
wire [ 9:0] ram_addr;
reg ram_w_reg;
wire ram_w;
wire [ 9:0] addr_w;
wire [ 9:0] addr_r;
//DPRAM1 端口及数据
//a端口 DSP写平均直流电压、均压放电、开关频率等参数   地址范围0x100010~0x10002f 
//b端口 FPGA读平均直流电压、均压放电、开关频率等参数  地址范围0x100010~0x10002f`
//b端口 FPGA写主控数据  地址范围0x100100~0x1001ff
//a端口 DSP读主控数据   地址范围0x100100~0x1001ff
reg dsp_w_reg1,dsp_w_reg2;

assign dsp_w = ((XZCS6 == 1'b0)&&(DSP_A[15:8] == 8'h0)&&(XWE == 1'b0));	//写DSP使能信号,DSP写RAM数，地址范围0x100010~0x10002f
assign dsp_addr = (XZCS6 == 1'b0)? DSP_A[9:0] : 10'b0; //DSP地址
assign dsp_din = (dsp_w) ? DSP_D : 16'b0; //DSP写RAM数据
assign DSP_D = ((XWE==1'b1) && (XRD == 1'b0) && (XZCS6 == 1'b0)&&(DSP_A[15:8] == 8'h1))? dsp_dout : 16'bzzzzzzzzzzzzzzzz; //DSP读RAM数据

assign ram_addr = ram_w?  addr_w : addr_r; //RAM地址选择

reg [15:0] dsp_din_reg;
always @ ( posedge clk_100M )
begin
	if (!reset_n) begin
		dsp_w_reg1 <= 1'b0;
		dsp_w_reg2 <= 1'b0;
	end
	else begin
		dsp_w_reg1 <= dsp_w;
		dsp_w_reg2 <= dsp_w_reg1;
	end
end
DPRAM  DPRAM1
				(				
				  .clka	(clk_100M),
				  .wea	(dsp_w   	),//不能用dsp_w_reg2替换，因为DSP的写使能和数据线的匹配时序，延时20ns影响时序
				  .addra	(dsp_addr	),
				  .dina	(dsp_din_reg),
				  .douta	(dsp_dout	),
				  
				  .clkb	(clk_100M), 
				  .web	(ram_w   	),
				  .addrb	(ram_addr	),
				  .dinb	(ram_din    ),
				  .doutb	(ram_dout	)
				 );

always @ ( posedge clk_100M )
begin
	if (!reset_n ) dsp_din_reg	<=	16'd0;
	else dsp_din_reg <= dsp_din ;
end

//always @ ( posedge clk_100M )
//begin
//	if (!reset_n ) ram_w_reg<=	1'b0;
//	else ram_w_reg <= ram_w ;
//end

//FPGA写RAM
FPGA_wr FPGA_write (
							.clk_100M(clk_100M),						
							.reset_n(reset_n),
							.start_DPRAM(start_DPRAM),				
							.o_ram_wea(ram_w),
							.o_ram_addr(addr_w),							
							.o_ram_data(ram_din),
							.XINT1W(XINT1),							
							.XRD(XRD),

							.ControlWord_A(i_CtrlWord_A),			
							.ControlWord_B(i_CtrlWord_B),
							.RenewalCnt_RC_A(i_RenewCntCP_A),	
							.RenewalCnt_RC_B(i_RenewCntCP_B),
							.CommStateRC_A(i_ComStaCP_A),			
							.CommStateRC_B(i_ComStaCP_B),
							.ComStaCP(i_CP_MasSla_Sta),
							.ComSta_fastlock(i_ComSta_fastlock),
														
 							.Phase_udcA(Phase_udcA),         
							.Phase_udcB(Phase_udcB),         
							.Phase_udcC(Phase_udcC),
							
							.ram_addr_a(ram_addr_a),
							.ram_addr_b(ram_addr_b),
							.ram_addr_c(ram_addr_c),
								 
							.ram_data_a(ram_data_a),
							.ram_data_b(ram_data_b),
							.ram_data_c(ram_data_c)
);

//FPGA读RAM
FPGA_rd   FPGA_rd (
							.clk_100M(clk_100M),				
							.reset_n(reset_n),
							.addr_r(addr_r),					
							.XINT1(XINT1),
							.ram_dout(ram_dout),				
							.XWE(XWE),
							.dsp_w(dsp_w_reg2),
							
							.Phase_sta(Phase_sta),			
							.LinkNum_Total(LinkNum_Total),
							.F_switch(F_switch),				
							.Kp_Udc(Kp_Udc),		
							.UdcThirdCtrlLim(UdcThirdCtrlLim),
							.sumerrKB(sumerrKB),
							.Redun_pos1(o_Redun_pos1),		
							.Redun_pos2(o_Redun_pos2),
							.Redun_pos3(o_Redun_pos3),		
							.Redun_pos4(o_Redun_pos4),
							.Redun_pos5(o_Redun_pos5),		
							.Redun_pos6(o_Redun_pos6),
							.VCU_Mode(o_VCU_Mode),			
							.para_grp_TFR(o_para_grp_TFR),
							.backup1(backup1),//DSP备用数据
							.backup2(backup2),
							.backup3(backup3),
							.backup4(backup4),
							.backup5(backup5),
							.backup6(backup6),
							.backup7(backup7),
							.backup8(backup8),
							.backup9(backup9),
							.backup10(backup10),
							.backup11(backup11),
							.backup12(backup12),
							.backup13(backup13),
							.backup14(backup14),
							.backup15(backup15),
							.backup16(backup16),
							.backup17(backup17),
							.backup18(backup18)
);
//	 
//wire [35:0] ILAControl;
//wire [79:0] data_chipscp; 
//assign data_chipscp [15:0] = {13'd0,ram_w_reg,start_DPRAM,XINT1};
//assign data_chipscp [31:16] = ram_addr;
//assign data_chipscp [47:32] =ram_dout;
//assign data_chipscp [63:48] =dsp_addr;
//assign data_chipscp [79:64] =dsp_dout;
//
//ICON_GL SVG_icon ( 
//     .CONTROL0            ( ILAControl) 
//); 
//
//ILA_GL SVG_ila ( 
//     .CONTROL            ( ILAControl), 
//     .CLK                ( clk_100M), 
//     .DATA               ( data_chipscp), 
//     .TRIG0              ( start_DPRAM), 
//	  .TRIG1              (  ),
//	  .TRIG2              (  ),
//	  .TRIG3              ( )
//);
endmodule
