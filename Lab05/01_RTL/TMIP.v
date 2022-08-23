//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   2022 ICLAB Spring Course
//   Lab05			: Template Matching With Image Processing
//   Author         : Yao-Zhan Xu (xuyaozhan8905@gmail.com)
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   File Name   : TMIP.v
//   Module Name : TMIP
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

module TMIP(
// input signals
    clk,
    rst_n,
    in_valid,
	in_valid_2,
    image,
	img_size,
    template, 
    action,
	
// output signals
    out_valid,
    out_x,
    out_y,
    out_img_pos,
    out_value
); 
//================================================================
//  INPUT AND OUTPUT DECLARATION                         
//================================================================
input        clk, rst_n, in_valid, in_valid_2;
input [15:0] image, template;
input [4:0]  img_size;
input [2:0]  action;

output reg        out_valid;
output reg [3:0]  out_x, out_y; 
output reg [7:0]  out_img_pos;
output reg signed[39:0] out_value;

//================================================================
//  integer / genvar / parameters
//================================================================
// FLIP
parameter HORIZONTAL = 3'd2,
		  VERTICAL = 3'd3,
		  LEFT_DIAG = 3'd4,
		  RIGHT_DIAG = 3'd5;
// FSM
parameter STATE_IDLE = 3'd0,
		  STATE_CROSS = 3'd1,
		  STATE_BEFORE = 3'd2, // initial img_addr && flip_cnt && adj_cnt
		  STATE_POOLING = 3'd3,
		  STATE_FLIP = 3'd4,
		  STATE_ZOOMIN = 3'd5,
		  STATE_ADJUST = 3'd6,
		  STATE_OUTPUT = 3'd7;
// cur_state == STATE_IDLE	  
parameter SUB_STATE_WAIT = 1'b0, SUB_STATE_INPUT = 1'b1;
// cur_state == CROSS CORRELATION
//parameter SUB_STATE_CROSS4 = 2'd0, SUB_STATE_CROSS6 = 2'd1, SUB_STATE_CROSS9 = 2'd2;
parameter SUB_STATE_LEFT_TOP = 3'd0, SUB_STATE_TOP = 3'd1, SUB_STATE_RIGHT_TOP = 3'd2, SUB_STATE_LEFT = 3'd3, 
		  SUB_STATE_MID = 3'd4, SUB_STATE_RIGHT = 3'd5, SUB_STATE_LEFT_DOWN = 3'd6, SUB_STATE_DOWN = 3'd7, SUB_STATE_RIGHT_DOWN = 4'd8;
// cur_state == ADJUSTMENT, ZOOM-IN,  MAX POOLING
parameter SUB_STATE_READ = 2'd0, SUB_STATE_DELAY = 2'd2 , SUB_STATE_WRITE = 2'd1;
// cur_state == MAX POOLING
parameter SUB_STATE_READ2 = 3'd3, SUB_STATE_READ3 = 3'd4, SUB_STATE_READ4 = 3'd5, SUB_STATE_READ5 = 3'd6;
integer i;
//================================================================
//   Wires & Registers 
//================================================================
// FSM
reg [2:0] cur_state, nx_state;
reg cur_input_state, nx_input_state; // cur_state == STATE_IDLE
reg [3:0] cur_cross_state, nx_cross_state; // cur_state == STATE_CROSS
reg cur_adjust_state, nx_adjust_state; // cur_state == STATE_ADJUST 
reg [1:0] cur_zoom_state, nx_zoom_state; // cur_state == STATE_ZOOMIN
reg [2:0] cur_pooling_state, nx_pooling_state; // cur_state == STATE_POOLING
reg cur_flip_state, nx_flip_state; // cur_state == STATE_FLIP
// image SRAM port
reg [7:0] img_addr; // address or image sram
reg img_wen; // write enable negative of image sram 
reg img_wen2; // write enable negative of image sram 
wire signed [15:0] img_data; // output or image sram  
wire signed [15:0] img_data2; // output or image sram  
reg signed [15:0] img_input_data;
reg mem_sel; // select one of SRAM
wire signed [15:0] img_data3; // choose img_data or img_data2
// INPUT
reg [4:0] size; // 4*4 or 8*8 or 16*16
reg [2:0] act[0:15]; // action 
reg signed [15:0] kernel_tmp[0:8]; // template
reg signed [15:0] kernel; // using for resource sharing 

reg [7:0] in_cnt; // counter of input image data  
reg [3:0] act_cnt; // counter of action data

reg flag;// in_valid_2 flag 

// answer SRAM port
wire ans_wen; // write enable negative of answer sram
reg [7:0] ans_addr; // address of answer sram 
wire signed [39:0] ans_data; // output data of answer sram  
reg signed  [39:0] ans_input; // input data of answer sram 
// cross
reg [7:0] cross_cnt; // address control by  img_addr
reg [3:0] inner_cnt; // interior counter. Using for cross correlation.
wire signed  [39:0] mul; // multiplexer(template*image)

reg finish_cross; // Is cross correlation proccess done 
// pre_output
reg [7:0] tmp_ans_addr; // ans_addr minus one. To simplify code cleanliness 

reg [3:0] max_x, max_y; // index of maximun value
reg [7:0] max_pos;//  index of maximun value
reg signed [39:0] max_value; // maximun value
reg [3:0] previous_cross_state; // using in max_pos
reg [3:0] pos_type; // using in out_img_pos

reg flag_output; // Using for one clock cycle delay
reg flag_cross_finish; // Using for one clock cycle delay
// shortcut + brightness adjustment	
reg flag_adj_finish; // finish_adjustment flag
reg [7:0] adj_cnt; // adjustment counter 
reg [7:0] adj_mem_cnt; // adjustment counter 
wire signed [15:0] tmp_adj_data; // temporary operation variable 
wire signed [15:0] adj_data; // contorl data input of image sram
// zoomin
reg [7:0] zoom_cnt; // zoomin counter 
reg signed [15:0] zoom_data; // contorl data input of image sram
reg [1:0] zoom_output_cnt;// proccess counter
reg [7:0] tmp_zoom_cnt; // after zoomin counter
reg [7:0] orig_zoom_cnt; // before zoomin counter 
reg signed [15:0] img_buffer; // SRAM img_data buffer
wire signed [15:0] tmp_zoom_data; // temporary variable

reg flag_zoom_finish; // finish flag
reg flag_zoom_init; // initial zoom_cnt
// Max pooling
reg signed [15:0] pooling_data; // contorl data input of image sram
reg [7:0] pooling_cnt; // pooling counter
reg [7:0] pooling_mem_cnt; // pooling counter
reg flag_pool_finish; // finish flag

//flip
reg flag_flip_finish; // finish flag
reg [7:0] flip_cnt, flip_mem_cnt; // flip counter
reg [2:0] cur_act; // 2: Horizontal, 3: vertical, 4: Left-diagona, 5: Right-diagonal
//================================================================
//	INPUT
//================================================================
always@( posedge clk or negedge rst_n ) begin
	if( !rst_n ) in_cnt <= 0;
	else if( in_valid ) in_cnt <= in_cnt + 1;
	else in_cnt <= 0;
end

always@( posedge clk or negedge rst_n ) begin
	if( !rst_n ) size <= 0;
	else if( in_valid && in_cnt == 0 ) size <= img_size ;
	else if( cur_state == STATE_ADJUST && flag_adj_finish ) begin
		if( size == 16 ) size <= 8;
		else if( size == 8 ) size <= 4;
	end
	else if( cur_state == STATE_ZOOMIN && flag_zoom_finish ) begin
		if( size == 8 ) size <= 16;
		else if( size == 4 ) size <= 8;
	end
	else if( cur_state == STATE_POOLING && flag_pool_finish ) begin
		if( size == 16 ) size <= 8;
		else if( size == 8 ) size <= 4;
	end
end

always@( posedge clk or negedge rst_n ) begin
	if( !rst_n ) begin
		for( i=0 ; i< 9 ; i=i+1 ) kernel_tmp[i] <= 0;
	end
	else if( in_valid && in_cnt < 9 ) kernel_tmp[in_cnt] <= template;
end
	
always@( posedge clk or negedge rst_n ) begin
	if( !rst_n ) act_cnt <= 0;
	else if( in_valid_2 ) act_cnt <= act_cnt + 1;
	else act_cnt <= 0;
end

always@( posedge clk or negedge rst_n ) begin
	if( !rst_n ) begin
		for( i=0 ; i<16 ; i=i+1 ) act[i] <= 0;
	end
	else if( cur_state == STATE_IDLE ) begin
		if( in_valid_2 ) act[act_cnt] <= action;
		else if( flag == 1'b1 ) begin
			act[15] <= 0;
			for( i=14 ; i>=0 ; i=i-1 ) act[i] <= act[i+1]; 
		end
	end
	// corner case
	else if( (cur_state==STATE_POOLING && flag_pool_finish)||(cur_state==STATE_ZOOMIN&&flag_zoom_finish)||(cur_state==STATE_ADJUST&&flag_adj_finish) || (cur_state == STATE_FLIP&&flag_flip_finish) ) begin
		act[15] <= 0;
		for( i=14 ; i>=0 ; i=i-1 ) act[i] <= act[i+1]; 
	end
 end

always@( posedge clk or negedge rst_n ) begin
	if( !rst_n ) flag <= 0;
	else if( in_valid_2 ) flag <= 1;
	else if( cur_state != STATE_IDLE ) flag <= 0;
end

//================================================================
//  IMAGE SRAM
//================================================================

IMG_MEM_100MHz MEM1(.Q(img_data), .CLK(clk), .CEN(1'b0), .WEN(img_wen), .A(img_addr), .D(img_input_data), .OEN(1'b0));
IMG_MEM_100MHz MEM2(.Q(img_data2), .CLK(clk), .CEN(1'b0), .WEN(img_wen2), .A(img_addr), .D(img_input_data), .OEN(1'b0));

always @( posedge clk or negedge rst_n ) begin
	if( !rst_n ) mem_sel <= 1'b1;
	else if( cur_state == STATE_IDLE ) mem_sel <= 1'b1;
	else if( cur_state == STATE_FLIP && flag_flip_finish ) mem_sel <= ~mem_sel;
end
assign img_data3 = ( mem_sel )? img_data : img_data2;

always@( * ) begin
	case( cur_state )
	STATE_IDLE: img_input_data = image;
	STATE_ADJUST: img_input_data = adj_data ;
	STATE_ZOOMIN: img_input_data = zoom_data;
	STATE_FLIP: img_input_data = img_data3;
	STATE_POOLING: img_input_data = pooling_data;
	default: img_input_data = 0;
	endcase
end


always@( * ) begin
	case( cur_state )
	STATE_IDLE: begin
		if( nx_input_state == SUB_STATE_WAIT ) begin
			img_wen  = 1'b1; img_wen2 = 1'b1;
		end
		else begin
			img_wen  = ~mem_sel; img_wen2 = mem_sel;
		end
	end
	STATE_ADJUST: begin
		if( cur_adjust_state == SUB_STATE_WRITE ) begin
			img_wen = ~mem_sel; img_wen2 = mem_sel;
		end
		else begin
			img_wen  = 1'b1; img_wen2 = 1'b1;
		end
	end
	STATE_FLIP: begin
		if( cur_flip_state == SUB_STATE_READ ) begin
			img_wen  = 1'b1; img_wen2 = 1'b1;
		end
		else begin
			img_wen  = mem_sel; img_wen2 = ~mem_sel;
		end
	end
	STATE_ZOOMIN: begin 
		if( cur_zoom_state == SUB_STATE_WRITE && !flag_zoom_finish ) begin
			img_wen = ~mem_sel; img_wen2 = mem_sel;
		end
		else begin
			img_wen  = 1'b1; img_wen2 = 1'b1;
		end
	end
	STATE_POOLING: begin 
		if( cur_pooling_state == SUB_STATE_WRITE ) begin
			img_wen = ~mem_sel; img_wen2 = mem_sel;
		end
		else begin
			img_wen  = 1'b1; img_wen2 = 1'b1;
		end
	end
	default: begin
			img_wen  = 1'b1; img_wen2 = 1'b1;
		end
	endcase
end

always@( * ) begin
	case( cur_state ) 
	STATE_IDLE: img_addr = in_cnt;
	STATE_CROSS, STATE_BEFORE: img_addr = cross_cnt;
	STATE_ADJUST: begin
		if( size == 4 ) begin
			if( adj_mem_cnt == 16 ) img_addr = 0;
			else img_addr = adj_mem_cnt;
		end
		else begin
			if( cur_adjust_state == SUB_STATE_WRITE ) img_addr = adj_mem_cnt;
			else img_addr = adj_cnt;	
		end
	end
	STATE_FLIP: begin
		if( cur_flip_state == SUB_STATE_READ ) img_addr = flip_cnt; 
		else img_addr = flip_mem_cnt; 
	end
	STATE_ZOOMIN: img_addr = zoom_cnt;
	STATE_POOLING: begin
		if( cur_pooling_state == SUB_STATE_READ2 || cur_pooling_state == SUB_STATE_READ3 || cur_pooling_state == SUB_STATE_READ4 || cur_pooling_state == SUB_STATE_READ5  )
			img_addr = pooling_mem_cnt;
		else img_addr = pooling_cnt;
	end
	default: img_addr = 0;
	endcase	
end

//================================================================
//	SHORTCUT + BRIGHTNESS ADJUSTMENT
//================================================================
always@( posedge clk or negedge rst_n ) begin
	if( !rst_n ) adj_cnt <= 0;
	else if( cur_state == STATE_ADJUST ) begin
		if( nx_adjust_state == SUB_STATE_READ ) begin
			if( size == 8 ) adj_cnt <= ( adj_cnt[2:0] == 3'b101 )? adj_cnt+5 : adj_cnt+1 ;
			else if( size == 16 ) adj_cnt <= ( adj_cnt[3:0] == 4'b1011 )? adj_cnt+9 : adj_cnt+1 ;			
		end
	end
	else if( cur_state == STATE_ZOOMIN ) begin
		if( size == 8 || size == 16 ) adj_cnt <= 'd68;
		else adj_cnt <= 'd18;
	end
	else if( cur_state == STATE_POOLING ) begin
		if( size == 16 ) adj_cnt <= 'd18;
		else adj_cnt <= 'd0;
	end
	else begin
		if( size == 8 ) adj_cnt <= 'd18;
		else if( size == 16 ) adj_cnt <= 'd68;
		else adj_cnt <= 'd0;
	end
end

always@( posedge clk or negedge rst_n ) begin
	if( !rst_n ) adj_mem_cnt <= 0;
	else if( cur_state == STATE_ADJUST ) begin
		if( cur_adjust_state == SUB_STATE_WRITE ) adj_mem_cnt <= adj_mem_cnt + 1;
	end
	else adj_mem_cnt <= 0;
end

always@( * ) begin
	case( cur_adjust_state )
	SUB_STATE_READ: begin
		if( size == 4 ) flag_adj_finish = ( adj_mem_cnt == 16 )? 1 : 0;
		else if( size == 8 ) flag_adj_finish = ( adj_cnt == 50 )? 1 : 0;
		// size == 16 
		else flag_adj_finish = ( adj_cnt == 196 )? 1 : 0; 
	end
	SUB_STATE_WRITE: flag_adj_finish = 0;
	default: flag_adj_finish = 0; 
	endcase
end

assign tmp_adj_data = ( img_data3[0] )? img_data3 - 1: img_data3; 
assign adj_data = tmp_adj_data/2 + 50 ;

//================================================================
//	ZOOM-IN
//================================================================
wire signed[19:0] zoom_data_1, zoom_data_2, zoom_data_3, zoom_data_4;

always@( posedge clk or negedge rst_n ) begin
	if( !rst_n ) img_buffer <= 0;
	else if( cur_state == STATE_ZOOMIN ) begin
		if( cur_zoom_state == SUB_STATE_DELAY ) img_buffer <= img_data3;
	end
end

assign zoom_data_1 = img_buffer;
assign zoom_data_2 = img_buffer/3;
assign zoom_data_3 = (img_buffer*2)/3 + 20;
assign tmp_zoom_data = ( img_buffer[0] )? img_buffer - 1 : img_buffer ; 
assign zoom_data_4 = tmp_zoom_data/2;

always@( * ) begin
	case( zoom_output_cnt )
	2'd0: zoom_data = zoom_data_1;
	2'd1: zoom_data = zoom_data_2;
	2'd2: zoom_data = zoom_data_3;
	2'd3: zoom_data = zoom_data_4;
	endcase	
end

always@( posedge clk or negedge rst_n ) begin
	if( !rst_n ) orig_zoom_cnt <= 0;
	else if( cur_state == STATE_ZOOMIN ) begin 
		if( cur_zoom_state == SUB_STATE_READ ) orig_zoom_cnt <= zoom_cnt;
	end
	else orig_zoom_cnt <= zoom_cnt;
end

always@( posedge clk or negedge rst_n ) begin
	if( !rst_n ) tmp_zoom_cnt <= 0;
	else if( cur_state == STATE_ZOOMIN ) begin
		if( cur_zoom_state == SUB_STATE_READ ) begin
			if( flag_zoom_init ) begin
				if( size == 8 ) tmp_zoom_cnt <= 238;
				else if( size == 4 ) tmp_zoom_cnt <= 54;
			end
		end
		else if( cur_zoom_state == SUB_STATE_DELAY ) begin
			if( size == 4 && zoom_cnt[1:0] == 2'b00 ) tmp_zoom_cnt <= tmp_zoom_cnt - 10;
			else if( size == 8 && zoom_cnt[2:0] == 3'b000 ) tmp_zoom_cnt <= tmp_zoom_cnt - 18;
			else tmp_zoom_cnt <= tmp_zoom_cnt - 2;
		end
	end
	else begin
		if( size == 8 ) tmp_zoom_cnt <= 238;
		else if( size == 4 ) tmp_zoom_cnt <= 54;
	end
end

always@( posedge clk or negedge rst_n ) begin
	if( !rst_n ) zoom_cnt <= 0;
	else if( cur_state == STATE_ZOOMIN ) begin
		if( cur_zoom_state == SUB_STATE_WRITE ) begin
			case( zoom_output_cnt ) 
			0: zoom_cnt <= zoom_cnt+1;	
			1: zoom_cnt <= zoom_cnt+size+size-1;	
			2: zoom_cnt <= zoom_cnt+1;
			3: begin
				if( orig_zoom_cnt == 0 ) begin
					if( size == 4 ) zoom_cnt <= 63;
					else zoom_cnt <= 255;
				end
				else zoom_cnt <= orig_zoom_cnt -1 ;
			end
			endcase
		end
		else if( cur_zoom_state == SUB_STATE_DELAY ) zoom_cnt <= tmp_zoom_cnt;
	end
	else begin
		if( cur_state == STATE_ADJUST || cur_state == STATE_POOLING ) begin
			if( size == 4 ) zoom_cnt <= 15;
			else if( size == 8 ) zoom_cnt <= 15;
			// size == 16
			else zoom_cnt <= 63;
		end
		else begin
			if( size == 4 ) zoom_cnt <= 15;
			else if( size == 8 ) zoom_cnt <= 63;
		end
	end
end

always@( posedge clk or negedge rst_n ) begin
	if( !rst_n ) zoom_output_cnt <= 0;
	else if( cur_zoom_state == SUB_STATE_WRITE ) zoom_output_cnt <= zoom_output_cnt + 1;
	else zoom_output_cnt <= 0;
end

always@( posedge clk or negedge rst_n ) begin
	if( !rst_n ) flag_zoom_finish <= 0;
	else if( cur_state == STATE_ZOOMIN ) begin
		if( size == 16 ) flag_zoom_finish <= 1'b1;
		else if( zoom_output_cnt == 2'd3 ) begin
			if( size == 4 ) flag_zoom_finish <= ( zoom_cnt == 7'd9 )? 1'b1 :1'b0;
			else if( size == 8 ) flag_zoom_finish <= ( zoom_cnt == 7'd17 )? 1'b1 :1'b0;
		end
		else flag_zoom_finish <= 1'b0;
	end
	else flag_zoom_finish <= 1'b0;
end

always@( posedge clk or negedge rst_n ) begin
	if( !rst_n ) flag_zoom_init <= 0;
	else if( cur_state == STATE_IDLE||(cur_state==STATE_POOLING && flag_pool_finish)||(cur_state==STATE_ZOOMIN&&flag_zoom_finish)||(cur_state==STATE_ADJUST&&flag_adj_finish) || (cur_state == STATE_FLIP&&flag_flip_finish) ) flag_zoom_init <= 1;
	else flag_zoom_init <= 0;
end

//================================================================
//	MAX POOLING
//================================================================
always@( posedge clk or negedge rst_n ) begin
	if( !rst_n ) pooling_data <= 0;
	else if( cur_state == STATE_POOLING ) begin
		if( cur_pooling_state == SUB_STATE_READ3 ) pooling_data <= img_data3;
		else if( cur_pooling_state == SUB_STATE_READ4 || cur_pooling_state == SUB_STATE_READ5 || cur_pooling_state == SUB_STATE_DELAY ) 
			pooling_data <= ( img_data3 > pooling_data )? img_data3: pooling_data;
	end
end

always@( posedge clk or negedge rst_n ) begin
	if( !rst_n ) pooling_cnt <= 0;
	else if( cur_state == STATE_POOLING ) begin
		if( flag_pool_finish ) pooling_cnt <= 0;
		else if( cur_pooling_state == SUB_STATE_WRITE ) pooling_cnt <= pooling_cnt + 1;
	end
	else pooling_cnt <= 0;
end

always@( posedge clk or negedge rst_n ) begin
	if( !rst_n ) pooling_mem_cnt <= 0;
	else if( cur_state == STATE_POOLING ) begin
		if( cur_pooling_state == SUB_STATE_READ ) begin
			if( size == 8 ) pooling_mem_cnt <= pooling_cnt[3:2] * 16 + pooling_cnt[1:0] * 2;
			else if( size == 16 ) pooling_mem_cnt <= pooling_cnt[5:3] * 32 + pooling_cnt[2:0] * 2;
		end
		else if( cur_pooling_state == SUB_STATE_READ2 ) pooling_mem_cnt <= pooling_mem_cnt + 1;
		else if( cur_pooling_state == SUB_STATE_READ3 ) pooling_mem_cnt <= pooling_mem_cnt + size - 1;
		else if( cur_pooling_state == SUB_STATE_READ4 ) pooling_mem_cnt <= pooling_mem_cnt + 1;		
	end
end

always@( posedge clk or negedge rst_n ) begin
	if( !rst_n ) flag_pool_finish <= 0;
	else if( cur_state == STATE_POOLING ) begin
		if( size == 4 ) flag_pool_finish <= 1'b1;
		else if( cur_pooling_state == SUB_STATE_WRITE ) begin
			if( size == 8 ) flag_pool_finish <= ( pooling_cnt == 7'd15 )? 1'b1 :1'b0;
			else if( size == 16 ) flag_pool_finish <= ( pooling_cnt == 7'd63 )? 1'b1 :1'b0;
		end
		else flag_pool_finish <= 0;
	end
	else flag_pool_finish <= 0;
end

//================================================================
//	FLIP
//================================================================
always @( posedge clk or negedge rst_n ) begin
	if( !rst_n ) flag_flip_finish <= 1'd0;
	else if( cur_state == STATE_FLIP && cur_flip_state == SUB_STATE_WRITE ) begin
		case( cur_act ) 
		HORIZONTAL: begin
			if( size == 4 ) flag_flip_finish <= (flip_cnt=='d15&&flip_mem_cnt=='d15);
			else if( size == 8 ) flag_flip_finish <= (flip_cnt=='d63&&flip_mem_cnt=='d63);
			else flag_flip_finish <= (flip_cnt=='d255&&flip_mem_cnt=='d255);
		end
		VERTICAL: begin
			if( size == 4 ) flag_flip_finish <= (flip_cnt=='d12&&flip_mem_cnt=='d15);
			else if( size == 8 ) flag_flip_finish <= (flip_cnt=='d56&&flip_mem_cnt=='d63);
			else flag_flip_finish <= (flip_cnt=='d240&&flip_mem_cnt=='d255);
		end
		LEFT_DIAG: begin
			if( size == 4 ) flag_flip_finish <= (flip_cnt=='d15&&flip_mem_cnt=='d15);
			else if( size == 8 ) flag_flip_finish <= (flip_cnt=='d63&&flip_mem_cnt=='d63);
			else flag_flip_finish <= (flip_cnt=='d255&&flip_mem_cnt=='d255);
		end
		RIGHT_DIAG: begin
			if( size == 4 ) flag_flip_finish <= (flip_cnt=='d0&&flip_mem_cnt=='d15);
			else if( size == 8 ) flag_flip_finish <= (flip_cnt=='d0&&flip_mem_cnt=='d63);
			else flag_flip_finish <= (flip_cnt=='d0&&flip_mem_cnt=='d255);
		end
		endcase
	end
	else flag_flip_finish <= 1'd0;
end

always @( posedge clk or negedge rst_n ) begin
	if( !rst_n ) begin
		flip_cnt <= 'd0; flip_mem_cnt <= 'd0;
	end
	else if( cur_state == STATE_FLIP ) begin
		if( cur_flip_state == SUB_STATE_READ ) begin
			case( cur_act )
			HORIZONTAL: begin
				if( size == 4 ) 	 flip_cnt[3:0] <= ( flip_cnt[3:2] == 2'b11 )? flip_cnt[3:0] + size - 1: flip_cnt[3:0] + size; 
				else if( size == 8 ) flip_cnt[5:0] <= ( flip_cnt[5:3] == 3'b111 )? flip_cnt[5:0] + size - 1: flip_cnt[5:0] + size; 
				else				 flip_cnt[7:0] <= ( flip_cnt[7:4] == 4'b1111 )? flip_cnt[7:0] + size - 1: flip_cnt[7:0] + size; 
			end
			VERTICAL: begin
				if( size == 4 ) 	 flip_cnt[3:0] <= ( flip_cnt[1:0] == 2'b11 )? flip_cnt[3:0] - 7 : flip_cnt[3:0] + 1; 
				else if( size == 8 ) flip_cnt[5:0] <= ( flip_cnt[2:0] == 3'b111 )? flip_cnt[5:0] - 15: flip_cnt[5:0] + 1; 
				else				 flip_cnt[7:0] <= ( flip_cnt[3:0] == 4'b1111 )? flip_cnt[7:0] - 31: flip_cnt[7:0] + 1; 
			end
			LEFT_DIAG: begin
				if( size == 4 ) 	 flip_cnt[3:0] <= flip_cnt[3:0] - 1; 
				else if( size == 8 ) flip_cnt[5:0] <= flip_cnt[5:0] - 1; 
				else				 flip_cnt[7:0] <= flip_cnt[7:0] - 1;		
			end
			RIGHT_DIAG: begin
				if( size == 4 ) 	 flip_cnt[3:0] <= flip_cnt[3:0] + 1; 
				else if( size == 8 ) flip_cnt[5:0] <= flip_cnt[5:0] + 1; 
				else				 flip_cnt[7:0] <= flip_cnt[7:0] + 1;
			end
			endcase
		end
		else begin
			case( cur_act )
			HORIZONTAL: begin
				if( size == 4 ) 	 flip_mem_cnt[3:0] <= ( flip_mem_cnt[3:2] == 2'b11 )? flip_mem_cnt[3:0] + size + 1: flip_mem_cnt[3:0] + size; 
				else if( size == 8 ) flip_mem_cnt[5:0] <= ( flip_mem_cnt[5:3] == 3'b111 )? flip_mem_cnt[5:0] + size + 1: flip_mem_cnt[5:0] + size; 
				else				 flip_mem_cnt[7:0] <= ( flip_mem_cnt[7:4] == 4'b1111 )? flip_mem_cnt[7:0] + size + 1: flip_mem_cnt[7:0] + size;
			end
			VERTICAL: begin
				if( size == 4 ) 	 flip_mem_cnt[3:0] <= flip_mem_cnt[3:0] + 1; 
				else if( size == 8 ) flip_mem_cnt[5:0] <= flip_mem_cnt[5:0] + 1; 
				else				 flip_mem_cnt[7:0] <= flip_mem_cnt[7:0] + 1;
			end
			LEFT_DIAG: begin
				if( size == 4 ) 	 flip_mem_cnt[3:0] <= ( flip_mem_cnt[3:2] == 2'b11 )? flip_mem_cnt[3:0] + 5 : flip_mem_cnt[3:0] + 4; 
				else if( size == 8 ) flip_mem_cnt[5:0] <= ( flip_mem_cnt[5:3] == 3'b111 )? flip_mem_cnt[5:0] + 9 : flip_mem_cnt[5:0] + 8; 
				else				 flip_mem_cnt[7:0] <= ( flip_mem_cnt[7:4] == 4'b1111 )? flip_mem_cnt[7:0] + 17 : flip_mem_cnt[7:0] + 16;
			end
			RIGHT_DIAG: begin
				if( size == 4 ) 	 flip_mem_cnt[3:0] <= ( flip_mem_cnt[3:2] == 2'b11 )? flip_mem_cnt[3:0] + 5 : flip_mem_cnt[3:0] + 4; 
				else if( size == 8 ) flip_mem_cnt[5:0] <= ( flip_mem_cnt[5:3] == 3'b111 )? flip_mem_cnt[5:0] + 9 : flip_mem_cnt[5:0] + 8; 
				else				 flip_mem_cnt[7:0] <= ( flip_mem_cnt[7:4] == 4'b1111 )? flip_mem_cnt[7:0] + 17 : flip_mem_cnt[7:0] + 16;
			end
			endcase
		end
	end
	else begin
		if( cur_state == STATE_ADJUST || cur_state == STATE_POOLING ) begin
			case( act[0] ) 
			HORIZONTAL: begin // HORIZONTAL
				flip_mem_cnt <= 'd0;
				if( size == 4 || size == 8 ) flip_cnt <= 'd3;
				else flip_cnt <= 'd7;
			end
			VERTICAL: begin // VERTICAL
				flip_mem_cnt <= 'd0;
				if( size == 4 || size == 8 ) flip_cnt <= 'd12;
				else flip_cnt <= 'd56;
			end
			LEFT_DIAG: begin // LEFT_DIAG
				flip_mem_cnt <= 'd0;
				if( size == 4 || size == 8 ) flip_cnt <= 'd15;
				else flip_cnt <= 'd63;	
			end
			RIGHT_DIAG: begin // RIGHT_DIAG
				flip_mem_cnt <= 'd0;
				flip_cnt <= 'd0;
			end
			
			endcase
		end
		else if( cur_state == STATE_ZOOMIN ) begin
			case( act[0] ) 
			HORIZONTAL: begin // HORIZONTAL
				flip_mem_cnt <= 'd0;
				if( size == 8 || size == 16 ) flip_cnt <= 'd15;
				else flip_cnt <= 'd7;
			end
			VERTICAL: begin // VERTICAL
				flip_mem_cnt <= 'd0;
				if( size == 8 || size == 16 ) flip_cnt <= 'd240;
				else flip_cnt <= 'd56;
			end
			LEFT_DIAG: begin // LEFT_DIAG
				flip_mem_cnt <= 'd0;
				if( size == 8 || size == 16 ) flip_cnt <= 'd255;
				else flip_cnt <= 'd63;
			end
			RIGHT_DIAG: begin // RIGHT_DIAG
				flip_mem_cnt <= 'd0;
				flip_cnt <= 'd0;
			end	
			endcase
		end
		else if( cur_state == STATE_BEFORE ) begin
			case( cur_act )
			HORIZONTAL: begin // HORIZONTAL
				flip_mem_cnt <= 'd0;
				if( size == 4 ) flip_cnt <= 'd3;
				else if( size == 8 ) flip_cnt <= 'd7;
				else flip_cnt <= 'd15;
			end
			VERTICAL: begin // VERTICAL
				flip_mem_cnt <= 'd0;
				if( size == 4 ) flip_cnt <= 'd12;
				else if( size == 8 ) flip_cnt <= 'd56;
				else flip_cnt <= 'd240;
			end
			LEFT_DIAG: begin // LEFT_DIAG
				flip_mem_cnt <= 'd0;
				if( size == 4 ) flip_cnt <= 'd15;
				else if( size == 8 ) flip_cnt <= 'd63;
				else flip_cnt <= 'd255;	
			end
			RIGHT_DIAG: begin // RIGHT_DIAG
				flip_mem_cnt <= 'd0;
				flip_cnt <= 'd0;	
			end	
			endcase
		end
		else begin
			case( act[0] )
			HORIZONTAL: begin // HORIZONTAL
				flip_mem_cnt <= 'd0;
				if( size == 4 ) flip_cnt <= 'd3;
				else if( size == 8 ) flip_cnt <= 'd7;
				else flip_cnt <= 'd15;
			end
			VERTICAL: begin // VERTICAL
				flip_mem_cnt <= 'd0;
				if( size == 4 ) flip_cnt <= 'd12;
				else if( size == 8 ) flip_cnt <= 'd56;
				else flip_cnt <= 'd240;
			end
			LEFT_DIAG: begin // LEFT_DIAG
				flip_mem_cnt <= 'd0;
				if( size == 4 ) flip_cnt <= 'd15;
				else if( size == 8 ) flip_cnt <= 'd63;
				else flip_cnt <= 'd255;	
			end
			RIGHT_DIAG: begin // RIGHT_DIAG
				flip_mem_cnt <= 'd0;
				flip_cnt <= 'd0;	
			end	
			endcase
		end
	end
end

always @( posedge clk or negedge rst_n ) begin
	if( !rst_n ) cur_act <= 2'd0;
	else if( cur_state == STATE_IDLE ||(cur_state==STATE_POOLING && flag_pool_finish)||(cur_state==STATE_ZOOMIN&&flag_zoom_finish)||(cur_state==STATE_ADJUST&&flag_adj_finish) || (cur_state == STATE_FLIP&&flag_flip_finish) ) cur_act <= act[0];
end

//================================================================
//	CROSS CORRELATION
//================================================================
always@( * ) begin
	case( cur_cross_state ) 
	SUB_STATE_LEFT_TOP, SUB_STATE_RIGHT_TOP, SUB_STATE_RIGHT_DOWN, SUB_STATE_LEFT_DOWN: 
		finish_cross = ( inner_cnt == 4 )? 1'b1 : 1'b0 ;
	SUB_STATE_TOP, SUB_STATE_LEFT, SUB_STATE_RIGHT, SUB_STATE_DOWN:   
		finish_cross = ( inner_cnt == 6 )? 1'b1 : 1'b0 ;
	SUB_STATE_MID: 		
		finish_cross = ( inner_cnt == 9 )? 1'b1 : 1'b0 ;
	default: finish_cross = 1'b0;
	endcase
end

always@( posedge clk or negedge rst_n ) begin
	if( !rst_n ) ans_addr <= 0;
	else if( nx_state == STATE_CROSS )begin
		if( finish_cross ) begin
			if( size == 4 && ans_addr == 15 ) ans_addr <= 0;
			else if( size == 8 && ans_addr == 63 ) ans_addr <= 0;
			else if( size == 16 && ans_addr == 255 ) ans_addr <= 0;
			else ans_addr <= ans_addr + 1;
		end
	end
	else if( nx_state == STATE_OUTPUT ) ans_addr <= ans_addr + 1;
	else ans_addr <= 0;
end

always@( posedge clk or negedge rst_n ) begin
	if( !rst_n ) inner_cnt <= 0;
	else if( cur_state == STATE_CROSS ) begin
		if( !finish_cross )	inner_cnt <= inner_cnt + 1;
		else inner_cnt <= 0;
	end
	else inner_cnt <= 0;
end

always@( * ) begin
	case( cur_cross_state ) 
	SUB_STATE_LEFT_TOP: begin
		case( inner_cnt )
		0: kernel = kernel_tmp[4];	
		1: kernel = kernel_tmp[5];
		2: kernel = kernel_tmp[7];
		3: kernel = kernel_tmp[8];	
		default: kernel = 'd0; 
		endcase
	end
	SUB_STATE_TOP: begin
		case( inner_cnt )
		0: kernel = kernel_tmp[3];
		1: kernel = kernel_tmp[4]; 
		2: kernel = kernel_tmp[5];
		3: kernel = kernel_tmp[6];
		4: kernel = kernel_tmp[7];
		5: kernel = kernel_tmp[8];
		default: kernel = 'd0;
		endcase
	end
	SUB_STATE_RIGHT_TOP: begin
		case( inner_cnt )
		0: kernel = kernel_tmp[3];
		1: kernel = kernel_tmp[4];	
		2: kernel = kernel_tmp[6];
		3: kernel = kernel_tmp[7];
		default: kernel = 'd0;
		endcase
	end
	SUB_STATE_LEFT: begin
		case( inner_cnt )
		0: kernel = kernel_tmp[1];
		1: kernel = kernel_tmp[2];
		2: kernel = kernel_tmp[4];
		3: kernel = kernel_tmp[5];
		4: kernel = kernel_tmp[7]; 
		5: kernel = kernel_tmp[8];
		default: kernel = 'd0; 
		endcase
	end
	SUB_STATE_MID: begin
		case( inner_cnt ) 
		0: kernel = kernel_tmp[0];
		1: kernel = kernel_tmp[1]; 
		2: kernel = kernel_tmp[2]; 
		3: kernel = kernel_tmp[3];
		4: kernel = kernel_tmp[4]; 
		5: kernel = kernel_tmp[5]; 
		6: kernel = kernel_tmp[6]; 
		7: kernel = kernel_tmp[7]; 
		8: kernel = kernel_tmp[8]; 
		default: kernel = 'd0; 
		endcase
	end
	SUB_STATE_RIGHT: begin
		case( inner_cnt )
		0: kernel = kernel_tmp[0];
		1: kernel = kernel_tmp[1];
		2: kernel = kernel_tmp[3]; 
		3: kernel = kernel_tmp[4]; 
		4: kernel = kernel_tmp[6]; 
		5: kernel = kernel_tmp[7]; 
		default: kernel = 'd0; 
		endcase
	end
	SUB_STATE_LEFT_DOWN: begin 
		case( inner_cnt )
		0: kernel = kernel_tmp[1]; 
		1: kernel = kernel_tmp[2]; 
		2: kernel = kernel_tmp[4]; 
		3: kernel = kernel_tmp[5]; 
		default: kernel = 'd0; 
		endcase
	end
	SUB_STATE_DOWN: begin // including RIGHT_DOWN corner case
		case( inner_cnt )
		0: kernel = kernel_tmp[0]; 
		1: kernel = kernel_tmp[1]; 
		2: kernel = kernel_tmp[2]; 
		3: kernel = kernel_tmp[3]; 
		4: kernel = kernel_tmp[4]; 
		5: kernel = kernel_tmp[5]; 
		default: kernel = 'd0; 
		endcase
	end
	SUB_STATE_RIGHT_DOWN: begin
		case( inner_cnt )
		0: kernel = kernel_tmp[0]; 
		1: kernel = kernel_tmp[1]; 
		2: kernel = kernel_tmp[3]; 
		3: kernel = kernel_tmp[4];
		default: kernel = 'd0; 
		endcase
	end
	default: kernel = 'd0; 
	endcase
end

always@( * ) begin
	if( cur_state == STATE_CROSS ) begin
		case( cur_cross_state ) 
		SUB_STATE_LEFT_TOP: begin
			case( inner_cnt )
			0: cross_cnt = ans_addr+1;
			1: cross_cnt = ans_addr+size;
			2: cross_cnt = ans_addr+size+1;				
			3: cross_cnt = ans_addr;				
			default: cross_cnt = 0;
			endcase
		end
		SUB_STATE_TOP: begin
			case( inner_cnt )
			0: cross_cnt = ans_addr;				
			1: cross_cnt = ans_addr+1;				
			2: cross_cnt = ans_addr+size-1;				
			3: cross_cnt = ans_addr+size;				
			4: cross_cnt = ans_addr+size+1;								
			5: cross_cnt = ans_addr;
			default: cross_cnt = ans_addr;
			endcase
		end
		SUB_STATE_RIGHT_TOP: begin
			case( inner_cnt )
			0: cross_cnt = ans_addr;
			1: cross_cnt = ans_addr+size-1;
			2: cross_cnt = ans_addr+size;
			3: cross_cnt = ans_addr;
			default: cross_cnt = 0;			
			endcase
		end
		SUB_STATE_LEFT: begin
			case( inner_cnt )
			0: cross_cnt = ans_addr-size+1;
			1: cross_cnt = ans_addr;
			2: cross_cnt = ans_addr+1;
			3: cross_cnt = ans_addr+size;
			4: cross_cnt = ans_addr+size+1;
			5: cross_cnt = ans_addr;
			default: cross_cnt = ans_addr-size;
			endcase			
		end
		SUB_STATE_MID: begin				
			case( inner_cnt ) 
			0: cross_cnt = ans_addr-size;
			1: cross_cnt = ans_addr-size+1;
			2: cross_cnt = ans_addr-1;
			3: cross_cnt = ans_addr;
			4: cross_cnt = ans_addr+1;
			5: cross_cnt = ans_addr+size-1;
			6: cross_cnt = ans_addr+size;
			7: cross_cnt = ans_addr+size+1;
			8: cross_cnt = ans_addr;
			default: cross_cnt = ans_addr-size;
			endcase
		end
		SUB_STATE_RIGHT: begin	
			case( inner_cnt )
			0: cross_cnt = ans_addr-size;
			1: cross_cnt = ans_addr-1;
			2: cross_cnt = ans_addr;
			3: cross_cnt = ans_addr+size-1;
			4: cross_cnt = ans_addr+size;
			5: cross_cnt = ans_addr;
			default: cross_cnt = ans_addr-size+1;
			endcase
		end
		SUB_STATE_LEFT_DOWN: begin 
			case( inner_cnt )
			0: cross_cnt = ans_addr-size+1;
			1: cross_cnt = ans_addr;
			2: cross_cnt = ans_addr+1;
			3: cross_cnt = ans_addr;
			default: cross_cnt = ans_addr-size;
			endcase
		end
		SUB_STATE_DOWN: begin 
			case( inner_cnt )
			0: cross_cnt = ans_addr-size;
			1: cross_cnt = ans_addr-size+1;
			2: cross_cnt = ans_addr-1;
			3: cross_cnt = ans_addr;
			4: cross_cnt = ans_addr+1;
			5: cross_cnt = ans_addr;
			default: cross_cnt = ans_addr-size;
			endcase
		end
		SUB_STATE_RIGHT_DOWN: begin
			case( inner_cnt )
			0: cross_cnt = ans_addr-size;
			1: cross_cnt = ans_addr-1;
			2: cross_cnt = ans_addr;
			3: cross_cnt = ans_addr;
			default: cross_cnt = 0;
			endcase
		end
		default: cross_cnt = 0;
		endcase
	end
	/*else if( cur_state == STATE_BEFORE ) begin
		case(flip_tmp)
		0,7,8,15: cross_cnt = 0;
		1,5,10,14: cross_cnt = size - 1;
		2,6,9,13: cross_cnt = size * ( size - 1 );
		3,4,11,12: cross_cnt = size * size - 1;
		default: cross_cnt = 0;
		endcase
	end*/
	else cross_cnt = 0;
end

assign mul = img_data3 * kernel;

always@( posedge clk or negedge rst_n ) begin
	if( !rst_n ) ans_input <= 0;
	else if( cur_state == STATE_CROSS ) begin
		if( inner_cnt == 0 ) ans_input <= mul;
		else ans_input <= ans_input + mul ;
	end
end

// ANSWER SRAM
ANS_MEM_100MHz ANSWER(.Q(ans_data), .CLK(clk), .CEN(1'b0), .WEN(ans_wen), .A(ans_addr), .D(ans_input), .OEN(1'b0));

assign ans_wen = ( finish_cross )? 1'b0 : 1'b1; 

//================================================================
//	PRE_OUTPUT
//================================================================ 
always@( * ) begin
	if( size == 4 ) tmp_ans_addr = ( ans_addr == 0 )? 8'd15: ans_addr - 1;
	else if( size == 8 ) tmp_ans_addr = ( ans_addr == 0 )? 8'd63: ans_addr - 1;
	// size == 16
	else tmp_ans_addr = ( ans_addr == 0 )? 8'd255: ans_addr - 1;
end

always@( posedge clk or negedge rst_n ) begin
	if( !rst_n ) begin
		max_value <= 0;	max_y <= 0;	max_x <= 0;	
	end
	else if( cur_state == STATE_CROSS && inner_cnt == 0 ) begin
		if( ans_addr == 1 ) begin
			max_value <= ans_data; max_y <= 0;	max_x <= 0;	
		end
		else begin
			if( max_value < ans_data ) begin
				max_value <= ans_data; 
				max_y <= tmp_ans_addr % size;
				max_x <= tmp_ans_addr / size;
			end
		end
	end	
end

always@( posedge clk or negedge rst_n ) begin
	if( !rst_n ) begin
		max_pos <= 0; pos_type <= SUB_STATE_LEFT_TOP;
	end
	else if( cur_state == STATE_CROSS && inner_cnt == 0 ) begin
		if( ans_addr == 1 ) begin
			max_pos <= 0; pos_type <= SUB_STATE_LEFT_TOP;
		end
		else begin
			if( max_value < ans_data ) begin
				pos_type <= previous_cross_state; 
				case( previous_cross_state )
				SUB_STATE_LEFT_TOP: 				 max_pos <= tmp_ans_addr;
				SUB_STATE_TOP, SUB_STATE_RIGHT_TOP:	 max_pos <= tmp_ans_addr - 1;
				SUB_STATE_LEFT, SUB_STATE_LEFT_DOWN: max_pos <= tmp_ans_addr - size;
				SUB_STATE_MID, SUB_STATE_RIGHT, SUB_STATE_DOWN, SUB_STATE_RIGHT_DOWN : 	
						max_pos <= tmp_ans_addr - size - 1;
				endcase
			end
		end
	end	
end
always@( posedge clk or negedge rst_n ) begin
	if( !rst_n ) previous_cross_state <= 9;
	else previous_cross_state <= cur_cross_state;
end

always@( posedge clk or negedge rst_n ) begin
	if( !rst_n ) flag_cross_finish <= 1'b0;
	else  flag_cross_finish <= ( cur_cross_state == SUB_STATE_RIGHT_DOWN && finish_cross )? 1'b1: 1'b0;
end

always@( posedge clk or negedge rst_n ) begin
	if( !rst_n ) flag_output <= 0;
	else begin
		if( size == 4 ) 		flag_output <= ans_addr == 15;
		else if( size == 8 ) 	flag_output <= ans_addr == 63;
		//size == 16
		else 				 	flag_output <= ans_addr == 255;
	end
end
//================================================================
//	OUTPUT
//================================================================
always@( posedge clk or negedge rst_n ) begin
	if( !rst_n ) out_valid <= 0;
	else out_valid <= cur_state == STATE_OUTPUT ; 
end

always@( posedge clk or negedge rst_n ) begin
	if( !rst_n ) begin
		out_x <= 0;
		out_y <= 0;
	end
	else if( cur_state == STATE_OUTPUT ) begin
		out_x <= max_x;
		out_y <= max_y;
	end
end

always@( posedge clk or negedge rst_n ) begin
	if( !rst_n ) out_img_pos <= 0;
	else if( cur_state == STATE_OUTPUT ) begin
		case( pos_type )
		SUB_STATE_LEFT_TOP: begin
			case( ans_addr ) 
			1: out_img_pos <= max_pos;
			2: out_img_pos <= out_img_pos+1;
			3: out_img_pos <= max_pos+size;
			4: out_img_pos <= out_img_pos+1;
			default: out_img_pos <= 0;
			endcase
		end
		SUB_STATE_TOP: begin
			case( ans_addr ) 
			1: out_img_pos <= max_pos;
			2: out_img_pos <= out_img_pos+1;
			3: out_img_pos <= out_img_pos+1;
			4: out_img_pos <= max_pos+size;
			5: out_img_pos <= out_img_pos+1;
			6: out_img_pos <= out_img_pos+1;
			default: out_img_pos <= 0;
			endcase
		end
		SUB_STATE_RIGHT_TOP: begin
			case( ans_addr ) 
			1: out_img_pos <= max_pos;
			2: out_img_pos <= out_img_pos+1;
			3: out_img_pos <= max_pos+size;
			4: out_img_pos <= out_img_pos+1;
			default: out_img_pos <= 0;
			endcase
		end
		SUB_STATE_LEFT: begin
			case( ans_addr ) 
			1: out_img_pos <= max_pos;
			2: out_img_pos <= out_img_pos+1;
			3: out_img_pos <= max_pos+size;
			4: out_img_pos <= out_img_pos+1;
			5: out_img_pos <= max_pos+size+size;
			6: out_img_pos <= out_img_pos+1;
			default: out_img_pos <= 0;
			endcase
		end
		SUB_STATE_MID: begin
			case( ans_addr ) 
			1: out_img_pos <= max_pos;
			2: out_img_pos <= out_img_pos+1;
			3: out_img_pos <= out_img_pos+1;
			4: out_img_pos <= max_pos+size;
			5: out_img_pos <= out_img_pos+1;
			6: out_img_pos <= out_img_pos+1;
			7: out_img_pos <= max_pos+size+size;
			8: out_img_pos <= out_img_pos+1;
			9: out_img_pos <= out_img_pos+1;
			default: out_img_pos <= 0;
			endcase
		end
		SUB_STATE_RIGHT: begin
			case( ans_addr ) 
			1: out_img_pos <= max_pos;
			2: out_img_pos <= out_img_pos+1;
			3: out_img_pos <= max_pos+size;
			4: out_img_pos <= out_img_pos+1;
			5: out_img_pos <= max_pos+size+size;
			6: out_img_pos <= out_img_pos+1;
			default: out_img_pos <= 0;
			endcase
		end
		SUB_STATE_LEFT_DOWN: begin
			case( ans_addr ) 
			1: out_img_pos <= max_pos;
			2: out_img_pos <= out_img_pos+1;
			3: out_img_pos <= max_pos+size;
			4: out_img_pos <= out_img_pos+1;
			default: out_img_pos <= 0;
			endcase
		end
		SUB_STATE_DOWN: begin
			case( ans_addr ) 
			1: out_img_pos <= max_pos;
			2: out_img_pos <= out_img_pos+1;
			3: out_img_pos <= out_img_pos+1;
			4: out_img_pos <= max_pos+size;
			5: out_img_pos <= out_img_pos+1;
			6: out_img_pos <= out_img_pos+1;
			default: out_img_pos <= 0;
			endcase
		end
		SUB_STATE_RIGHT_DOWN: begin
			case( ans_addr ) 
			1: out_img_pos <= max_pos;
			2: out_img_pos <= out_img_pos+1;
			3: out_img_pos <= max_pos+size;
			4: out_img_pos <= out_img_pos+1;
			default: out_img_pos <= 0;
			endcase
		end
		endcase		
	end
end

always@( posedge clk or negedge rst_n ) begin
	if( !rst_n ) out_value <= 0;
	else if( cur_state == STATE_OUTPUT ) out_value <= ans_data;
end

//================================================================
//	FSM
//================================================================
// global state
always@( posedge clk or negedge rst_n ) begin
	if( !rst_n ) cur_state <= STATE_IDLE;
	else cur_state <= nx_state;
end
always@( * ) begin
	case( cur_state ) 
	STATE_IDLE: begin
		if( flag == 1'b1 && in_valid_2 == 1'b0 ) begin
			case( act[0] ) 
			0: nx_state = STATE_BEFORE;
			1: nx_state = STATE_POOLING;
			2,3,4,5: nx_state = STATE_FLIP;
			6: nx_state = STATE_ZOOMIN;
			7: nx_state = STATE_ADJUST;
			default: nx_state = STATE_IDLE;
			endcase
		end
		else nx_state = STATE_IDLE;
	end
	STATE_CROSS: nx_state = ( flag_cross_finish )? STATE_OUTPUT : STATE_CROSS ; 
	STATE_BEFORE: begin
		if( cur_act == 0 ) nx_state = STATE_CROSS;
		else if( cur_act == 7 ) nx_state = STATE_ADJUST;
		else nx_state = STATE_FLIP;
		
	end
	STATE_ZOOMIN:begin
		if( flag_zoom_finish ) begin
			case( act[0] ) 
			0: nx_state = STATE_BEFORE;
			1: nx_state = STATE_POOLING;
			2,3,4,5: nx_state = STATE_FLIP;
			6: nx_state = STATE_ZOOMIN;
			7: nx_state = STATE_ADJUST;
			default: nx_state = STATE_IDLE;
			endcase
		end
		else nx_state = STATE_ZOOMIN;
	end
	STATE_FLIP: begin
		if( flag_flip_finish ) begin
			case( act[0] ) 
			0: nx_state = STATE_BEFORE;
			1: nx_state = STATE_POOLING;
			2,3,4,5: nx_state = STATE_BEFORE;
			6: nx_state = STATE_ZOOMIN;
			7: nx_state = STATE_ADJUST;
			default: nx_state = STATE_IDLE;
			endcase
		end
		else nx_state = STATE_FLIP;
	end
	STATE_ADJUST: begin 
		if( flag_adj_finish ) begin
			case( act[0] ) 
			0: nx_state = STATE_BEFORE;
			1: nx_state = STATE_POOLING;
			2,3,4,5: nx_state = STATE_FLIP;
			6: nx_state = STATE_ZOOMIN;
			7: nx_state = STATE_BEFORE;
			default: nx_state = STATE_IDLE;
			endcase
		end
		else nx_state = STATE_ADJUST;
	end
	STATE_POOLING: begin
		if( flag_pool_finish ) begin
			case( act[0] ) 
			0: nx_state = STATE_BEFORE;
			1: nx_state = STATE_POOLING;
			2,3,4,5: nx_state = STATE_FLIP;
			6: nx_state = STATE_ZOOMIN;
			7: nx_state = STATE_ADJUST;
			default: nx_state = STATE_IDLE;
			endcase   
		end
		else nx_state = STATE_POOLING;
	end
	STATE_OUTPUT: nx_state = ( flag_output )? STATE_IDLE: STATE_OUTPUT;
	default: nx_state = STATE_IDLE;
	endcase
end
// input state 
always@( posedge clk or negedge rst_n ) begin
	if( !rst_n ) cur_input_state <= SUB_STATE_WAIT;
	else cur_input_state <= nx_input_state;
end
always@( * ) begin
	case( cur_input_state ) 
	SUB_STATE_WAIT: nx_input_state = ( in_valid )? SUB_STATE_INPUT : SUB_STATE_WAIT ;
	SUB_STATE_INPUT: nx_input_state = ( !in_valid )? SUB_STATE_WAIT : SUB_STATE_INPUT;
	endcase
end
// cross state
always@( posedge clk or negedge rst_n ) begin
	if( !rst_n ) cur_cross_state <= SUB_STATE_LEFT_TOP;
	else cur_cross_state <= nx_cross_state;
end
always@( * ) begin
	if( finish_cross ) begin
		case( cur_cross_state ) 
		SUB_STATE_LEFT_TOP: nx_cross_state = ( cur_state == STATE_CROSS )? SUB_STATE_TOP : SUB_STATE_LEFT_TOP ;
		SUB_STATE_TOP: begin
			if( size == 4 ) 	 nx_cross_state = ( ans_addr[1:0] == 2'd2 )? SUB_STATE_RIGHT_TOP : SUB_STATE_TOP ;
			else if( size == 8 ) nx_cross_state = ( ans_addr[2:0] == 3'd6 )? SUB_STATE_RIGHT_TOP : SUB_STATE_TOP ;
			// size == 16
			else nx_cross_state = ( ans_addr[3:0] == 4'd14 )? SUB_STATE_RIGHT_TOP : SUB_STATE_TOP ; 
		end
		SUB_STATE_RIGHT_TOP: nx_cross_state = SUB_STATE_LEFT;
		SUB_STATE_LEFT: nx_cross_state = SUB_STATE_MID;
		SUB_STATE_MID: begin
			if( size == 4 ) 	 nx_cross_state = ( ans_addr[1:0] == 2'd2 )? SUB_STATE_RIGHT : SUB_STATE_MID ;
			else if( size == 8 ) nx_cross_state = ( ans_addr[2:0] == 3'd6 )? SUB_STATE_RIGHT : SUB_STATE_MID ;
			// size == 16
			else nx_cross_state = ( ans_addr[3:0] == 4'd14 )? SUB_STATE_RIGHT : SUB_STATE_MID ; 
		end
		SUB_STATE_RIGHT: begin
			if( size == 4 )  nx_cross_state = ( ans_addr == 11 )? SUB_STATE_LEFT_DOWN : SUB_STATE_LEFT ;
			else if( size == 8 ) nx_cross_state = ( ans_addr == 55 )? SUB_STATE_LEFT_DOWN : SUB_STATE_LEFT ;
			// size == 16 
			else nx_cross_state = ( ans_addr == 239 )? SUB_STATE_LEFT_DOWN : SUB_STATE_LEFT ;
		end
		SUB_STATE_LEFT_DOWN: nx_cross_state = SUB_STATE_DOWN;
		SUB_STATE_DOWN: begin // including RIGHT_DOWN corner case
			if( size == 4 ) 	 nx_cross_state = ( ans_addr[1:0] == 2'd2 )? SUB_STATE_RIGHT_DOWN : SUB_STATE_DOWN ;
			else if( size == 8 ) nx_cross_state = ( ans_addr[2:0] == 3'd6 )? SUB_STATE_RIGHT_DOWN : SUB_STATE_DOWN ;
			// size == 16
			else nx_cross_state = ( ans_addr[3:0] == 4'd14 )? SUB_STATE_RIGHT_DOWN : SUB_STATE_DOWN ; 
		end
		SUB_STATE_RIGHT_DOWN: nx_cross_state = SUB_STATE_LEFT_TOP;
		default: nx_cross_state = SUB_STATE_LEFT_TOP;
		endcase
	end
	else nx_cross_state = cur_cross_state;
end
// adjustment state
always@( posedge clk or negedge rst_n ) begin
	if( !rst_n ) cur_adjust_state <= SUB_STATE_READ;
	else cur_adjust_state <= nx_adjust_state;
end
always@( * ) begin
	case( cur_adjust_state ) 
	SUB_STATE_READ: nx_adjust_state = ( cur_state == STATE_ADJUST && !flag_adj_finish )? SUB_STATE_WRITE : SUB_STATE_READ ;
	SUB_STATE_WRITE: nx_adjust_state = SUB_STATE_READ;
	default: nx_adjust_state = SUB_STATE_READ;
	endcase
end
// zoom-in state
always@( posedge clk or negedge rst_n ) begin
	if( !rst_n ) cur_zoom_state <= SUB_STATE_READ;
	else cur_zoom_state <= nx_zoom_state;
end
always@( * ) begin
	case( cur_zoom_state ) 
	SUB_STATE_READ: nx_zoom_state = ( cur_state == STATE_ZOOMIN && !flag_zoom_finish )? SUB_STATE_DELAY : SUB_STATE_READ ;
	SUB_STATE_DELAY: nx_zoom_state = SUB_STATE_WRITE;
	SUB_STATE_WRITE: nx_zoom_state = ( zoom_output_cnt == 2'd3 )? SUB_STATE_READ : SUB_STATE_WRITE;
	default: nx_zoom_state = SUB_STATE_READ;
	endcase
end
// max pooling state
always@( posedge clk or negedge rst_n ) begin
	if( !rst_n ) cur_pooling_state <= SUB_STATE_READ;
	else cur_pooling_state <= nx_pooling_state;
end
always@( * ) begin
	case( cur_pooling_state ) 
	SUB_STATE_READ: nx_pooling_state = ( cur_state == STATE_POOLING && !flag_pool_finish )? SUB_STATE_READ2 : SUB_STATE_READ ;
	SUB_STATE_READ2: nx_pooling_state = SUB_STATE_READ3;
	SUB_STATE_READ3: nx_pooling_state = SUB_STATE_READ4;
	SUB_STATE_READ4: nx_pooling_state = SUB_STATE_READ5;
	SUB_STATE_READ5: nx_pooling_state = SUB_STATE_DELAY;
	SUB_STATE_DELAY: nx_pooling_state = SUB_STATE_WRITE;
	SUB_STATE_WRITE: nx_pooling_state = SUB_STATE_READ ;
	default: nx_pooling_state = SUB_STATE_READ;
	endcase
end
//flip state
always@( posedge clk or negedge rst_n ) begin
	if( !rst_n ) cur_flip_state <= SUB_STATE_READ;
	else cur_flip_state <= nx_flip_state;
end
always@( * ) begin
	case( cur_flip_state ) 
	SUB_STATE_READ: nx_flip_state = ( cur_state == STATE_FLIP && !flag_flip_finish )? SUB_STATE_WRITE : SUB_STATE_READ ;
	SUB_STATE_WRITE: nx_flip_state = SUB_STATE_READ;
	endcase
end

endmodule
