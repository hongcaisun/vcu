`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: CEPRI
// Engineer: Zhang Dian-qing
// 
// Create Date:    15:15:01 03/14/2019 
// Design Name: 
// Module Name:    SpwmGen 
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
module SpwmGen(
					input i_clk,
					input i_clk_20M,
					input clk_100K,
					input clk_1M,
					input i_reset_n,
					input i_start_PWM,
					input signed[31:0]i_TargetVolA,i_TargetVolB,i_TargetVolC,//主从判断后最终的调制电压
               input signed[15:0]i_CosThetA,i_CosThetB,i_CosThetC,//主从判断后最终的余弦值					
               input [15:0]i_LinkNum_Total,//单相模块总个数
					input [15:0]i_SwitchFreq,//开关频率
					input [15:0]i_Kp_Udc,//直流电压第三级控参
					input [15:0]i_Udc_limit,//直流电压第三级控制限幅
					input [15:0]i_Redun_pos1,i_Redun_pos2,i_Redun_pos3,i_Redun_pos4,i_Redun_pos5,i_Redun_pos6,//A/B/C冗余位置字
					input [15:0]i_VCU_Mode,//阀控机箱类型 3相合一/单相				
					input [383:0]i_LinkUdcA_BUS,i_LinkUdcB_BUS,i_LinkUdcC_BUS,//模块直流电压汇总
					output [15:0]o_PhaseA_Udc,o_PhaseB_Udc,o_PhaseC_Udc,//相平均直流电压	
					output signed [15:0] Ave_TargetVolA,Ave_TargetVolB,Ave_TargetVolC,//三相平均调制电压
					output [47:0]o_PWM_A_BUS,o_PWM_B_BUS,o_PWM_C_BUS,//PWM波
					output [383:0]o_CtrlVolA_BUS,o_CtrlVolB_BUS,o_CtrlVolC_BUS//模块调制电压汇总
					);						
//-------------------------------Main Program Starts---------------------------------------------//					
//warning!目前由72个模块改为54个模块，故相应的变量做调整
parameter TOTAL_NUM_MODEL = 6'd18;
parameter BIT_NUM = 18'd0;//18'd0 54个模块 24'd0 72个模块
wire [15:0]i_Redun_pos2_ini = {14'h3f,i_Redun_pos2[1:0]};//18个模块，后面6个全部冗余，该参数主要针对PWM计算初始相角计算模块
wire [15:0]i_Redun_pos4_ini = {14'h3f,i_Redun_pos4[1:0]};
wire [15:0]i_Redun_pos6_ini = {14'h3f,i_Redun_pos6[1:0]};
//------------------------------------------------------------
wire  [15:0] LinkNumA_Work,LinkNumB_Work,LinkNumC_Work;//ABC三相正常工作、没有冗余的链节数目
wire  redun_Syn;//冗余后产生一次载波同步信号
wire  carrier_syn_out;//载波周期同步信号
wire  Carrier_Syn = redun_Syn | carrier_syn_out;//载波同步信号

wire [15:0]angle_shiftA,angle_shiftB,angle_shiftC;//ABC三相相邻模块三角载波移相角
wire [383:0]initi_angleA_BUS,initi_angleB_BUS,initi_angleC_BUS;//模块初始相角
wire [15:0]Freqency_cnt;//开关频率计数器20M时钟
wire signed [15:0] temp; 
wire signed [31:0] temp_long; 
//----------------实际工作链节模块数计算模块-----------------//
WorkNum_calc #(
					.TOTAL_NUM_MODEL(TOTAL_NUM_MODEL),
					.BIT_NUM(BIT_NUM)
)
WorkNum_calc(
          .i_clk_20M(i_clk_20M),
			 .i_reset_n(i_reset_n),
			 .i_LinkNum_Total(i_LinkNum_Total),//单相模块总个数
			 .i_VCU_Mode(i_VCU_Mode),//阀控机箱类型 3相合一/单相
			 .i_Redun_pos1(i_Redun_pos1),//A/B/C冗余位置字
			 .i_Redun_pos2(i_Redun_pos2),
			 .i_Redun_pos3(i_Redun_pos3),
			 .i_Redun_pos4(i_Redun_pos4),
			 .i_Redun_pos5(i_Redun_pos5),
			 .i_Redun_pos6(i_Redun_pos6),
			 .o_LinkNumA_Work(LinkNumA_Work),//ABC三相正常工作、没有冗余的链节数目
			 .o_LinkNumB_Work(LinkNumB_Work),
			 .o_LinkNumC_Work(LinkNumC_Work),
			 .redun_Syn(redun_Syn)//冗余后产生一次载波同步信号
			 );
//----------------相平均直流电压指令计算模块-----------------//
Ave_phaseUdc_calc  Ave_phaseUdc_calc(
          .i_clk_20M(i_clk_20M),
			 .i_reset_n(i_reset_n),
			 .i_VCU_Mode(i_VCU_Mode),//阀控机箱类型 3相合一/单相	 			 
			 .i_LinkUdcA_BUS(i_LinkUdcA_BUS),//模块直流电压汇总
			 .i_LinkUdcB_BUS(i_LinkUdcB_BUS),
			 .i_LinkUdcC_BUS(i_LinkUdcC_BUS),
			 .i_LinkNumA_Work(LinkNumA_Work),//ABC三相正常工作、没有冗余的链节数目
			 .i_LinkNumB_Work(LinkNumB_Work),
			 .i_LinkNumC_Work(LinkNumC_Work),
			 
			 .o_PhaseA_Udc(o_PhaseA_Udc),//相平均直流电压	
			 .o_PhaseB_Udc(o_PhaseB_Udc),
			 .o_PhaseC_Udc(o_PhaseC_Udc)			 			 
			 );
//----------------每个模块平均调节电压指令计算模块-----------------//
Ave_TargetVol_calc  Ave_TargetVol_calc(
          .i_clk_20M(i_clk_20M),
			 .i_reset_n(i_reset_n),
			 .i_VCU_Mode(i_VCU_Mode),//阀控机箱类型 3相合一/单相	 			 
			 .i_TargetVolA(i_TargetVolA),//主从判断后最终的调制电压
			 .i_TargetVolB(i_TargetVolB),
			 .i_TargetVolC(i_TargetVolC),
			 .i_LinkNumA_Work(LinkNumA_Work),//ABC三相正常工作、没有冗余的链节数目
			 .i_LinkNumB_Work(LinkNumB_Work),
			 .i_LinkNumC_Work(LinkNumC_Work),
			 
			 .o_Ave_TargetVolA(Ave_TargetVolA),//相平均调制电压	
			 .o_Ave_TargetVolB(Ave_TargetVolB),
			 .o_Ave_TargetVolC(Ave_TargetVolC)			 			 
			 );

//----------------相邻工作模块PWM三角载波移相角计算模块-----------------//
Angle_shift_calc Angle_shift_calc(
          .i_clk_20M(i_clk_20M),
			 .i_reset_n(i_reset_n),
			 .i_VCU_Mode(i_VCU_Mode),//阀控机箱类型 3相合一/单相
			 .i_SwitchFreq(i_SwitchFreq),//开关频率
			 .i_LinkNumA_Work(LinkNumA_Work),//ABC三相正常工作、没有冗余的链节数目
			 .i_LinkNumB_Work(LinkNumB_Work),
			 .i_LinkNumC_Work(LinkNumC_Work),
			 .o_Freqency_cnt(Freqency_cnt),//开关频率计数器20M时钟
			 .o_temp(temp),
			 .o_temp_long(temp_long),
          .o_angle_shiftA(angle_shiftA),//ABC三相相邻模块三角载波移相角
			 .o_angle_shiftB(angle_shiftB),
			 .o_angle_shiftC(angle_shiftC)
          );
//----------------三角载波同步生成模块-----------------//
Carrier_Syn_gen Carrier_Syn_gen(
          .i_clk_20M(i_clk_20M),
			 .i_reset_n(i_reset_n),
			 .i_Freqency_cnt(Freqency_cnt),//开关频率计数器20M时钟
			 .o_syn_out(carrier_syn_out)//载波周期同步信号
          );
//----------------PWM计算初始相角计算模块-----------------//
Initial_Angle_calc  Initial_Angle_calc(
          .i_clk_20M(i_clk_20M),
			 .i_reset_n(i_reset_n),
			 .i_VCU_Mode(i_VCU_Mode),//阀控机箱类型 3相合一/单相
          .i_angle_shiftA(angle_shiftA),//ABC三相相邻模块三角载波移相角
			 .i_angle_shiftB(angle_shiftB),
			 .i_angle_shiftC(angle_shiftC),
			 .i_Redun_pos1(i_Redun_pos1),//A/B/C冗余位置字
			 .i_Redun_pos2(i_Redun_pos2_ini),
			 .i_Redun_pos3(i_Redun_pos3),
			 .i_Redun_pos4(i_Redun_pos4_ini),
			 .i_Redun_pos5(i_Redun_pos5),
			 .i_Redun_pos6(i_Redun_pos6_ini),
          .o_initi_angleA_BUS(initi_angleA_BUS),//模块初始相角
			 .o_initi_angleB_BUS(initi_angleB_BUS),
			 .o_initi_angleC_BUS(initi_angleC_BUS)
          );
//----------------载波移相CSPWM计算模块-----------------//
CSPWM_calc  CSPWM_calc(
          .i_clk(i_clk),
          .i_clk_20M(i_clk_20M),
			 .clk_cps(clk_100K),
			 .i_reset_n(i_reset_n),
			 .i_start_PWM(i_start_PWM),
			 .i_VCU_Mode(i_VCU_Mode),//阀控机箱类型 3相合一/单相
			 .i_Ave_TargetVolA(Ave_TargetVolA),//相平均调制电压	
			 .i_Ave_TargetVolB(Ave_TargetVolB),
			 .i_Ave_TargetVolC(Ave_TargetVolC),
			 .i_CosThetA(i_CosThetA),//主从判断后最终的余弦值
			 .i_CosThetB(i_CosThetB),
			 .i_CosThetC(i_CosThetC),
			 .i_LinkUdcA_BUS(i_LinkUdcA_BUS),//模块直流电压汇总
			 .i_LinkUdcB_BUS(i_LinkUdcB_BUS),
			 .i_LinkUdcC_BUS(i_LinkUdcC_BUS),
			 .i_PhaseA_Udc(o_PhaseA_Udc),//相平均直流电压	
			 .i_PhaseB_Udc(o_PhaseB_Udc),
			 .i_PhaseC_Udc(o_PhaseC_Udc),	
			 .i_Freqency_cnt(Freqency_cnt),//开关频率计数器20M时钟
			 .i_temp(temp),
			 .i_temp_long(temp_long),
			 .i_Carrier_Syn(Carrier_Syn),//载波同步信号
          .i_initi_angleA_BUS(initi_angleA_BUS),//模块初始相角
			 .i_initi_angleB_BUS(initi_angleB_BUS),
			 .i_initi_angleC_BUS(initi_angleC_BUS),
			 .i_Kp_Udc(i_Kp_Udc),//直流电压第三级控参
			 .i_Udc_limit(i_Udc_limit),//直流电压第三级控制限幅
			 .o_PWM_A_BUS(o_PWM_A_BUS),//PWM波
			 .o_PWM_B_BUS(o_PWM_B_BUS),
			 .o_PWM_C_BUS(o_PWM_C_BUS),
			 .o_CtrlVolA_BUS(o_CtrlVolA_BUS),//模块调制电压汇总
			 .o_CtrlVolB_BUS(o_CtrlVolB_BUS),
			 .o_CtrlVolC_BUS(o_CtrlVolC_BUS)
          );
//---------------------------------------
//reg[2:0] clk_10k_cnt;
//reg clk_10k;
//always @ (posedge clk_100K) 
//begin
//	if(!i_reset_n)begin
//		clk_10k_cnt<=3'd0;
//		clk_10k<=1'b0;
//	end
//	else begin 
//		if(clk_10k_cnt == 3'd5) clk_10k_cnt<=3'd0;
//		else clk_10k_cnt<=clk_10k_cnt+1;
//		if(clk_10k_cnt == 3'd5) clk_10k<=~clk_10k;
//		else clk_10k<=clk_10k;
//	end
//end
//-------------------------------------------------------------------
//wire [35:0] ILAControl;
//wire [671:0] data_chipscp;

//assign data_chipscp [15:0] = LinkNumA_Work;
//assign data_chipscp [31:16] = LinkNumB_Work;
//assign data_chipscp [47:32] = LinkNumC_Work;
//assign data_chipscp [63:48] = initi_angleA_BUS[383:368];
//assign data_chipscp [79:64] = initi_angleA_BUS[367:352];
//assign data_chipscp [95:80] = initi_angleA_BUS[351:336];
//assign data_chipscp [111:96] = initi_angleA_BUS[335:320];
//assign data_chipscp [127:112] = initi_angleA_BUS[319:304];
//assign data_chipscp [143:128] = initi_angleA_BUS[303:288];
//assign data_chipscp [159:144] = initi_angleA_BUS[287:272];
//assign data_chipscp [175:160] = initi_angleA_BUS[271:256];
//assign data_chipscp [191:176] = initi_angleA_BUS[255:240];
//assign data_chipscp [207:192] = initi_angleA_BUS[239:224];
//assign data_chipscp [223:208] = initi_angleA_BUS[223:208];
//assign data_chipscp [239:224] = initi_angleA_BUS[207:192];
//assign data_chipscp [255:240] = initi_angleA_BUS[191:176];
//assign data_chipscp [271:256] = initi_angleA_BUS[175:160];
//assign data_chipscp [287:272] = initi_angleA_BUS[159:144];
//assign data_chipscp [303:288] = initi_angleA_BUS[143:128];
//assign data_chipscp [319:304] = initi_angleA_BUS[127:112];
//assign data_chipscp [335:320] = initi_angleA_BUS[111:96];
//assign data_chipscp [351:336] = initi_angleA_BUS[95:80];
//assign data_chipscp [367:352] = initi_angleA_BUS[79:64];
//assign data_chipscp [383:368] = initi_angleA_BUS[63:48];
//assign data_chipscp [399:384] = initi_angleA_BUS[47:32];
//assign data_chipscp [415:400] = initi_angleA_BUS[31:16];
//assign data_chipscp [431:416] = initi_angleA_BUS[15:0];
//assign data_chipscp [447:432] = o_PhaseA_Udc;
//assign data_chipscp [463:448] = o_PhaseB_Udc;
//assign data_chipscp [479:464] = o_PhaseC_Udc;
//assign data_chipscp [495:480] = Ave_TargetVolA;
//assign data_chipscp [511:496] = Ave_TargetVolB;
//assign data_chipscp [559:512] = {angle_shiftB,angle_shiftA,Ave_TargetVolC};
//assign data_chipscp [607:560] = {32'b0,angle_shiftC};
//assign data_chipscp [655:608] = {};

//assign data_chipscp [15:0] = i_TargetVolA[15:0];
//assign data_chipscp [31:16] = i_TargetVolA[31:16];
//assign data_chipscp [47:32] = i_TargetVolB[15:0];
//assign data_chipscp [63:48] = o_CtrlVolA_BUS[383:368];
//assign data_chipscp [79:64] = o_CtrlVolA_BUS[367:352];
//assign data_chipscp [95:80] = o_CtrlVolA_BUS[351:336];
//assign data_chipscp [111:96] = o_CtrlVolA_BUS[335:320];
//assign data_chipscp [127:112] = o_CtrlVolA_BUS[319:304];
//assign data_chipscp [143:128] = o_CtrlVolA_BUS[303:288];
//assign data_chipscp [159:144] = o_CtrlVolA_BUS[287:272];
//assign data_chipscp [175:160] = o_CtrlVolA_BUS[271:256];
//assign data_chipscp [191:176] = o_CtrlVolA_BUS[255:240];
//assign data_chipscp [207:192] = o_CtrlVolA_BUS[239:224];
//assign data_chipscp [223:208] = o_CtrlVolA_BUS[223:208];
//assign data_chipscp [239:224] = o_CtrlVolA_BUS[207:192];
//assign data_chipscp [255:240] = o_CtrlVolA_BUS[191:176];
//assign data_chipscp [271:256] = o_CtrlVolA_BUS[175:160];
//assign data_chipscp [287:272] = o_CtrlVolA_BUS[159:144];
//assign data_chipscp [303:288] = o_CtrlVolA_BUS[143:128];
//assign data_chipscp [319:304] = o_CtrlVolA_BUS[127:112];
//assign data_chipscp [335:320] = o_CtrlVolA_BUS[111:96];
//assign data_chipscp [351:336] = o_CtrlVolA_BUS[95:80];
//assign data_chipscp [367:352] = o_CtrlVolA_BUS[79:64];
//assign data_chipscp [671:656] = o_CtrlVolA_BUS[63:48];
//assign data_chipscp [383:368] = o_CtrlVolA_BUS[47:32];
//assign data_chipscp [399:384] = o_CtrlVolA_BUS[31:16];
//assign data_chipscp [415:400] = o_CtrlVolA_BUS[15:0];
//assign data_chipscp [431:416] = i_TargetVolB[31:16];
//assign data_chipscp [447:432] = i_TargetVolC[15:0];
//assign data_chipscp [463:448] = i_TargetVolC[31:16];
//assign data_chipscp [479:464] = Ave_TargetVolA;
//assign data_chipscp [495:480] = Ave_TargetVolB;
//assign data_chipscp [511:496] = Ave_TargetVolC;
//assign data_chipscp [559:512] = o_PWM_A_BUS;
//assign data_chipscp [607:560] = o_PWM_B_BUS;
//assign data_chipscp [655:608] = o_PWM_C_BUS;
//
//
//new_icon SVG_icon ( 
//     .CONTROL0            ( ILAControl) 
//); 
//
//new_ila SVG_ila ( 
//		.CONTROL            ( ILAControl), 
//		.CLK                ( clk_1M), 
//		.DATA               ( data_chipscp), 
//		.TRIG0              (i_start_PWM),
//		.TRIG1              (),
//		.TRIG2              (), 
//		.TRIG3              ( )
//		
//);
//--------------------------------------------------------
	
endmodule
