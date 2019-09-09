`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:  CEPRI
// Engineer: ZHANG DIANQING
// 
// Create Date:    10:53:28 07/25/2018 
// Design Name: 
// Module Name:    UdcBUS_Conv_Phase 
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
module UdcBUS_Conv_Phase(input [383:0]LinkUdc_BUS,
							    output [15:0]LinkUdc1,LinkUdc2,LinkUdc3,LinkUdc4,LinkUdc5,LinkUdc6,LinkUdc7,LinkUdc8,LinkUdc9,LinkUdc10,
											LinkUdc11,LinkUdc12,LinkUdc13,LinkUdc14,LinkUdc15,LinkUdc16,LinkUdc17,LinkUdc18,LinkUdc19,LinkUdc20,
											LinkUdc21,LinkUdc22,LinkUdc23,LinkUdc24);
											
assign 	 LinkUdc1 = 	LinkUdc_BUS[16*23+15:16*23];					 
assign 	 LinkUdc2 = 	LinkUdc_BUS[16*22+15:16*22];
assign 	 LinkUdc3 = 	LinkUdc_BUS[16*21+15:16*21];
assign 	 LinkUdc4 = 	LinkUdc_BUS[16*20+15:16*20];
assign 	 LinkUdc5 = 	LinkUdc_BUS[16*19+15:16*19];
assign 	 LinkUdc6 = 	LinkUdc_BUS[16*18+15:16*18];
assign 	 LinkUdc7 = 	LinkUdc_BUS[16*17+15:16*17];
assign 	 LinkUdc8 = 	LinkUdc_BUS[16*16+15:16*16];
assign 	 LinkUdc9 = 	LinkUdc_BUS[16*15+15:16*15];
assign 	 LinkUdc10 = 	LinkUdc_BUS[16*14+15:16*14];
assign 	 LinkUdc11 = 	LinkUdc_BUS[16*13+15:16*13];
assign 	 LinkUdc12 = 	LinkUdc_BUS[16*12+15:16*12];
assign 	 LinkUdc13 = 	LinkUdc_BUS[16*11+15:16*11];
assign 	 LinkUdc14 = 	LinkUdc_BUS[16*10+15:16*10];
assign 	 LinkUdc15 = 	LinkUdc_BUS[16*9+15:16*9];
assign 	 LinkUdc16 = 	LinkUdc_BUS[16*8+15:16*8];
assign 	 LinkUdc17 = 	LinkUdc_BUS[16*7+15:16*7];
assign 	 LinkUdc18 = 	LinkUdc_BUS[16*6+15:16*6];
assign 	 LinkUdc19 = 	LinkUdc_BUS[16*5+15:16*5];
assign 	 LinkUdc20 = 	LinkUdc_BUS[16*4+15:16*4];
assign 	 LinkUdc21 = 	LinkUdc_BUS[16*3+15:16*3];
assign 	 LinkUdc22 = 	LinkUdc_BUS[16*2+15:16*2];
assign 	 LinkUdc23 = 	LinkUdc_BUS[16*1+15:16*1];
assign 	 LinkUdc24 = 	LinkUdc_BUS[15:0];    


endmodule
