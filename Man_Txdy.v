`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:51:16 04/01/2013 
// Design Name: 
// Module Name:    Man_Txdy 
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
module Man_Txdy(
					input clk_20M,
					input reset_n,
					input txd_en,
					input [txd_num-1:0]data_in,
					output txd
);  

	parameter	txd_num = 12;
	
	reg	[15:0] cnt;
	reg	[ 3:0] cnt1;
	reg   [ 3:0] cnt2;
	reg			 en;
	reg	[ 1:0] data_sam;
	reg	[txd_num-1:0] data_in_reg ;
	reg   [ 1:0] state;
	assign txd = data_sam[0];
//--------txd_en发送使能有效，状态机10，计数器大于发送数据个数12，状态机01------------
always @ (posedge clk_20M)
begin
	if(!reset_n) state <= 2'b01;
	else if (txd_en) state <= 2'b10;
	else if (cnt >= txd_num) state <= 2'b01;
	else state <= state;
end
//------------------------
always @ (posedge clk_20M)
begin
	if(!reset_n) begin	
		en 		<=1'b0;
		cnt		<= 16'd0;
		data_in_reg <= 0;
		cnt2		   <= 4'd0;
   end	  
	else begin
		case (state)
		2'b01 : begin   //将要发送的数据接收过来
						en 		   <=1'b0;
						cnt		   <= 16'd0;
						data_in_reg <= data_in;
						cnt2		   <= 4'd0;
				  end
		2'b10 : begin//20M时钟cnt2计数10个数，数据右移
						en 		   <=1'b1;
						if(cnt2==4'd9) begin
							data_in_reg	<= data_in_reg>>1;
							cnt		   <= cnt + 16'd1;
							cnt2			<= 4'd0;
						end
						else begin
							data_in_reg <= data_in_reg;
							cnt2		   <= cnt2+4'd1;
						end
					end
		default : begin
						en 		   <=1'b0;
						cnt		   <= 16'd0;
						data_in_reg <= 0;
						cnt2			<= 4'd0;
					 end
	   endcase
	end
end

//发送2M
always @ (posedge clk_20M)
begin
	if(!reset_n) begin
		data_sam		<= 2'b11;
		cnt1 			<= 4'd0;
	end
	else if(en) begin
		if	(cnt1 == 4'd0) begin 
			cnt1<= cnt1+ 4'd1;
			if(data_in_reg[0]) data_sam <= 2'b10;
			else data_sam <= 2'b01;					
		end
		else if(cnt1 == 4'd5) begin
			cnt1     <= cnt1+ 4'd1;
			data_sam	<= data_sam>>1;
		end
		else if(cnt1 == 4'd9) cnt1	<= 4'd0;
		else cnt1<= cnt1+ 4'd1;
	end
	else begin
		data_sam		<= 2'b11;
		cnt1			<= 4'd0;
	end
end
endmodule
