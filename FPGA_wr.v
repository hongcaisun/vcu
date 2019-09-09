`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:48:11 09/14/2017 
// Design Name: 
// Module Name:    FPGA_wr 
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
module FPGA_wr(
					input clk_100M,
					input reset_n,
					input start_DPRAM,
					output reg o_ram_wea,
					output reg [9:0]o_ram_addr,
					output reg [15:0]o_ram_data,
					output reg XINT1W,
					input XRD,
					
					input [15:0]ControlWord_A,			
					input [15:0]ControlWord_B,
					input [15:0]RenewalCnt_RC_A,		
					input [15:0]RenewalCnt_RC_B,
					input [15:0]CommStateRC_A,			
					input [15:0]CommStateRC_B,
					input [15:0]ComStaCP,
					input [15:0]ComSta_fastlock,
		 
					input [15:0]Phase_udcA,				
					input [15:0]Phase_udcB,			   
					input [15:0]Phase_udcC,
					 output reg [9:0]ram_addr_a,
					 output reg [9:0]ram_addr_b,
					 output reg [9:0]ram_addr_c,
					 
					 input [15:0]ram_data_a,
					 input [15:0]ram_data_b,
					 input [15:0]ram_data_c
);

parameter NUM_CP = 10'd14;
parameter NUM_PHASEA = 10'd80;
parameter NUM_PHASEB = 10'd80;
parameter NUM_PHASEC = 10'd82;
parameter ADDR_CP = 10'h100 + NUM_CP - 10'h1;
parameter ADDR_PHASEA = ADDR_CP + NUM_PHASEA;
parameter ADDR_PHASEB = ADDR_PHASEA + NUM_PHASEB;
parameter ADDR_PHASEC = ADDR_PHASEB + NUM_PHASEC;

parameter NUM_CP_DAT = NUM_CP+10'd1;

parameter STATE0		=5'd0;
parameter STATE1		=5'd1;
parameter STATE2		=5'd2;
parameter STATE3		=5'd3;
parameter STATE4		=5'd4;
parameter STATE5		=5'd5;
parameter STATE6		=5'd6;
parameter STATE7		=5'd7;
parameter STATE8		=5'd8;
parameter STATE9		=5'd9;
parameter STATE10		=5'd10;
parameter STATE11		=5'd11;
parameter STATE12		=5'd12;
parameter STATE13		=5'd13;


reg [9:0]cnt;
reg ram_w,ram_w_reg;//дRAM0дʹ�ܺ���һ��ʱ�ӵ��ź�
reg start_DPRAM_reg;//дDPRAMʹ���ź���һ��ʱ��
reg [15:0]RenewalCnt_VCtrl;//����FPGA���¼�����
reg [15:0] cnt_fs;//���ж��ź���չ���ƽ�ļ�����
reg XINT1,XINT1_old;//DSP�ж��źź���һ��ʱ�ӵ��ź�
reg [9:0]ram0_addr;//dpram0���ĵ�ַ��
wire [15:0]ram0_data;//dpram0����������
reg [15:0]ram_din;//dpram0д��������
reg [4:0]ram_state;
reg [15:0]ram_cp_sum;//�ر�У���
reg [15:0]ram_moduleA_sum,ram_moduleB_sum,ram_moduleC_sum;//ģ������У���
//----------------дRAM0дʹ����һ��ʱ��--------------------
always @ (posedge clk_100M)
begin
	if(!reset_n) ram_w_reg <= 1'b0;
	else ram_w_reg <= ram_w;
end

//------------дDPRAMʹ���ź���һ��ʱ��-------
always @ (posedge clk_100M)
begin
    if(!reset_n) start_DPRAM_reg <= 1'b1;
	 else start_DPRAM_reg <= start_DPRAM;
end
//----------------����FPGA���¼�����+1---------------
always @ (posedge clk_100M)
begin
	if (!reset_n)
		RenewalCnt_VCtrl <= 16'd0;
	else if ( start_DPRAM & !start_DPRAM_reg )//������
		RenewalCnt_VCtrl <= RenewalCnt_VCtrl + 16'd1;
	else
		RenewalCnt_VCtrl <= RenewalCnt_VCtrl;
end
//--------------����DSP�ж�ʹ���ź�---------------------
always @ (posedge clk_100M)
begin
	if (!reset_n) begin
		XINT1 <= 1'b0;
	end
	else if ((start_DPRAM & !start_DPRAM_reg) || (o_ram_addr!=10'h0)) begin
		if (o_ram_addr == ADDR_PHASEC) XINT1 <= 1'b1;
		else XINT1 <= 1'b0;  
	end
	else XINT1 <= 1'b0;
end
//------���ж��ź���չ��2us-------
always @ (posedge clk_100M)
begin
	XINT1_old <= XINT1;		
	if (!reset_n) begin
		cnt_fs <= 16'd0;
		XINT1W <= 1'b0;
	end
	else if ((!XINT1_old)&(XINT1)) begin//������
		cnt_fs <= 16'd0;
		XINT1W <= 1'b1;
	end
	else if (cnt_fs <= 16'd240) begin
		cnt_fs <= cnt_fs +16'd1;
		XINT1W <= 1'b1;
	end
	else begin
		cnt_fs <= cnt_fs;
		XINT1W <= 1'b0;
	end  
end
//-------dpram0��дʹ���źų���д�����ã�����ʱ�䶼�ǽ�ֹд-------------
always @ (posedge clk_100M)
begin
	if(!reset_n) begin
		cnt <= 10'h0;
		ram_w <= 1'b0;
	end
	else if ((start_DPRAM & !start_DPRAM_reg) || (cnt!=10'h0)) begin
		if(cnt == NUM_CP_DAT) begin
			cnt <= 10'h0;
			ram_w <= 1'b0;
		end
		else begin 
			cnt <= cnt + 10'h1;
			ram_w <= 1'b1;
		end
	end
	else begin 
		cnt <= 10'h0;
	end
end
//--------------д��ַʱ��1��ַд����--------------
dpram_1024 ram_CP (
  .clka(clk_100M), // input clka
  .wea(ram_w_reg), // input [0 : 0] wea
  .addra(cnt), // input [9 : 0] addra
  .dina(ram_din), // input [15 : 0] dina
  .douta(), // output [15 : 0] douta
  .clkb(clk_100M), // input clkb
  .web(1'b0), // input [0 : 0] web
  .addrb(ram0_addr), // input [9 : 0] addrb
  .dinb(), // input [15 : 0] dinb
  .doutb(ram0_data) // output [15 : 0] doutb
);
//-------------------------------------------------
always @ (negedge reset_n or posedge clk_100M)//�˶���Ƶ�dpram0��dpram1���е���������ram0�ĵ�ַ1Ϊ��Ч��ַ
begin                                         //��˴˶ε�ַ��Ӧ��ʽЭ���1��
	if (!reset_n) begin                        //102��Ӧ�ر���������
		ram0_addr <= 10'd0;                           //103��Ӧ�ر��ĵ��Ƶ�ѹA 104��Ӧ�ر��ĵ��Ƶ�ѹB �Դ�����
		ram_addr_a<=10'd0;
		ram_addr_b<=10'd0;
		ram_addr_c<=10'd0;
		o_ram_wea <= 1'b0;
		o_ram_addr <= 10'd0;		
		o_ram_data <= 16'd0;
		ram_cp_sum <= 16'd0;
		ram_moduleA_sum <= 16'd0;
		ram_moduleB_sum <= 16'd0;
		ram_moduleC_sum <= 16'd0;
	end
	else begin
		case(ram_state)
			STATE0: begin
				if(cnt == NUM_CP_DAT) begin
					ram_state<=STATE1;
					ram0_addr<=10'd1;//�Ƚ���һ�����ݵ�ַ��ram0,STATE2ʱ��һ�����ݿ���					
				end
				else begin
				   ram_state <= STATE0;
					ram0_addr <= 10'd0;
					ram_addr_a<=10'd0;
		         ram_addr_b<=10'd0;
		         ram_addr_c<=10'd0;
					o_ram_wea <= 1'b0;
					o_ram_addr <= 10'd0;					
					o_ram_data <= 16'd0;
					ram_cp_sum <= 16'd0;
					ram_moduleA_sum <= 16'd0;
					ram_moduleB_sum <= 16'd0;
					ram_moduleC_sum <= 16'd0;
				end
			end
			STATE1: begin  
				ram_state<=STATE2;
				ram0_addr<=ram0_addr+10'd1;
				o_ram_data<=ram0_data;
			end
			STATE2: begin  
				ram_state<=STATE3;
				ram0_addr<=ram0_addr+10'd1;
				o_ram_data<=ram0_data;
			end
			STATE3:begin 
				ram0_addr<=ram0_addr+10'd1;
				o_ram_wea<=1;//STATE3ʱ���ⲿDSP�ӿ�RAMд���һ������
				o_ram_addr<=10'h100;//ƥ��RAM��ַ��ʼ��ַ
				o_ram_data<=ram0_data;
				ram_cp_sum<=ram0_data;
				ram_state<=STATE4;
			end
			STATE4:begin//����FPGAд��dsp���˶�Ϊд��ر���Ϣ��У��
				ram0_addr<=ram0_addr+10'd1;
				o_ram_wea<=1;
				o_ram_addr<=o_ram_addr+10'd1;
				o_ram_data<=ram0_data;
				ram_cp_sum <= ram_cp_sum +ram0_data;
				if (o_ram_addr == ADDR_CP-10'd2) begin
					ram_state<=STATE5;
					ram_addr_a<=10'd1;//A��RAM���ݵ�һ����ַ���ݣ�STATE4�ڶ���clk����
				end
				else ram_state<=STATE4;
			end
			STATE5:begin
				o_ram_wea<=1;
				o_ram_addr<=o_ram_addr+10'd1;
				o_ram_data<=~ram_cp_sum;
				ram_state<=STATE6;
				ram_addr_a<=ram_addr_a+10'd1;
			end
			STATE6:begin//����FPGAд��dsp���˶�Ϊд��A���������ݣ���������RX_Unit RAM
				ram_addr_a<=ram_addr_a+10'd1;
				o_ram_wea<=1;
				o_ram_addr<=o_ram_addr+10'd1;								
				if(o_ram_addr == (ADDR_PHASEA-10'd1))begin
				  o_ram_data<=~ram_moduleA_sum;
				  ram_state<=STATE7;
				  ram_addr_b<=10'd1;//B��RAM���ݵ�һ����ַ���ݣ�STATE5�ڶ���clk����				 
				end
				else if(o_ram_addr == ADDR_CP)begin//A��ƽ��ֱ����ѹ
				  o_ram_data<=Phase_udcA;
				  ram_moduleA_sum <= Phase_udcA;				  
				end
				else begin
				  o_ram_data<=ram_data_a;
				  ram_moduleA_sum <= ram_moduleA_sum +ram_data_a;
				end
			end
			STATE7:begin
				ram_addr_b<=ram_addr_b+10'd1;
				o_ram_wea<=1;
				o_ram_addr<=o_ram_addr+10'd1;
				o_ram_data<=Phase_udcB;
				ram_moduleB_sum <= Phase_udcB;
				ram_state<=STATE8;
			end
			STATE8:begin
				ram_addr_b<=ram_addr_b+10'd1;
				ram_state<=STATE9;
			end
			STATE9:begin//����FPGAд��dsp���˶�Ϊд��B���������ݣ���������RX_Unit RAM
				ram_addr_b<=ram_addr_b+10'd1;
				o_ram_wea<=1;
				o_ram_addr<=o_ram_addr+10'd1;				
				if(o_ram_addr == (ADDR_PHASEB-10'd1))begin
				  o_ram_data<=~ram_moduleB_sum;	
				  ram_state<=STATE10;
				  ram_addr_c<=10'd1;//C��RAM���ݵ�һ����ַ���ݣ�STATE6�ڶ���clk����				 
				end
				else begin
				  o_ram_data<=ram_data_b;
				  ram_moduleB_sum <= ram_moduleB_sum +ram_data_b;
				end
			end
			STATE10:begin
				ram_addr_c<=ram_addr_c+10'd1;
				o_ram_wea<=1;
				o_ram_addr<=o_ram_addr+10'd1;
				o_ram_data<=Phase_udcC;
				ram_moduleC_sum <= Phase_udcC;	
				ram_state<=STATE11;
			end
			STATE11:begin
				ram_addr_c<=ram_addr_c+10'd1;
				ram_state<=STATE12;
			end
			STATE12:begin//����FPGAд��dsp���˶�Ϊд��C���������ݣ���������RX_Unit RAM
				ram_addr_c<=ram_addr_c+10'd1;
				o_ram_wea<=1;
				o_ram_addr<=o_ram_addr+10'd1;				
				if(o_ram_addr == (ADDR_PHASEC-10'd1))begin
				  o_ram_data<=~ram_moduleC_sum;	
				  ram_state<=STATE13;
				end
				else begin
				  o_ram_data<=ram_data_c;
				  ram_moduleC_sum <= ram_moduleC_sum +ram_data_c;
				end
			end			
			default:  begin
				   ram_state <= STATE0;
					ram0_addr <= 10'd0;
					ram_addr_a<=10'd0;
		         ram_addr_b<=10'd0;
		         ram_addr_c<=10'd0;
					o_ram_wea <= 1'b0;
					o_ram_addr <= 10'd0;					
					o_ram_data <= 16'd0;
					ram_cp_sum <= 16'd0;
					ram_moduleA_sum <= 16'd0;
					ram_moduleB_sum <= 16'd0;
					ram_moduleC_sum <= 16'd0;				
			end
		endcase	  
	end
end
//---------------��dpram0д����---------------------
always @ (posedge clk_100M)
begin
	if (!reset_n) ram_din <= 16'h0;
	else begin
		case (cnt)
		 10'd1 :ram_din <= ControlWord_A;//�ر�Aϵͳ�·�������
		 10'd2 :ram_din <= 16'd0;//����;
		 10'd3 :ram_din <= RenewalCnt_RC_A;//�ر�Aϵͳ���¼�����
		 10'd4 :ram_din <= ControlWord_B;//�ر�Bϵͳ�·�������
		 10'd5 :ram_din <= 16'd0;//����;
		 10'd6 :ram_din <= RenewalCnt_RC_B;//�ر�Bϵͳ���¼�����
		 10'd7 :ram_din <= CommStateRC_A;//��AϵͳͨѶ״̬��
		 10'd8 :ram_din <= CommStateRC_B;//��BϵͳͨѶ״̬��
		 10'd9 :ram_din <= ComStaCP;//�ر�״̬��
		 10'd10:ram_din <= ComSta_fastlock;//����
		 10'd11:ram_din <= 16'd0;//����
		 10'd12:ram_din <= 16'd0;//����
		 10'd13:ram_din <= RenewalCnt_VCtrl;//����FPGA���¼�����
		 10'd14:ram_din <= 16'd0;//У����1����1��13�������ȡ�����û���ram����У��ͣ�������������0���������ø�λ�á�
		 default : ram_din <=16'h0;
		endcase
  end
end
////-----------------------------------Test---------------------------------//
//wire [35:0] ILAControl;
//wire [79:0] data_chipscp; 
////assign data_chipscp [5:0] = {ram_w_reg,ram_w,XINT1,XINT1W,start_DPRAM_reg,start_DPRAM};
////assign data_chipscp [8:6] = {ram_state};
////assign data_chipscp [10:9] = {1'b0,o_ram_wea};
//assign data_chipscp [15:0] = {1'b0,ram0_addr,ram_state};
//assign data_chipscp [31:16] = ram_data_a;
//assign data_chipscp [47:32] = {6'b0,o_ram_addr};
//assign data_chipscp [63:48] = {6'b0,ram_addr_a};
//assign data_chipscp [79:64] = o_ram_data;
//
//new_icon SVG_icon ( 
//     .CONTROL0            ( ILAControl) 
//); 
//
//new_ila SVG_ila ( 
//     .CONTROL            ( ILAControl), 
//     .CLK                ( clk_100M), 
//     .DATA               ( data_chipscp), 
//     .TRIG0              (start_DPRAM ) ,
//	    .TRIG1              ( XINT1W),
//     .TRIG2              ( ), 
//	    .TRIG3              ( )
//);
endmodule
