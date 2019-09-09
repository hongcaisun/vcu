`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: CEPRI
// Engineer: ZHANG DIANQING
// 
// Create Date:    11:16:10 07/25/2018 
// Design Name: 
// Module Name:    LinkState_BUS_Conv 
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
module LinkState_BUS_Conv(
                          input [767:0]LinkStaA_BUS,LinkStaB_BUS,LinkStaC_BUS,
								  output [15:0]LinkStateA1_h,LinkStateA1_l,LinkStateA2_h,LinkStateA2_l,LinkStateA3_h,LinkStateA3_l,LinkStateA4_h,LinkStateA4_l,
													LinkStateA5_h,LinkStateA5_l,LinkStateA6_h,LinkStateA6_l,LinkStateA7_h,LinkStateA7_l,LinkStateA8_h,LinkStateA8_l,
													LinkStateA9_h,LinkStateA9_l,LinkStateA10_h,LinkStateA10_l,LinkStateA11_h,LinkStateA11_l,LinkStateA12_h,LinkStateA12_l,
													LinkStateA13_h,LinkStateA13_l,LinkStateA14_h,LinkStateA14_l,LinkStateA15_h,LinkStateA15_l,LinkStateA16_h,LinkStateA16_l,
													LinkStateA17_h,LinkStateA17_l,LinkStateA18_h,LinkStateA18_l,LinkStateA19_h,LinkStateA19_l,LinkStateA20_h,LinkStateA20_l,
													LinkStateA21_h,LinkStateA21_l,LinkStateA22_h,LinkStateA22_l,LinkStateA23_h,LinkStateA23_l,LinkStateA24_h,LinkStateA24_l,
										
													LinkStateB1_h,LinkStateB1_l,LinkStateB2_h,LinkStateB2_l,LinkStateB3_h,LinkStateB3_l,LinkStateB4_h,LinkStateB4_l,
													LinkStateB5_h,LinkStateB5_l,LinkStateB6_h,LinkStateB6_l,LinkStateB7_h,LinkStateB7_l,LinkStateB8_h,LinkStateB8_l,
													LinkStateB9_h,LinkStateB9_l,LinkStateB10_h,LinkStateB10_l,LinkStateB11_h,LinkStateB11_l,LinkStateB12_h,LinkStateB12_l,
													LinkStateB13_h,LinkStateB13_l,LinkStateB14_h,LinkStateB14_l,LinkStateB15_h,LinkStateB15_l,LinkStateB16_h,LinkStateB16_l,
													LinkStateB17_h,LinkStateB17_l,LinkStateB18_h,LinkStateB18_l,LinkStateB19_h,LinkStateB19_l,LinkStateB20_h,LinkStateB20_l,
													LinkStateB21_h,LinkStateB21_l,LinkStateB22_h,LinkStateB22_l,LinkStateB23_h,LinkStateB23_l,LinkStateB24_h,LinkStateB24_l,
										
													LinkStateC1_h,LinkStateC1_l,LinkStateC2_h,LinkStateC2_l,LinkStateC3_h,LinkStateC3_l,LinkStateC4_h,LinkStateC4_l,
													LinkStateC5_h,LinkStateC5_l,LinkStateC6_h,LinkStateC6_l,LinkStateC7_h,LinkStateC7_l,LinkStateC8_h,LinkStateC8_l,
													LinkStateC9_h,LinkStateC9_l,LinkStateC10_h,LinkStateC10_l,LinkStateC11_h,LinkStateC11_l,LinkStateC12_h,LinkStateC12_l,
													LinkStateC13_h,LinkStateC13_l,LinkStateC14_h,LinkStateC14_l,LinkStateC15_h,LinkStateC15_l,LinkStateC16_h,LinkStateC16_l,
													LinkStateC17_h,LinkStateC17_l,LinkStateC18_h,LinkStateC18_l,LinkStateC19_h,LinkStateC19_l,LinkStateC20_h,LinkStateC20_l,
													LinkStateC21_h,LinkStateC21_l,LinkStateC22_h,LinkStateC22_l,LinkStateC23_h,LinkStateC23_l,LinkStateC24_h,LinkStateC24_l
    );


assign LinkStateA1_h  = LinkStaA_BUS[16*47+15:16*47];
assign LinkStateA1_l  = LinkStaA_BUS[16*46+15:16*46];
assign LinkStateA2_h  = LinkStaA_BUS[16*45+15:16*45];
assign LinkStateA2_l  = LinkStaA_BUS[16*44+15:16*44];
assign LinkStateA3_h  = LinkStaA_BUS[16*43+15:16*43];
assign LinkStateA3_l  = LinkStaA_BUS[16*42+15:16*42];
assign LinkStateA4_h  = LinkStaA_BUS[16*41+15:16*41];
assign LinkStateA4_l  = LinkStaA_BUS[16*40+15:16*40];
assign LinkStateA5_h  = LinkStaA_BUS[16*39+15:16*39];
assign LinkStateA5_l  = LinkStaA_BUS[16*38+15:16*38];
assign LinkStateA6_h  = LinkStaA_BUS[16*37+15:16*37];
assign LinkStateA6_l  = LinkStaA_BUS[16*36+15:16*36];
assign LinkStateA7_h  = LinkStaA_BUS[16*35+15:16*35];
assign LinkStateA7_l  = LinkStaA_BUS[16*34+15:16*34];
assign LinkStateA8_h  = LinkStaA_BUS[16*33+15:16*33];
assign LinkStateA8_l  = LinkStaA_BUS[16*32+15:16*32];
assign LinkStateA9_h  = LinkStaA_BUS[16*31+15:16*31];
assign LinkStateA9_l  = LinkStaA_BUS[16*30+15:16*30];
assign LinkStateA10_h  = LinkStaA_BUS[16*29+15:16*29];
assign LinkStateA10_l  = LinkStaA_BUS[16*28+15:16*28];
assign LinkStateA11_h  = LinkStaA_BUS[16*27+15:16*27];
assign LinkStateA11_l  = LinkStaA_BUS[16*26+15:16*26];
assign LinkStateA12_h  = LinkStaA_BUS[16*25+15:16*25];
assign LinkStateA12_l  = LinkStaA_BUS[16*24+15:16*24];
assign LinkStateA13_h  = LinkStaA_BUS[16*23+15:16*23];
assign LinkStateA13_l  = LinkStaA_BUS[16*22+15:16*22];
assign LinkStateA14_h  = LinkStaA_BUS[16*21+15:16*21];
assign LinkStateA14_l  = LinkStaA_BUS[16*20+15:16*20];
assign LinkStateA15_h  = LinkStaA_BUS[16*19+15:16*19];
assign LinkStateA15_l  = LinkStaA_BUS[16*18+15:16*18];
assign LinkStateA16_h  = LinkStaA_BUS[16*17+15:16*17];
assign LinkStateA16_l  = LinkStaA_BUS[16*16+15:16*16];
assign LinkStateA17_h  = LinkStaA_BUS[16*15+15:16*15];
assign LinkStateA17_l  = LinkStaA_BUS[16*14+15:16*14];
assign LinkStateA18_h  = LinkStaA_BUS[16*13+15:16*13];
assign LinkStateA18_l  = LinkStaA_BUS[16*12+15:16*12];
assign LinkStateA19_h  = LinkStaA_BUS[16*11+15:16*11];
assign LinkStateA19_l  = LinkStaA_BUS[16*10+15:16*10];
assign LinkStateA20_h  = LinkStaA_BUS[16*9+15:16*9];
assign LinkStateA20_l  = LinkStaA_BUS[16*8+15:16*8];
assign LinkStateA21_h  = LinkStaA_BUS[16*7+15:16*7];
assign LinkStateA21_l  = LinkStaA_BUS[16*6+15:16*6];
assign LinkStateA22_h  = LinkStaA_BUS[16*5+15:16*5];
assign LinkStateA22_l  = LinkStaA_BUS[16*4+15:16*4];
assign LinkStateA23_h  = LinkStaA_BUS[16*3+15:16*3];
assign LinkStateA23_l  = LinkStaA_BUS[16*2+15:16*2];
assign LinkStateA24_h  = LinkStaA_BUS[16*1+15:16];
assign LinkStateA24_l  = LinkStaA_BUS[15:0];

assign LinkStateB1_h  = LinkStaB_BUS[16*47+15:16*47];
assign LinkStateB1_l  = LinkStaB_BUS[16*46+15:16*46];
assign LinkStateB2_h  = LinkStaB_BUS[16*45+15:16*45];
assign LinkStateB2_l  = LinkStaB_BUS[16*44+15:16*44];
assign LinkStateB3_h  = LinkStaB_BUS[16*43+15:16*43];
assign LinkStateB3_l  = LinkStaB_BUS[16*42+15:16*42];
assign LinkStateB4_h  = LinkStaB_BUS[16*41+15:16*41];
assign LinkStateB4_l  = LinkStaB_BUS[16*40+15:16*40];
assign LinkStateB5_h  = LinkStaB_BUS[16*39+15:16*39];
assign LinkStateB5_l  = LinkStaB_BUS[16*38+15:16*38];
assign LinkStateB6_h  = LinkStaB_BUS[16*37+15:16*37];
assign LinkStateB6_l  = LinkStaB_BUS[16*36+15:16*36];
assign LinkStateB7_h  = LinkStaB_BUS[16*35+15:16*35];
assign LinkStateB7_l  = LinkStaB_BUS[16*34+15:16*34];
assign LinkStateB8_h  = LinkStaB_BUS[16*33+15:16*33];
assign LinkStateB8_l  = LinkStaB_BUS[16*32+15:16*32];
assign LinkStateB9_h  = LinkStaB_BUS[16*31+15:16*31];
assign LinkStateB9_l  = LinkStaB_BUS[16*30+15:16*30];
assign LinkStateB10_h  = LinkStaB_BUS[16*29+15:16*29];
assign LinkStateB10_l  = LinkStaB_BUS[16*28+15:16*28];
assign LinkStateB11_h  = LinkStaB_BUS[16*27+15:16*27];
assign LinkStateB11_l  = LinkStaB_BUS[16*26+15:16*26];
assign LinkStateB12_h  = LinkStaB_BUS[16*25+15:16*25];
assign LinkStateB12_l  = LinkStaB_BUS[16*24+15:16*24];
assign LinkStateB13_h  = LinkStaB_BUS[16*23+15:16*23];
assign LinkStateB13_l  = LinkStaB_BUS[16*22+15:16*22];
assign LinkStateB14_h  = LinkStaB_BUS[16*21+15:16*21];
assign LinkStateB14_l  = LinkStaB_BUS[16*20+15:16*20];
assign LinkStateB15_h  = LinkStaB_BUS[16*19+15:16*19];
assign LinkStateB15_l  = LinkStaB_BUS[16*18+15:16*18];
assign LinkStateB16_h  = LinkStaB_BUS[16*17+15:16*17];
assign LinkStateB16_l  = LinkStaB_BUS[16*16+15:16*16];
assign LinkStateB17_h  = LinkStaB_BUS[16*15+15:16*15];
assign LinkStateB17_l  = LinkStaB_BUS[16*14+15:16*14];
assign LinkStateB18_h  = LinkStaB_BUS[16*13+15:16*13];
assign LinkStateB18_l  = LinkStaB_BUS[16*12+15:16*12];
assign LinkStateB19_h  = LinkStaB_BUS[16*11+15:16*11];
assign LinkStateB19_l  = LinkStaB_BUS[16*10+15:16*10];
assign LinkStateB20_h  = LinkStaB_BUS[16*9+15:16*9];
assign LinkStateB20_l  = LinkStaB_BUS[16*8+15:16*8];
assign LinkStateB21_h  = LinkStaB_BUS[16*7+15:16*7];
assign LinkStateB21_l  = LinkStaB_BUS[16*6+15:16*6];
assign LinkStateB22_h  = LinkStaB_BUS[16*5+15:16*5];
assign LinkStateB22_l  = LinkStaB_BUS[16*4+15:16*4];
assign LinkStateB23_h  = LinkStaB_BUS[16*3+15:16*3];
assign LinkStateB23_l  = LinkStaB_BUS[16*2+15:16*2];
assign LinkStateB24_h  = LinkStaB_BUS[16*1+15:16];
assign LinkStateB24_l  = LinkStaB_BUS[15:0];

assign LinkStateC1_h  = LinkStaC_BUS[16*47+15:16*47];
assign LinkStateC1_l  = LinkStaC_BUS[16*46+15:16*46];
assign LinkStateC2_h  = LinkStaC_BUS[16*45+15:16*45];
assign LinkStateC2_l  = LinkStaC_BUS[16*44+15:16*44];
assign LinkStateC3_h  = LinkStaC_BUS[16*43+15:16*43];
assign LinkStateC3_l  = LinkStaC_BUS[16*42+15:16*42];
assign LinkStateC4_h  = LinkStaC_BUS[16*41+15:16*41];
assign LinkStateC4_l  = LinkStaC_BUS[16*40+15:16*40];
assign LinkStateC5_h  = LinkStaC_BUS[16*39+15:16*39];
assign LinkStateC5_l  = LinkStaC_BUS[16*38+15:16*38];
assign LinkStateC6_h  = LinkStaC_BUS[16*37+15:16*37];
assign LinkStateC6_l  = LinkStaC_BUS[16*36+15:16*36];
assign LinkStateC7_h  = LinkStaC_BUS[16*35+15:16*35];
assign LinkStateC7_l  = LinkStaC_BUS[16*34+15:16*34];
assign LinkStateC8_h  = LinkStaC_BUS[16*33+15:16*33];
assign LinkStateC8_l  = LinkStaC_BUS[16*32+15:16*32];
assign LinkStateC9_h  = LinkStaC_BUS[16*31+15:16*31];
assign LinkStateC9_l  = LinkStaC_BUS[16*30+15:16*30];
assign LinkStateC10_h  = LinkStaC_BUS[16*29+15:16*29];
assign LinkStateC10_l  = LinkStaC_BUS[16*28+15:16*28];
assign LinkStateC11_h  = LinkStaC_BUS[16*27+15:16*27];
assign LinkStateC11_l  = LinkStaC_BUS[16*26+15:16*26];
assign LinkStateC12_h  = LinkStaC_BUS[16*25+15:16*25];
assign LinkStateC12_l  = LinkStaC_BUS[16*24+15:16*24];
assign LinkStateC13_h  = LinkStaC_BUS[16*23+15:16*23];
assign LinkStateC13_l  = LinkStaC_BUS[16*22+15:16*22];
assign LinkStateC14_h  = LinkStaC_BUS[16*21+15:16*21];
assign LinkStateC14_l  = LinkStaC_BUS[16*20+15:16*20];
assign LinkStateC15_h  = LinkStaC_BUS[16*19+15:16*19];
assign LinkStateC15_l  = LinkStaC_BUS[16*18+15:16*18];
assign LinkStateC16_h  = LinkStaC_BUS[16*17+15:16*17];
assign LinkStateC16_l  = LinkStaC_BUS[16*16+15:16*16];
assign LinkStateC17_h  = LinkStaC_BUS[16*15+15:16*15];
assign LinkStateC17_l  = LinkStaC_BUS[16*14+15:16*14];
assign LinkStateC18_h  = LinkStaC_BUS[16*13+15:16*13];
assign LinkStateC18_l  = LinkStaC_BUS[16*12+15:16*12];
assign LinkStateC19_h  = LinkStaC_BUS[16*11+15:16*11];
assign LinkStateC19_l  = LinkStaC_BUS[16*10+15:16*10];
assign LinkStateC20_h  = LinkStaC_BUS[16*9+15:16*9];
assign LinkStateC20_l  = LinkStaC_BUS[16*8+15:16*8];
assign LinkStateC21_h  = LinkStaC_BUS[16*7+15:16*7];
assign LinkStateC21_l  = LinkStaC_BUS[16*6+15:16*6];
assign LinkStateC22_h  = LinkStaC_BUS[16*5+15:16*5];
assign LinkStateC22_l  = LinkStaC_BUS[16*4+15:16*4];
assign LinkStateC23_h  = LinkStaC_BUS[16*3+15:16*3];
assign LinkStateC23_l  = LinkStaC_BUS[16*2+15:16*2];
assign LinkStateC24_h  = LinkStaC_BUS[16*1+15:16];
assign LinkStateC24_l  = LinkStaC_BUS[15:0];
endmodule
