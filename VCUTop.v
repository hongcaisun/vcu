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
      //�ⲿʱ��Դ
		input							CLK_FPGA,  // 10 MHz
		//dsp�ӿ�
		input							XWE,XRD,XR_W,XZCS6,	 		 	
		input		[15:0]			DSP_A,
		inout		[15:0]			DSP_D,		
		output						XREADY, XRST,XRST_F,WDI,//WDI-��4Mʱ��Ϊι���ź�
		output						XINT1,//FPGA��DSP�ж�
      input                   rstn_in,
		//DSP��FPGA֮��IO�ڡ����뿪��
		input							LINK_F_D_1,LINK_F_D_2,LINK_F_D_3,LINK_F_D_4,LINK_F_D_5,LINK_F_D_6,LINK_F_D_7,LINK_F_D_8,						
		input                   Jump1,Jump2,Jump3,Jump4,                 
		//mcbsp�ӿڼ������ź�
		input							McDRA,McFSRA,McCLKRA,
		output                  McDXA,McFSXA,McCLKXA,
		output						McFS_DIR,McDXR_DIR,McCLK_DIR,			
		// ���ա����͹�ͷ
		input                   OPTO_IN1,OPTO_IN2,OPTO_IN3,OPTO_IN4,OPTO_IN5,OPTO_IN6,OPTO_IN7,OPTO_IN8,	
		output						OPTO_OUT1,OPTO_OUT2,OPTO_OUT3,OPTO_OUT4,OPTO_OUT5,OPTO_OUT6,OPTO_OUT7,OPTO_OUT8, 		
		// ���ա����͵�Ԫ�����������ź�
		input 	[53:0]         Module_RX,		  						  		
		output 	[53:0]         Module_TX,
		//����LED
		output						TEST1,TEST2,TEST3,TEST4,
		//���崫�䵽ǰ���ָʾ���ź�
		output						SA_F_LED,   //Aϵͳָʾ��
		output						IDLE_F_LED, //����ָʾ��
		output						ALARM_F_LED,//����ָʾ��
		output						SB_F_LED		//Bϵͳָʾ��
);
//--------------------ʱ�Ӽ���λ�źŶ���----------------------//
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
//--------------------����ʱ�����ʹ�ܡ������źŶ���------------------//
wire rdint_CP,start_PWM,start_DPRAM,start_txCP,start_Unit,start_mcbsp,start_rxsta;													 
//--------------------���շ��Ϳر������źŶ���------------------//
wire [15:0]  ControlWord;//�����жϺ����յĿ���������
wire signed [31:0] TargetVolA,TargetVolB,TargetVolC;//�����жϺ����յĵ��Ƶ�ѹ
wire signed [15:0] Ave_TargetVolA,Ave_TargetVolB,Ave_TargetVolC;//��ƽ�����Ƶ�ѹ
wire signed [15:0] CosThetA,CosThetB,CosThetC;//�����жϺ����յ�����ֵ
wire [15:0]  CtrlWord_A,CtrlWord_B;//����A/Bϵͳ���Ƶ�ѹ
wire [15:0]  RenewCntCP_A,RenewCntCP_B;//����A/Bϵͳ���¼�����			
wire [15:0]  ComStaCP_A,ComStaCP_B;//����A/Bϵͳͨ��״̬��
wire [15:0]  CP_MasSla_Sta;//�ر�����״̬��
wire [15:0]  PhaseStaCP;//���ر����յ���״̬��
wire sumerr_DSP;//FPGA���շ���DSPУ�����λ   
//--------------------���շ���ģ�������źŶ���------------------//
wire [383:0] LinkUdcA_BUS,LinkUdcB_BUS,LinkUdcC_BUS;//ģ��ֱ����ѹ����16*24=384
wire [863:0]linksta;
//wire [767:0] LinkStaA_BUS,LinkStaB_BUS,LinkStaC_BUS;//ģ��״̬��Ϣ����16*2*24=768
wire [15:0]  Mod_ComSta1,Mod_ComSta2,Mod_ComSta3,Mod_ComSta4,Mod_ComSta5,Mod_ComSta6,
             Mod_ComSta7,Mod_ComSta8,Mod_ComSta9,Mod_ComSta10,Mod_ComSta11,Mod_ComSta12;//����ģ��ͨ��״̬(У��+����)
wire [9:0]   ram_addr_a,ram_addr_b,ram_addr_c;
wire [15:0]  ram_data_a,ram_data_b,ram_data_c;
wire [4:0]ram_addr_udca,ram_addr_udcb,ram_addr_udcc;
wire [15:0]ram_data_udca,ram_data_udcb,ram_data_udcc;
//--------------------PWM��������źŶ���------------------//
wire [383:0] CtrlVolA_BUS,CtrlVolB_BUS,CtrlVolC_BUS;//ģ����Ƶ�ѹ����16*24=384
wire [47:0]  PWM_A_BUS,PWM_B_BUS,PWM_C_BUS;//2*24
wire [15:0]  PhaseA_Udc,PhaseB_Udc,PhaseC_Udc;//��ƽ��ֱ����ѹ
//--------------------��DSP����źŶ���------------------//
wire WD_RST,WD_DSP_ERR,XINT_DSP_ERR,DSP_ERR_RST;
assign XRST =  (Jump1)?  1'b1 : ~(WD_RST | DSP_ERR_RST);//��λDSP
wire [15:0]  VCU_Mode;//���ػ������� 3���һ/����
wire [15:0]  para_grp_TFR;//¼�������
wire [15:0]  PhaseStaDSP,LinkNum_Total,SwitchFreq,Udc_limit,Kp_Udc;
wire [15:0]  Redun_pos1,Redun_pos2,Redun_pos3,Redun_pos4,Redun_pos5,Redun_pos6;//ģ������λ����
wire [15:0]dat_reserve[18:1];//DSP��FPGA֮��ı�������
//------------------------------------------------------
wire IN_OptoPhaseC_sysA,IN_OptoPhaseC_sysB,IN_phaselock1,IN_phaselock2;
wire OUT_OptoPhaseC_sysA,OUT_OptoPhaseC_sysB,OUT_phaselock1,OUT_phaselock2;
wire [15:0]ComSta_fastlock;//���ٷ���״̬��
assign IN_OptoPhaseC_sysA = Jump2 ? OPTO_IN7 : 1'b0;//�����C���������
assign IN_OptoPhaseC_sysB = Jump2 ? OPTO_IN8 : 1'b0;
assign IN_phaselock1 = Jump2 ? 1'b0 : OPTO_IN7;//������������������
assign IN_phaselock2 = Jump2 ? 1'b0 : OPTO_IN8;
assign OPTO_OUT7 = Jump2 ? OUT_OptoPhaseC_sysA : OUT_phaselock1;//�����C��������˻�����������������
assign OPTO_OUT8 = Jump2 ? OUT_OptoPhaseC_sysB : OUT_phaselock2;
//------------------------------------------------------
//�����ź�
wire mod_lock;//��Ԫ����ģ������ź�
wire phaselock1_brk,phaselock2_brk;//���������˶���
wire phaselock1_pulerr,phaselock2_pulerr;//����������Ƶ�ʴ���
wire fastlock;//�Ӳ���������������Ӻ�Ŀ��ٷ����ź�
wire phaselock1,phaselock2;//������������ķ����ź�
assign	XREADY = 1'b1;
//--------------------ǰ���ָʾ��----------------------//
assign	ALARM_F_LED = ~ ( PhaseStaCP[0] | PhaseStaCP[8] );
assign	IDLE_F_LED = 1'b1;
assign	SA_F_LED = ~PhaseStaCP[13];
assign	SB_F_LED = ~PhaseStaCP[14];
//--------------------MCBSP����----------------------//
assign	McFS_DIR = 1'b1;
assign	McDXR_DIR = 1'b1;
assign	McCLK_DIR = 1'b1;
//--------------------������----------------------//
//assign OPTO_OUT1 = 1'b1;
//assign OPTO_OUT2 = 1'b1;
assign OPTO_OUT3 = 1'b1;
assign OPTO_OUT4 = 1'b1;
//assign OPTO_OUT5 = 1'b1;
//assign OPTO_OUT6 = 1'b1;
//assign XINT1 = 1'b1;
//assign OPTO_OUT7 = 1'b1;
//assign OPTO_OUT8 = 1'b1;

//--------------------����ָʾ��------------------------//
assign	TEST1 = ~ControlWord[0] ; //���ظ�λ
assign	TEST2 = ~PhaseStaCP[15];//~LED2 ; //DSP����
assign	TEST3 = 1'b1;//~LED3 ;
assign	TEST4 = 1'b1;//~LED4;
//-----------------------------������ģ������-----------------------------//
//-----------------------------u0_FPGA_Version---------------------------//
//ģ�����ƣ�FPGA_Version
//ģ�鹦�ܣ�����FPGA�汾��Ϣ��ͨ���ϴ�DSP����λ����ѯFPGA����汾
 FPGA_Version u0_FPGA_Version (
								 .i_clk(clk_100M), 
								 .DSP_A(DSP_A), 
								 .DSP_D(DSP_D), 
								 .XZCS6(XZCS6), 
								 .XRD(XRD), 
								 .XWE(XWE)
    );
//-----------------------------u1_clk_sig---------------------------//
//ģ�����ƣ�clk_sig
//ģ�鹦�ܣ�
 clk_sig u1_clk_sig (
								 .CLK_IN1(CLK_FPGA),      // �ⲿʱ��Դ���� 10MHz
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
//ģ�����ƣ�Reset_watchdog
//ģ�鹦�ܣ�
//---------------------��99ms��101ms�����ź�test-------
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
								 .i_WDI_dsp(LINK_F_D_1),   //DSP��FPGA��ι���ź�,IO��ֱ�� test clk99_101),//
								 .i_XZCS6(XZCS6),
								 .i_XWE(XWE),
								 .i_XRD(XRD),
								 .i_DSP_A(DSP_A),
								 .o_reset_n1(reset_n1),    //����λ�ź�
								 .o_reset_n2(reset_n2),    //��λ�ź�-��Ԫ����ģ��
								 .o_reset_n3(reset_n3),    //��λ�ź�-��Ԫ����ģ��
								 .o_reset_n4(reset_n4),    //��λ�ź�-PWMģ��
								 .o_WD_RST(WD_RST),        //FPGA��λDSP��λ�ź�
								 .o_DSP_ERR_RST(DSP_ERR_RST),//DSP�жϹ��ϸ�λ�ź�
								 .o_XRST_F(XRST_F),        //��ͷ��λ�ź�-��ʱ��ģ��u1�ĸ�λ�ź�һ��
								 .o_WDI(WDI),              //FPGA�����Ź�оƬι���ź�-��4Mʱ��Ϊι���ź�
								 .o_WD_DSP_ERR(WD_DSP_ERR),    //DSPι�������ź�
								 .o_XINT_DSP_ERR(XINT_DSP_ERR)//DSP�ж�ִ�й��ϣ���ַ������
								 );
//-----------------------------u3_Int_Ena_ctrl---------------------------//
//ģ�����ƣ�Int_Ena_ctrl
//ģ�鹦�ܣ�
//--------------��78.1us�ź�------------
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
//---------------------����֡ͬ���������ֵ����Сֵ�ĳ���
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
                         .i_syn_ref(rdint_CP),//�ⲿͬ���ο��ź�  start_syn1),//
								 .o_xint_st(start_DPRAM),//дDPRAM�����ź�
								 .o_PWM_calc_st(start_PWM),//PWM���������ź�
								 .o_Module_tx_st(start_Unit),//���͵�Ԫģ��ͨ�������ź�
								 .o_CP_tx_st(start_txCP),//���Ϳر�ͨ�������ź�
								 .o_Mcbsp_tx_st(start_mcbsp),//MCBSP���������ź�
								 .o_rxstaram(start_rxsta)
								 );
//-----------------------------u4_DPRAM---------------------------//
//ģ�����ƣ�TOPDPRAM
//ģ�鹦�ܣ�
DPRAM1  u4_DPRAM (
                         .clk_100M(clk_100M),
								 .reset_n(reset_n1),
								 .start_DPRAM(start_DPRAM),
								 .DSP_A(DSP_A),
								 .DSP_D(DSP_D),
								 .XZCS6(XZCS6),
								 .XWE(XWE),
								 .XRD(XRD),
								 
								 .i_CtrlWord_A(CtrlWord_A),//�ر�A�·�������
								 .i_CtrlWord_B(CtrlWord_B),//�ر�B�·�������
								 .i_RenewCntCP_A(RenewCntCP_A),//�ر�Aϵͳ���¼�����
								 .i_RenewCntCP_B(RenewCntCP_B),//�ر�Bϵͳ���¼�����
								 .i_ComStaCP_A(ComStaCP_A),//���տر�AϵͳͨѶ״̬��
								 .i_ComStaCP_B(ComStaCP_B),//���տر�BϵͳͨѶ״̬��
								 .i_CP_MasSla_Sta(CP_MasSla_Sta),//�ر�����״̬��
								 .i_ComSta_fastlock(ComSta_fastlock),//���ٷ���״̬��
								 
								 .Phase_udcA(PhaseA_Udc),//��ƽ��ֱ����ѹ
								 .Phase_udcB(PhaseB_Udc),		
								 .Phase_udcC(PhaseC_Udc),	
								 
								 .ram_addr_a(ram_addr_a),
								 .ram_addr_b(ram_addr_b),
								 .ram_addr_c(ram_addr_c),
								 
								 .ram_data_a(ram_data_a),
								 .ram_data_b(ram_data_b),
								 .ram_data_c(ram_data_c),								 
										
								 .Phase_sta(PhaseStaDSP),//��״̬��		
								 .LinkNum_Total(LinkNum_Total),//����ģ���ܸ���		
								 .F_switch(SwitchFreq),//����Ƶ��		
								 .Kp_Udc(Kp_Udc),//ֱ����ѹ�������ز�		
								 .UdcThirdCtrlLim(Udc_limit),//ֱ����ѹ�����������޷�
								 .o_Redun_pos1(Redun_pos1),//A/B/C����λ����
								 .o_Redun_pos2(Redun_pos2),
								 .o_Redun_pos3(Redun_pos3),
								 .o_Redun_pos4(Redun_pos4),
								 .o_Redun_pos5(Redun_pos5),
								 .o_Redun_pos6(Redun_pos6),
								 .o_VCU_Mode(VCU_Mode),//���ػ������� 3���һ/����
								 .o_para_grp_TFR(para_grp_TFR),//¼�������
								 .backup1(dat_reserve[1]),//DSP��������
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
								 
								 .XINT1(XINT1),//DSP�ж�
								 .sumerrKB(sumerr_DSP)//FPGA���շ���DSPУ�����λ
								);	
////-----------------------------u5_CP_TxRx---------------------------//
////ģ�����ƣ�CP_TxRx
////ģ�鹦�ܣ�
assign Module_TX[53:1] = 53'd0;
CP_TxRx  u5_CP_TxRx(     
                         .i_clk(clk_100M),
								 .i_clk_20M(clk_20M),
								 .i_clk_100K(clk_100K),
								 .i_reset_n(reset_n1),
								 .i_start_txCP(start_txCP),//����ʹ��
								 .i_WD_DSP_ERR(WD_DSP_ERR),//DSPι�������ź�
								 .i_XINT_DSP_ERR(XINT_DSP_ERR),//DSP�ж�ִ�й��ϣ���ַ������
								 .i_sumerr_DSP(sumerr_DSP),//FPGA���շ���DSPУ�����λ
								 .i_PhaseStaDSP(PhaseStaDSP),//DSP����FPGA��״̬��
								 .i_VCU_Mode(VCU_Mode),//���ػ������� 3���һ/����		
								 .i_phaselock1_brk(phaselock1_brk),//����������1����
								 .i_phaselock2_brk(phaselock2_brk),//����������2����
								 .i_phaselock1_pulerr(phaselock1_pulerr),//����������1Ƶ�ʳ���
								 .i_phaselock2_pulerr(phaselock2_pulerr),//����������2Ƶ�ʳ���
								 
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
								 
								 .i_fastlock1(~OPTO_IN3),//���ٷ�����������
								 .i_fastlock2(~OPTO_IN4),
								 .o_fastlock_final(fastlock),//�Ӳ���������������Ӻ�Ŀ��ٷ����ź�
								 .o_ComSta_fastlock(ComSta_fastlock),//���ٷ���״̬��
								 .i_phaselock1(phaselock1),//������������ķ����ź�
								 .i_phaselock2(phaselock2),
								 
								 .i_PhaseA_Udc(PhaseA_Udc),//��ƽ��ֱ����ѹ
								 .i_PhaseB_Udc(PhaseB_Udc),
								 .i_PhaseC_Udc(PhaseC_Udc),
								 
								 .o_ControlWord(ControlWord),//�����жϺ����յĿ���������
								 .o_TargetVolA(TargetVolA),//�����жϺ����յĵ��Ƶ�ѹ
								 .o_TargetVolB(TargetVolB),
								 .o_TargetVolC(TargetVolC),
								 .o_CosThetA(CosThetA),//�����жϺ����յ�����ֵ
								 .o_CosThetB(CosThetB),
								 .o_CosThetC(CosThetC),
								 
								 .o_CtrlWord_A(CtrlWord_A),//�ر�A�·�������
								 .o_CtrlWord_B(CtrlWord_B),//�ر�B�·�������	
								 .o_RenewCntCP_A(RenewCntCP_A),//�ر�Aϵͳ���¼�����	
								 .o_RenewCntCP_B(RenewCntCP_B),//�ر�Bϵͳ���¼�����								 
								 .o_ComStaCP_A(ComStaCP_A),//���տر�AϵͳͨѶ״̬��
								 .o_ComStaCP_B(ComStaCP_B),//���տر�BϵͳͨѶ״̬��
								 .o_CP_MasSla_Sta(CP_MasSla_Sta),//�ر�����״̬��
								 
								 .o_rdint_CP(rdint_CP),//�ⲿͬ���ο��ź�
								 .o_PhaseStaCP(PhaseStaCP)//���ر����յ���״̬��
								 
							 );
//-----------------------------u6_Rx_Unit---------------------------//
//ģ�����ƣ�Rx_Unit
//ģ�鹦�ܣ�
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
//ģ�����ƣ�Tx_Unit
//ģ�鹦�ܣ�		
Tx_Unit       u7_Tx_Unit(								 
                         .i_clk(clk_20M),
								 .i_reset_n(reset_n3),
								 .i_ControlWord(ControlWord),//�����жϺ����յĿ���������
								 .i_PhaseSta(PhaseStaCP),//���ر����յ���״̬��
								 .i_start_Unit(start_Unit),//���͵�Ԫģ��ͨ�������ź�
								 .i_lock(mod_lock),//��Ԫ����ģ������ź�
								 .i_Redun_pos1(Redun_pos1),//A/B/C����λ����
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
//ģ�����ƣ�SpwmGen
//ģ�鹦�ܣ�								
SpwmGen       u8_SpwmGen(
                         .i_clk(clk_50M),
								 .i_clk_20M(clk_20M),
								 .clk_100K(clk_100K),
								 .clk_1M(clk_1M),
								 .i_reset_n(reset_n4),
								 .i_start_PWM(start_PWM),
								 .i_TargetVolA(TargetVolA),//�����жϺ����յĵ��Ƶ�ѹ	
                         .i_TargetVolB(TargetVolB),
								 .i_TargetVolC(TargetVolC),
								 .i_CosThetA(CosThetA),//�����жϺ����յ�����ֵ
								 .i_CosThetB(CosThetB),
								 .i_CosThetC(CosThetC),
								 
								 .i_LinkNum_Total(LinkNum_Total),//����ģ���ܸ���	
								 .i_SwitchFreq(SwitchFreq),//����Ƶ��
								 .i_Kp_Udc(Kp_Udc),//ֱ����ѹ�������ز�	
								 .i_Udc_limit(Udc_limit),//ֱ����ѹ�����������޷�
								 .i_Redun_pos1(Redun_pos1),//A/B/C����λ����
								 .i_Redun_pos2(Redun_pos2),
								 .i_Redun_pos3(Redun_pos3),
								 .i_Redun_pos4(Redun_pos4),
								 .i_Redun_pos5(Redun_pos5),
								 .i_Redun_pos6(Redun_pos6),
								 .i_VCU_Mode(VCU_Mode),//���ػ������� 3���һ/����								 
					          
								 .i_LinkUdcA_BUS(LinkUdcA_BUS),//ģ��ֱ����ѹ����
								 .i_LinkUdcB_BUS(LinkUdcB_BUS), 
								 .i_LinkUdcC_BUS(LinkUdcC_BUS),
								 
								 .o_PhaseA_Udc(PhaseA_Udc),//��ƽ��ֱ����ѹ		
								 .o_PhaseB_Udc(PhaseB_Udc),		
								 .o_PhaseC_Udc(PhaseC_Udc),
                         .Ave_TargetVolA(Ave_TargetVolA),//��ƽ�����Ƶ�ѹ	
								 .Ave_TargetVolB(Ave_TargetVolB),
								 .Ave_TargetVolC(Ave_TargetVolC),								 
								 
								 .o_PWM_A_BUS(PWM_A_BUS),//PWM��
								 .o_PWM_B_BUS(PWM_B_BUS),
								 .o_PWM_C_BUS(PWM_C_BUS),
								 .o_CtrlVolA_BUS(CtrlVolA_BUS),//ģ����Ƶ�ѹ����
								 .o_CtrlVolB_BUS(CtrlVolB_BUS),
								 .o_CtrlVolC_BUS(CtrlVolC_BUS)
								 );
//-----------------------------u9_Mcbsp_ctrl---------------------------//
//ģ�����ƣ�Mcbsp_ctrl
//ģ�鹦�ܣ�
Mcbsp_ctrl    	u9_Mcbsp_ctrl(
                         .i_clk(clk_100M),
                         .i_clk_mcbsp(clk_15M),
                         .i_reset_n(reset_n1),
								 .i_Mcbsp_tx_st(start_mcbsp),//MCBSP���������ź�
								 .i_ControlWord(ControlWord),//��ϵͳ����������
								 .i_PhaseSta(PhaseStaCP),//(PhaseStaCP),//���ո��ر�����״̬��
								 .i_PhaseA_Udc(PhaseA_Udc),//��ƽ��ֱ����ѹ		
								 .i_PhaseB_Udc(PhaseB_Udc),		
								 .i_PhaseC_Udc(PhaseC_Udc),
								 .i_TargetVolA(Ave_TargetVolA),//��ƽ�����Ƶ�ѹ	
                         .i_TargetVolB(Ave_TargetVolB),
								 .i_TargetVolC(Ave_TargetVolC),
								 								 
								 .ram_addr_udca(ram_addr_udca),//A/B/C��ֱ����ѹ
								 .ram_addr_udcb(ram_addr_udcb),
								 .ram_addr_udcc(ram_addr_udcc),
								 
								 .ram_data_udca(ram_data_udca),
								 .ram_data_udcb(ram_data_udcb),
								 .ram_data_udcc(ram_data_udcc),
								 
								 .i_CtrlVolA_BUS(CtrlVolA_BUS),//A/B/C���Ʋ���ѹ
								 .i_CtrlVolB_BUS(CtrlVolB_BUS),
								 .i_CtrlVolC_BUS(CtrlVolC_BUS),
								 
								 .i_VCU_Mode(),//���ػ������� 3���һ/����
								 .i_para_grp_TFR(para_grp_TFR),//¼�������
								 .backup1(dat_reserve[1]),//DSP��������
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
								 
    							 .o_McDXA(McDXA),//mcbsp֡ͬ����ʱ�ӡ�����
								 .o_McFSXA(McFSXA),
								 .o_McCLKXA(McCLKXA),
								 .linksta_bus(linksta)
                         );			  
//-----------------------------u10_lock_handle---------------------------//
//ģ�����ƣ�lock_handle
//ģ�鹦�ܣ�		
lock_handle   	u10_lock_handle(
                         .i_clk_20M(clk_20M),
								 .i_clk_lock(clk_1M),//������ʱ��Ƶ��
								 .i_clk_nonlock(clk_100K),//�Ƿ�����ʱ��Ƶ��
                         .i_reset_n(reset_n1),
								 .i_ControlWord(ControlWord),//��ϵͳ����������
								 .i_PhaseSta(PhaseStaCP),//���ر����յ���״̬��
								 .i_phaselock1(IN_phaselock1),//������������Ļ����ź�
								 .i_phaselock2(IN_phaselock2),
								 .i_fastlock(fastlock),//�Ӳ���������������Ӻ�Ŀ��ٷ����ź�
								 .o_phaselock1_brk(phaselock1_brk),//����������1����
								 .o_phaselock2_brk(phaselock2_brk),//����������2����
								 .o_phaselock1_pulerr(phaselock1_pulerr),//����������1Ƶ�ʳ���
								 .o_phaselock2_pulerr(phaselock2_pulerr),//����������2Ƶ�ʳ���
								 .o_lock(mod_lock),//��Ԫ����ģ������ź�
								 .o_phaselock1_opto(OUT_phaselock1),//����������Ļ����ź�
								 .o_phaselock2_opto(OUT_phaselock2),
								 .o_phaselock1(phaselock1),//������������ķ����ź�
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
