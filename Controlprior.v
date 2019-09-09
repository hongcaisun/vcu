`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:50:46 04/01/2013 
// Design Name: 
// Module Name:    Controlprior 
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
module Controlprior(
							input reset_n,
							input clk_20M,
							input PWM_L,
							input PWM_R,
							input [15:0]ControlWord,
							input [15:0]PhaseStaA,
							input bypass,
							input discharge,
							input start,
							input lock,
							output [11:0]module_con,
							output reg tx_en
);

reg [ 1:0] PWM;
reg start_tx;
reg start_tx_reg;
reg [11:0] cnt;
reg syn;
reg [ 3:0] con;
reg [ 2:0]cnt2;
reg syn_out;
reg start_reg;
reg start_reg_reg;
assign module_con = {1'b0,~{syn_out,con},syn_out,con,1'b0};//{1'b0,5'b10011,1'b0,4'b1100,1'b0};//test use
//----------------����ʹ���ź���һ��ʱ��-------------
always @ (posedge clk_20M)
begin
	if(!reset_n) begin 
		start_reg <= 1'b0;
		start_reg_reg <= 1'b0;
	end
	else begin
		start_reg <= start;
		start_reg_reg <= start_reg;
	end
end
//-----------����ʹ���ź������أ�syn��1----
always @ (posedge clk_20M)
begin
	if(!reset_n) begin
		syn <= 1'b0;
	end
	else if ((start_reg_reg==1'b0) && (start_reg==1'b1)) begin
		syn <= 1'b1;
	end
	else syn <= 1'b0;
end
//-----------syn�ź���һ��ʱ�ӿ����չ��6��ʱ�ӿ��---------------------
always @ (posedge clk_20M)
begin
	if(!reset_n) begin
		cnt2 <= 3'd0;
		syn_out <= 1'b0;
	end
	else if((syn) || (cnt2 != 3'd0)) begin
		if(cnt2 == 3'd6) begin
			syn_out <= 1'b0;
			cnt2 <= 3'd0;
		end
		else begin 
			cnt2 <= cnt2 + 3'd1;
			syn_out <= 1'b1;
		end
	end
	else begin
		syn_out <= 1'b0;
		cnt2    <= 3'd0;
	end
end
//----------����ʹ���ź������أ�start_tx��1��֮�����������155��ʱ�ӣ�7.8us����start_tx��1-------------------------
always @ (posedge clk_20M)
begin
	if(!reset_n) begin
		cnt <= 12'h0;
		start_tx <= 1'b0;
	end
	else if ((start_reg_reg==1'b0) && (start_reg==1'b1)) begin
		cnt <= 12'h0;
		start_tx <= 1'b1;
	end
	else if (cnt == 12'd155) begin
		cnt <= 12'h0;
		start_tx <= 1'b1;
	end
	else begin
		cnt <= cnt + 12'h1;
		start_tx <= 1'b0;
	end
end
//------------start_tx��һ��ʱ��-----------------------
always @ (posedge clk_20M)
begin
	if(!reset_n) begin 
		tx_en <= 1'b0;
		start_tx_reg <= 1'b0;
	end
	else begin
		tx_en	<= start_tx_reg;
		start_tx_reg <= start_tx;
	end
end
//-----------------------------------
always @ (posedge clk_20M)  //sample PWM
begin
	if(!reset_n) PWM <= 2'b00;
	else if(start_tx) begin
		case ({PWM_L,PWM_R})
		 2'b11 : PWM <= 2'b11;
		 2'b10 : PWM <= 2'b10;
		 2'b01 : PWM <= 2'b01;
		 2'b00 : PWM <= 2'b00;
		default PWM <= 2'b00;
		endcase
	  end
end
//-----------------------------------
always @ (posedge clk_20M)
begin
	if(!reset_n)  begin
		con  <= 4'b0001;//����
	end
	else if (start_tx_reg) begin
		if( !PhaseStaA[0] && PhaseStaA[2] && bypass)//�յ����ڿ��Ƶ�Ԫ"��������"����ҷ���DSP������״̬���е�"��������"λ��Ч������"����"λ���֣�����Ҫ�����ģ���·�"��·"����
		   begin                                                                //�����ʱ���ж��������
				if(ControlWord[0] == 1'b1) con <= 4'b1001;//������·��λ
				else con <= 4'b0110;//������·
		end
		else if ((lock || (ControlWord[1] == 1'b0)) && !ControlWord[0]) con <= 4'b0001;//����
		else if ((lock || (ControlWord[1] == 1'b0)) &&(ControlWord[0] == 1'b1)) con <= 4'b0010;//������λ
		else if (ControlWord[1]== 1'b1) begin
			case (PWM) 
				2'b11 : con <= 4'b1101;  //ȫ��ͨ
				2'b10 : con <= 4'b1010;  //��ͨ
				2'b01 : con <= 4'b1100;  //�ҿ�ͨ
				2'b00 : con <= 4'b1110;  //ȫ����ͨ
				default : con <= 4'b1110;  //ȫ����ͨ
			endcase
		end
		else con <= con;
	end
	else con <= con;
end

endmodule
