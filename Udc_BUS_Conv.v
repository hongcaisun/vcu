`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: CEPRI
// Engineer: ZHANG DIANQING
// 
// Create Date:    10:23:07 07/25/2018 
// Design Name: 
// Module Name:    Udc_BUS_Conv 
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
module Udc_BUS_Conv(
                   input [383:0]LinkUdcA_BUS,LinkUdcB_BUS,LinkUdcC_BUS,
						 output [15:0]LinkUdcA1,LinkUdcA2,LinkUdcA3,LinkUdcA4,LinkUdcA5,LinkUdcA6,LinkUdcA7,LinkUdcA8,LinkUdcA9,LinkUdcA10,
									LinkUdcA11,LinkUdcA12,LinkUdcA13,LinkUdcA14,LinkUdcA15,LinkUdcA16,LinkUdcA17,LinkUdcA18,LinkUdcA19,LinkUdcA20,
									LinkUdcA21,LinkUdcA22,LinkUdcA23,LinkUdcA24,
									LinkUdcB1,LinkUdcB2,LinkUdcB3,LinkUdcB4,LinkUdcB5,LinkUdcB6,LinkUdcB7,LinkUdcB8,LinkUdcB9,LinkUdcB10,
									LinkUdcB11,LinkUdcB12,LinkUdcB13,LinkUdcB14,LinkUdcB15,LinkUdcB16,LinkUdcB17,LinkUdcB18,LinkUdcB19,LinkUdcB20,
									LinkUdcB21,LinkUdcB22,LinkUdcB23,LinkUdcB24,
									LinkUdcC1,LinkUdcC2,LinkUdcC3,LinkUdcC4,LinkUdcC5,LinkUdcC6,LinkUdcC7,LinkUdcC8,LinkUdcC9,LinkUdcC10,
									LinkUdcC11,LinkUdcC12,LinkUdcC13,LinkUdcC14,LinkUdcC15,LinkUdcC16,LinkUdcC17,LinkUdcC18,LinkUdcC19,LinkUdcC20,
									LinkUdcC21,LinkUdcC22,LinkUdcC23,LinkUdcC24);
parameter LINKNUM = 24;
parameter BUSNUM  = 383;
assign 	 LinkUdcA1 = 	LinkUdcA_BUS[16*23+15:16*23];					 
assign 	 LinkUdcA2 = 	LinkUdcA_BUS[16*22+15:16*22];
assign 	 LinkUdcA3 = 	LinkUdcA_BUS[16*21+15:16*21];
assign 	 LinkUdcA4 = 	LinkUdcA_BUS[16*20+15:16*20];
assign 	 LinkUdcA5 = 	LinkUdcA_BUS[16*19+15:16*19];
assign 	 LinkUdcA6 = 	LinkUdcA_BUS[16*18+15:16*18];
assign 	 LinkUdcA7 = 	LinkUdcA_BUS[16*17+15:16*17];
assign 	 LinkUdcA8 = 	LinkUdcA_BUS[16*16+15:16*16];
assign 	 LinkUdcA9 = 	LinkUdcA_BUS[16*15+15:16*15];
assign 	 LinkUdcA10 = 	LinkUdcA_BUS[16*14+15:16*14];
assign 	 LinkUdcA11 = 	LinkUdcA_BUS[16*13+15:16*13];
assign 	 LinkUdcA12 = 	LinkUdcA_BUS[16*12+15:16*12];
assign 	 LinkUdcA13 = 	LinkUdcA_BUS[16*11+15:16*11];
assign 	 LinkUdcA14 = 	LinkUdcA_BUS[16*10+15:16*10];
assign 	 LinkUdcA15 = 	LinkUdcA_BUS[16*9+15:16*9];
assign 	 LinkUdcA16 = 	LinkUdcA_BUS[16*8+15:16*8];
assign 	 LinkUdcA17 = 	LinkUdcA_BUS[16*7+15:16*7];
assign 	 LinkUdcA18 = 	LinkUdcA_BUS[16*6+15:16*6];
assign 	 LinkUdcA19 = 	LinkUdcA_BUS[16*5+15:16*5];
assign 	 LinkUdcA20 = 	LinkUdcA_BUS[16*4+15:16*4];
assign 	 LinkUdcA21 = 	LinkUdcA_BUS[16*3+15:16*3];
assign 	 LinkUdcA22 = 	LinkUdcA_BUS[16*2+15:16*2];
assign 	 LinkUdcA23 = 	LinkUdcA_BUS[16*1+15:16*1];
assign 	 LinkUdcA24 = 	LinkUdcA_BUS[15:0];

assign 	 LinkUdcB1 = 	LinkUdcB_BUS[16*23+15:16*23];					 
assign 	 LinkUdcB2 = 	LinkUdcB_BUS[16*22+15:16*22];
assign 	 LinkUdcB3 = 	LinkUdcB_BUS[16*21+15:16*21];
assign 	 LinkUdcB4 = 	LinkUdcB_BUS[16*20+15:16*20];
assign 	 LinkUdcB5 = 	LinkUdcB_BUS[16*19+15:16*19];
assign 	 LinkUdcB6 = 	LinkUdcB_BUS[16*18+15:16*18];
assign 	 LinkUdcB7 = 	LinkUdcB_BUS[16*17+15:16*17];
assign 	 LinkUdcB8 = 	LinkUdcB_BUS[16*16+15:16*16];
assign 	 LinkUdcB9 = 	LinkUdcB_BUS[16*15+15:16*15];
assign 	 LinkUdcB10 = 	LinkUdcB_BUS[16*14+15:16*14];
assign 	 LinkUdcB11 = 	LinkUdcB_BUS[16*13+15:16*13];
assign 	 LinkUdcB12 = 	LinkUdcB_BUS[16*12+15:16*12];
assign 	 LinkUdcB13 = 	LinkUdcB_BUS[16*11+15:16*11];
assign 	 LinkUdcB14 = 	LinkUdcB_BUS[16*10+15:16*10];
assign 	 LinkUdcB15 = 	LinkUdcB_BUS[16*9+15:16*9];
assign 	 LinkUdcB16 = 	LinkUdcB_BUS[16*8+15:16*8];
assign 	 LinkUdcB17 = 	LinkUdcB_BUS[16*7+15:16*7];
assign 	 LinkUdcB18 = 	LinkUdcB_BUS[16*6+15:16*6];
assign 	 LinkUdcB19 = 	LinkUdcB_BUS[16*5+15:16*5];
assign 	 LinkUdcB20 = 	LinkUdcB_BUS[16*4+15:16*4];
assign 	 LinkUdcB21 = 	LinkUdcB_BUS[16*3+15:16*3];
assign 	 LinkUdcB22 = 	LinkUdcB_BUS[16*2+15:16*2];
assign 	 LinkUdcB23 = 	LinkUdcB_BUS[16*1+15:16*1];
assign 	 LinkUdcB24 = 	LinkUdcB_BUS[15:0];

assign 	 LinkUdcC1 = 	LinkUdcC_BUS[16*23+15:16*23];					 
assign 	 LinkUdcC2 = 	LinkUdcC_BUS[16*22+15:16*22];
assign 	 LinkUdcC3 = 	LinkUdcC_BUS[16*21+15:16*21];
assign 	 LinkUdcC4 = 	LinkUdcC_BUS[16*20+15:16*20];
assign 	 LinkUdcC5 = 	LinkUdcC_BUS[16*19+15:16*19];
assign 	 LinkUdcC6 = 	LinkUdcC_BUS[16*18+15:16*18];
assign 	 LinkUdcC7 = 	LinkUdcC_BUS[16*17+15:16*17];
assign 	 LinkUdcC8 = 	LinkUdcC_BUS[16*16+15:16*16];
assign 	 LinkUdcC9 = 	LinkUdcC_BUS[16*15+15:16*15];
assign 	 LinkUdcC10 = 	LinkUdcC_BUS[16*14+15:16*14];
assign 	 LinkUdcC11 = 	LinkUdcC_BUS[16*13+15:16*13];
assign 	 LinkUdcC12 = 	LinkUdcC_BUS[16*12+15:16*12];
assign 	 LinkUdcC13 = 	LinkUdcC_BUS[16*11+15:16*11];
assign 	 LinkUdcC14 = 	LinkUdcC_BUS[16*10+15:16*10];
assign 	 LinkUdcC15 = 	LinkUdcC_BUS[16*9+15:16*9];
assign 	 LinkUdcC16 = 	LinkUdcC_BUS[16*8+15:16*8];
assign 	 LinkUdcC17 = 	LinkUdcC_BUS[16*7+15:16*7];
assign 	 LinkUdcC18 = 	LinkUdcC_BUS[16*6+15:16*6];
assign 	 LinkUdcC19 = 	LinkUdcC_BUS[16*5+15:16*5];
assign 	 LinkUdcC20 = 	LinkUdcC_BUS[16*4+15:16*4];
assign 	 LinkUdcC21 = 	LinkUdcC_BUS[16*3+15:16*3];
assign 	 LinkUdcC22 = 	LinkUdcC_BUS[16*2+15:16*2];
assign 	 LinkUdcC23 = 	LinkUdcC_BUS[16*1+15:16*1];
assign 	 LinkUdcC24 = 	LinkUdcC_BUS[15:0];
endmodule
