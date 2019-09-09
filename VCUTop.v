`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: CEPRI
// Engineer: Zhang Dianqing
// 
// Create Date:    14:42:21 01/22/2019 
// Design Name: 
// Module Name:    VCUTop 
// Project Name: 
// Target Devices: XC6SLX150-FGG484I
// Tool versions:  ISE14.7
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module VCUTop(
      //外部时钟源
		input							CLK_FPGA,  // 10 MHz
		//dsp接口
		input							XWE,XRD,XR_W,XZCS6,	 		 	
		input		[15:0]			DSP_A,
		inout		[15:0]			DSP_D,		
		output						XREADY, XRST,XRST_F,WDI,//WDI-以4M时钟为喂狗信号
		output						XINT1,//FPGA给DSP中断
      input                   rstn_in,
		//DSP与FPGA之间IO口、拨码开关
		input							LINK_F_D_1,LINK_F_D_2,LINK_F_D_3,LINK_F_D_4,LINK_F_D_5,LINK_F_D_6,LINK_F_D_7,LINK_F_D_8,						
		input                   Jump1,Jump2,Jump3,Jump4,                 
		//mcbsp接口及控制信号
		input							McDRA,McFSRA,McCLKRA,
		output                  McDXA,McFSXA,McCLKXA,
		output						McFS_DIR,McDXR_DIR,McCLK_DIR,			
		// 接收、发送光头
		input                   OPTO_IN1,OPTO_IN2,OPTO_IN3,OPTO_IN4,OPTO_IN5,OPTO_IN6,OPTO_IN7,OPTO_IN8,	
		output						OPTO_OUT1,OPTO_OUT2,OPTO_OUT3,OPTO_OUT4,OPTO_OUT5,OPTO_OUT6,OPTO_OUT7,OPTO_OUT8, 		
		// 接收、发送单元控制器串行信号
		input 	[53:0]         Module_RX,		  						  		
		output 	[53:0]         Module_TX,
		//板上LED
		output						TEST1,TEST2,TEST3,TEST4,
		//背板传输到前面板指示灯信号
		output						SA_F_LED,   //A系统指示灯
		output						IDLE_F_LED, //空闲指示灯
		output						ALARM_F_LED,//故障指示灯
		output						SB_F_LED		//B系统指示灯
);
//--------------------时钟及复位信号定义----------------------//
wire clk_20M;
wire clk_120M;
wire clk_100M;
wire clk_50M;
wire clk_15M;
wire clk_4M;
wire clk_1M;
wire clk_100K;
wire DcmLock;
wire reset_n1,reset_n2,reset_n3,reset_n4;          
//--------------------整体时序相关使能、启动信号定义------------------//
wire rdint_CP,start_PWM,start_DPRAM,start_txCP,start_Unit,start_mcbsp,start_rxsta;													 
//--------------------接收发送控保数据信号定义------------------//
wire [15:0]  ControlWord;//主从判断后最终的控制命令字
wire signed [31:0] TargetVolA,TargetVolB,TargetVolC;//主从判断后最终的调制电压
wire signed [15:0] Ave_TargetVolA,Ave_TargetVolB,Ave_TargetVolC;//相平均调制电压
wire signed [15:0] CosThetA,CosThetB,CosThetC;//主从判断后最终的余弦值
wire [15:0]  CtrlWord_A,CtrlWord_B;//主从A/B系统调制电压
wire [15:0]  RenewCntCP_A,RenewCntCP_B;//主从A/B系统更新计数器			
wire [15:0]  ComStaCP_A,ComStaCP_B;//主从A/B系统通信状态字
wire [15:0]  CP_MasSla_Sta;//控保主从状态字
wire [15:0]  PhaseStaCP;//给控保最终的相状态字
wire sumerr_DSP;//FPGA接收阀控DSP校验错误位   
//--------------------接收发送模块数据信号定义------------------//
wire [383:0] LinkUdcA_BUS,LinkUdcB_BUS,LinkUdcC_BUS;//模块直流电压汇总16*24=384
wire [863:0]linksta;
//wire [767:0] LinkStaA_BUS,LinkStaB_BUS,LinkStaC_BUS;//模块状态信息汇总16*2*24=768
wire [15:0]  Mod_ComSta1,Mod_ComSta2,Mod_ComSta3,Mod_ComSta4,Mod_ComSta5,Mod_ComSta6,
             Mod_ComSta7,Mod_ComSta8,Mod_ComSta9,Mod_ComSta10,Mod_ComSta11,Mod_ComSta12;//接收模块通信状态(校验+断线)
wire [9:0]   ram_addr_a,ram_addr_b,ram_addr_c;
wire [15:0]  ram_data_a,ram_data_b,ram_data_c;
wire [4:0]ram_addr_udca,ram_addr_udcb,ram_addr_udcc;
wire [15:0]ram_data_udca,ram_data_udcb,ram_data_udcc;
//--------------------PWM计算相关信号定义------------------//
wire [383:0] CtrlVolA_BUS,CtrlVolB_BUS,CtrlVolC_BUS;//模块调制电压汇总16*24=384
wire [47:0]  PWM_A_BUS,PWM_B_BUS,PWM_C_BUS;//2*24
wire [15:0]  PhaseA_Udc,PhaseB_Udc,PhaseC_Udc;//相平均直流电压
//--------------------与DSP相关信号定义------------------//
wire WD_RST,WD_DSP_ERR,XINT_DSP_ERR,DSP_ERR_RST;
assign XRST =  (Jump1)?  1'b1 : ~(WD_RST | DSP_ERR_RST);//复位DSP
wire [15:0]  VCU_Mode;//阀控机箱类型 3相合一/单相
wire [15:0]  para_grp_TFR;//录波组参数
wire [15:0]  PhaseStaDSP,LinkNum_Total,SwitchFreq,Udc_limit,Kp_Udc;
wire [15:0]  Redun_pos1,Redun_pos2,Redun_pos3,Redun_pos4,Redun_pos5,Redun_pos6;//模块冗余位置字
wire [15:0]dat_reserve[18:1];//DSP与FPGA之间的备用数据
//------------------------------------------------------
wire IN_OptoPhaseC_sysA,IN_OptoPhaseC_sysB,IN_phaselock1,IN_phaselock2;
wire OUT_OptoPhaseC_sysA,OUT_OptoPhaseC_sysB,OUT_phaselock1,OUT_phaselock2;
wire [15:0]ComSta_fastlock;//快速封锁状态字
assign IN_OptoPhaseC_sysA = Jump2 ? OPTO_IN7 : 1'b0;//三相的C相命令光纤
assign IN_OptoPhaseC_sysB = Jump2 ? OPTO_IN8 : 1'b0;
assign IN_phaselock1 = Jump2 ? 1'b0 : OPTO_IN7;//单相的相间封锁命令光纤
assign IN_phaselock2 = Jump2 ? 1'b0 : OPTO_IN8;
assign OPTO_OUT7 = Jump2 ? OUT_OptoPhaseC_sysA : OUT_phaselock1;//三相的C相命令光纤或单相的相间封锁命令光纤
assign OPTO_OUT8 = Jump2 ? OUT_OptoPhaseC_sysB : OUT_phaselock2;
//------------------------------------------------------
//封锁信号
wire mod_lock;//单元功率模块封锁信号
wire phaselock1_brk,phaselock2_brk;//相间封锁光纤断线
wire phaselock1_pulerr,phaselock2_pulerr;//相间封锁光纤频率错误
wire fastlock;//从测量机箱过来判主从后的快速封锁信号
wire phaselock1,phaselock2;//其他两相过来的封锁信号
assign	XREADY = 1'b1;
//--------------------前面板指示灯----------------------//
assign	ALARM_F_LED = ~ ( PhaseStaCP[0] | PhaseStaCP[8] );
assign	IDLE_F_LED = 1'b1;
assign	SA_F_LED = ~PhaseStaCP[13];
assign	SB_F_LED = ~PhaseStaCP[14];
//--------------------MCBSP驱动----------------------//
assign	McFS_DIR = 1'b1;
assign	McDXR_DIR = 1'b1;
assign	McCLK_DIR = 1'b1;
//--------------------不发光----------------------//
//assign OPTO_OUT1 = 1'b1;
//assign OPTO_OUT2 = 1'b1;
assign OPTO_OUT3 = 1'b1;
assign OPTO_OUT4 = 1'b1;
//assign OPTO_OUT5 = 1'b1;
//assign OPTO_OUT6 = 1'b1;
//assign XINT1 = 1'b1;
//assign OPTO_OUT7 = 1'b1;
//assign OPTO_OUT8 = 1'b1;

//--------------------板内指示灯------------------------//
assign	TEST1 = ~ControlWord[0] ; //主控复位
assign	TEST2 = ~PhaseStaCP[15];//~LED2 ; //DSP故障
assign	TEST3 = 1'b1;//~LED3 ;
assign	TEST4 = 1'b1;//~LED4;
//-----------------------------程序功能模块例化-----------------------------//
//-----------------------------u0_FPGA_Version---------------------------//
//模块名称：FPGA_Version
//模块功能：产生FPGA版本信息，通过上传DSP供上位机查询FPGA程序版本
 FPGA_Version u0_FPGA_Version (
								 .i_clk(clk_100M), 
								 .DSP_A(DSP_A), 
								 .DSP_D(DSP_D), 
								 .XZCS6(XZCS6), 
								 .XRD(XRD), 
								 .XWE(XWE)
    );
//-----------------------------u1_clk_sig---------------------------//
//模块名称：clk_sig
//模块功能：
 clk_sig u1_clk_sig (
								 .CLK_IN1(CLK_FPGA),      // 外部时钟源输入 10MHz
								 .clk_20M(clk_20M),       // OUT
								 .clk_100M(clk_100M),     // OUT
								 .clk_120M(clk_120M),
								 .clk_50M(clk_50M),       // OUT
								 .clk_15M(clk_15M),
								 .clk_4M(clk_4M),         // OUT
								 .clk_1M(clk_1M),         // OUT
								 .clk_100K(clk_100K),     // OUT
								 .DcmLock(DcmLock)// OUT
								 ); 
//-----------------------------u2_Reset_watchdog---------------------------//
//模块名称：Reset_watchdog
//模块功能：
//---------------------给99ms和101ms周期信号test-------
//reg [15:0]cnt_99,cnt_101;
//reg clk99_101;
//reg [2:0]cnt1;
//always @ (posedge clk_100K)
//begin
//	if ( cnt1 >= 3'd6 ) begin
//		cnt1 <= 3'd0;
//		cnt_99 <= 16'd0;
//		cnt_101 <= 16'd0;
//	end
//	else if ( cnt1 <=3'd2 ) begin
//		if ( cnt_99  == 16'd9900 ) begin
//			cnt_99 <= 16'd0;
//			clk99_101 <= ~clk99_101;
//			cnt1 <= cnt1 +3'd1;
//		end
//		else begin
//			cnt_99 <= cnt_99 + 16'd1;
//			cnt_101 <= 16'd0;
//			clk99_101 <= clk99_101;
//		end
//	end
//	else begin
//		if ( cnt_101  == 16'd10100 ) begin
//			cnt_101 <= 16'd0;
//			clk99_101 <= ~clk99_101;
//			cnt1 <= cnt1 +3'd1;
//		end
//		else begin
//			cnt_101 <= cnt_101 + 16'd1;
//			cnt_99 <= 16'd0;
//			clk99_101 <= clk99_101;
//		end
//	end
//end
//------------------------------------------------
Reset_watchdog u2_Reset_watchdog(
                         .i_clk(clk_20M),
								 .i_clk_wdi(clk_4M),
								 .clk_100M(clk_100M),
								 .i_DcmLock(DcmLock),
								 .i_WDI_dsp(LINK_F_D_1),   //DSP给FPGA的喂狗信号,IO口直连 test clk99_101),//
								 .i_XZCS6(XZCS6),
								 .i_XWE(XWE),
								 .i_XRD(XRD),
								 .i_DSP_A(DSP_A),
								 .o_reset_n1(reset_n1),    //主复位信号
								 .o_reset_n2(reset_n2),    //复位信号-单元接收模块
								 .o_reset_n3(reset_n3),    //复位信号-单元发送模块
								 .o_reset_n4(reset_n4),    //复位信号-PWM模块
								 .o_WD_RST(WD_RST),        //FPGA复位DSP复位信号
								 .o_DSP_ERR_RST(DSP_ERR_RST),//DSP中断故障复位信号
								 .o_XRST_F(XRST_F),        //光头复位信号-与时钟模块u1的复位信号一致
								 .o_WDI(WDI),              //FPGA给看门狗芯片喂狗信号-以4M时钟为喂狗信号
								 .o_WD_DSP_ERR(WD_DSP_ERR),    //DSP喂狗故障信号
								 .o_XINT_DSP_ERR(XINT_DSP_ERR)//DSP中断执行故障（地址操作）
								 );
//-----------------------------u3_Int_Ena_ctrl---------------------------//
//模块名称：Int_Ena_ctrl
//模块功能：
//--------------造78.1us信号------------
//reg[13:0] syn1_cnt;
//reg start_syn1;
//always @ (posedge clk_20M) 
//begin
//	if(syn1_cnt == 14'd1562) syn1_cnt<=14'd0;
//	else syn1_cnt<=syn1_cnt+1;
//	
//	if(syn1_cnt == 14'd1512)start_syn1 <= 1'b1;
//   else if(syn1_cnt ==14'd1562)start_syn1 <= 1'b0;	
//	else  start_syn1 <= start_syn1;	
//end
//--------------------------
//---------------------测试帧同步周期最大值和最小值的程序
//parameter ZHENZHOUQI = 173;
//parameter ZHENZHOUQIMAX = ZHENZHOUQI*20;
//parameter ZHENZHOUQIMIN = (ZHENZHOUQI - 8)*20; 
//reg spi_fs_in_reg,spi_fs_in_reg1,spi_fs_in_reg2;
//reg flag_min,flag_max;
//reg [15:0] cnt_spi;
//reg [15:0] cnt_reg;
//always @ (posedge clk_20M )
//begin
//	spi_fs_in_reg2 <= spi_fs_in_reg1;
//	spi_fs_in_reg1 <= spi_fs_in_reg;
//	spi_fs_in_reg <= XINT1;
//	if (!reset_n1)
//		cnt_spi <= 16'd0;
//	else if ( (spi_fs_in_reg1==1'b0) && (spi_fs_in_reg==1'b1) )
//	begin
//		cnt_reg <= cnt_spi;
//		cnt_spi <= 16'd0;
//	end		
//	else if (cnt_spi == ZHENZHOUQIMAX )
//		cnt_spi <= ZHENZHOUQIMAX;
//	else
//	begin
//		cnt_spi <= cnt_spi + 16'd1;
//		cnt_reg <= cnt_reg;
//	end
//end
//always @ (posedge clk_20M )
//begin	
//	if (!reset_n1)
//		flag_max <= 1'b0;
//	else if ( cnt_reg == ZHENZHOUQIMAX )
//		flag_max <= 1'b1;
//	else
//		flag_max <= 1'b0;
//end
//always @ (posedge clk_20M )
//begin	
//	if (!reset_n1)
//		flag_min <= 1'b0;
//	else if ( cnt_reg < ZHENZHOUQIMIN )
//		flag_min <= 1'b1;
//	else
//		flag_min <= 1'b0;
//end
//---------------------------	
Int_Ena_ctrl u3_Int_Ena_ctrl(
                         .i_clk(clk_100M),
								 .i_reset_n(reset_n1),
                         .i_syn_ref(rdint_CP),//外部同步参考信号  start_syn1),//
								 .o_xint_st(start_DPRAM),//写DPRAM启动信号
								 .o_PWM_calc_st(start_PWM),//PWM计算启动信号
								 .o_Module_tx_st(start_Unit),//发送单元模块通信启动信号
								 .o_CP_tx_st(start_txCP),//发送控保通信启动信号
								 .o_Mcbsp_tx_st(start_mcbsp),//MCBSP发送启动信号
								 .o_rxstaram(start_rxsta)
								 );
//-----------------------------u4_DPRAM---------------------------//
//模块名称：TOPDPRAM
//模块功能：
DPRAM1  u4_DPRAM (
                         .clk_100M(clk_100M),
								 .reset_n(reset_n1),
								 .start_DPRAM(start_DPRAM),
								 .DSP_A(DSP_A),
								 .DSP_D(DSP_D),
								 .XZCS6(XZCS6),
								 .XWE(XWE),
								 .XRD(XRD),
								 
								 .i_CtrlWord_A(CtrlWord_A),//控保A下发命令字
								 .i_CtrlWord_B(CtrlWord_B),//控保B下发命令字
								 .i_RenewCntCP_A(RenewCntCP_A),//控保A系统更新计数器
								 .i_RenewCntCP_B(RenewCntCP_B),//控保B系统更新计数器
								 .i_ComStaCP_A(ComStaCP_A),//接收控保A系统通讯状态字
								 .i_ComStaCP_B(ComStaCP_B),//接收控保B系统通讯状态字
								 .i_CP_MasSla_Sta(CP_MasSla_Sta),//控保主从状态字
								 .i_ComSta_fastlock(ComSta_fastlock),//快速封锁状态字
								 
								 .Phase_udcA(PhaseA_Udc),//相平均直流电压
								 .Phase_udcB(PhaseB_Udc),		
								 .Phase_udcC(PhaseC_Udc),	
								 
								 .ram_addr_a(ram_addr_a),
								 .ram_addr_b(ram_addr_b),
								 .ram_addr_c(ram_addr_c),
								 
								 .ram_data_a(ram_data_a),
								 .ram_data_b(ram_data_b),
								 .ram_data_c(ram_data_c),								 
										
								 .Phase_sta(PhaseStaDSP),//相状态字		
								 .LinkNum_Total(LinkNum_Total),//单相模块总个数		
								 .F_switch(SwitchFreq),//开关频率		
								 .Kp_Udc(Kp_Udc),//直流电压第三级控参		
								 .UdcThirdCtrlLim(Udc_limit),//直流电压第三级控制限幅
								 .o_Redun_pos1(Redun_pos1),//A/B/C冗余位置字
								 .o_Redun_pos2(Redun_pos2),
								 .o_Redun_pos3(Redun_pos3),
								 .o_Redun_pos4(Redun_pos4),
								 .o_Redun_pos5(Redun_pos5),
								 .o_Redun_pos6(Redun_pos6),
								 .o_VCU_Mode(VCU_Mode),//阀控机箱类型 3相合一/单相
								 .o_para_grp_TFR(para_grp_TFR),//录波组参数
								 .backup1(dat_reserve[1]),//DSP备用数据
								 .backup2(dat_reserve[2]),
								 .backup3(dat_reserve[3]),
								 .backup4(dat_reserve[4]),
								 .backup5(dat_reserve[5]),
								 .backup6(dat_reserve[6]),
								 .backup7(dat_reserve[7]),
								 .backup8(dat_reserve[8]),
								 .backup9(dat_reserve[9]),
								 .backup10(dat_reserve[10]),
								 .backup11(dat_reserve[11]),
								 .backup12(dat_reserve[12]),
								 .backup13(dat_reserve[13]),
								 .backup14(dat_reserve[14]),
								 .backup15(dat_reserve[15]),
								 .backup16(dat_reserve[16]),
								 .backup17(dat_reserve[17]),
								 .backup18(dat_reserve[18]),
								 
								 .XINT1(XINT1),//DSP中断
								 .sumerrKB(sumerr_DSP)//FPGA接收阀控DSP校验错误位
								);	
////-----------------------------u5_CP_TxRx---------------------------//
////模块名称：CP_TxRx
////模块功能：
assign Module_TX[53:1] = 53'd0;
CP_TxRx  u5_CP_TxRx(     
                         .i_clk(clk_100M),
								 .i_clk_20M(clk_20M),
								 .i_clk_100K(clk_100K),
								 .i_reset_n(reset_n1),
								 .i_start_txCP(start_txCP),//发送使能
								 .i_WD_DSP_ERR(WD_DSP_ERR),//DSP喂狗故障信号
								 .i_XINT_DSP_ERR(XINT_DSP_ERR),//DSP中断执行故障（地址操作）
								 .i_sumerr_DSP(sumerr_DSP),//FPGA接收阀控DSP校验错误位
								 .i_PhaseStaDSP(PhaseStaDSP),//DSP传给FPGA相状态字
								 .i_VCU_Mode(VCU_Mode),//阀控机箱类型 3相合一/单相		
								 .i_phaselock1_brk(phaselock1_brk),//相间封锁光纤1断线
								 .i_phaselock2_brk(phaselock2_brk),//相间封锁光纤2断线
								 .i_phaselock1_pulerr(phaselock1_pulerr),//相间封锁光纤1频率出错
								 .i_phaselock2_pulerr(phaselock2_pulerr),//相间封锁光纤2频率出错
								 
								 .i_OptoPhaseA_sysA(~OPTO_IN1),
								 .i_OptoPhaseA_sysB(~OPTO_IN2),
								 .i_OptoPhaseB_sysA(~OPTO_IN5),
								 .i_OptoPhaseB_sysB(~OPTO_IN6),
								 .i_OptoPhaseC_sysA(~IN_OptoPhaseC_sysA),
								 .i_OptoPhaseC_sysB(~IN_OptoPhaseC_sysB),								 
								 .o_OptoPhaseA_sysA(Module_TX[0]),
								 .o_OptoPhaseA_sysB(OPTO_OUT2),
								 .o_OptoPhaseB_sysA(OPTO_OUT5),
								 .o_OptoPhaseB_sysB(OPTO_OUT6),
								 .o_OptoPhaseC_sysA(OUT_OptoPhaseC_sysA),
								 .o_OptoPhaseC_sysB(OUT_OptoPhaseC_sysB),
								 
								 .i_fastlock1(~OPTO_IN3),//快速封锁光纤输入
								 .i_fastlock2(~OPTO_IN4),
								 .o_fastlock_final(fastlock),//从测量机箱过来判主从后的快速封锁信号
								 .o_ComSta_fastlock(ComSta_fastlock),//快速封锁状态字
								 .i_phaselock1(phaselock1),//其他两相过来的封锁信号
								 .i_phaselock2(phaselock2),
								 
								 .i_PhaseA_Udc(PhaseA_Udc),//相平均直流电压
								 .i_PhaseB_Udc(PhaseB_Udc),
								 .i_PhaseC_Udc(PhaseC_Udc),
								 
								 .o_ControlWord(ControlWord),//主从判断后最终的控制命令字
								 .o_TargetVolA(TargetVolA),//主从判断后最终的调制电压
								 .o_TargetVolB(TargetVolB),
								 .o_TargetVolC(TargetVolC),
								 .o_CosThetA(CosThetA),//主从判断后最终的余弦值
								 .o_CosThetB(CosThetB),
								 .o_CosThetC(CosThetC),
								 
								 .o_CtrlWord_A(CtrlWord_A),//控保A下发命令字
								 .o_CtrlWord_B(CtrlWord_B),//控保B下发命令字	
								 .o_RenewCntCP_A(RenewCntCP_A),//控保A系统更新计数器	
								 .o_RenewCntCP_B(RenewCntCP_B),//控保B系统更新计数器								 
								 .o_ComStaCP_A(ComStaCP_A),//接收控保A系统通讯状态字
								 .o_ComStaCP_B(ComStaCP_B),//接收控保B系统通讯状态字
								 .o_CP_MasSla_Sta(CP_MasSla_Sta),//控保主从状态字
								 
								 .o_rdint_CP(rdint_CP),//外部同步参考信号
								 .o_PhaseStaCP(PhaseStaCP)//给控保最终的相状态字
								 
							 );
//-----------------------------u6_Rx_Unit---------------------------//
//模块名称：Rx_Unit
//模块功能：
Rx_Unit       u6_Rx_Unit   (                         
                         .i_clk(clk_100M),
								 .i_clk_20M(clk_20M),
								 .i_reset_n(reset_n2),
								 .i_Module_RX(Module_RX[53:0]),	
								 
								 .start_DPRAM(start_DPRAM),
								 .start_rxsta(start_rxsta),
								 .ram_addr_a(ram_addr_a),
								 .ram_addr_b(ram_addr_b),
								 .ram_addr_c(ram_addr_c),
								 
								 .ram_data_a(ram_data_a),
								 .ram_data_b(ram_data_b),
								 .ram_data_c(ram_data_c),
								 
								 .ram_addr_udca(ram_addr_udca),
								 .ram_addr_udcb(ram_addr_udcb),
								 .ram_addr_udcc(ram_addr_udcc),
								 
								 .ram_data_udca(ram_data_udca),
								 .ram_data_udcb(ram_data_udcb),
								 .ram_data_udcc(ram_data_udcc),
								
								 .o_LinkUdcA_BUS(LinkUdcA_BUS),
								 .o_LinkUdcB_BUS(LinkUdcB_BUS),
								 .o_LinkUdcC_BUS(LinkUdcC_BUS),
								
								 .o_Mod_ComSta1(Mod_ComSta1),
								 .o_Mod_ComSta2(Mod_ComSta2),
								 .o_Mod_ComSta3(Mod_ComSta3),
								 .o_Mod_ComSta4(Mod_ComSta4),
								 .o_Mod_ComSta5(Mod_ComSta5),
								 .o_Mod_ComSta6(Mod_ComSta6),
								 .o_Mod_ComSta7(Mod_ComSta7),
								 .o_Mod_ComSta8(Mod_ComSta8),
								 .o_Mod_ComSta9(Mod_ComSta9),
								 .o_Mod_ComSta10(Mod_ComSta10),
								 .o_Mod_ComSta11(Mod_ComSta11),
								 .o_Mod_ComSta12(Mod_ComSta12),
								 .linksta_bus(linksta)
							  );	 
//-----------------------------u7_Tx_Unit---------------------------//
//模块名称：Tx_Unit
//模块功能：		
Tx_Unit       u7_Tx_Unit(								 
                         .i_clk(clk_20M),
								 .i_reset_n(reset_n3),
								 .i_ControlWord(ControlWord),//主从判断后最终的控制命令字
								 .i_PhaseSta(PhaseStaCP),//给控保最终的相状态字
								 .i_start_Unit(start_Unit),//发送单元模块通信启动信号
								 .i_lock(mod_lock),//单元功率模块封锁信号
								 .i_Redun_pos1(Redun_pos1),//A/B/C冗余位置字
								 .i_Redun_pos2(Redun_pos2),
								 .i_Redun_pos3(Redun_pos3),
								 .i_Redun_pos4(Redun_pos4),
								 .i_Redun_pos5(Redun_pos5),
								 .i_Redun_pos6(Redun_pos6),
								 .i_PWM_A_BUS(PWM_A_BUS),
								 .i_PWM_B_BUS(PWM_B_BUS),
								 .i_PWM_C_BUS(PWM_C_BUS),
								 .o_Module_TX()
								 );		
//-----------------------------u8_SpwmGen---------------------------//
//模块名称：SpwmGen
//模块功能：								
SpwmGen       u8_SpwmGen(
                         .i_clk(clk_50M),
								 .i_clk_20M(clk_20M),
								 .clk_100K(clk_100K),
								 .clk_1M(clk_1M),
								 .i_reset_n(reset_n4),
								 .i_start_PWM(start_PWM),
								 .i_TargetVolA(TargetVolA),//主从判断后最终的调制电压	
                         .i_TargetVolB(TargetVolB),
								 .i_TargetVolC(TargetVolC),
								 .i_CosThetA(CosThetA),//主从判断后最终的余弦值
								 .i_CosThetB(CosThetB),
								 .i_CosThetC(CosThetC),
								 
								 .i_LinkNum_Total(LinkNum_Total),//单相模块总个数	
								 .i_SwitchFreq(SwitchFreq),//开关频率
								 .i_Kp_Udc(Kp_Udc),//直流电压第三级控参	
								 .i_Udc_limit(Udc_limit),//直流电压第三级控制限幅
								 .i_Redun_pos1(Redun_pos1),//A/B/C冗余位置字
								 .i_Redun_pos2(Redun_pos2),
								 .i_Redun_pos3(Redun_pos3),
								 .i_Redun_pos4(Redun_pos4),
								 .i_Redun_pos5(Redun_pos5),
								 .i_Redun_pos6(Redun_pos6),
								 .i_VCU_Mode(VCU_Mode),//阀控机箱类型 3相合一/单相								 
					          
								 .i_LinkUdcA_BUS(LinkUdcA_BUS),//模块直流电压汇总
								 .i_LinkUdcB_BUS(LinkUdcB_BUS), 
								 .i_LinkUdcC_BUS(LinkUdcC_BUS),
								 
								 .o_PhaseA_Udc(PhaseA_Udc),//相平均直流电压		
								 .o_PhaseB_Udc(PhaseB_Udc),		
								 .o_PhaseC_Udc(PhaseC_Udc),
                         .Ave_TargetVolA(Ave_TargetVolA),//相平均调制电压	
								 .Ave_TargetVolB(Ave_TargetVolB),
								 .Ave_TargetVolC(Ave_TargetVolC),								 
								 
								 .o_PWM_A_BUS(PWM_A_BUS),//PWM波
								 .o_PWM_B_BUS(PWM_B_BUS),
								 .o_PWM_C_BUS(PWM_C_BUS),
								 .o_CtrlVolA_BUS(CtrlVolA_BUS),//模块调制电压汇总
								 .o_CtrlVolB_BUS(CtrlVolB_BUS),
								 .o_CtrlVolC_BUS(CtrlVolC_BUS)
								 );
//-----------------------------u9_Mcbsp_ctrl---------------------------//
//模块名称：Mcbsp_ctrl
//模块功能：
Mcbsp_ctrl    	u9_Mcbsp_ctrl(
                         .i_clk(clk_100M),
                         .i_clk_mcbsp(clk_15M),
                         .i_reset_n(reset_n1),
								 .i_Mcbsp_tx_st(start_mcbsp),//MCBSP发送启动信号
								 .i_ControlWord(ControlWord),//主系统控制命令字
								 .i_PhaseSta(PhaseStaCP),//(PhaseStaCP),//最终给控保的相状态字
								 .i_PhaseA_Udc(PhaseA_Udc),//相平均直流电压		
								 .i_PhaseB_Udc(PhaseB_Udc),		
								 .i_PhaseC_Udc(PhaseC_Udc),
								 .i_TargetVolA(Ave_TargetVolA),//相平均调制电压	
                         .i_TargetVolB(Ave_TargetVolB),
								 .i_TargetVolC(Ave_TargetVolC),
								 								 
								 .ram_addr_udca(ram_addr_udca),//A/B/C相直流电压
								 .ram_addr_udcb(ram_addr_udcb),
								 .ram_addr_udcc(ram_addr_udcc),
								 
								 .ram_data_udca(ram_data_udca),
								 .ram_data_udcb(ram_data_udcb),
								 .ram_data_udcc(ram_data_udcc),
								 
								 .i_CtrlVolA_BUS(CtrlVolA_BUS),//A/B/C调制波电压
								 .i_CtrlVolB_BUS(CtrlVolB_BUS),
								 .i_CtrlVolC_BUS(CtrlVolC_BUS),
								 
								 .i_VCU_Mode(),//阀控机箱类型 3相合一/单相
								 .i_para_grp_TFR(para_grp_TFR),//录波组参数
								 .backup1(dat_reserve[1]),//DSP备用数据
								 .backup2(dat_reserve[2]),
								 .backup3(dat_reserve[3]),
								 .backup4(dat_reserve[4]),
								 .backup5(dat_reserve[5]),
								 .backup6(dat_reserve[6]),
								 .backup7(dat_reserve[7]),
								 .backup8(dat_reserve[8]),
								 .backup9(dat_reserve[9]),
								 .backup10(dat_reserve[10]),
								 .backup11(dat_reserve[11]),
								 .backup12(dat_reserve[12]),
								 .backup13(dat_reserve[13]),
								 .backup14(dat_reserve[14]),
								 .backup15(dat_reserve[15]),
								 .backup16(dat_reserve[16]),
								 .backup17(dat_reserve[17]),
								 .backup18(dat_reserve[18]),
								 
    							 .o_McDXA(McDXA),//mcbsp帧同步、时钟、数据
								 .o_McFSXA(McFSXA),
								 .o_McCLKXA(McCLKXA),
								 .linksta_bus(linksta)
                         );			  
//-----------------------------u10_lock_handle---------------------------//
//模块名称：lock_handle
//模块功能：		
lock_handle   	u10_lock_handle(
                         .i_clk_20M(clk_20M),
								 .i_clk_lock(clk_1M),//封锁用时钟频率
								 .i_clk_nonlock(clk_100K),//非封锁用时钟频率
                         .i_reset_n(reset_n1),
								 .i_ControlWord(ControlWord),//主系统控制命令字
								 .i_PhaseSta(PhaseStaCP),//给控保最终的相状态字
								 .i_phaselock1(IN_phaselock1),//来自其他两相的互锁信号
								 .i_phaselock2(IN_phaselock2),
								 .i_fastlock(fastlock),//从测量机箱过来判主从后的快速封锁信号
								 .o_phaselock1_brk(phaselock1_brk),//相间封锁光纤1断线
								 .o_phaselock2_brk(phaselock2_brk),//相间封锁光纤2断线
								 .o_phaselock1_pulerr(phaselock1_pulerr),//相间封锁光纤1频率出错
								 .o_phaselock2_pulerr(phaselock2_pulerr),//相间封锁光纤2频率出错
								 .o_lock(mod_lock),//单元功率模块封锁信号
								 .o_phaselock1_opto(OUT_phaselock1),//给其他两相的互锁信号
								 .o_phaselock2_opto(OUT_phaselock2),
								 .o_phaselock1(phaselock1),//其他两相过来的封锁信号
								 .o_phaselock2(phaselock2)
                         );					 

//-----------------------------------Test---------------------------------
//wire [35:0] ILAControl;
//wire [79:0] data_chipscp; 
//assign data_chipscp [8:0] = {clk_20M,reset_n1,rdint_CP,start_DPRAM,start_PWM,start_Unit,start_txCP,start_mcbsp,XINT1};
//assign data_chipscp [31:16] = cnt_reg;
////assign data_chipscp [47:32] = {M48_T,M47_T,M46_T,M45_T,M44_T,M43_T,M42_T,M41_T,M40_T,M39_T,M38_T,M37_T,M36_T,M35_T,M34_T,M33_T};
////assign data_chipscp [63:48] = {M64_T,M63_T,M62_T,M61_T,M60_T,M59_T,M58_T,M57_T,M56_T,M55_T,M54_T,M53_T,M52_T,M51_T,M50_T,M49_T};
////assign data_chipscp [79:64] = {8'b0,M72_T,M71_T,M70_T,M69_T,M68_T,M67_T,M66_T,M65_T};
//
//
//new_icon SVG_icon ( 
//     .CONTROL0            ( ILAControl) 
//); 
//
//new_ila SVG_ila ( 
//     .CONTROL            ( ILAControl), 
//     .CLK                ( clk_100M), 
//     .DATA               ( data_chipscp), 
//     .TRIG0              (XINT1 ) ,
//	    .TRIG1              ( flag_max),
//     .TRIG2              (flag_min ), 
//	    .TRIG3              ( )
//);

endmodule
