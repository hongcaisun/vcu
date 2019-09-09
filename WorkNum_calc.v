`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:44:30 03/14/2019 
// Design Name: 
// Module Name:    WorkNum_calc 
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
module WorkNum_calc#(
							parameter TOTAL_NUM_MODEL = 6'd18,
							parameter BIT_NUM = 18'd0
)
(
                     input i_clk_20M,
					      input i_reset_n,
						   input [15:0]i_LinkNum_Total,
							input [15:0]i_VCU_Mode,
							input [15:0]i_Redun_pos1,
							input [15:0]i_Redun_pos2,
							input [15:0]i_Redun_pos3,
							input [15:0]i_Redun_pos4,
							input [15:0]i_Redun_pos5,
							input [15:0]i_Redun_pos6,
							output[15:0]o_LinkNumA_Work,
							output[15:0]o_LinkNumB_Work,
							output[15:0]o_LinkNumC_Work,
							output      redun_Syn
                     );
//------------信号定义----------------//
parameter NUM_MODEL = TOTAL_NUM_MODEL - 6'd1;
wire [23:0] redun_wordA = {i_Redun_pos2[7:0],i_Redun_pos1};//A相冗余位置字
wire [23:0] redun_wordB = {i_Redun_pos4[7:0],i_Redun_pos3};//B相冗余位置字
wire [23:0] redun_wordC = {i_Redun_pos6[7:0],i_Redun_pos5};//C相冗余位置字

reg  [23:0] redun_wordA_reg;
reg  [23:0] redun_wordB_reg;
reg  [23:0] redun_wordC_reg;
reg  [5:0]	redun_numA;	//A相冗余模块个数
reg  [5:0]	redun_numB;	//B相冗余模块个数
reg  [5:0]	redun_numC;	//C相冗余模块个数
reg  [5:0]	redun_numA_temp;	//A相冗余模块个数中间量
reg  [5:0]	redun_numB_temp;	//B相冗余模块个数中间量
reg  [5:0]	redun_numC_temp;	//C相冗余模块个数中间量
reg  [5:0]  Link_cntA; //用于判断模块冗余计数器
reg  [5:0]  Link_cntB; //用于判断模块冗余计数器
reg  [5:0]  Link_cntC; //用于判断模块冗余计数器
//reg  [7:0]  cnt_shift_ready;//冗余后，重新得到载波移相初始角的最大时间 约250clk=12.5us

assign o_LinkNumA_Work = (i_VCU_Mode == 16'h55aa) ? (i_LinkNum_Total-redun_numA) : (i_LinkNum_Total-redun_numA-redun_numB-redun_numC);//55AA:3合一,单相时默认A为总工作个数
assign o_LinkNumB_Work = (i_VCU_Mode == 16'h55aa) ? (i_LinkNum_Total-redun_numB) : (i_LinkNum_Total-redun_numA-redun_numB-redun_numC);//55AA:3合一,单相时默认A为总工作个数
assign o_LinkNumC_Work = (i_VCU_Mode == 16'h55aa) ? (i_LinkNum_Total-redun_numC) : (i_LinkNum_Total-redun_numA-redun_numB-redun_numC);//55AA:3合一,单相时默认A为总工作个数

assign redun_Syn = 1'b0;//冗余后只根据载波同步信号同步，不主动额外同步
//----------------冗余位置字拍一个时钟-------------------
always @ (posedge i_clk_20M)
begin
	if(!i_reset_n)redun_wordA_reg <= 24'd0;
	else redun_wordA_reg <= redun_wordA;
end

always @ (posedge i_clk_20M)
begin
	if(!i_reset_n)redun_wordB_reg <= 24'd0;
	else redun_wordB_reg <= redun_wordB;
end

always @ (posedge i_clk_20M)
begin
	if(!i_reset_n)redun_wordC_reg <= 24'd0;
	else redun_wordC_reg <= redun_wordC;
end
//------------A相冗余模块数计算-------------//
always @ (posedge i_clk_20M)
begin
   if(!i_reset_n)
	  begin
      redun_numA<=0;
		redun_numA_temp<=0;
		Link_cntA<=0;
	  end
	else if(redun_wordA_reg[NUM_MODEL:0] == BIT_NUM)
	  begin
	   redun_numA<=0;
		redun_numA_temp<=0;		
		Link_cntA<=0;
	  end
	else begin	  
	   if(Link_cntA < TOTAL_NUM_MODEL)begin
		  if(redun_wordA_reg[Link_cntA] == 1'b1)begin
		    Link_cntA  <= Link_cntA  + 1;
		    redun_numA_temp <= redun_numA_temp + 1;
		  end
		  else Link_cntA  <= Link_cntA  + 1;
		end
		else begin
		  	 redun_numA<=redun_numA_temp;
			 redun_numA_temp<=0;
		    Link_cntA<=0;
		end
	  end
end
//------------B相冗余模块数计算-------------//
always @ (posedge i_clk_20M)
begin
   if(!i_reset_n)
	  begin
      redun_numB<=0;
		redun_numB_temp<=0;
		Link_cntB<=0;
	  end
	else if(redun_wordB_reg[NUM_MODEL:0] == BIT_NUM)
	  begin
	   redun_numB<=0;
		redun_numB_temp<=0;		
		Link_cntB<=0;
	  end
	else begin	  
	   if(Link_cntB < TOTAL_NUM_MODEL)begin
		  if(redun_wordB_reg[Link_cntB] == 1'b1)begin
		    Link_cntB  <= Link_cntB  + 1;
		    redun_numB_temp <= redun_numB_temp + 1;
		  end
		  else Link_cntB  <= Link_cntB  + 1;
		end
		else begin
		  	 redun_numB<=redun_numB_temp;
			 redun_numB_temp<=0;
		    Link_cntB<=0;
		end
	  end
end
//------------C相冗余模块数计算-------------//
always @ (posedge i_clk_20M)
begin
   if(!i_reset_n)
	  begin
      redun_numC<=0;
		redun_numC_temp<=0;
		Link_cntC<=0;
	  end
	else if(redun_wordC_reg[NUM_MODEL:0] == BIT_NUM)
	  begin
	   redun_numC<=0;
		redun_numC_temp<=0;		
		Link_cntC<=0;
	  end
	else begin	  
	   if(Link_cntC < TOTAL_NUM_MODEL)begin
		  if(redun_wordC_reg[Link_cntC] == 1'b1)begin
		    Link_cntC  <= Link_cntC  + 1;
		    redun_numC_temp <= redun_numC_temp + 1;
		  end
		  else Link_cntC  <= Link_cntC  + 1;
		end
		else begin
		  	 redun_numC<=redun_numC_temp;
			 redun_numC_temp<=0;
		    Link_cntC<=0;
		end
	  end
end
//计算完新的载波移相角后，重新同步一下
//always @ (posedge clk_20M)
//begin
//   if(!reset_n)begin
//	  cnt_shift_ready <= 8'd0;
//	  redun_Syn <=1'b0;
//	end
//	else if((redun_wordC_reg != redun_wordC) || (cnt_shift_ready > 8'd0))begin
//	  if(cnt_shift_ready < 8'd250)cnt_shift_ready<= cnt_shift_ready + 8'd1; 
//	  else begin
//	    cnt_shift_ready<= 8'd0; 
//		 redun_Syn <= 1'b1;
//	  end
//	end
//	else redun_Syn <= 1'b0;
//end
endmodule
