`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:        CEPRI
// Engineer:       ZHANG DIANQING
// 
// Create Date:    10:27:26 09/27/2016 
// Design Name: 
// Module Name:    FPGA_Version 
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
module FPGA_Version(
       input i_clk,
		 input [15:0] DSP_A,
		 output [15:0] DSP_D,
		 input XZCS6,
		 input XRD,		 
		 input XWE		 
    );
reg [15:0] o_FPGA_Version;
assign DSP_D = ((XWE==1'b1) && (XRD == 1'b0) && (XZCS6 == 1'b0)&&(DSP_A[15:4] == 12'h030))? o_FPGA_Version : 16'bzzzzzzzzzzzzzzzz; //DSP��RAM����

parameter NAME_NUM = 8;
parameter VER_NUM  = 16;
parameter WORD_NUM8 = 8*16;
parameter WORD_NUM7 = 7*16;
parameter WORD_NUM6 = 6*16;
parameter WORD_NUM5 = 5*16;
parameter WORD_NUM4 = 4*16;
parameter WORD_NUM3 = 3*16;
parameter WORD_NUM2 = 2*16;
parameter WORD_NUM1 = 1*16;
wire [NAME_NUM*16:1]FPGA_NAME;//GB2312����
wire [VER_NUM*8:1] FPGA_VER;//ASCII����
wire [3:0] addr_rd_Version;
assign addr_rd_Version =  DSP_A[3:0];    
//***********�˴���дFPGA��Ԫ���Ƽ�����汾��**************//

assign FPGA_NAME = "���ؿ��Ƶ�Ԫ    ";//������ƣ��̶�Ϊ8���֣����������󲹿ո�
assign FPGA_VER  = "V1.12.190810TEST";//����汾��Ϣ+���ڣ��Ϊ16���ֽ�

//***********�˴���дFPGA��Ԫ���Ƽ�����汾��**************//

always @ (posedge i_clk)
begin
    case(addr_rd_Version)
	 4'd0:o_FPGA_Version<=FPGA_NAME[WORD_NUM8:WORD_NUM7+1];//�������
	 4'd1:o_FPGA_Version<=FPGA_NAME[WORD_NUM7:WORD_NUM6+1];//	
	 4'd2:o_FPGA_Version<=FPGA_NAME[WORD_NUM6:WORD_NUM5+1];//	
	 4'd3:o_FPGA_Version<=FPGA_NAME[WORD_NUM5:WORD_NUM4+1];//	
	 4'd4:o_FPGA_Version<=FPGA_NAME[WORD_NUM4:WORD_NUM3+1];//
	 4'd5:o_FPGA_Version<=FPGA_NAME[WORD_NUM3:WORD_NUM2+1];//
	 4'd6:o_FPGA_Version<=FPGA_NAME[WORD_NUM2:WORD_NUM1+1];//
	 4'd7:o_FPGA_Version<=FPGA_NAME[WORD_NUM1:1];//
	 
	 4'd8:o_FPGA_Version<=FPGA_VER[WORD_NUM8:WORD_NUM7+1];//����汾��Ϣ+����
	 4'd9:o_FPGA_Version<=FPGA_VER[WORD_NUM7:WORD_NUM6+1];//	
	 4'd10:o_FPGA_Version<=FPGA_VER[WORD_NUM6:WORD_NUM5+1];//	
	 4'd11:o_FPGA_Version<=FPGA_VER[WORD_NUM5:WORD_NUM4+1];//	
	 4'd12:o_FPGA_Version<=FPGA_VER[WORD_NUM4:WORD_NUM3+1];//
	 4'd13:o_FPGA_Version<=FPGA_VER[WORD_NUM3:WORD_NUM2+1];//
	 4'd14:o_FPGA_Version<=FPGA_VER[WORD_NUM2:WORD_NUM1+1];//
	 4'd15:o_FPGA_Version<=FPGA_VER[WORD_NUM1:1];//
//	 5'd0:o_FPGA_Version<=401;//FPGA�汾�ţ�����100�ϴ�����V4r00��V4.00����400�ϴ���
//	 5'd1:o_FPGA_Version<=2016;//��	
//	 5'd2:o_FPGA_Version<=11;//��	
//	 5'd3:o_FPGA_Version<=11;//��	
//	 5'd4:o_FPGA_Version<=18;//ʱ
//	 5'd5:o_FPGA_Version<=04;//��
	 default:o_FPGA_Version<=0;
	 endcase  	 
end

endmodule
