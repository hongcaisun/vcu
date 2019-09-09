`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: CEPRI
// Engineer: ZHANG DIANQING
// 
// Create Date:    14:45:06 05/22/2015 
// Design Name: 
// Module Name:    PWM_TDM 
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
module PWM_TDM_cps(
					input clk_50M,
					input clk_20M,
					input clk_cps,
					input reset_n,
					input start,
					input signed [15:0]TargetVol,//相平均调制电压
					input signed [31:0]CosTheta,//三级稳压控制余弦*三级比例参数
					input [15:0]phaseUdc,//相平均直流电压
					input [15:0]LinkUdcA,//模块直流电压
					input [15:0]LinkUdcB,
					input [15:0]LinkUdcC,
					input [15:0]Udc_limit,//直流电压第三级控制限幅
               input [15:0]PulWidth_Min,//最小脉宽限制
					input [15:0]PulWidth_Max,
					input signed [15:0]temp,
					input signed [31:0]temp_long,
					input AngleDirA,
					input [15:0]AngleA,
					output reg PWM_leftA,//PWM波
					output reg PWM_rightA,
					input AngleDirB,
					input [15:0]AngleB,
					output reg PWM_leftB,
					output reg PWM_rightB,
					input AngleDirC,
					input [15:0]AngleC,
					output reg PWM_leftC,
					output reg PWM_rightC,
//					input AngleDirD,
//					input [15:0]AngleD,
//					output reg PWM_leftD,
//					output reg PWM_rightD,
//					input AngleDirE,
//					input [15:0]AngleE,
//					output reg PWM_leftE,
//					output reg PWM_rightE,
               output reg[15:0]TargetVolA,//模块调制电压
					output reg[15:0]TargetVolB,
					output reg[15:0]TargetVolC
					);


//parameter Freq_min = 300;
//parameter Freq_max = 21922;
//parameter temp_a = 16'h2B67;  
//parameter temp_long_a = 32'h2B67;

//assign PWM_leftD=1'b0,PWM_rightD=1'b0,PWM_leftE=1'b0,PWM_rightE=1'b0;

wire   signed [15:0] Udc_temp,Uout_offset,FinalVout,Uout_temp,Udc_limit_neg;
wire   signed [47:0] VOFFSET;
reg           [15:0] LinkUdc; 
wire   signed [31:0] Modula_finalL;
wire   signed [31:0] Modula_finalR;
wire   signed [31:0] quotient;
wire   signed [31:0] dividend;
wire   signed [31:0] AmpLimitL;//限幅--左桥
wire   signed [31:0] AmpLimitR;//限幅--右桥
assign Udc_temp			= $signed(phaseUdc) - $signed(LinkUdc);
assign Udc_limit_neg		= {1'b1,(~Udc_limit[14:0]+1)};
assign VOFFSET          = Udc_temp * CosTheta >>> 19;
assign Uout_temp      	= VOFFSET[15:0];
assign Uout_offset		= Uout_temp[15] ? ((Uout_temp <= Udc_limit_neg)?  Udc_limit_neg :Uout_temp):((Uout_temp >= $signed(Udc_limit))? $signed(Udc_limit) : Uout_temp);
assign FinalVout        = TargetVol + Uout_offset;
assign dividend         = temp * FinalVout;
assign Modula_finalL    = temp_long + quotient;
assign Modula_finalR    = temp_long - quotient;
assign AmpLimitL  = Modula_finalL[31] ? PulWidth_Min : ((Modula_finalL > PulWidth_Max) ? PulWidth_Max:((Modula_finalL < PulWidth_Min) ? PulWidth_Min : Modula_finalL));
assign AmpLimitR  = Modula_finalR[31] ? PulWidth_Min : ((Modula_finalR > PulWidth_Max) ? PulWidth_Max:((Modula_finalR < PulWidth_Min) ? PulWidth_Min : Modula_finalR));
//**********************************************************//
//reg   signed [15:0] FinalVoutA;

reg         [15:0] cmpReg1_tempA;
reg         [15:0] cmpReg2_tempA;
//reg  signed [31:0] cmpReg1_temp_1A;
//reg  signed [31:0] cmpReg2_temp_2A;
reg         [15:0] cmpReg1A;
reg         [15:0] cmpReg2A;

reg comp_done_left_upA;
reg comp_done_left_downA;
reg comp_done_right_upA;
reg comp_done_right_downA;

//assign cmpReg1A = cmpReg1_temp_1A[15:0];
//assign cmpReg2A = cmpReg2_temp_2A[15:0];

//**********************************************************//
//reg  signed [15:0] FinalVoutB;

reg         [15:0] cmpReg1_tempB;
reg         [15:0] cmpReg2_tempB;
//reg  signed [31:0] cmpReg1_temp_1B;
//reg  signed [31:0] cmpReg2_temp_2B;
reg         [15:0] cmpReg1B;
reg         [15:0] cmpReg2B;

reg comp_done_left_upB;
reg comp_done_left_downB;
reg comp_done_right_upB;
reg comp_done_right_downB;


//assign cmpReg1B = cmpReg1_temp_1B[15:0];
//assign cmpReg2B = cmpReg2_temp_2B[15:0];
//**********************************************************//
//reg  signed [15:0] FinalVoutC;

reg         [15:0] cmpReg1_tempC;
reg         [15:0] cmpReg2_tempC;
//reg  signed [31:0] cmpReg1_temp_1C;
//reg  signed [31:0] cmpReg2_temp_2C;
reg         [15:0] cmpReg1C;
reg         [15:0] cmpReg2C;

reg comp_done_left_upC;
reg comp_done_left_downC;
reg comp_done_right_upC;
reg comp_done_right_downC;


//assign cmpReg1C = cmpReg1_temp_1C[15:0];
//assign cmpReg2C = cmpReg2_temp_2C[15:0];
////**********************************************************//
////reg  signed [15:0] FinalVoutD;
//
////reg         [15:0] cmpReg1_tempD;
////reg         [15:0] cmpReg2_tempD;
////reg  signed [31:0] cmpReg1_temp_1D;
////reg  signed [31:0] cmpReg2_temp_2D;
//reg         [15:0] cmpReg1D;
//reg         [15:0] cmpReg2D;
//
//reg comp_done_left_upD;
//reg comp_done_left_downD;
//reg comp_done_right_upD;
//reg comp_done_right_downD;
//
////assign cmpReg1D = cmpReg1_temp_1D[15:0];
////assign cmpReg2D = cmpReg2_temp_2D[15:0];
//
////**********************************************************//
////reg  signed [15:0] FinalVoutE;
//
////reg         [15:0] cmpReg1_tempE;
////reg         [15:0] cmpReg2_tempE;
////reg  signed [31:0] cmpReg1_temp_1E;
////reg  signed [31:0] cmpReg2_temp_2E;
//reg         [15:0] cmpReg1E;
//reg         [15:0] cmpReg2E;
//
//reg comp_done_left_upE;
//reg comp_done_left_downE;
//reg comp_done_right_upE;
//reg comp_done_right_downE;
//
////assign cmpReg1E = cmpReg1_temp_1E[15:0];
////assign cmpReg2E = cmpReg2_temp_2E[15:0];
//**********************************************************//
//reg          [15:0] divisor;

reg          [ 7:0] state;
reg          [ 7:0] next_state;

reg	start_reg ;
reg	start_reg_reg ;
reg  [5:0] cnt_Div;

parameter S0 = 8'b00000001;
parameter S1 = 8'b00000010;
parameter S2 = 8'b00000100;
parameter S3 = 8'b00001000;
parameter S4 = 8'b00010000;
parameter S5 = 8'b00100000;
parameter S6 = 8'b01000000;
parameter S7 = 8'b10000000;
//parameter S8 = 8'b000100000000;
//parameter S9 = 8'b001000000000;
//parameter S10 = 8'b010000000000;
//parameter S11 = 8'b100000000000;

Div_shift div (
	.clk(clk_50M),
	.dividend(dividend), // Bus [31 : 0] 
	.divisor(LinkUdc), // Bus [15 : 0] 
	.quotient(quotient) // Bus [31 : 0] 
	); // Bus [15 : 0] 
//reg Target_en;
//wire wea = Target_en ? 1'b1 : 1'b0;
//reg [3:0]  wr_addr;
//reg [15:0] dina;
//reg [3:0]  rd_addr;
//wire [15:0] ram_dout;
//
//TargetVol_RAM  TargetVol_RAM
//				(				
//				  .clka	(clk_20M		),
//				  .wea	(wea      	),
//				  .addra	(wr_addr	   ),
//				  .dina	(dina       ),
//				  .douta	(        	),
//				  .clkb	(clk_20M		),
//				  .web	(1'b0	      ),
//				  .addrb	(rd_addr	   ),
//				  .dinb	(       		),
//				  .doutb	(ram_dout	)
//				 );

always @ (posedge clk_50M or negedge reset_n ) 
 begin
    if (!reset_n) begin
	     start_reg_reg  <= 1'b0;
		  start_reg      <= 1'b0;
	 end
	 else begin
	     start_reg 		<= start ;
		  start_reg_reg   <= start_reg ;
	 end
 end

always @ (posedge clk_50M or negedge reset_n)
begin
 if (!reset_n) state <= S0;
 else state <= next_state;
end
  	  
always @ ( * )
begin
 next_state = S0;
 case (state)
	S0:
	  begin
		 if (start_reg_reg == 1'b1) next_state = S1;
		 else next_state = S0;
	  end
	S1: 
	    if(cnt_Div == 6'd39) next_state = S2;//保证调制波（除以直流电压）计算完毕
		 else next_state = S1;
	S2: next_state = S3;
	S3: 
	  begin
	    if(cnt_Div == 6'd39) next_state = S4;//保证调制波（除以直流电压）计算完毕
		 else next_state = S3;
	  end
	S4: next_state = S5;
	S5: 
	  begin
	    if(cnt_Div == 6'd39) next_state = S6;//保证调制波（除以直流电压）计算完毕
		 else next_state = S5;
	  end
	S6: next_state = S7;
	S7: next_state = S0;
//	  begin
//	    if(cnt_Div == 6'd39) next_state = S8;//保证调制波（除以直流电压）计算完毕
//		 else next_state = S7;
//	  end
//	S8: next_state = S9;
//	S9: 
//	  begin
//	    if(cnt_Div == 6'd39) next_state = S10;//保证调制波（除以直流电压）计算完毕
//		 else next_state = S9;
//	  end
//	S10: next_state = S11;
//	S11: next_state = S0;
 endcase
end

always @ (posedge clk_50M or negedge reset_n)
begin
 if (!reset_n)
	begin
	  LinkUdc          <= 16'b0;
	  cmpReg1A         <= 16'b0;
	  cmpReg2A         <= 16'b0;
	  cmpReg1B         <= 16'b0;
	  cmpReg2B         <= 16'b0;
	  cmpReg1C         <= 16'b0;
	  cmpReg2C         <= 16'b0;
//	  cmpReg1D         <= 16'b0;
//	  cmpReg2D         <= 16'b0;
//	  cmpReg1E         <= 16'b0;
//	  cmpReg2E         <= 16'b0;
//	  //	  FinalVoutB       <= 16'b0;
//	  cmpReg1_tempB    <= 32'b0;
//	  cmpReg2_tempB    <= 32'b0;
////	  FinalVoutC       <= 16'b0;
//	  cmpReg1_tempC    <= 32'b0;
//	  cmpReg2_tempC    <= 32'b0;
////	  FinalVoutD       <= 16'b0;
//	  cmpReg1_tempD    <= 32'b0;
//	  cmpReg2_tempD    <= 32'b0;
////	  FinalVoutE       <= 16'b0;
//	  cmpReg1_tempE    <= 32'b0;
//	  cmpReg2_tempE    <= 32'b0;
	  cnt_Div          <= 6'd0;
	end
 else
	begin
	  case (state)
		 S1:   
		    begin
			    LinkUdc    <= LinkUdcA;
				 if(cnt_Div < 6'd39)cnt_Div <= cnt_Div + 6'd1;
				 else cnt_Div <= 6'd0;
			 end
		 S2:   
		    begin
			    cmpReg1_tempA <= AmpLimitL;
				 cmpReg2_tempA <= AmpLimitR;
//				 cmpReg1A <= AmpLimitL;
//				 cmpReg2A <= AmpLimitR;
			 end				 
		 S3:   	
		    begin
			    LinkUdc    <= LinkUdcB;
				 if(cnt_Div < 6'd39)cnt_Div <= cnt_Div + 6'd1;
				 else cnt_Div <= 6'd0;
			 end
		 S4:
		    begin
			    cmpReg1_tempB <= AmpLimitL;
				 cmpReg2_tempB <= AmpLimitR;
//				 				 cmpReg1B <= AmpLimitL;
//				 cmpReg2B <= AmpLimitR;
			 end				 
		 S5:   	
		    begin
			    LinkUdc    <= LinkUdcC;
				 if(cnt_Div < 6'd39)cnt_Div <= cnt_Div + 6'd1;
				 else cnt_Div <= 6'd0;
			 end
		 S6:
		    begin
			    cmpReg1_tempC <= AmpLimitL;
				 cmpReg2_tempC <= AmpLimitR;
//				 				 cmpReg1C <= AmpLimitL;
//				 cmpReg2C <= AmpLimitR;
			 end
		 S7:   	
		    begin
			  cmpReg1A <= cmpReg1_tempA;
			  cmpReg2A <= cmpReg2_tempA;
			  cmpReg1B <= cmpReg1_tempB;
			  cmpReg2B <= cmpReg2_tempB;
			  cmpReg1C <= cmpReg1_tempC;
			  cmpReg2C <= cmpReg2_tempC;
//			    LinkUdc    <= LinkUdcD;
//				 if(cnt_Div < 6'd39)cnt_Div <= cnt_Div + 6'd1;
//				 else cnt_Div <= 6'd0;
			 end
//		 S8:
//		    begin
////			    cmpReg1_tempD <= AmpLimitL;
////				 cmpReg2_tempD <= AmpLimitR;
//				 				 cmpReg1D <= AmpLimitL;
//				 cmpReg2D <= AmpLimitR;
//			 end
//		 S9:   	
//		    begin
//			    LinkUdc    <= LinkUdcE;
//				 if(cnt_Div < 6'd39)cnt_Div <= cnt_Div + 6'd1;
//				 else cnt_Div <= 6'd0;
//			 end
//		 S10:
//		    begin
////			    cmpReg1_tempE <= AmpLimitL;
////				 cmpReg2_tempE <= AmpLimitR;
//				 				 cmpReg1E <= AmpLimitL;
//				 cmpReg2E <= AmpLimitR;
//			 end
//		 S11:
//			begin   //保证5个模块同步输出调制波
////			  cmpReg1A <= cmpReg1_tempA;
////			  cmpReg2A <= cmpReg2_tempA;
////			  cmpReg1B <= cmpReg1_tempB;
////			  cmpReg2B <= cmpReg2_tempB;
////			  cmpReg1C <= cmpReg1_tempC;
////			  cmpReg2C <= cmpReg2_tempC;
////			  cmpReg1D <= cmpReg1_tempD;
////			  cmpReg2D <= cmpReg2_tempD;
////			  cmpReg1E <= cmpReg1_tempE;
////			  cmpReg2E <= cmpReg2_tempE;
////			  cmpReg1_temp_1B <= cmpReg1_tempB;
////			  cmpReg2_temp_2B <= cmpReg2_tempB;
////			  cmpReg1_temp_1C <= cmpReg1_tempC;
////			  cmpReg2_temp_2C <= cmpReg2_tempC;
////			  cmpReg1_temp_1D <= cmpReg1_tempD;
////			  cmpReg2_temp_2D <= cmpReg2_tempD;
////			  cmpReg1_temp_1E <= cmpReg1_tempE;
////			  cmpReg2_temp_2E <= cmpReg2_tempE;
//			  
////			  Target_en <= 1'b1;
////			  if(wr_addr < 4'd10)wr_addr<=wr_addr+1;
////			  else wr_addr<=4'd0;
////			  case( wr_addr )
////			      0: dina <= cmpReg1_tempA;//读RAM时需要10个CLK,无法保证5个模块同步输出调制波
////					1: dina <= cmpReg2_tempA;
////					2: dina <= cmpReg1_tempB;
////					3: dina <= cmpReg2_tempB;
////					4: dina <= cmpReg1_tempC;
////					5: dina <= cmpReg2_tempC;
////					6: dina <= cmpReg1_tempD;
////					7: dina <= cmpReg2_tempD;
////					8: dina <= cmpReg1_tempE;
////					9: dina <= cmpReg2_tempE;
////					default: dina <= dina;
////			  endcase 
//
////			  if( cmpReg1_tempA[31] ) cmpReg1_temp_1A <= PulWidth_Min;
////			  else if (cmpReg1_tempA > PulWidth_Max) cmpReg1_temp_1A <= PulWidth_Max;
////			  else if (cmpReg1_tempA < PulWidth_Min) cmpReg1_temp_1A <= PulWidth_Min;
////			  else cmpReg1_temp_1A <= cmpReg1_tempA ;
//
////			  if (cmpReg2_tempA[31]) cmpReg2_temp_2A <= PulWidth_Min;
////			  else if (cmpReg2_tempA > PulWidth_Max) cmpReg2_temp_2A <= PulWidth_Max;
////			  else if (cmpReg2_tempA < PulWidth_Min) cmpReg2_temp_2A <= PulWidth_Min;
////			  else cmpReg2_temp_2A <= cmpReg2_tempA ;	
////			  
////			  
////			  if( cmpReg1_tempB[31] ) cmpReg1_temp_1B <= PulWidth_Min;
////			  else if (cmpReg1_tempB > PulWidth_Max) cmpReg1_temp_1B <= PulWidth_Max;
////			  else if (cmpReg1_tempB < PulWidth_Min) cmpReg1_temp_1B <= PulWidth_Min;
////			  else cmpReg1_temp_1B <= cmpReg1_tempB ;
////
////			  if (cmpReg2_tempB[31]) cmpReg2_temp_2B <= PulWidth_Min;
////			  else if (cmpReg2_tempB > PulWidth_Max) cmpReg2_temp_2B <= PulWidth_Max;
////			  else if (cmpReg2_tempB < PulWidth_Min) cmpReg2_temp_2B <= PulWidth_Min;
////			  else cmpReg2_temp_2B <= cmpReg2_tempB ;		
////			  
////			  
////			  if( cmpReg1_tempC[31] ) cmpReg1_temp_1C <= PulWidth_Min;
////			  else if (cmpReg1_tempC > PulWidth_Max) cmpReg1_temp_1C <= PulWidth_Max;
////			  else if (cmpReg1_tempC < PulWidth_Min) cmpReg1_temp_1C <= PulWidth_Min;
////			  else cmpReg1_temp_1C <= cmpReg1_tempC ;
////
////			  if (cmpReg2_tempC[31]) cmpReg2_temp_2C <= PulWidth_Min;
////			  else if (cmpReg2_tempC > PulWidth_Max) cmpReg2_temp_2C <= PulWidth_Max;
////			  else if (cmpReg2_tempC < PulWidth_Min) cmpReg2_temp_2C <= PulWidth_Min;
////			  else cmpReg2_temp_2C <= cmpReg2_tempC ;			
////
////			  if( cmpReg1_tempD[31] ) cmpReg1_temp_1D <= PulWidth_Min;
////			  else if (cmpReg1_tempD > PulWidth_Max) cmpReg1_temp_1D <= PulWidth_Max;
////			  else if (cmpReg1_tempD < PulWidth_Min) cmpReg1_temp_1D <= PulWidth_Min;
////			  else cmpReg1_temp_1D <= cmpReg1_tempD ;
////
////			  if (cmpReg2_tempD[31]) cmpReg2_temp_2D <= PulWidth_Min;
////			  else if (cmpReg2_tempD > PulWidth_Max) cmpReg2_temp_2D <= PulWidth_Max;
////			  else if (cmpReg2_tempD < PulWidth_Min) cmpReg2_temp_2D <= PulWidth_Min;
////			  else cmpReg2_temp_2D <= cmpReg2_tempD ;		
////
////			  if( cmpReg1_tempE[31] ) cmpReg1_temp_1E <= PulWidth_Min;
////			  else if (cmpReg1_tempE > PulWidth_Max) cmpReg1_temp_1E <= PulWidth_Max;
////			  else if (cmpReg1_tempE < PulWidth_Min) cmpReg1_temp_1E <= PulWidth_Min;
////			  else cmpReg1_temp_1E <= cmpReg1_tempE ;
////
////			  if (cmpReg2_tempE[31]) cmpReg2_temp_2E <= PulWidth_Min;
////			  else if (cmpReg2_tempE > PulWidth_Max) cmpReg2_temp_2E <= PulWidth_Max;
////			  else if (cmpReg2_tempE < PulWidth_Min) cmpReg2_temp_2E <= PulWidth_Min;
////			  else cmpReg2_temp_2E <= cmpReg2_tempE ;	
//			  
//			end
	  endcase
	end
end


always @ ( posedge clk_20M or negedge reset_n )
begin
 if ( ~reset_n ) begin
	  comp_done_left_upA 		<= 1'b0;
	  comp_done_left_downA 	<= 1'b0;		  
	  comp_done_right_upA 	<= 1'b0;
	  comp_done_right_downA 	<= 1'b0;
	  PWM_leftA 					<= 1'b0;
	  PWM_rightA 				<= 1'b0;
	end
 else begin
	  if ( AngleDirA == 1'b0 )  // up
		 begin
			comp_done_left_downA <= 1'b0;
			if ( !comp_done_left_upA && cmpReg1A < AngleA  )
			  begin
				 comp_done_left_upA <= 1'b1;
				 PWM_leftA <= 1'b0;
			  end
		 end
	  else
		 begin
			comp_done_left_upA <= 1'b0;
			if ( !comp_done_left_downA && cmpReg1A > AngleA )
			  begin
				 comp_done_left_downA <= 1'b1;
				 PWM_leftA <= 1'b1;
			  end			 
		 end			 
	  if ( AngleDirA == 1'b0 )  // up
		 begin
			comp_done_right_downA <= 1'b0;
			if ( !comp_done_right_upA && cmpReg2A < AngleA )
			  begin
				 comp_done_right_upA <= 1'b1;
				 PWM_rightA <= 1'b0;
			  end
		 end
	  else
		 begin
			comp_done_right_upA <= 1'b0;
			if ( !comp_done_right_downA && cmpReg2A > AngleA )
			  begin
				 comp_done_right_downA <= 1'b1;
				 PWM_rightA <= 1'b1;
			  end			 
		 end			  
	end
end


always @ ( posedge clk_20M or negedge reset_n )
begin
 if ( ~reset_n ) begin
	  comp_done_left_upB 		<= 1'b0;
	  comp_done_left_downB 	<= 1'b0;		  
	  comp_done_right_upB 	<= 1'b0;
	  comp_done_right_downB 	<= 1'b0;
	  PWM_leftB 					<= 1'b0;
	  PWM_rightB 				<= 1'b0;
	end
 else begin
	  if ( AngleDirB == 1'b0 )  // up
		 begin
			comp_done_left_downB <= 1'b0;
			if ( !comp_done_left_upB && cmpReg1B < AngleB  )
			  begin
				 comp_done_left_upB <= 1'b1;
				 PWM_leftB <= 1'b0;
			  end
		 end
	  else
		 begin
			comp_done_left_upB <= 1'b0;
			if ( !comp_done_left_downB && cmpReg1B > AngleB )
			  begin
				 comp_done_left_downB <= 1'b1;
				 PWM_leftB <= 1'b1;
			  end			 
		 end			 
	  if ( AngleDirB == 1'b0 )  // up
		 begin
			comp_done_right_downB <= 1'b0;
			if ( !comp_done_right_upB && cmpReg2B < AngleB )
			  begin
				 comp_done_right_upB <= 1'b1;
				 PWM_rightB <= 1'b0;
			  end
		 end
	  else
		 begin
			comp_done_right_upB <= 1'b0;
			if ( !comp_done_right_downB && cmpReg2B > AngleB )
			  begin
				 comp_done_right_downB <= 1'b1;
				 PWM_rightB <= 1'b1;
			  end			 
		 end			  
	end
end

always @ ( posedge clk_20M or negedge reset_n )
begin
 if ( ~reset_n ) begin
	  comp_done_left_upC 		<= 1'b0;
	  comp_done_left_downC 	<= 1'b0;		  
	  comp_done_right_upC 	<= 1'b0;
	  comp_done_right_downC 	<= 1'b0;
	  PWM_leftC 					<= 1'b0;
	  PWM_rightC 				<= 1'b0;
	end
 else begin
	  if ( AngleDirC == 1'b0 )  // up
		 begin
			comp_done_left_downC <= 1'b0;
			if ( !comp_done_left_upC && cmpReg1C < AngleC  )
			  begin
				 comp_done_left_upC <= 1'b1;
				 PWM_leftC <= 1'b0;
			  end
		 end
	  else
		 begin
			comp_done_left_upC <= 1'b0;
			if ( !comp_done_left_downC && cmpReg1C > AngleC )
			  begin
				 comp_done_left_downC <= 1'b1;
				 PWM_leftC <= 1'b1;
			  end			 
		 end			 
	  if ( AngleDirC == 1'b0 )  // up
		 begin
			comp_done_right_downC <= 1'b0;
			if ( !comp_done_right_upC && cmpReg2C < AngleC )
			  begin
				 comp_done_right_upC <= 1'b1;
				 PWM_rightC <= 1'b0;
			  end
		 end
	  else
		 begin
			comp_done_right_upC <= 1'b0;
			if ( !comp_done_right_downC && cmpReg2C > AngleC )
			  begin
				 comp_done_right_downC <= 1'b1;
				 PWM_rightC <= 1'b1;
			  end			 
		 end			  
	end
end

//--------------------------------------// 
always @ (posedge clk_50M or negedge reset_n ) 
begin
    if (!reset_n)        TargetVolA<=0;
    else if(state == S2) TargetVolA <= FinalVout;//Uout_offset;//FinalVout;
end	 
always @ (posedge clk_50M or negedge reset_n ) 
begin
    if (!reset_n)        TargetVolB<=0;
    else if(state == S4) TargetVolB <= FinalVout;//Udc_temp;//FinalVout;
end
always @ (posedge clk_50M or negedge reset_n ) 
begin
    if (!reset_n)        TargetVolC<=0;
    else if(state == S6) TargetVolC <= FinalVout;//Uout_temp;//FinalVout;
end
//--------------------------------------//

//wire [35:0] ILAControl;
//wire [79:0] data_chipscp; 
//assign data_chipscp [31:0] = CosTheta;
////assign data_chipscp [31:16] = LinkUdc;
////assign data_chipscp [47:32] = Udc_limit;
//assign data_chipscp [63:32] = VOFFSET;
//assign data_chipscp [79:64] = Uout_offset;
//
//
//new_icon SVG_icon ( 
//     .CONTROL0            ( ILAControl) 
//); 
//
//new_ila SVG_ila ( 
//     .CONTROL            ( ILAControl), 
//     .CLK                ( clk_cps), 
//     .DATA               ( data_chipscp), 
//     .TRIG0              ( start_reg_reg) ,
//	    .TRIG1              (start_reg_reg ),
//     .TRIG2              ( ), 
//	    .TRIG3              ( )
//);
endmodule
