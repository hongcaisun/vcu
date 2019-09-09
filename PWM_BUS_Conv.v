`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: CEPRI
// Engineer: ZHANG DIANQING
// 
// Create Date:    11:47:15 07/25/2018 
// Design Name: 
// Module Name:    PWM_BUS_Conv 
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
module PWM_BUS_Conv(
                    input [47:0] PWM_A_BUS,PWM_B_BUS,PWM_C_BUS,
						  output       MA1_A,MA1_B,MA2_A,MA2_B,MA3_A,MA3_B,MA4_A,MA4_B,MA5_A,MA5_B,MA6_A,
											MA6_B,MA7_A,MA7_B,MA8_A,MA8_B,MA9_A,MA9_B,MA10_A,MA10_B,MA11_A,
											MA11_B,MA12_A,MA12_B,MA13_A,MA13_B,MA14_A,MA14_B,MA15_A,MA15_B,
											MA16_A,MA16_B,MA17_A,MA17_B,MA18_A,MA18_B,MA19_A,MA19_B,MA20_A,
											MA20_B,MA21_A,MA21_B,MA22_A,MA22_B,MA23_A,MA23_B,MA24_A,MA24_B,
											MB1_A,MB1_B,MB2_A,MB2_B,MB3_A,MB3_B,MB4_A,MB4_B,MB5_A,MB5_B,MB6_A,
											MB6_B,MB7_A,MB7_B,MB8_A,MB8_B,MB9_A,MB9_B,MB10_A,MB10_B,MB11_A,
											MB11_B,MB12_A,MB12_B,MB13_A,MB13_B,MB14_A,MB14_B,MB15_A,MB15_B,
											MB16_A,MB16_B,MB17_A,MB17_B,MB18_A,MB18_B,MB19_A,MB19_B,MB20_A,
											MB20_B,MB21_A,MB21_B,MB22_A,MB22_B,MB23_A,MB23_B,MB24_A,MB24_B,								
											MC1_A,MC1_B,MC2_A,MC2_B,MC3_A,MC3_B,MC4_A,MC4_B,MC5_A,MC5_B,MC6_A,
											MC6_B,MC7_A,MC7_B,MC8_A,MC8_B,MC9_A,MC9_B,MC10_A,MC10_B,MC11_A,
											MC11_B,MC12_A,MC12_B,MC13_A,MC13_B,MC14_A,MC14_B,MC15_A,MC15_B,
											MC16_A,MC16_B,MC17_A,MC17_B,MC18_A,MC18_B,MC19_A,MC19_B,MC20_A,
											MC20_B,MC21_A,MC21_B,MC22_A,MC22_B,MC23_A,MC23_B,MC24_A,MC24_B
    );

assign MA1_A  = PWM_A_BUS[47];
assign MA1_B  = PWM_A_BUS[46];
assign MA2_A  = PWM_A_BUS[45];
assign MA2_B  = PWM_A_BUS[44];
assign MA3_A  = PWM_A_BUS[43];
assign MA3_B  = PWM_A_BUS[42];
assign MA4_A  = PWM_A_BUS[41];
assign MA4_B  = PWM_A_BUS[40];
assign MA5_A  = PWM_A_BUS[39];
assign MA5_B  = PWM_A_BUS[38];
assign MA6_A  = PWM_A_BUS[37];
assign MA6_B  = PWM_A_BUS[36];
assign MA7_A  = PWM_A_BUS[35];
assign MA7_B  = PWM_A_BUS[34];
assign MA8_A  = PWM_A_BUS[33];
assign MA8_B  = PWM_A_BUS[32];
assign MA9_A  = PWM_A_BUS[31];
assign MA9_B  = PWM_A_BUS[30];
assign MA10_A  = PWM_A_BUS[29];
assign MA10_B  = PWM_A_BUS[28];
assign MA11_A  = PWM_A_BUS[27];
assign MA11_B  = PWM_A_BUS[26];
assign MA12_A  = PWM_A_BUS[25];
assign MA12_B  = PWM_A_BUS[24];
assign MA13_A  = PWM_A_BUS[23];
assign MA13_B  = PWM_A_BUS[22];
assign MA14_A  = PWM_A_BUS[21];
assign MA14_B  = PWM_A_BUS[20];
assign MA15_A  = PWM_A_BUS[19];
assign MA15_B  = PWM_A_BUS[18];
assign MA16_A  = PWM_A_BUS[17];
assign MA16_B  = PWM_A_BUS[16];
assign MA17_A  = PWM_A_BUS[15];
assign MA17_B  = PWM_A_BUS[14];
assign MA18_A  = PWM_A_BUS[13];
assign MA18_B  = PWM_A_BUS[12];
assign MA19_A  = PWM_A_BUS[11];
assign MA19_B  = PWM_A_BUS[10];
assign MA20_A  = PWM_A_BUS[9];
assign MA20_B  = PWM_A_BUS[8];
assign MA21_A  = PWM_A_BUS[7];
assign MA21_B  = PWM_A_BUS[6];
assign MA22_A  = PWM_A_BUS[5];
assign MA22_B  = PWM_A_BUS[4];
assign MA23_A  = PWM_A_BUS[3];
assign MA23_B  = PWM_A_BUS[2];
assign MA24_A  = PWM_A_BUS[1];
assign MA24_B  = PWM_A_BUS[0];

assign MB1_A  = PWM_B_BUS[47];
assign MB1_B  = PWM_B_BUS[46];
assign MB2_A  = PWM_B_BUS[45];
assign MB2_B  = PWM_B_BUS[44];
assign MB3_A  = PWM_B_BUS[43];
assign MB3_B  = PWM_B_BUS[42];
assign MB4_A  = PWM_B_BUS[41];
assign MB4_B  = PWM_B_BUS[40];
assign MB5_A  = PWM_B_BUS[39];
assign MB5_B  = PWM_B_BUS[38];
assign MB6_A  = PWM_B_BUS[37];
assign MB6_B  = PWM_B_BUS[36];
assign MB7_A  = PWM_B_BUS[35];
assign MB7_B  = PWM_B_BUS[34];
assign MB8_A  = PWM_B_BUS[33];
assign MB8_B  = PWM_B_BUS[32];
assign MB9_A  = PWM_B_BUS[31];
assign MB9_B  = PWM_B_BUS[30];
assign MB10_A  = PWM_B_BUS[29];
assign MB10_B  = PWM_B_BUS[28];
assign MB11_A  = PWM_B_BUS[27];
assign MB11_B  = PWM_B_BUS[26];
assign MB12_A  = PWM_B_BUS[25];
assign MB12_B  = PWM_B_BUS[24];
assign MB13_A  = PWM_B_BUS[23];
assign MB13_B  = PWM_B_BUS[22];
assign MB14_A  = PWM_B_BUS[21];
assign MB14_B  = PWM_B_BUS[20];
assign MB15_A  = PWM_B_BUS[19];
assign MB15_B  = PWM_B_BUS[18];
assign MB16_A  = PWM_B_BUS[17];
assign MB16_B  = PWM_B_BUS[16];
assign MB17_A  = PWM_B_BUS[15];
assign MB17_B  = PWM_B_BUS[14];
assign MB18_A  = PWM_B_BUS[13];
assign MB18_B  = PWM_B_BUS[12];
assign MB19_A  = PWM_B_BUS[11];
assign MB19_B  = PWM_B_BUS[10];
assign MB20_A  = PWM_B_BUS[9];
assign MB20_B  = PWM_B_BUS[8];
assign MB21_A  = PWM_B_BUS[7];
assign MB21_B  = PWM_B_BUS[6];
assign MB22_A  = PWM_B_BUS[5];
assign MB22_B  = PWM_B_BUS[4];
assign MB23_A  = PWM_B_BUS[3];
assign MB23_B  = PWM_B_BUS[2];
assign MB24_A  = PWM_B_BUS[1];
assign MB24_B  = PWM_B_BUS[0];

assign MC1_A  = PWM_C_BUS[47];
assign MC1_B  = PWM_C_BUS[46];
assign MC2_A  = PWM_C_BUS[45];
assign MC2_B  = PWM_C_BUS[44];
assign MC3_A  = PWM_C_BUS[43];
assign MC3_B  = PWM_C_BUS[42];
assign MC4_A  = PWM_C_BUS[41];
assign MC4_B  = PWM_C_BUS[40];
assign MC5_A  = PWM_C_BUS[39];
assign MC5_B  = PWM_C_BUS[38];
assign MC6_A  = PWM_C_BUS[37];
assign MC6_B  = PWM_C_BUS[36];
assign MC7_A  = PWM_C_BUS[35];
assign MC7_B  = PWM_C_BUS[34];
assign MC8_A  = PWM_C_BUS[33];
assign MC8_B  = PWM_C_BUS[32];
assign MC9_A  = PWM_C_BUS[31];
assign MC9_B  = PWM_C_BUS[30];
assign MC10_A  = PWM_C_BUS[29];
assign MC10_B  = PWM_C_BUS[28];
assign MC11_A  = PWM_C_BUS[27];
assign MC11_B  = PWM_C_BUS[26];
assign MC12_A  = PWM_C_BUS[25];
assign MC12_B  = PWM_C_BUS[24];
assign MC13_A  = PWM_C_BUS[23];
assign MC13_B  = PWM_C_BUS[22];
assign MC14_A  = PWM_C_BUS[21];
assign MC14_B  = PWM_C_BUS[20];
assign MC15_A  = PWM_C_BUS[19];
assign MC15_B  = PWM_C_BUS[18];
assign MC16_A  = PWM_C_BUS[17];
assign MC16_B  = PWM_C_BUS[16];
assign MC17_A  = PWM_C_BUS[15];
assign MC17_B  = PWM_C_BUS[14];
assign MC18_A  = PWM_C_BUS[13];
assign MC18_B  = PWM_C_BUS[12];
assign MC19_A  = PWM_C_BUS[11];
assign MC19_B  = PWM_C_BUS[10];
assign MC20_A  = PWM_C_BUS[9];
assign MC20_B  = PWM_C_BUS[8];
assign MC21_A  = PWM_C_BUS[7];
assign MC21_B  = PWM_C_BUS[6];
assign MC22_A  = PWM_C_BUS[5];
assign MC22_B  = PWM_C_BUS[4];
assign MC23_A  = PWM_C_BUS[3];
assign MC23_B  = PWM_C_BUS[2];
assign MC24_A  = PWM_C_BUS[1];
assign MC24_B  = PWM_C_BUS[0];
endmodule
