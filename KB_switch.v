`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: CEPRI
// Engineer:Zhang Dian-qing
// 
// Create Date:    22:07:10 03/13/2019 
// Design Name: 
// Module Name:    CP_switch 
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
module KB_switch(    
					 input clk_20M,
					 input i_clk_100K,
					 input reset_n,
					 input rd_intA,//����֡������ɱ�־
					 input rd_intB,//����֡������ɱ�־
					 input i_WD_DSP_ERR,//DSPι�������ź�
					 input i_XINT_DSP_ERR,//DSP�ж�ִ�й��ϣ���ַ������
					 input i_sumerr_DSP,//FPGA���շ���DSPУ�����λ
					 input [15:0]i_PhaseStaDSP,//DSP����FPGA��״̬��
					 
					 input [15:0]i_CtrlWord_A,//�ر�A�·�������
					 input [15:0]i_CtrlWord_B,//�ر�B�·�������	
					 input [31:0]i_TargetVol_CPA,//����Aϵͳ�ĵ��Ƶ�ѹ
					 input [31:0]i_TargetVol_CPB,//����Bϵͳ�ĵ��Ƶ�ѹ	 
					 input [15:0]i_CosThet_CPA,//����Aϵͳ������ֵ
					 input [15:0]i_CosThet_CPB,//����Bϵͳ������ֵ
					 
					 input i_fastlock1,//Aϵͳ�·����ٷ���
					 input i_fastlock2,//Bϵͳ�·����ٷ���
					 output reg o_fastlock_final,//�����жϺ����շ����Ŀ��ٷ���
					 
					 output reg[15:0]o_ControlWord,//�����жϺ����յĿ���������
					 output reg[31:0]o_TargetVol,//�����жϺ����յĵ��Ƶ�ѹ
					 output reg[15:0]o_CosThet,//�����жϺ����յ�����ֵ
					 output [15:0]o_CP_MasSla_Sta,//�ر�����״̬��
                output [15:0]o_PhaseStaCPA,//��״̬��
                output [15:0]o_PhaseStaCPB,//��״̬��					 
					 output reg o_rdint_CP//�ⲿͬ���ο��ź�
//					 output system,
//					 output [1:0]system_state
					 );
//**********************����DSP���Ϳر�����У��ͳ�������6���㣬��λ���ܹ��ϣ�����20ms��ȷ������0���ܹ���****//
parameter CHECK_ERR_CNT = 18750;//6���� 156.25us*6
parameter CHECK_RETURN_CNT = 400000;//20ms
reg [15:0]DSP_check_err_cnt;//���������
reg [19:0]DSP_check_right_cnt;//��ȷ������
reg check_err;//FPGA����DSP���Ϳر�����У��ͳ���
//�źŶ���
reg [1:0]system_state,system_state_old;//�ж�װ�ü�A/Bϵͳ���Ӳ����������2bit 
reg system_A_state,system_B_state;
reg start1,start2;//�����յ�װ�ü�A/Bϵͳ������ϱ�־��һ��ʱ�ӵ��ź�
reg [1:0]comm_state; 
reg system,system_reg;
reg switchBtoA,switchAtoB;
reg sys_Stat_A_final,sys_Stat_B_final;
//----------�����л�ʹ�������Ĵ���----------
reg state_MS_A,state_MS_B;
reg [15:0]state_MS_A_reg,state_MS_B_reg;
//-------------------------���ر������յ���״̬��-----------------
wire DSP_err_total;//DSP�ܹ��ϣ�DSP���Ź����ϡ�DSP�ⲿ�жϹ��ϡ�FPGA����DSPУ����ϣ��ж�6���㣩
assign DSP_err_total = i_WD_DSP_ERR | i_XINT_DSP_ERR | check_err;
assign o_PhaseStaCPA = {DSP_err_total,sys_Stat_B_final,sys_Stat_A_final,i_PhaseStaDSP[12],i_PhaseStaDSP[11],i_PhaseStaDSP[10:0]};
assign o_PhaseStaCPB = {DSP_err_total,sys_Stat_A_final,sys_Stat_B_final,i_PhaseStaDSP[11],i_PhaseStaDSP[12],i_PhaseStaDSP[10:0]};
assign o_CP_MasSla_Sta = {14'd0,sys_Stat_B_final,sys_Stat_A_final};
//-------------FPGA���շ���DSPУ�����λ����ʱ�����------------
always @ (posedge clk_20M)
begin
	if(!reset_n) begin 
		DSP_check_err_cnt <= 16'd0;
		DSP_check_right_cnt <= 20'd0;
		end
	else if(i_sumerr_DSP)begin
		DSP_check_err_cnt <= DSP_check_err_cnt + 16'd1;
		DSP_check_right_cnt <= 20'd0;
		end
	else begin 
	   DSP_check_right_cnt <= DSP_check_right_cnt+20'd1;
		DSP_check_err_cnt<= 16'd0;
		end
end
//-----------FPGA���շ���DSPУ�����λ����ʱ�䳬��6�����20ms--------------
always @ (posedge clk_20M)
begin
	if(!reset_n)begin
		check_err <= 1'b0;
	end
	else if(DSP_check_err_cnt >= CHECK_ERR_CNT)begin
		check_err <= 1'b1;
	end
	else if(DSP_check_right_cnt >= CHECK_RETURN_CNT)begin
		check_err <= 1'b0;
	end
	else check_err <= check_err;
end
//-------------------------�����л�ʹ����Ҫ����160us----------------------
always @ (posedge i_clk_100K)
begin
	if(!reset_n) begin
		state_MS_A <= 1'b0;
		state_MS_B <= 1'b0;
		state_MS_A_reg <= 16'b0;
		state_MS_B_reg <= 16'b0;
	end
	else begin
		state_MS_A_reg <= {state_MS_A_reg[14:0],i_CtrlWord_A[8]};
		state_MS_B_reg <= {state_MS_B_reg[14:0],i_CtrlWord_B[8]};
		if (state_MS_A_reg == 16'hffff) state_MS_A <= 1'b1;
		else if (state_MS_A_reg == 16'h0) state_MS_A <= 1'b0;
		else state_MS_A <= state_MS_A;
		if (state_MS_B_reg == 16'hffff) state_MS_B <= 1'b1;
		else if (state_MS_B_reg == 16'h0) state_MS_B <= 1'b0;
		else state_MS_B <= state_MS_B;
	end
end
//-------------����װ�ü�A/B�·��Ĳ����ж����Ӳ���1ʱ��----------------------
always @ (posedge clk_20M)
begin
	if(!reset_n) begin
		system_state <= 2'b01;
		system_state_old<= 2'b01;
	end
	else begin
		case ({state_MS_B,state_MS_A})//�ر��·��������е�����ϵͳ
			2'b00 : system_state <= 2'b00;//˫��
			2'b10 : system_state <= 2'b10;//B��
			2'b01 : system_state <= 2'b01;//A��
			2'b11 : system_state <= 2'b11;//˫��
			default : system_state <= 2'b01;//Ĭ��A��
		endcase
		system_state_old <= system_state;
	end
end
//----------��������֡������־�ź���һ��ʱ��----------------
always @ (posedge clk_20M)
begin
	if(!reset_n) start1 <= 1'b0;
	else start1 <= rd_intA;
end
always @ (posedge clk_20M)
begin
	if(!reset_n) start2 <= 1'b0;
	else start2 <= rd_intB;
end
//******************����Ϊ��***************//
always @ (posedge clk_20M)
begin
	if(!reset_n) begin
		system <= 1'b0; 
		sys_Stat_A_final <= 1'b1;
		sys_Stat_B_final <= 1'b0;
	end
	else if (system_state == 2'b01)begin 
		system <= 1'b0;//0ΪA��
		sys_Stat_A_final <= 1'b1;
		sys_Stat_B_final <= 1'b0;
	end													
	else if (system_state == 2'b10) begin 
		system <= 1'b1;
		sys_Stat_A_final <= 1'b0;
		sys_Stat_B_final <= 1'b1;
	end
	else if(system_state == 2'b00)begin//˫��ʱ�̣��ϴ�˫�ӵ�״̬
		system <= system; 
		sys_Stat_A_final <= 1'b0;
		sys_Stat_B_final <= 1'b0;
	end
	else if((system_state == 2'b11)&&(system_state_old!=2'b11)) begin //˫���Ĵ���
		if(system_state_old==2'b10)begin //ԭ��ΪBϵͳ���л���A��
			system <= 1'b0;
			sys_Stat_A_final <= 1'b1;
			sys_Stat_B_final <= 1'b0;
		end
		else if(system_state_old==2'b01)begin //ԭ��ΪAϵͳ���л���B��
			system <= 1'b1;
			sys_Stat_A_final <= 1'b0;
			sys_Stat_B_final <= 1'b1;
		end	
		else begin  
			system <= 1'b0;
			sys_Stat_A_final <= 1'b1;
			sys_Stat_B_final <= 1'b0;
		end
	end
	else begin
		system <= system;
		sys_Stat_A_final <= sys_Stat_A_final;
		sys_Stat_B_final <= sys_Stat_B_final;	
	end
end
//-------------system��һ��ʱ��-----------------
always @ (posedge clk_20M)
begin
	if(!reset_n) system_reg	<= 1'b0;
	else  system_reg	<= system;
end
//--------------------------------------
always @ (posedge clk_20M)
begin
	if(!reset_n) begin
		switchBtoA <= 1'b0;
		switchAtoB <= 1'b0;
	end
	else if((system_reg) && (!system)) switchBtoA <= 1'b1;
	else if((!system_reg) && (system)) switchAtoB <= 1'b1;
	else begin
		switchBtoA <= 1'b0;
		switchAtoB <= 1'b0;
	end
end
//-----------------��������ѡ�����-----------------------
always @ ( * )//���б������ۺ�������always�������������Զ���ӣ������Լ�����  ����߼�
begin
	if(!reset_n) begin
		o_ControlWord<= 16'd0;
		o_TargetVol<= 32'd0;
		o_CosThet<= 16'd0;
		o_rdint_CP<=1'b0;
		o_fastlock_final <= 1'b0;
	end
	else if(switchBtoA) begin//�л���Aϵͳ
		o_ControlWord<= i_CtrlWord_A;
		o_TargetVol<= i_TargetVol_CPA;
		o_CosThet<= i_CosThet_CPA;
		o_rdint_CP<=start1;
		o_fastlock_final <= i_fastlock1;
	end
	else if(switchAtoB) begin//�л���Bϵͳ
		o_ControlWord<= i_CtrlWord_B;
		o_TargetVol<= i_TargetVol_CPB;
		o_CosThet<= i_CosThet_CPB;
		o_rdint_CP<=start2;
		o_fastlock_final <= i_fastlock2;
	end
	else if(system) begin  //Bϵͳ
		o_ControlWord<= i_CtrlWord_B;
		o_TargetVol<= i_TargetVol_CPB;
		o_CosThet<= i_CosThet_CPB;
		o_rdint_CP<=start2;
		o_fastlock_final <= i_fastlock2;
	end
	else if(!system) begin //Aϵͳ
		o_ControlWord<= i_CtrlWord_A;
		o_TargetVol<= i_TargetVol_CPA;
		o_CosThet<= i_CosThet_CPA;
		o_rdint_CP<=start1;
		o_fastlock_final <= i_fastlock1;
	end

end
//---------------------------------------------
//wire [35:0]ILAControl;
//wire [79:0]data_chipscp; 
//assign data_chipscp[15:0] = i_CtrlWord_A;
//assign data_chipscp [31:16] = i_CtrlWord_B;
//assign data_chipscp [47:32] = o_ControlWord;
//assign data_chipscp [63:48] = {12'b0,i_sumerr_DSP};
////assign data_chipscp [79:64] = PhaseStaCPB;
//
//new_icon svg_icon ( 
//     .CONTROL0            ( ILAControl) 
//); 
//
//new_ila svg_ila ( 
//     .CONTROL            ( ILAControl), 
//     .CLK                ( clk_20M), 
//     .DATA               ( data_chipscp), 
//     .TRIG0              ( i_WD_DSP_ERR ), 
//	  .TRIG1              ( i_XINT_DSP_ERR),
//	  .TRIG2              (  check_err),
//	  .TRIG3              ( )
//);
endmodule
