/*按键消抖电路
*抖动小于15MS 输入时钟为12M
*rst_n rst信号低电平有效
*按键信号key_in 默认状态为0  按下为1 
*/
module key_btn(
	input clk_12m,
	input rst_n,
	input key_in,
	output key_out
);
//KEY_JITTER 测试，20 代表原来的2000
parameter KEY_JITTER = 8'd20; //12Mhz 120ns

parameter OUT_SDA= 4'd2;
/*异步复位同步释放
* rst_n_sys 为系统使用的复位信号
*/
reg [1:0] rst_n_sys_r;
wire  rst_n_sys;
always @(posedge clk_12m or negedge rst_n) begin
	if(!rst_n) begin
		rst_n_sys_r <= 2'b00;
	end
	else begin
		rst_n_sys_r[0] <= 1'b1 ;
		rst_n_sys_r[1] <= rst_n_sys_r[0];		
	end 
end
assign rst_n_sys = rst_n_sys_r[1];


reg [1:0]key_in_r;
reg [15:0] delay_cnt;
wire key_in_change;
wire key_in_r_test1;
wire key_in_r_test2;
always @ (posedge clk_12m or negedge rst_n_sys) begin
	if(!rst_n_sys) begin
		key_in_r <= 2'b00;
	end
	else  begin
		key_in_r <= {key_in_r[0],key_in};
	end 

end 
assign  key_in_change = (~key_in_r[1]&key_in_r[0]) | (key_in_r[1] & ~ key_in_r[0]); 
assign	key_in_r_test1 = (~key_in_r[1]&key_in_r[0]);
assign	key_in_r_test2 = (key_in_r[1] & (~ key_in_r[0]));


always @(posedge clk_12m or negedge rst_n_sys) begin
	if(!rst_n_sys) begin
		delay_cnt <= 16'd0;
	end 
	else begin
		if(key_in_change) begin
			delay_cnt <= 16'd0;
		end
		else if (delay_cnt == KEY_JITTER) begin
			delay_cnt <= 16'd0;
		end
		else begin
			delay_cnt <= delay_cnt + 1'b1;
		end 
		
	end 

end
 
assign key_out = ((delay_cnt == KEY_JITTER ) && (key_in == 1'b1) ) ? 1'b1 : 1'b0; 
 
endmodule