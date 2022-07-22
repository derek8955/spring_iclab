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
parameter STATE_IDLE = 3'd0,
		  STATE_CROSS = 3'd1,
		  STATE_POOLING = 3'd2,
		  STATE_HVFLIP = 3'd3,
		  STATE_LRFLIP = 3'd4,
		  STATE_ZOOMIN = 3'd5,
		  STATE_ADJUST = 3'd6,
		  STATE_OUTPUT = 3'd7;

// cur_state == STATE_IDLE	  
parameter SUB_STATE_WAIT = 1'b0, SUB_STATE_INPUT = 1'b1;
// cur_state == STATE_CROSS 
parameter SUB_STATE_LEFT_TOP = 3'd0, SUB_STATE_TOP = 3'd1, SUB_STATE_RIGHT_TOP = 3'd2, SUB_STATE_LEFT = 3'd3, 
		  SUB_STATE_MID = 3'd4, SUB_STATE_RIGHT = 3'd5, SUB_STATE_LEFT_DOWN = 3'd6, SUB_STATE_DOWN = 3'd7, SUB_STATE_RIGHT_DOWN = 4'd8;
integer i;
//================================================================
//   Wires & Registers 
//================================================================
// FSM
reg [2:0] cur_state, nx_state;
reg cur_input_state, nx_input_state; // cur_state == STATE_IDLE
reg [3:0] cur_cross_state, nx_cross_state; // cur_state == STATE_CROSS
//SRAM port
reg [7:0] img_addr;
wire img_wen; // write enable negative of image sram 
wire signed [15:0] img_data; // output or image sram  

//INPUT
reg [4:0] size; // 4*4 or 8*8 or 16*16
reg [2:0] act[0:15]; // action 
reg signed [15:0] kernel_tmp[0:8]; // template
reg signed [15:0] kernel;

reg [7:0] in_cnt; // image data counter 
reg [3:0] in2_cnt; // action data counter 

reg flag;// in_valid_2 flag 

//cross
reg [7:0] ans_addr;
reg [7:0] pos_img;
reg [3:0] inner_cnt; 

wire ans_wen;
wire signed [39:0] ans_data; // output or image sram  
reg signed  [39:0] ans_input;
wire signed  [39:0] mul;

reg finish_cross; // Is proccess done 
//pre_output
wire [7:0] tmp_ans_addr;
reg flag_cross_finish;

reg [3:0] max_x, max_y;
reg [7:0] max_pos;
reg signed [39:0] max_value;
// output
reg flag_output;
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
end

always@( posedge clk or negedge rst_n ) begin
	if( !rst_n ) begin
		for( i=0 ; i< 9 ; i=i+1 ) kernel_tmp[i] <= 0;
	end
	else if( in_valid && in_cnt < 9 ) kernel_tmp[in_cnt] <= template;
end

// IMAGE
IMG_MEM_100MHz IMAGE(.Q(img_data), .CLK(clk), .CEN(1'b0), .WEN(img_wen), .A(img_addr), .D(image), .OEN(1'b0));

assign img_wen = ( nx_input_state == SUB_STATE_WAIT )? 1'b1 : 1'b0;

always@( * ) begin
	case( cur_state ) 
	STATE_IDLE: img_addr = in_cnt;
	STATE_CROSS: img_addr = pos_img;
	default: img_addr = 0;
	endcase	
end

always@( posedge clk or negedge rst_n ) begin
	if( !rst_n ) in2_cnt <= 0;
	else if( in_valid_2 ) in2_cnt <= in2_cnt + 1;
	else in2_cnt <= 0;
end

always@( posedge clk or negedge rst_n ) begin
	if( !rst_n ) begin
		for( i=0 ; i<16 ; i=i+1 ) act[i] <= 0;
	end
	else if( in_valid_2 ) act[in2_cnt] <= action;
 end

always@( posedge clk or negedge rst_n ) begin
	if( !rst_n ) flag <= 0;
	else flag <= in_valid_2;
end

//================================================================
//	CROSS CORRELATION
//================================================================

always@( * ) begin
	case( cur_cross_state ) 
	SUB_STATE_LEFT_TOP, SUB_STATE_RIGHT_TOP, SUB_STATE_RIGHT_DOWN, SUB_STATE_LEFT_DOWN: 	  	finish_cross = ( inner_cnt == 4 )? 1'b1 : 1'b0 ;
	SUB_STATE_TOP, SUB_STATE_LEFT, SUB_STATE_RIGHT, SUB_STATE_DOWN:   							finish_cross = ( inner_cnt == 6 )? 1'b1 : 1'b0 ;
	SUB_STATE_MID: 													 							finish_cross = ( inner_cnt == 9 )? 1'b1 : 1'b0 ;
	endcase
end

always@( posedge clk or negedge rst_n ) begin
	if( !rst_n ) ans_addr <= 0;
	else if( nx_state == STATE_OUTPUT || ( cur_state == STATE_CROSS && finish_cross ) ) ans_addr <= ans_addr + 1;
end

always@( posedge clk or negedge rst_n ) begin
	if( !rst_n ) inner_cnt <= 0;
	else if( cur_state == STATE_CROSS ) begin
		if( !finish_cross )	inner_cnt <= inner_cnt + 1;
		else inner_cnt <= 0;
	end
end

always@( * ) begin
	case( cur_cross_state ) 
		SUB_STATE_LEFT_TOP: begin
			case( inner_cnt )
			0: begin
				kernel = kernel_tmp[4];	pos_img = ans_addr+1;
			end
			1: begin 
				kernel = kernel_tmp[5];	pos_img = ans_addr+size;
			end
			2: begin
				kernel = kernel_tmp[7];	pos_img = ans_addr+size+1;				
			end
			3: begin
				kernel = kernel_tmp[8];	pos_img = ans_addr;				
			end	
			default: begin
				kernel = 'd0; pos_img = 0;
			end
			endcase
		end
		SUB_STATE_TOP: begin
			case( inner_cnt )
			0: begin
				kernel = kernel_tmp[3]; pos_img = ans_addr;				
			end
			1: begin
				kernel = kernel_tmp[4]; pos_img = ans_addr+1;				
			end	
			2: begin
				kernel = kernel_tmp[5]; pos_img = ans_addr+size-1;				
			end	
			3: begin
				kernel = kernel_tmp[6];	pos_img = ans_addr+size;				
			end
			4: begin
				kernel = kernel_tmp[7]; pos_img = ans_addr+size+1;								
			end
			5: begin
				kernel = kernel_tmp[8];	pos_img = ans_addr;
			end
			default: begin
				kernel = 'd0; pos_img = ans_addr;
			end			
			endcase
		end
		SUB_STATE_RIGHT_TOP: begin
			case( inner_cnt )
			0: begin
				kernel = kernel_tmp[3];	pos_img = ans_addr;
			end
			1: begin
				kernel = kernel_tmp[4];	pos_img = ans_addr+size-1;
			end
			2: begin
				kernel = kernel_tmp[6];	pos_img = ans_addr+size;
			end
			3: begin
				kernel = kernel_tmp[7];	pos_img = ans_addr;
			end
			default: begin
				kernel = 'd0; pos_img = 0;
			end	
			endcase
		end
		SUB_STATE_LEFT: begin
			case( inner_cnt )
			0: begin
				kernel = kernel_tmp[1];	pos_img = ans_addr-size+1;
				end
			1: begin
				kernel = kernel_tmp[2];	pos_img = ans_addr;
			end
			2: begin
				kernel = kernel_tmp[4];	pos_img = ans_addr+1;
			end
			3: begin
				kernel = kernel_tmp[5];	pos_img = ans_addr+size;
			end
			4: begin
				kernel = kernel_tmp[7]; pos_img = ans_addr+size+1;
			end
			5: begin
				kernel = kernel_tmp[8];	pos_img = ans_addr;
			end
			default: begin
				kernel = 'd0; pos_img = ans_addr-size;
			end		
			endcase
		end
		SUB_STATE_MID: begin
			case( inner_cnt ) 
			0: begin
				kernel = kernel_tmp[0]; pos_img = ans_addr-size;
			end
			1: begin
				kernel = kernel_tmp[1]; pos_img = ans_addr-size+1;
			end
			2: begin
				kernel = kernel_tmp[2]; pos_img = ans_addr-1;
			end
			3: begin
				kernel = kernel_tmp[3]; pos_img = ans_addr;
			end
			4: begin
				kernel = kernel_tmp[4]; pos_img = ans_addr+1;
			end
			5: begin
				kernel = kernel_tmp[5]; pos_img = ans_addr+size-1;
			end
			6: begin
				kernel = kernel_tmp[6]; pos_img = ans_addr+size;
			end
			7: begin
				kernel = kernel_tmp[7]; pos_img = ans_addr+size+1;
			end
			8: begin
				kernel = kernel_tmp[8]; pos_img = ans_addr;
			end
			default: begin
				kernel = 'd0; pos_img = ans_addr-size;
			end		
			endcase
			
		end
		SUB_STATE_RIGHT: begin
			case( inner_cnt )
			0: begin
				kernel = kernel_tmp[0]; pos_img = ans_addr-size;
			end
			1: begin
				kernel = kernel_tmp[1]; pos_img = ans_addr-1;
			end
			2: begin
				kernel = kernel_tmp[3]; pos_img = ans_addr;
			end
			3:begin
				kernel = kernel_tmp[4]; pos_img = ans_addr+size-1;
			end
			4: begin
				kernel = kernel_tmp[6]; pos_img = ans_addr+size;
			end
			5: begin
				kernel = kernel_tmp[7]; pos_img = ans_addr;
			end
			default: begin
				kernel = 'd0; pos_img = ans_addr-size+1;
			end		
			endcase
		end
		SUB_STATE_LEFT_DOWN: begin 
			case( inner_cnt )
			0: begin
				kernel = kernel_tmp[1]; pos_img = ans_addr-size+1;
			end
			1: begin
				kernel = kernel_tmp[2]; pos_img = ans_addr;
			end
			2: begin
				kernel = kernel_tmp[4]; pos_img = ans_addr+1;
			end
			3: begin
				kernel = kernel_tmp[5]; pos_img = ans_addr;
			end
			default: begin
				kernel = 'd0; pos_img = ans_addr-size;
			end		
			endcase
		end
		SUB_STATE_DOWN: begin // including RIGHT_DOWN corner case
			case( inner_cnt )
			0: begin
				kernel = kernel_tmp[0]; pos_img = ans_addr-size;
			end
			1: begin
				kernel = kernel_tmp[1]; pos_img = ans_addr-size+1;
			end
			2: begin
				kernel = kernel_tmp[2]; pos_img = ans_addr-1;
			end
			3: begin
				kernel = kernel_tmp[3]; pos_img = ans_addr;
			end
			4: begin
				kernel = kernel_tmp[4]; pos_img = ans_addr+1;
			end
			5: begin
				kernel = kernel_tmp[5]; pos_img = ans_addr;
			end
			default: begin
				kernel = 'd0; pos_img = ans_addr-size;
			end		
			endcase
		end
		SUB_STATE_RIGHT_DOWN: begin
			case( inner_cnt )
			0: begin
				kernel = kernel_tmp[0]; pos_img = ans_addr-size;
			end
			1: begin
				kernel = kernel_tmp[1]; pos_img = ans_addr-1;
			end
			2: begin
				kernel = kernel_tmp[3]; pos_img = ans_addr;
			end
			3: begin
				kernel = kernel_tmp[4]; pos_img = ans_addr;
			end
			default: begin
				kernel = 'd0; pos_img = 0;
			end		
			endcase
		end
		default: begin
			kernel = 'd0; pos_img = 0;
		end		
	endcase
end

assign mul = img_data * kernel;

always@( posedge clk or negedge rst_n ) begin
	if( !rst_n ) ans_input <= 0;
	else if( cur_state == STATE_CROSS ) begin
		if( inner_cnt == 0 ) ans_input <= mul;
		else ans_input <= ans_input + mul ;
	end
end

// ANSWER
ANS_MEM_100MHz ANSWER(.Q(ans_data), .CLK(clk), .CEN(1'b0), .WEN(ans_wen), .A(ans_addr), .D(ans_input), .OEN(1'b0));

assign ans_wen = ( finish_cross )? 1'b0 : 1'b1; 

//================================================================
//	PRE_OUTPUT
//================================================================
assign tmp_ans_addr = ans_addr - 1;

always@( posedge clk or negedge rst_n ) begin
	if( !rst_n ) begin
		max_value <= 0;	max_y <= 0;	max_x <= 0;	max_pos <= 0;
	end
	else if( cur_state == STATE_CROSS && inner_cnt == 0 ) begin
		if( max_value < ans_data ) begin
			max_value <= ans_data; 
			max_y <= tmp_ans_addr % size;
			max_x <= tmp_ans_addr / size;
			max_pos <= tmp_ans_addr - size - 1 ;
		end
	end
	else if( cur_state == STATE_IDLE ) begin
		max_value <= 0; max_y <= 0;	max_x <= 0;	max_pos <= 0;
	end
end
// Using for one clock cycle delay
always@( posedge clk or negedge rst_n ) begin
	if( !rst_n ) flag_cross_finish <= 1'b0;
	else  flag_cross_finish <= ( cur_cross_state == SUB_STATE_RIGHT_DOWN && finish_cross )? 1'b1: 1'b0;
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
end

always@( posedge clk or negedge rst_n ) begin
	if( !rst_n ) out_value <= 0;
	else if( cur_state == STATE_OUTPUT ) out_value <= ans_data;
end
//================================================================
//	flag_output
//================================================================
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
//	FSM
//================================================================
always@( posedge clk or negedge rst_n ) begin
	if( !rst_n ) cur_state <= STATE_IDLE;
	else cur_state <= nx_state;
end
always@( * ) begin
	case( cur_state ) 
	STATE_IDLE: nx_state = ( flag == 1'b1 && in_valid_2 == 1'b0 )? STATE_CROSS : STATE_IDLE;
	STATE_CROSS: nx_state = ( flag_cross_finish )? STATE_OUTPUT : STATE_CROSS ; 
	STATE_OUTPUT: nx_state = ( flag_output )? STATE_IDLE: STATE_OUTPUT;
	default: nx_state = STATE_IDLE;
	endcase

end
//input state 
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
//cross state
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
		endcase
	end
	else nx_cross_state = cur_cross_state;
end

endmodule
