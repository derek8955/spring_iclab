//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   2021 ICLAB Spring Course
//   Lab03			: Sudoku (SD)
//   Author         : Yao Zhan Xu (xuyaozha8905@gmail.com)
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   File Name   : SD.v
//   Module Name : SD
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

module SD(
    // Input signals
    clk,
    rst_n,
	in_valid,
	in,
    // Output signals
    out_valid,
    out
);
//================================================================
//  INPUT AND OUTPUT DECLARATION                         
//================================================================
input clk, rst_n, in_valid;
input [3:0] in;
output reg out_valid;
output reg [3:0] out;
//================================================================
//  integer / genvar / parameters
//================================================================
integer i, j;
genvar idx, jdx, zdx;

parameter IDLE    = 2'd0, 
          FORWARD = 2'd1,
		  BAKWARD = 2'd2,
		  OUTPUT  = 2'd3;
//================================================================
//   Wires & Registers 
//================================================================
//FSM
reg [1:0] cur_state; //current state
reg [1:0] nx_state; // next state 
//input
reg [6:0] in_cnt; // input counter
reg [3:0] grid[0:8][0:8]; // 9*9 sudoku
reg [3:0] space_x[15:0], space_y[15:0]; // blank position
//IS_exist
wire IS_exist_row[1:9][0:8];
wire IS_exist_col[1:9][0:8];
wire IS_exist_square[1:9][0:8];
wire IS_exist[1:9];
reg [3:0] cur_square;
//IS_legal
wire [3:0] row_status[1:9], col_status[1:9], square_status[1:9];
reg IS_legal;

reg [3:0] space_cnt;
reg [3:0] value;
reg [3:0] out_cnt;

//================================================================
//  INPUT
//================================================================

always@( posedge clk or negedge rst_n ) 
begin
	if ( !rst_n ) in_cnt <= 7'd0 ;
	else 
	begin
		if ( in_valid == 1'b1 )	in_cnt <= in_cnt + 1 ;
		else if ( nx_state == OUTPUT ) in_cnt <= 7'd0 ;
	end
end

always@( posedge clk or negedge rst_n ) 
begin
	if ( !rst_n ) begin
		for( i=0 ; i<9 ; i=i+1 )
			for( j=0 ; j<9 ; j=j+1 )
				grid[i][j] <= 4'd0 ;
	end
	else if ( nx_state == IDLE ) 
	begin
		if ( in_valid == 1'b1 ) 
		begin
			grid[8][8] <= in ;			
			for( i=0 ; i<9 ; i=i+1 )	
				for( j=0 ; j<8 ; j=j+1 )
					grid[i][j] <= grid[i][j+1] ;
			for( i=0 ; i<8 ; i=i+1 )	
				grid[i][8] <= grid[i+1][0] ;
		end
	end
	else if ( nx_state == FORWARD || nx_state == BAKWARD ) grid[space_x[space_cnt]][space_y[space_cnt]] <= value ;

end

always@( posedge clk or negedge rst_n ) 
begin
	if ( !rst_n ) begin
		for( i=0 ; i<16 ; i=i+1 ) 
		begin
			space_x[i] <= 0 ;
			space_y[i] <= 0 ;
		end
	end
	else if( nx_state == IDLE )
	begin
		space_x[0] <= 0 ;
		space_y[0] <= 0 ;
		if ( in_valid == 1'b1 && in == 4'd0 ) 
		begin
			space_x[1] <= in_cnt / 9;
			space_y[1] <= in_cnt % 9  ;
			for( i=2 ; i<16 ; i=i+1 ) 
			begin
				space_x[i] <= space_x[i-1] ;
				space_y[i] <= space_y[i-1] ;
			end
		end
	end
end
	
//================================================================
// 	space_cnt 
//================================================================
always@( posedge clk or negedge rst_n )
begin
	if ( !rst_n ) 	space_cnt <= 4'd15 ;
	else if ( nx_state == FORWARD ) space_cnt <= space_cnt - 1 ;
	else if ( nx_state == BAKWARD )	space_cnt <= space_cnt + 1 ;
	else if ( nx_state == OUTPUT ) space_cnt <= 4'd15;
end

//================================================================
// 	IS_exist
//================================================================
always@( * ) 
begin
	if ( IS_exist[1] == 1'b0 ) value = 4'd1;	
	else if ( IS_exist[2] == 1'b0 ) value = 4'd2;
	else if ( IS_exist[3] == 1'b0 ) value = 4'd3;
	else if ( IS_exist[4] == 1'b0 ) value = 4'd4;
	else if ( IS_exist[5] == 1'b0 ) value = 4'd5;
	else if ( IS_exist[6] == 1'b0 ) value = 4'd6;
	else if ( IS_exist[7] == 1'b0 ) value = 4'd7;
	else if ( IS_exist[8] == 1'b0 ) value = 4'd8;
	else if ( IS_exist[9] == 1'b0 ) value = 4'd9;
	else value = 4'd0;	
end

generate
	for( zdx=1 ; zdx<10 ; zdx=zdx+1 ) 
		assign IS_exist[zdx] = ( grid[space_x[space_cnt]][space_y[space_cnt]] >= zdx ) || IS_exist_row[zdx][space_x[space_cnt]] || IS_exist_col[zdx][space_y[space_cnt]] || IS_exist_square[zdx][ cur_square ];*+
		
endgenerate

always@( * )
begin
	if( space_x[ space_cnt ] < 3 ) 
	begin
		if( space_y[ space_cnt ] < 3 ) cur_square = 0;
		else if( space_y[ space_cnt ] < 6 ) cur_square = 1;
		else cur_square = 2;
	end
	else if( space_x[ space_cnt ] < 6 ) 
	begin
		if( space_y[ space_cnt ] < 3 ) cur_square = 3;
		else if( space_y[ space_cnt ] < 6 ) cur_square = 4;
		else cur_square = 5;
	end
	else 
	begin
		if( space_y[ space_cnt ] < 3 ) cur_square = 6;
		else if( space_y[ space_cnt ] < 6 ) cur_square = 7;
		else cur_square = 8;
	end
end

generate
	for( zdx=1 ; zdx<10 ; zdx=zdx+1 ) 
	begin
		for( idx=0 ; idx<9 ; idx=idx+1 )
			assign IS_exist_row[zdx][idx] = ( grid[idx][0] == zdx ) || ( grid[idx][1] == zdx ) || ( grid[idx][2] == zdx ) ||
										    ( grid[idx][3] == zdx ) || ( grid[idx][4] == zdx ) || ( grid[idx][5] == zdx ) ||
										    ( grid[idx][6] == zdx ) || ( grid[idx][7] == zdx ) || ( grid[idx][8] == zdx );
		for( jdx=0 ; jdx<9 ; jdx=jdx+1 )
			assign IS_exist_col[zdx][jdx] = ( grid[0][jdx] == zdx ) || ( grid[1][jdx] == zdx) || ( grid[2][jdx] == zdx) ||
										    ( grid[3][jdx] == zdx ) || ( grid[4][jdx] == zdx) || ( grid[5][jdx] == zdx) ||
										    ( grid[6][jdx] == zdx ) || ( grid[7][jdx] == zdx) || ( grid[8][jdx] == zdx);
		for( idx=0 ; idx<7 ; idx=idx+3 ) // 0、3、6
			begin
				for( jdx=0 ; jdx<7 ; jdx=jdx+3 ) // 0、3、6
					assign IS_exist_square[ zdx ][ idx+jdx/3 ] = ( grid[idx][jdx] == zdx ) || ( grid[idx][jdx+1] == zdx ) || ( grid[idx][jdx+2] == zdx ) ||
														         ( grid[idx+1][jdx] == zdx ) || ( grid[idx+1][jdx+1] == zdx ) || ( grid[idx+1][jdx+2] == zdx ) ||
														         ( grid[idx+2][jdx] == zdx ) || ( grid[idx+2][jdx+1] == zdx ) || ( grid[idx+2][jdx+2] == zdx );
			end
	end
endgenerate

//================================================================
//  IS_legal
//================================================================
generate
	for( zdx=1 ; zdx<10 ; zdx=zdx+1 ) 
	begin
		assign row_status[zdx] =    ( IS_exist_row[zdx][0] == 0 ) || ( IS_exist_row[zdx][1] == 0 ) || ( IS_exist_row[zdx][2] == 0 ) ||
									( IS_exist_row[zdx][3] == 0 ) || ( IS_exist_row[zdx][4] == 0 ) || ( IS_exist_row[zdx][5] == 0 ) ||
									( IS_exist_row[zdx][6] == 0 ) || ( IS_exist_row[zdx][7] == 0 ) || ( IS_exist_row[zdx][8] == 0 );
		assign col_status[zdx] =    ( IS_exist_col[zdx][0] == 0 ) || ( IS_exist_col[zdx][1] == 0 ) || ( IS_exist_col[zdx][2] == 0 ) ||
									( IS_exist_col[zdx][3] == 0 ) || ( IS_exist_col[zdx][4] == 0 ) || ( IS_exist_col[zdx][5] == 0 ) ||
									( IS_exist_col[zdx][6] == 0 ) || ( IS_exist_col[zdx][7] == 0 ) || ( IS_exist_col[zdx][8] == 0 );
		assign square_status[zdx] = ( IS_exist_square[zdx][0] == 0 ) || ( IS_exist_square[zdx][1] == 0 ) || ( IS_exist_square[zdx][2] == 0 ) ||
									( IS_exist_square[zdx][3] == 0 ) || ( IS_exist_square[zdx][4] == 0 ) || ( IS_exist_square[zdx][5] == 0 ) ||
									( IS_exist_square[zdx][6] == 0 ) || ( IS_exist_square[zdx][7] == 0 ) || ( IS_exist_square[zdx][8] == 0 );
	end
endgenerate

always@( * )
begin
	if( row_status[1] || col_status[1] || square_status[1] ) IS_legal = 1'b0;
	else if( row_status[2] || col_status[2] || square_status[2] ) IS_legal = 1'b0;
	else if( row_status[3] || col_status[3] || square_status[3] ) IS_legal = 1'b0;
	else if( row_status[4] || col_status[4] || square_status[4] ) IS_legal = 1'b0;
	else if( row_status[5] || col_status[5] || square_status[5] ) IS_legal = 1'b0;
	else if( row_status[6] || col_status[6] || square_status[6] ) IS_legal = 1'b0;
	else if( row_status[7] || col_status[7] || square_status[7] ) IS_legal = 1'b0;
	else if( row_status[8] || col_status[8] || square_status[8] ) IS_legal = 1'b0;
	else if( row_status[9] || col_status[9] || square_status[9] ) IS_legal = 1'b0;
	else IS_legal = 1'b1;
end

//================================================================
//  PRE_OUTPUT
//================================================================
always@( posedge clk or negedge rst_n ) 
begin
	if ( !rst_n ) out_cnt <= 4'd15 ;
	else if ( nx_state == IDLE ) out_cnt <= 4'd15;
	else if ( nx_state == OUTPUT ) out_cnt <= out_cnt - 1;
end

//================================================================
//  OUTPUT : out_valid & out
//================================================================
always@( posedge clk or negedge rst_n ) 
begin
	if ( !rst_n ) out_valid <= 1'b0;
	else if ( nx_state == OUTPUT )	out_valid <= 1'b1;
	else out_valid <= 1'b0;
end

always@( posedge clk or negedge rst_n ) 
begin
	if ( !rst_n ) out <= 4'd0;
	else if ( nx_state == OUTPUT) 
	begin
		if ( IS_legal == 1'b0 ) out <= 4'd1 0;
		else out <= grid[ space_x[out_cnt] ][ space_y[out_cnt] ];
	end
	else out <= 4'd0;
end

//================================================================
//  FSM
//================================================================
always@( posedge clk or negedge rst_n ) 
begin
	if ( !rst_n ) cur_state <= IDLE ;
	else cur_state <= nx_state ;
end

always@( * ) 
begin
	case( cur_state )
	IDLE: 
	begin
		if ( in_cnt == 7'd81 ) nx_state = FORWARD;
		else nx_state = IDLE;
	end
	FORWARD: 
	begin
		if ( space_cnt == 4'd0 ) nx_state = OUTPUT;
		else if ( value == 4'd0 )	nx_state = BAKWARD;
		else nx_state = FORWARD ;
	end
	BAKWARD: 
	begin
		if ( space_cnt == 4'd0 ) nx_state = OUTPUT;
		else if ( value == 4'd0 ) nx_state = BAKWARD;
		else nx_state = FORWARD;
	end		
	OUTPUT: 
	begin
		if ( IS_legal==1'b0 || out_cnt==4'd0 ) nx_state = IDLE;
		else nx_state = OUTPUT;
	end
	endcase
end

endmodule