/************************************
*Project   : 	async_fifo
*File Name :	asunc_fifo.v
*Author    :	hxy
*E-mail    : 
*Vision	   :	v2.0
*Data	   :    2019.10.01
*************************************/
module async_fifo 
#(
		parameter DATA_WIDTH = 8,
		parameter ADD_WIDTH	 = 5 ,
		parameter RAM_DEPTH = (1 << ADD_WIDTH)
)

(
			input	rst,
			input	wclk,
			input	w_en,
			input	rclk,
			input	r_en,
			input	[DATA_WIDTH-1 : 0]data_in,
			
			output	 full,
			output	 empty,
			output 	reg	[DATA_WIDTH-1 : 0]data_out
				
);

reg [ADD_WIDTH-1 : 0]	w_add_bin;
reg [ADD_WIDTH-1 : 0]	r_add_bin;
reg [ADD_WIDTH-1 : 0]	w_add_gray;
reg [ADD_WIDTH-1 : 0]	r_add_gray;

reg [ADD_WIDTH-1 : 0] 	w_add_gray_r1;
reg [ADD_WIDTH-1 : 0]	w_add_gray_r2;
reg [ADD_WIDTH-1 : 0] 	r_add_gray_r1;
reg [ADD_WIDTH-1 : 0]	r_add_gray_r2;

reg [DATA_WIDTH-1 : 0]	mem [RAM_DEPTH-1 : 0]; //32x8 RAM

//generate binary write address
always@(posedge wclk) begin
	if(rst) begin
		w_add_bin <=  'b0;
	end 
	else if((1 == w_en) && (0 == full))begin
		w_add_bin <= w_add_bin + 'b1;
	end 
	else begin
		w_add_bin <= w_add_bin;
	end 
end

//generate binary read address
always@(posedge rclk) begin
	if(rst) begin
		r_add_bin <=   'b0;
	end 
	else if((1 == r_en) && (0 == empty))begin
		r_add_bin <= r_add_bin + 'b1;
	end 
	else begin
		r_add_bin <= r_add_bin;
	end 
end

// binary write address  --> gray write address
always@(posedge wclk) begin
	if(rst) begin
		w_add_gray <=   'b0;
	end 
	else if(w_en && (!full))begin
//		w_add_gray <= (w_add_bin >> 1) ^ w_add_bin;
		w_add_gray <= {1'b0 , w_add_bin[ADD_WIDTH-1 : 1]} ^ w_add_bin;
	end 
	else begin
		w_add_gray <= w_add_gray;
	end 
end

// binary read address  --> gray read address

always@(posedge rclk) begin
	if(rst) begin
		r_add_gray <=   'b0;
	end 
	else if(w_en && (!full))begin
//		r_add_gray <= (r_add_bin >> 1) ^ r_add_bin;
		r_add_gray <= {1'b0 , r_add_bin[ADD_WIDTH-1 : 1]} ^ r_add_bin;
	end 
	else begin
		r_add_gray <= r_add_gray;
	end 
end


//2 dff to syn
always@(posedge wclk) begin
	if(rst) begin
		w_add_gray_r1 <=   'b0;
		w_add_gray_r2 <=   'b0;
	end
	else begin
		w_add_gray_r1 <= w_add_gray;
		w_add_gray_r2 <= w_add_gray_r1;
		
		if((1 == w_en) && (0 == full) ) begin
			data_out <= mem[w_add_gray_r2];
		end 
	
	end 
	
end 

always@(posedge rclk) begin
	if(rst) begin
		r_add_gray_r1 <=   'b0;
		r_add_gray_r2 <=   'b0;
	end 
	else begin
		r_add_gray_r1 <= r_add_gray;
		r_add_gray_r2 <= r_add_gray_r1;
		
		if((1 == r_en) && (0 == empty) ) begin
			data_out <= mem[r_add_gray_r2];
		end
	
	end 

end

//generate empty full

assign full = ((w_add_bin[ADD_WIDTH-1] != r_add_bin[ADD_WIDTH-1])&&  \
					(w_add_bin[ADD_WIDTH-2:0]==r_add_bin[ADD_WIDTH-2:0])) ? 1 : 0;
assign empty = (r_add_bin == w_add_bin) ? 1 : 0 ;
endmodule
