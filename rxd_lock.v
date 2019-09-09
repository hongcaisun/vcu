`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:29:06 04/13/2018 
// Design Name: 
// Module Name:    rxd_Man_lock 
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
module rxd_Man_lock(clk_20M,clr,rxd,lock_stat,pulse_err
    );
	 input clk_20M;
	 input clr;
	 input rxd;
	 output reg lock_stat;//���Ϊ1M����ʱ���1
	 output reg pulse_err;//��ⲻ��1M��100k���壬�����������־
	 
	 parameter NUM_PULSE = 2; //ʵ�ʼ��������������ΪPULSENUM���ж�����������С��1��
	 //����������Ϊ1M�����źŶ�Ӧclk_20Mʱ�Ӹ�����1m�����Ӧ20��clk_20Mʱ�ӣ��ڴ�ȡ��10%��Χ
	 parameter NUM_1M_L = 18'd18;
	 parameter NUM_1M_H = 18'd22;
	 //����������Ϊ100K�����źŶ�Ӧclk_20Mʱ�Ӹ�����100K�����Ӧ200��clk_20Mʱ�ӣ��ڴ�ȡ��5%��Χ
	 parameter NUM_100K_L = 18'd190;
	 parameter NUM_100K_H = 18'd210;
	 
	 //***************����**************************//
	 reg [2:0] Samp_reg;
	 reg rxd_temp;
	 reg data_reg;
	 
	 wire rxd_low = ( Samp_reg[1:0] == 2'b00 );
	 wire rxd_high = ( Samp_reg[1:0] == 2'b11 );
	 
	 always @ ( negedge clr or posedge clk_20M )
	 begin
		if ( !clr )
			begin
				rxd_temp <= 1'b1;
				Samp_reg <= 3'b111;
				data_reg <= 1'b1;
			end
		else
			begin
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
	 //****************���������ؿ�ʼ����,��2����*********************//
	 reg [1:0] rxd_reg;
	 reg [7:0] cnt1;
	 
	 always @ ( negedge clr or posedge clk_20M )
	 begin
		if ( !clr )
			rxd_reg <= 2'b00;
		else
			rxd_reg <= { rxd_reg[0] , data_reg };
	 end
	 
	 always @ ( negedge clr or posedge clk_20M )
	 begin
		if ( !clr )
			cnt1 <= 8'b0;
		else if ( rxd_reg == 2'b01 )
			begin
				if ( cnt1 <= 8'd2 )
					cnt1 <= cnt1 + 1'd1;
				else
					cnt1 <= 8'd0;
			end
		 else
			cnt1 <= cnt1;
	 end
	 //*******************1M��100k��ʼ����******************//
	 reg [17:0] cnt2;
	 reg [17:0] cnt3;//�˼������Ƿ�ֹ�β����cnt1����ͣ��0��ʱ�򣬵��³���
	 reg [17:0] cnt4;//cnt2�ǵ�һ�����ڣ�cnt4�ڶ������ڼ���
	 always @ ( negedge clr or posedge clk_20M )
	 begin
		if ( !clr )
			begin
			cnt2 <= 18'd0;
			cnt3 <= 18'd0;
			cnt4 <= 18'd0;
			end
		else if ( cnt1 == 8'd0 )
			begin
			cnt2 <= 18'd0;
			cnt3 <= cnt3 + 18'd1;
			cnt4 <= 18'd0;
			end
		else if ( cnt1 == 8'd1 )
			begin
			cnt2 <= cnt2 + 18'd1;
			cnt3 <= 18'd0;
			cnt4 <= 18'd0;
			end
		else if ( cnt1 == 8'd2 )
			begin
			cnt2 <= cnt2;
			cnt3 <= 18'd0;
			cnt4 <= cnt4 + 18'd1;
			end
		else if ( cnt1 == 8'd3 )
			begin
			cnt2 <= cnt2;
			cnt3 <= 18'd0;
			cnt4 <= cnt4;
			end
		else if ( ( cnt2 == 18'h3ffff ) | ( cnt4 == 18'h3ffff ) | ( cnt3 == 18'h3ffff ) )
			begin
			cnt2 <= cnt2;
			cnt3 <= cnt3;
			cnt4 <= cnt4;
			end
		else
			begin
			cnt2 <= 18'd0;
			cnt3 <= 18'd0;
			cnt4 <= 18'd0;
			end
	 end
	 
	 //****************����Чλ�ʹ���λ*****************//
	 always @ ( negedge clr or posedge clk_20M )
	 begin
		if ( !clr )
			begin
			lock_stat <= 1'b0;
			pulse_err <= 1'b0;
			end
		else if ( cnt1 == ( NUM_PULSE +1 ) )
			begin
			if ( ( cnt2 >= NUM_1M_L ) & ( cnt2 <= NUM_1M_H ) & ( cnt4 >= NUM_1M_L ) & ( cnt4 <= NUM_1M_H ) )
				begin
				lock_stat <= 1'b1;//����
				pulse_err <= 1'b0;
				end
			else if ( ( cnt2 >= NUM_100K_L ) & ( cnt2 <= NUM_100K_H ) & ( cnt4 >= NUM_100K_L ) & ( cnt4 <= NUM_100K_H ) )
				begin
				lock_stat <= 1'b0;//����
				pulse_err <= 1'b0;
				end
			else
				begin
				lock_stat <= 1'b0;
				pulse_err <= 1'b1;
				end
			end
		else if ( ( cnt2 == 18'h3ffff ) | ( cnt3 == 18'h3ffff ) | ( cnt4 == 18'h3ffff ) )
			begin
			lock_stat <= 1'b0;
			pulse_err <= 1'b1;
			end
		else
			begin
			lock_stat <= lock_stat;
			pulse_err <= pulse_err;
			end
	end

			
endmodule
