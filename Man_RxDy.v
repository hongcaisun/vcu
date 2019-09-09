
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:25:18 03/13/2013 
// Design Name: 
// Module Name:    Man_Rx 
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
//霍夫曼编码接收程序
//clk: 模块主时钟
//reset_n: 模块异步复位
//data_q: 接收数据输出
//rxd: 串行数据输入
//rxd_comp: 本次数据接收完成标志输出


module Man_RxDy(
					input clk,
					input reset_n,
					input rxd,
					output [rx_num-1:0]data_q,
					output reg start,
					output [15:0]crc,
					output reg non_frame
);

	parameter crc_num             = 48; 
	parameter clk_div 				= 24;//100M 24  120M 29	
	parameter rx_num					= 66; //
	
	parameter idle_st				   = 2'b00;	
	parameter Data_rxd_st			= 2'b01;
	parameter Stop_rxd_st			= 2'b10;

	reg [1:0] rxd_state;
	reg [rx_num-1:0] Serial_shift_reg;
	reg [2:0] Samp_reg;
	reg rxd_comp;
	reg data_reg,rxd_temp,rxd_man,rxd_shift_En;
	reg [1:0] idle_count;
	reg [5:0] rxd_clk_div;
	reg rxd_clk,rxd_flag;
	
	assign data_q = Serial_shift_reg;
	
	wire rxd_start = rxd_man;//接收的数据有下降沿，则认为数据接收开始
	wire rxd_stop  = (idle_count > 2'h2);//接收的数据置高三个点，则认为数据接收完毕
	wire rxd_low   = (Samp_reg[2:0] == 3'b000);
	wire rxd_high  = (Samp_reg[2:0] == 3'b111);
	
	wire rxd_clk_phase = (rxd_state == idle_st) || (rxd_flag && (!rxd_clk || (rxd_clk_div >= ((clk_div - 1) >> 1))));
//////crc
	reg [ 6:0] crc_cnt;
	reg [15:0] CRC_out;
	reg temp;
	reg crc_clear;
	reg [ 3:0] delay_cnt;
	assign crc = CRC_out;
////

//rxd sample--------接收数据拍三个时钟
always @ (negedge reset_n or posedge clk)
begin
	if(!reset_n) 
		Samp_reg <= 3'b111;
	else 
		Samp_reg <= {Samp_reg[1:0],rxd};
end

//rxd_temp---------接收数据的三个点为低就是低，三个点为高就是高
always @ (negedge reset_n or posedge clk)
begin
	if(!reset_n) 
		rxd_temp <= 1'b1;
	else
		begin
			if(rxd_low) 
				rxd_temp <= 1'b0;
			else if(rxd_high) 
				rxd_temp <= 1'b1;
			else
				rxd_temp <= rxd_temp;
		end
end

//data_reg------rxd_temp拍一个时钟
always @ (negedge reset_n or posedge clk)
begin
	if(!reset_n) 
		data_reg <= 1'b1;
	else 
		data_reg <= rxd_temp;
end

//rxd_clk    
always @ (negedge reset_n or posedge clk)
begin
	if(!reset_n) begin
		rxd_clk <= 1'b0;
		rxd_clk_div <= 6'h0;
	end
	else begin
		if(rxd_clk_phase && (data_reg ^ rxd_temp)) begin//上升沿或下降沿 
			rxd_clk_div <= 6'h0;
			rxd_clk <= 1'b0;
		end
		else begin
			if(rxd_clk_div == clk_div) begin
				rxd_clk_div <= 6'h0;
				rxd_clk <= ~rxd_clk;
			end
			else rxd_clk_div <= rxd_clk_div + 6'h1;
		end
	end
end

//rxd_flag
always @ (negedge reset_n or posedge clk)
begin
	if(!reset_n)
		rxd_flag <= 1'b0;
	else
		begin
			if(rxd_clk_phase && (data_reg ^ rxd_temp))  
				rxd_flag <= 1'b0; 
			else if(!rxd_flag && (rxd_clk_div == clk_div))
				rxd_flag <= ~rxd_flag;
			else rxd_flag <= rxd_flag;
		end
end

//rxd_shift_En
always @ (negedge reset_n or posedge clk)
begin
	if(!reset_n)
		rxd_shift_En <= 1'b0;
	else 
		begin
			if(rxd_clk_phase && (data_reg ^ rxd_temp))  
				rxd_shift_En <= 1'b1; 
			else
				rxd_shift_En <= 1'b0;
		end
end

//rxd_man
always @ (negedge reset_n or posedge clk)
begin
	if(!reset_n) 
		rxd_man <= 1'b0;
	else 
		begin
			if({data_reg,rxd_temp} == 2'b10)//下降沿
				rxd_man <= 1'b1;
				else if({data_reg,rxd_temp} == 2'b01)//上升沿 
				rxd_man <= 1'b0;
			else rxd_man <= rxd_man;
		end
end
	
//Serial rxd state
always @ (negedge reset_n or posedge clk)  //
begin
	if(reset_n == 1'b0)
		rxd_state <= idle_st;
	else 
		begin
			case(rxd_state)
				idle_st:
						begin
							if(rxd_start) 
								rxd_state <= Data_rxd_st;
							else
								rxd_state <= idle_st;
						end
				Data_rxd_st: 
						begin
							if(rxd_stop) 
								rxd_state <= Stop_rxd_st;
							else 
								rxd_state <= Data_rxd_st;
						end
				Stop_rxd_st: 
						begin
							rxd_state <= idle_st;
						end
				default: rxd_state <= idle_st;
			endcase
		end
end

//idle_count------接收的数据置高三个点，则认为数据接收完毕
always @ (negedge rxd_temp or negedge rxd_clk)
begin
	if(!rxd_temp) 
		idle_count <= 2'h0;
	else 
		begin
			idle_count <= idle_count + 2'h1;
		end
end

//rxd_comp--------处于接收状态且接收停止有效，则置标志位置高
always @ (negedge reset_n or posedge clk)
begin
	if(reset_n == 1'b0) 
		rxd_comp <= 1'b0;
	else 
		begin
			if((rxd_state == Data_rxd_st) && rxd_stop) 
				rxd_comp <= 1'b1;
			else 
				rxd_comp <= 1'b0;
		end
end

//Serial_shift_reg lift shift--接收的数据从左开始压入变量中
always @ (posedge clk)   
begin
	if(!reset_n) Serial_shift_reg <=0;
	else if((rxd_state == Data_rxd_st) && rxd_shift_En) Serial_shift_reg <={(~rxd_man),Serial_shift_reg[rx_num-1:1]}; 
	else Serial_shift_reg <= Serial_shift_reg;
end

//CRC
always @ (posedge clk)
begin
	if((!reset_n) || (rxd_comp)) crc_cnt <= 7'd0;
	else if((rxd_state == Data_rxd_st) && rxd_shift_En ) crc_cnt <= crc_cnt + 7'd1;
	else crc_cnt <= crc_cnt;
end

always @ (posedge clk)
begin
	if(!reset_n) CRC_out <= 16'h0;
	else if(crc_clear) CRC_out <= 16'h0;
	else if((crc_cnt>7'd0) && (crc_cnt<=crc_num) && (rxd_shift_En)) begin
		temp = Serial_shift_reg[rx_num-1] ^ CRC_out[15];
		CRC_out[15] <= CRC_out[14];
		CRC_out[14] <= CRC_out[13];
		CRC_out[13] <= CRC_out[12];
		CRC_out[12] <= temp ^ CRC_out[11];
		CRC_out[11] <= CRC_out[10];
		CRC_out[10] <= CRC_out[9];
		CRC_out[9] <= CRC_out[8];
		CRC_out[8] <= CRC_out[7];
		CRC_out[7] <= CRC_out[6];
		CRC_out[6] <= CRC_out[5];
		CRC_out[5] <= temp ^ CRC_out[4];
		CRC_out[4] <= CRC_out[3];
		CRC_out[3] <= CRC_out[2];
		CRC_out[2] <= CRC_out[1];
		CRC_out[1] <= CRC_out[0];
		CRC_out[0] <= temp;
	  end
	else temp = 1'b0;
end   

always @ (posedge clk)
begin
	if(!reset_n) begin
		crc_clear <= 1'b0;
		delay_cnt <= 4'h0;
		start     <= 1'b0;
		non_frame <= 1'b0;
	  end
	else if((rxd_comp) && (crc_cnt!=(rx_num-1))) begin//不完整数据帧
	   non_frame <= 1'b1;
	end
	else if(((rxd_comp)&& (crc_cnt==(rx_num-1))) || (delay_cnt!=4'h0)) begin
	   non_frame <= 1'b0;
		if(delay_cnt==4'h9) begin 
			delay_cnt <= 4'h0;
			crc_clear <= 1'b1;
			start     <= 1'b0;
		  end
		else begin
			delay_cnt <= delay_cnt + 4'h1;
			crc_clear <= 1'b0;
			start     <= 1'b1;
		  end
	  end
	else begin
		crc_clear <= 1'b0;
		delay_cnt <= 4'h0;
		start     <= 1'b0;
	  end
end

endmodule
