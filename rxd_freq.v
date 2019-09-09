`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:45:11 07/24/2019 
// Design Name: 
// Module Name:    rxd_freq 
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
module rxd_freq(
					input clk_20M,
					input clr,
					input rxd,
					output reg lock_stat,//���Ϊ1M����ʱ���1
					output reg pulse_err,//��ⲻ��1M��100k���壬�����������־
					output reg phaselock_brk//���˶��߱�־λ
);
//�˲����Ǽ�������λ�����ֵ����Сֵ
parameter NUM_CNT_MAX = 9'd500;
parameter NUM_CNT_MIN = 9'd0;
//����������Ϊ1M�����źŶ�Ӧclk_20Mʱ�Ӹ�����1m�����Ӧ20��clk_20Mʱ�ӣ��ڴ�ȡ��10%��Χ
parameter NUM_1M_L = 9'd18;
parameter NUM_1M_H = 9'd22;
//����������Ϊ100K�����źŶ�Ӧclk_20Mʱ�Ӹ�����100K�����Ӧ200��clk_20Mʱ�ӣ��ڴ�ȡ��5%��Χ
parameter NUM_100K_L = 9'd190;
parameter NUM_100K_H = 9'd210;

parameter NUM_BRK = 19999;//1ms�����ж�

reg [2:0]Samp_reg;
reg rxd_temp;
reg data_reg;

reg [1:0]rxd_reg;
reg [8:0]cnt1;//���ڼ�����������511��20Mʱ�ӣ���ΪƵ�ʳ�����Χ
reg [8:0]cnt1_reg[1:0];//�������ڼ������Ĵ���
reg sig_dec;//�����ź��жϿ�ʼ��־λ
reg sig_overflow;//�����ź�Ƶ�ʳ���Χ��־λ

reg phaselock_reg;
reg phaselock_reg_reg;
reg [15:0] cnt3;
//***************����**************************//
wire rxd_low = ( Samp_reg[1:0] == 2'b00 );
wire rxd_high = ( Samp_reg[1:0] == 2'b11 );

always @ ( negedge clr or posedge clk_20M )
begin
	if ( !clr ) begin
		rxd_temp <= 1'b1;
		Samp_reg <= 3'b111;
		data_reg <= 1'b1;
	end
	else begin
		Samp_reg <= { Samp_reg[1:0] , rxd };
		if ( rxd_low )
			rxd_temp <= 1'b0;
		else if ( rxd_high )
			rxd_temp <= 1'b1;
		else
			rxd_temp <= rxd_temp;
		data_reg <= rxd_temp;
	end
end
//****************��һ�����ڵ�ʱ��*********************//
always @ ( negedge clr or posedge clk_20M )
begin
	if ( !clr )
		rxd_reg <= 2'b00;
	else
		rxd_reg <= { rxd_reg[0] , data_reg };
end

always @ ( negedge clr or posedge clk_20M )
begin
	if ( !clr )begin
		cnt1 <= 9'b0;
		sig_dec <= 1'b0;
		sig_overflow <= 1'b0;
		cnt1_reg[0] <= 9'd0;
		cnt1_reg[1] <= 9'd0;
	end
	else if ( rxd_reg == 2'b01 )begin
		cnt1_reg[0] <= cnt1;
		cnt1_reg[1] <= cnt1_reg[0];
		cnt1 <= 9'd0;
		sig_dec <= 1'b1;
		sig_overflow <= 1'b0;
	end
	else if ( cnt1 == NUM_CNT_MAX )begin
		cnt1 <= cnt1;
		sig_overflow <= 1'b1;
	end
	else begin
		cnt1 <= cnt1 + 9'd1;
		sig_dec <= 1'b0;
		sig_overflow <= sig_overflow;
	end
end
//------------------�н���������Ƶ���쳣------------------
reg [1:0]sig_dec_reg;//�����ؼĴ���
reg sig_log1,sig_log2,sig_log3,sig_log4,sig_log5,sig_log6;//�߼��жϱ�־λ
always @ ( negedge clr or posedge clk_20M )
begin
	if ( !clr )begin
		lock_stat <= 1'b0;
		pulse_err <= 1'b0;
		sig_dec_reg <= 2'b0;
	end
	else begin
		sig_dec_reg <= {sig_dec_reg[0],sig_dec};
		
		if (sig_dec_reg == 2'b01)begin
			if ( ( cnt1_reg[0] >= NUM_1M_L ) && ( cnt1_reg[0] <= NUM_1M_H ) && ( cnt1_reg[1] >= NUM_1M_L ) && ( cnt1_reg[1] <= NUM_1M_H ) )
				lock_stat <= 1'b1;//����
			else if ( ( cnt1_reg[0] >= NUM_100K_L ) && ( cnt1_reg[0] <= NUM_100K_H ) && ( cnt1_reg[1] >= NUM_100K_L ) && ( cnt1_reg[1] <= NUM_100K_H ) )
				lock_stat <= 1'b0;//����
			else
				lock_stat <= lock_stat;
		end
		else
			lock_stat <= lock_stat;
			
		if (sig_overflow)begin
			pulse_err <= 1'b1;
		end
		else if (sig_dec_reg == 2'b01)begin
			sig_log1 <= (cnt1_reg[0] >= NUM_CNT_MIN)&&(cnt1_reg[0] <= (NUM_1M_L-9'd1));
			sig_log2 <= (cnt1_reg[0] >= (NUM_1M_H+9'd1))&&(cnt1_reg[0] <= (NUM_100K_L-9'd1));
			sig_log3 <= (cnt1_reg[0] >= (NUM_100K_H+9'd1))&&(cnt1_reg[0] <= (NUM_CNT_MAX));
			sig_log4 <= (cnt1_reg[1] >= NUM_CNT_MIN)&&(cnt1_reg[1] <= (NUM_1M_L-9'd1));
			sig_log5 <= (cnt1_reg[1] >= (NUM_1M_H+9'd1))&&(cnt1_reg[1] <= (NUM_100K_L-9'd1));
			sig_log6 <= (cnt1_reg[1] >= (NUM_100K_H+9'd1))&&(cnt1_reg[1] <= (NUM_CNT_MAX));
		end
		else begin
			if ((sig_log1|sig_log2|sig_log3) & (sig_log4|sig_log5|sig_log6))
				pulse_err <= 1'b1;
			else
				pulse_err <= 1'b0;
		end
	end
end
//-------------------�й��˶���---------------
//-------------------����ķ�������������ʱ��-----------------
always @ (posedge clk_20M or negedge clr)
begin
	if(!clr) begin
		phaselock_reg <= 1'b0;
		phaselock_reg_reg	<= 1'b0;
	end
	else begin
		phaselock_reg <= rxd;//������������
		phaselock_reg_reg	<= phaselock_reg;
	end
end
//-------------------��ƽ����������--------------------
always @ (posedge clk_20M or negedge clr)
begin
	if(!clr) cnt3 <= 16'h0;
	else if((phaselock_reg_reg == phaselock_reg) && (phaselock_brk == 1'b0)) begin
		if (cnt3>(NUM_BRK+10)) cnt3 <= cnt3;
		else cnt3 <= cnt3 + 16'h1;
	end
	else if(phaselock_reg_reg != phaselock_reg) cnt3 <= 16'h0;
	else cnt3 <= cnt3;
end
//-------------------------�����ж�---------------------
always @ (posedge clk_20M or negedge clr)
begin
	if(!clr) phaselock_brk <= 1'b0;
	else if(cnt3>NUM_BRK) phaselock_brk <= 1'b1;
	else phaselock_brk <= 1'b0;
end
endmodule
