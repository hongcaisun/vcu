`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:44:55 03/14/2019 
// Design Name: 
// Module Name:    Initial_Angle_calc 
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
module Initial_Angle_calc(
								 input i_clk_20M,
								 input i_reset_n,
								 input [15:0]i_VCU_Mode,
								 input [15:0]i_angle_shiftA,
								 input [15:0]i_angle_shiftB,
								 input [15:0]i_angle_shiftC,
								 input [15:0]i_Redun_pos1,
								 input [15:0]i_Redun_pos2,
								 input [15:0]i_Redun_pos3,
								 input [15:0]i_Redun_pos4,
								 input [15:0]i_Redun_pos5,
								 input [15:0]i_Redun_pos6,
								 output [383:0]o_initi_angleA_BUS,
								 output [383:0]o_initi_angleB_BUS,
								 output [383:0]o_initi_angleC_BUS
                          );
reg [15:0]  initi_A1,initi_A2,initi_A3,initi_A4,initi_A5,initi_A6,initi_A7,initi_A8,initi_A9,initi_A10,
            initi_A11,initi_A12,initi_A13,initi_A14,initi_A15,initi_A16,initi_A17,initi_A18,initi_A19,initi_A20,
            initi_A21,initi_A22,initi_A23,initi_A24;//A相模块移相角	
reg [15:0]  initi_B1,initi_B2,initi_B3,initi_B4,initi_B5,initi_B6,initi_B7,initi_B8,initi_B9,initi_B10,
            initi_B11,initi_B12,initi_B13,initi_B14,initi_B15,initi_B16,initi_B17,initi_B18,initi_B19,initi_B20,
            initi_B21,initi_B22,initi_B23,initi_B24;//B相模块移相角	
reg [15:0]  initi_C1,initi_C2,initi_C3,initi_C4,initi_C5,initi_C6,initi_C7,initi_C8,initi_C9,initi_C10,
            initi_C11,initi_C12,initi_C13,initi_C14,initi_C15,initi_C16,initi_C17,initi_C18,initi_C19,initi_C20,
            initi_C21,initi_C22,initi_C23,initi_C24;//C相模块移相角	
				
assign o_initi_angleA_BUS = {initi_A1,initi_A2,initi_A3,initi_A4,initi_A5,initi_A6,initi_A7,initi_A8,initi_A9,initi_A10,
            initi_A11,initi_A12,initi_A13,initi_A14,initi_A15,initi_A16,initi_A17,initi_A18,initi_A19,initi_A20,
            initi_A21,initi_A22,initi_A23,initi_A24};
assign o_initi_angleB_BUS = {initi_B1,initi_B2,initi_B3,initi_B4,initi_B5,initi_B6,initi_B7,initi_B8,initi_B9,initi_B10,
            initi_B11,initi_B12,initi_B13,initi_B14,initi_B15,initi_B16,initi_B17,initi_B18,initi_B19,initi_B20,
            initi_B21,initi_B22,initi_B23,initi_B24};
assign o_initi_angleC_BUS = {initi_C1,initi_C2,initi_C3,initi_C4,initi_C5,initi_C6,initi_C7,initi_C8,initi_C9,initi_C10,
            initi_C11,initi_C12,initi_C13,initi_C14,initi_C15,initi_C16,initi_C17,initi_C18,initi_C19,initi_C20,
            initi_C21,initi_C22,initi_C23,initi_C24};
				
wire [23:0] redun_wordA = {i_Redun_pos2[7:0],i_Redun_pos1};//A相冗余位置字
wire [23:0] redun_wordB = {i_Redun_pos4[7:0],i_Redun_pos3};//B相冗余位置字
wire [23:0] redun_wordC = {i_Redun_pos6[7:0],i_Redun_pos5};//C相冗余位置字
				
reg  [7:0]  Link_cal; //用于一直循环计算模块数目

//-------------Link_cal从0到72之间一直循环---------------------
always @ (posedge i_clk_20M)
begin
   if(!i_reset_n)Link_cal  <= 8'd0;
	else begin
		if(Link_cal <= 8'd71) Link_cal <= Link_cal + 8'd1;
		else Link_cal  <= 8'd0;
	end
end	
	
always @ (posedge i_clk_20M)
begin
	if(!i_reset_n)begin
		initi_A1 <= 16'd0;initi_A2 <= 16'd0;initi_A3 <= 16'd0;initi_A4 <= 16'd0;
		initi_A5 <= 16'd0;initi_A6 <= 16'd0;initi_A7 <= 16'd0; initi_A8 <= 16'd0;
		initi_A9 <= 16'd0;initi_A10 <= 16'd0;initi_A11 <= 16'd0;initi_A12 <= 16'd0;
		initi_A13 <= 16'd0;initi_A14 <= 16'd0;initi_A15 <= 16'd0;initi_A16 <= 16'd0;
		initi_A17 <= 16'd0;initi_A18 <= 16'd0;initi_A19 <= 16'd0;initi_A20 <= 16'd0;
		initi_A21 <= 16'd0;initi_A22 <= 16'd0;initi_A23 <= 16'd0;initi_A24 <= 16'd0;
		initi_B1 <= 16'd0;initi_B2 <= 16'd0;initi_B3 <= 16'd0;initi_B4 <= 16'd0;
		initi_B5 <= 16'd0;initi_B6 <= 16'd0;initi_B7 <= 16'd0; initi_B8 <= 16'd0;
		initi_B9 <= 16'd0;initi_B10 <= 16'd0;initi_B11 <= 16'd0;initi_B12 <= 16'd0;
		initi_B13 <= 16'd0;initi_B14 <= 16'd0;initi_B15 <= 16'd0;initi_B16 <= 16'd0;
		initi_B17 <= 16'd0;initi_B18 <= 16'd0;initi_B19 <= 16'd0;initi_B20 <= 16'd0;
		initi_B21 <= 16'd0;initi_B22 <= 16'd0;initi_B23 <= 16'd0;initi_B24 <= 16'd0;
		initi_C1 <= 16'd0;initi_C2 <= 16'd0;initi_C3 <= 16'd0;initi_C4 <= 16'd0;
		initi_C5 <= 16'd0;initi_C6 <= 16'd0;initi_C7 <= 16'd0; initi_C8 <= 16'd0;
		initi_C9 <= 16'd0;initi_C10 <= 16'd0;initi_C11 <= 16'd0;initi_C12 <= 16'd0;
		initi_C13 <= 16'd0;initi_C14 <= 16'd0;initi_C15 <= 16'd0;initi_C16 <= 16'd0;
		initi_C17 <= 16'd0;initi_C18 <= 16'd0;initi_C19 <= 16'd0;initi_C20 <= 16'd0;
		initi_C21 <= 16'd0;initi_C22 <= 16'd0;initi_C23 <= 16'd0;initi_C24 <= 16'd0;
	end
	else begin
	case(Link_cal)
     8'd0: begin
	          if(redun_wordA[0]==1'b1) initi_A1 <= 16'd0;
             else initi_A1 <= 16'd0;
			  end
     8'd1: begin
	          if(redun_wordA[1]==1'b1) initi_A2 <= initi_A1;
             else if(redun_wordA[0]==1'b1)initi_A2 <= initi_A1;
				 else initi_A2 <= initi_A1 + i_angle_shiftA;
			  end	  
     8'd2: begin
	          if(redun_wordA[2]==1'b1) initi_A3 <= initi_A2;
             else initi_A3 <= initi_A2 + i_angle_shiftA;
			  end	 
     8'd3: begin
	          if(redun_wordA[3]==1'b1) initi_A4 <= initi_A3;
             else initi_A4 <= initi_A3 + i_angle_shiftA;
			  end	 		
     8'd4: begin
	          if(redun_wordA[4]==1'b1) initi_A5 <= initi_A4;
             else initi_A5 <= initi_A4 + i_angle_shiftA;
			  end	 	
     8'd5: begin
	          if(redun_wordA[5]==1'b1) initi_A6 <= initi_A5;
             else initi_A6 <= initi_A5 + i_angle_shiftA;
			  end	 
     8'd6: begin
	          if(redun_wordA[6]==1'b1) initi_A7 <= initi_A6;
             else initi_A7 <= initi_A6 + i_angle_shiftA;
			  end	 
     8'd7: begin
	          if(redun_wordA[7]==1'b1) initi_A8 <= initi_A7;
             else initi_A8 <= initi_A7 + i_angle_shiftA;
			  end	 
     8'd8: begin
	          if(redun_wordA[8]==1'b1) initi_A9 <= initi_A8;
             else initi_A9 <= initi_A8 + i_angle_shiftA;
			  end	 
     8'd9: begin
	          if(redun_wordA[9]==1'b1) initi_A10 <= initi_A9;
             else initi_A10 <= initi_A9 + i_angle_shiftA;
			  end	  
     8'd10: begin
	          if(redun_wordA[10]==1'b1) initi_A11 <= initi_A10;
             else initi_A11 <= initi_A10 + i_angle_shiftA;
			  end	
     8'd11: begin
	          if(redun_wordA[11]==1'b1) initi_A12 <= initi_A11;
             else initi_A12 <= initi_A11 + i_angle_shiftA;
			  end				  
	  8'd12: begin
	          if(redun_wordA[12]==1'b1) initi_A13 <= initi_A12;
             else initi_A13 <= initi_A12 + i_angle_shiftA;
			  end	 
     8'd13: begin
	          if(redun_wordA[13]==1'b1) initi_A14 <= initi_A13;
             else initi_A14 <= initi_A13 + i_angle_shiftA;
			  end	 		
     8'd14: begin
	          if(redun_wordA[14]==1'b1) initi_A15 <= initi_A14;
             else initi_A15 <= initi_A14 + i_angle_shiftA;
			  end	 	
     8'd15: begin
	          if(redun_wordA[15]==1'b1) initi_A16 <= initi_A15;
             else initi_A16 <= initi_A15 + i_angle_shiftA;
			  end	 
     8'd16: begin
	          if(redun_wordA[16]==1'b1) initi_A17 <= initi_A16;
             else initi_A17 <= initi_A16 + i_angle_shiftA;
			  end	 
     8'd17: begin
	          if(redun_wordA[17]==1'b1) initi_A18 <= initi_A17;
             else initi_A18 <= initi_A17 + i_angle_shiftA;
			  end	 
     8'd18: begin
	          if(redun_wordA[18]==1'b1) initi_A19 <= initi_A18;
             else initi_A19 <= initi_A18 + i_angle_shiftA;
			  end	 
     8'd19: begin
	          if(redun_wordA[19]==1'b1) initi_A20 <= initi_A19;
             else initi_A20 <= initi_A19 + i_angle_shiftA;
			  end	  
     8'd20: begin
	          if(redun_wordA[20]==1'b1) initi_A21 <= initi_A20;
             else initi_A21 <= initi_A20 + i_angle_shiftA;
			  end				  
     8'd21: begin
	          if(redun_wordA[21]==1'b1) initi_A22 <= initi_A21;
             else initi_A22 <= initi_A21 + i_angle_shiftA;
			  end				  
	  8'd22: begin
	          if(redun_wordA[22]==1'b1) initi_A23 <= initi_A22;
             else initi_A23 <= initi_A22 + i_angle_shiftA;
			  end				  
	  8'd23: begin
	          if(redun_wordA[23]==1'b1) initi_A24 <= initi_A23;
             else initi_A24 <= initi_A23 + i_angle_shiftA;
			  end	
//----------------------------B相------------------------------//		  
	  8'd24: begin 
	          if(redun_wordB[0]==1'b1) begin
				   if(i_VCU_Mode == 16'h55aa)initi_B1 <= 0;//三相合一
					else initi_B1 <= initi_A24;//单相
				 end
             else begin
				   if(i_VCU_Mode == 16'h55aa)initi_B1 <= 0;//三相合一
					else initi_B1 <= initi_A24 + i_angle_shiftB;//单相 
				 end
			  end
	  8'd25: begin 
	          if(redun_wordB[1]==1'b1) initi_B2 <= initi_B1;
				 else if(redun_wordB[0]==1'b1) initi_B2 <= initi_B1;
				 else  initi_B2 <= initi_B1 + i_angle_shiftB;
			  end 
     8'd26: begin
	          if(redun_wordB[2]==1'b1) initi_B3 <= initi_B2;
             else initi_B3 <= initi_B2 + i_angle_shiftB;
			  end	 
     8'd27: begin
	          if(redun_wordB[3]==1'b1) initi_B4 <= initi_B3;
             else initi_B4 <= initi_B3 + i_angle_shiftB;
			  end	 		
     8'd28: begin
	          if(redun_wordB[4]==1'b1) initi_B5 <= initi_B4;
             else initi_B5 <= initi_B4 + i_angle_shiftB;
			  end	 	
     8'd29: begin
	          if(redun_wordB[5]==1'b1) initi_B6 <= initi_B5;
             else initi_B6 <= initi_B5 + i_angle_shiftB;
			  end	 
     8'd30: begin
	          if(redun_wordB[6]==1'b1) initi_B7 <= initi_B6;
             else initi_B7 <= initi_B6 + i_angle_shiftB;
			  end	 
     8'd31: begin
	          if(redun_wordB[7]==1'b1) initi_B8 <= initi_B7;
             else initi_B8 <= initi_B7 + i_angle_shiftB;
			  end	 
     8'd32: begin
	          if(redun_wordB[8]==1'b1) initi_B9 <= initi_B8;
             else initi_B9 <= initi_B8 + i_angle_shiftB;
			  end	 
     8'd33: begin
	          if(redun_wordB[9]==1'b1) initi_B10 <= initi_B9;
             else initi_B10 <= initi_B9 + i_angle_shiftB;
			  end	  
     8'd34: begin
	          if(redun_wordB[10]==1'b1) initi_B11 <= initi_B10;
             else initi_B11 <= initi_B10 + i_angle_shiftB;
			  end	
     8'd35: begin
	          if(redun_wordB[11]==1'b1) initi_B12 <= initi_B11;
             else initi_B12 <= initi_B11 + i_angle_shiftB;
			  end				  
	  8'd36: begin
	          if(redun_wordB[12]==1'b1) initi_B13 <= initi_B12;
             else initi_B13 <= initi_B12 + i_angle_shiftB;
			  end	 
     8'd37: begin
	          if(redun_wordB[13]==1'b1) initi_B14 <= initi_B13;
             else initi_B14 <= initi_B13 + i_angle_shiftB;
			  end	 		
     8'd38: begin
	          if(redun_wordB[14]==1'b1) initi_B15 <= initi_B14;
             else initi_B15 <= initi_B14 + i_angle_shiftB;
			  end	 	
     8'd39: begin
	          if(redun_wordB[15]==1'b1) initi_B16 <= initi_B15;
             else initi_B16 <= initi_B15 + i_angle_shiftB;
			  end	 
     8'd40: begin
	          if(redun_wordB[16]==1'b1) initi_B17 <= initi_B16;
             else initi_B17 <= initi_B16 + i_angle_shiftB;
			  end	 
     8'd41: begin
	          if(redun_wordB[17]==1'b1) initi_B18 <= initi_B17;
             else initi_B18 <= initi_B17 + i_angle_shiftB;
			  end	 
     8'd42: begin
	          if(redun_wordB[18]==1'b1) initi_B19 <= initi_B18;
             else initi_B19 <= initi_B18 + i_angle_shiftB;
			  end	 
     8'd43: begin
	          if(redun_wordB[19]==1'b1) initi_B20 <= initi_B19;
             else initi_B20 <= initi_B19 + i_angle_shiftB;
			  end	  
     8'd44: begin
	          if(redun_wordB[20]==1'b1) initi_B21 <= initi_B20;
             else initi_B21 <= initi_B20 + i_angle_shiftB;
			  end				  
     8'd45: begin
	          if(redun_wordB[21]==1'b1) initi_B22 <= initi_B21;
             else initi_B22 <= initi_B21 + i_angle_shiftB;
			  end				  
	  8'd46: begin
	          if(redun_wordB[22]==1'b1) initi_B23 <= initi_B22;
             else initi_B23 <= initi_B22 + i_angle_shiftB;
			  end				  
	  8'd47: begin
	          if(redun_wordB[23]==1'b1) initi_B24 <= initi_B23;
             else initi_B24 <= initi_B23 + i_angle_shiftB;
			  end		
//----------------------------C相------------------------------//	
	  8'd48: begin 
	          if(redun_wordC[0]==1'b1) begin
				   if(i_VCU_Mode == 16'h55aa)initi_C1 <= 0;//三相合一
					else initi_C1 <= initi_B24;//单相
				 end
             else begin
				   if(i_VCU_Mode == 16'h55aa)initi_C1 <= 0;//三相合一
					else initi_C1 <= initi_B24 + i_angle_shiftC;//单相 
				 end
			  end
	  8'd49: begin 
	          if(redun_wordC[1]==1'b1) initi_C2 <= initi_C1;
				 else if(redun_wordC[0]==1'b1) initi_C2 <= initi_C1;
				 else  initi_C2 <= initi_C1 + i_angle_shiftC;
			  end 
     8'd50: begin
	          if(redun_wordC[2]==1'b1) initi_C3 <= initi_C2;
             else initi_C3 <= initi_C2 + i_angle_shiftC;
			  end	 
     8'd51: begin
	          if(redun_wordC[3]==1'b1) initi_C4 <= initi_C3;
             else initi_C4 <= initi_C3 + i_angle_shiftC;
			  end	 		
     8'd52: begin
	          if(redun_wordC[4]==1'b1) initi_C5 <= initi_C4;
             else initi_C5 <= initi_C4 + i_angle_shiftC;
			  end	 	
     8'd53: begin
	          if(redun_wordC[5]==1'b1) initi_C6 <= initi_C5;
             else initi_C6 <= initi_C5 + i_angle_shiftC;
			  end	 
     8'd54: begin
	          if(redun_wordC[6]==1'b1) initi_C7 <= initi_C6;
             else initi_C7 <= initi_C6 + i_angle_shiftC;
			  end	 
     8'd55: begin
	          if(redun_wordC[7]==1'b1) initi_C8 <= initi_C7;
             else initi_C8 <= initi_C7 + i_angle_shiftC;
			  end	 
     8'd56: begin
	          if(redun_wordC[8]==1'b1) initi_C9 <= initi_C8;
             else initi_C9 <= initi_C8 + i_angle_shiftC;
			  end	 
     8'd57: begin
	          if(redun_wordC[9]==1'b1) initi_C10 <= initi_C9;
             else initi_C10 <= initi_C9 + i_angle_shiftC;
			  end	  
     8'd58: begin
	          if(redun_wordC[10]==1'b1) initi_C11 <= initi_C10;
             else initi_C11 <= initi_C10 + i_angle_shiftC;
			  end	
     8'd59: begin
	          if(redun_wordC[11]==1'b1) initi_C12 <= initi_C11;
             else initi_C12 <= initi_C11 + i_angle_shiftC;
			  end				  
	  8'd60: begin
	          if(redun_wordC[12]==1'b1) initi_C13 <= initi_C12;
             else initi_C13 <= initi_C12 + i_angle_shiftC;
			  end	 
     8'd61: begin
	          if(redun_wordC[13]==1'b1) initi_C14 <= initi_C13;
             else initi_C14 <= initi_C13 + i_angle_shiftC;
			  end	 		
     8'd62: begin
	          if(redun_wordC[14]==1'b1) initi_C15 <= initi_C14;
             else initi_C15 <= initi_C14 + i_angle_shiftC;
			  end	 	
     8'd63: begin
	          if(redun_wordC[15]==1'b1) initi_C16 <= initi_C15;
             else initi_C16 <= initi_C15 + i_angle_shiftC;
			  end	 
     8'd64: begin
	          if(redun_wordC[16]==1'b1) initi_C17 <= initi_C16;
             else initi_C17 <= initi_C16 + i_angle_shiftC;
			  end	 
     8'd65: begin
	          if(redun_wordC[17]==1'b1) initi_C18 <= initi_C17;
             else initi_C18 <= initi_C17 + i_angle_shiftC;
			  end	 
     8'd66: begin
	          if(redun_wordC[18]==1'b1) initi_C19 <= initi_C18;
             else initi_C19 <= initi_C18 + i_angle_shiftC;
			  end	 
     8'd67: begin
	          if(redun_wordC[19]==1'b1) initi_C20 <= initi_C19;
             else initi_C20 <= initi_C19 + i_angle_shiftC;
			  end	  
     8'd68: begin
	          if(redun_wordC[20]==1'b1) initi_C21 <= initi_C20;
             else initi_C21 <= initi_C20 + i_angle_shiftC;
			  end				  
     8'd69: begin
	          if(redun_wordC[21]==1'b1) initi_C22 <= initi_C21;
             else initi_C22 <= initi_C21 + i_angle_shiftC;
			  end				  
	  8'd70: begin
	          if(redun_wordC[22]==1'b1) initi_C23 <= initi_C22;
             else initi_C23 <= initi_C22 + i_angle_shiftC;
			  end				  
	  8'd71: begin
	          if(redun_wordC[23]==1'b1) initi_C24 <= initi_C23;
             else initi_C24 <= initi_C23 + i_angle_shiftC;
			  end		  
	  default:      initi_A1 <= 16'd0;
   endcase		
   end	
end

endmodule
