`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:43:25 03/18/2019 
// Design Name: 
// Module Name:    lock_handle 
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
module lock_handle(
                         input i_clk_20M,
								 input i_clk_lock,//封锁用时钟频率
								 input i_clk_nonlock,//非封锁用时钟频率
                         input i_reset_n,
								 input [15:0]i_ControlWord,
								 input [15:0]i_PhaseSta,
								 input i_phaselock1,//来自其他两相的互锁信号
								 input i_phaselock2,
								 input i_fastlock,//从测量机箱过来判主从后的快速封锁信号
								 output o_phaselock1_brk,//相间封锁光纤1断线
								 output o_phaselock2_brk,//相间封锁光纤2断线
								 output o_phaselock1_pulerr,//相间封锁光纤1频率出错
								 output o_phaselock2_pulerr,//相间封锁光纤2频率出错
								 output o_lock,//单元功率模块封锁信号
								 output o_phaselock1_opto,//给其他两相的互锁信号
								 output o_phaselock2_opto,
								 output o_phaselock1,//其他两相过来的封锁信号
								 output o_phaselock2
);

//自身封锁
//封锁条件：相间封锁、相状态字相故障位、相状态字冗余封锁请求位、相状态字主从状态位（双从）、相状态字DSP故障位、快速封锁；
assign o_lock = o_phaselock1 | o_phaselock2 | i_PhaseSta[0] | i_PhaseSta[2] | (i_PhaseSta[14:13] == 2'b00)  |  i_PhaseSta[15] | i_fastlock; //给自己模块的封锁信号
//相间封锁
//封锁条件：相状态字相故障位、相状态字冗余封锁请求位、相状态字主从状态位（双从）、相状态字DSP故障位、控保下发命令字封锁位；
assign o_phaselock1_opto = (i_PhaseSta[0] | i_PhaseSta[2] | (i_PhaseSta[14:13] == 2'b00)  |  i_PhaseSta[15] | (~i_ControlWord[1])) ? i_clk_lock : i_clk_nonlock;//给其他两相的封锁信号
assign o_phaselock2_opto = (i_PhaseSta[0] | i_PhaseSta[2] | (i_PhaseSta[14:13] == 2'b00)  |  i_PhaseSta[15] | (~i_ControlWord[1])) ? i_clk_lock : i_clk_nonlock;

rxd_freq phaselock1(
				.clk_20M(i_clk_20M),
				.clr(i_reset_n),
				.rxd(i_phaselock1),
				.lock_stat(o_phaselock1),
				.pulse_err(o_phaselock1_pulerr),
				.phaselock_brk(o_phaselock1_brk)
);

rxd_freq phaselock2(
				.clk_20M(i_clk_20M),
				.clr(i_reset_n),
				.rxd(i_phaselock2),
				.lock_stat(o_phaselock2),
				.pulse_err(o_phaselock2_pulerr),
				.phaselock_brk(o_phaselock2_brk)
);

//--------------------------------------------------------------------
//wire [35:0] ILAControl;
//wire [79:0] data_chipscp; 
//assign data_chipscp [15:0] = {12'b0,o_phaselock2,o_phaselock1,o_phaselock2_brk,o_phaselock1_brk};
////assign data_chipscp [31:16] = ram_sta_din;
////assign data_chipscp [47:32] = ram1_dat_i;
////assign data_chipscp [63:48] = {3'b0,ram1_add_o,ram1_addr};
////assign data_chipscp [79:64] = ram1_data;
//new_icon SVG_icon ( 
//     .CONTROL0            ( ILAControl) 
//); 
//
//new_ila SVG_ila ( 
//     .CONTROL            ( ILAControl), 
//     .CLK                ( i_clk_20M), 
//     .DATA               ( data_chipscp), 
//     .TRIG0              (o_phaselock1_brk ) ,
//	    .TRIG1              (o_phaselock2_brk ),
//     .TRIG2              (o_phaselock1 ), 
//	    .TRIG3              (o_phaselock2 )
//);

endmodule
