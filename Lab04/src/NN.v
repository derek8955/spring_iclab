//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   2021 ICLAB Spring Course
//   Lab04			: Artificial Neural Network (NN)
//   Author         : Yao-Zhan Xu (xuyaozhan8905@gmail.com)
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   File Name   : NN.v
//   Module Name : NN
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################
// synopsys translate_off
`include "/usr/cad/synopsys/synthesis/2019.12/dw/sim_ver/DW_fp_mult.v"
`include "/usr/cad/synopsys/synthesis/2019.12/dw/sim_ver/DW_fp_add.v"
`include "/usr/cad/synopsys/synthesis/2019.12/dw/sim_ver/DW_fp_sub.v"
// synopsys translate_on

module NN(
	// Input signals
	clk,
	rst_n,
	in_valid_d,
	in_valid_t,
	in_valid_w1,
	in_valid_w2,
	data_point,
	target,
	weight1,
	weight2,
	// Output signals
	out_valid,
	out
);
//================================================================
//  parameters
//================================================================
// IEEE floating point paramenters
parameter inst_sig_width = 23;
parameter inst_exp_width = 8;
parameter inst_ieee_compliance = 0;
parameter inst_total_width = inst_sig_width + inst_exp_width;

//================================================================
//  INPUT AND OUTPUT DECLARATION                         
//================================================================
input  clk, rst_n, in_valid_d, in_valid_t, in_valid_w1, in_valid_w2;
input [inst_total_width:0] data_point, target;
input [inst_total_width:0] weight1, weight2;
output reg	out_valid;
output reg [inst_total_width:0] out;

//================================================================
//  integer / genvar / parameters
//================================================================
integer i;
genvar idx;

parameter LEARNING_RATE = 32'b0_0111_0101_00000110001001001101111 ;
//================================================================
//   Wires & Registers 
//================================================================
//  input
reg [1:0] in_cnt;
reg [3:0] weight1_cnt;
reg [1:0] weight2_cnt;
reg [inst_total_width:0] w1_r[0:11], w2_r[0:2];
reg [inst_total_width:0] s1_r[0:3], to_r;
reg flag;
//  pre_out
reg cur_stage [0:9];
//	forward
wire [inst_total_width:0] sw_1[0:11];
reg [inst_total_width:0] sw_1_r[0:11];

wire [inst_total_width:0] s2[0:2];
reg  [inst_total_width:0] s2_r[0:2];
wire [inst_total_width:0] y1_w[0:2];
reg  [inst_total_width:0] y1_r[0:2];

wire [inst_total_width:0] sw_2[0:2];
reg  [inst_total_width:0] sw_2_r[0:2];

wire [inst_total_width:0] y2;
reg  [inst_total_width:0] y2_r;
//	backward
wire [inst_total_width:0] delta2;
reg  [inst_total_width:0] delta2_r;
wire [inst_total_width:0] w2_delta2_w[0:2];
reg  [inst_total_width:0] w2_delta2_r[0:2];
wire [inst_total_width:0] delta1_w[0:2];
reg  [inst_total_width:0] delta1_r[0:2];

//	UPDATE
wire [inst_total_width:0] learn_s1[0:3];
reg  [inst_total_width:0] learn_s1_r[0:3];
wire [inst_total_width:0] learn_s2[0:2];
reg  [inst_total_width:0] learn_s2_r[0:2];

wire [inst_total_width:0] pre_new_w1_1[0:3], pre_new_w1_2[0:3], pre_new_w1_3[0:3];
reg  [inst_total_width:0] pre_new_w1_1r[0:3], pre_new_w1_2r[0:3], pre_new_w1_3r[0:3];

wire [inst_total_width:0] pre_new_w2[0:2];
reg  [inst_total_width:0] pre_new_w2_r[0:2];

wire [inst_total_width:0] new_w1[0:11];
wire [inst_total_width:0] new_w2[0:2];

//================================================================
//	FORWARD
//================================================================
generate 
for( idx=0 ; idx<4 ;idx=idx+1 )
begin
	fp_mult FOR_MULT_1_1( .a( s1_r[idx] ), .b( w1_r[idx] )  , .z( sw_1[idx] )   );
	fp_mult FOR_MULT_1_2( .a( s1_r[idx] ), .b( w1_r[idx+4] ), .z( sw_1[idx+4] ) );
	fp_mult FOR_MULT_1_3( .a( s1_r[idx] ), .b( w1_r[idx+8] ), .z( sw_1[idx+8] ) );
end
endgenerate

always@( posedge clk or negedge rst_n )
begin
	if( !rst_n ) 
	begin
		for( i=0; i< 12 ; i=i+1 ) sw_1_r[i] <= 0;
	end
	else if( cur_stage[3] )
	begin
		for( i=0; i< 12 ; i=i+1 ) sw_1_r[i] <= sw_1[i];
	end
end

fp_sum4 FOR_ADDER_1_1( .a( sw_1_r[0] ), .b( sw_1_r[1] ), .c( sw_1_r[2] ), .d( sw_1_r[3] ), .z( s2[0] ) );
fp_sum4 FOR_ADDER_1_2( .a( sw_1_r[4] ), .b( sw_1_r[5] ), .c( sw_1_r[6] ), .d( sw_1_r[7] ), .z( s2[1] ) );
fp_sum4 FOR_ADDER_1_3( .a( sw_1_r[8] ), .b( sw_1_r[9] ), .c( sw_1_r[10] ), .d( sw_1_r[11] ), .z( s2[2] ) );

generate
for( idx=0 ; idx<3 ; idx=idx+1 )
	always@( posedge clk or negedge rst_n )
	begin
		if (!rst_n) s2_r[idx] <= 0 ;
		else if( cur_stage[4] ) s2_r[idx] <= s2[idx];
	end	
endgenerate

generate
for( idx=0 ; idx<3 ; idx=idx+1 )
	assign y1_w[idx] = ( s2[idx][31] ) ? 0 : s2[idx];
endgenerate

generate
for( idx=0 ; idx<3 ; idx=idx+1 )
	always@( posedge clk or negedge rst_n )
	begin
		if ( !rst_n ) y1_r[idx] <= 0 ;
		else if( cur_stage[4] ) y1_r[idx] <= y1_w[idx];
	end
endgenerate

generate
for( idx=0 ; idx<3 ; idx=idx+1 )
	fp_mult MULT_h2( .a(w2_r[idx]), .b(y1_r[idx]), .z(sw_2[idx]) );
endgenerate

generate
for( idx=0 ; idx<3 ; idx=idx+1 )
	always@( posedge clk or negedge rst_n )
	begin
		if ( !rst_n ) sw_2_r[idx] <= 0 ;
		else if( cur_stage[5] ) sw_2_r[idx] <= sw_2[idx];
	end	
endgenerate

fp_sum3 SUM3_h2( .a( sw_2_r[0] ), .b( sw_2_r[1] ), .c( sw_2_r[2] ), .z( y2 ) );

always@( posedge clk or negedge rst_n )
begin
	if ( !rst_n ) y2_r <= 0 ;
	else if( cur_stage[6] ) y2_r <= y2;
end
//================================================================
//	BACKWORD
//================================================================

fp_sub SUB_delta2( .a(y2_r), .b(to_r), .z(delta2) );

always@( posedge clk or negedge rst_n )
begin
	if ( !rst_n ) delta2_r <= 0 ;
	else if( cur_stage[7] ) delta2_r <= delta2;
end

generate
for( idx=0 ; idx<3 ; idx=idx+1 )
	fp_mult MULT_w2_delta2( .a(w2_r[idx]), .b(delta2_r), .z(w2_delta2_w[idx]) );
endgenerate

generate
for( idx=0 ; idx<3 ; idx=idx+1 )
	always@( posedge clk or negedge rst_n )
	begin
		if ( !rst_n ) w2_delta2_r[idx] <= 0 ;
		else if( cur_stage[8] ) w2_delta2_r[idx] <= w2_delta2_w[idx] ;
	end
endgenerate

generate
for( idx=0 ; idx<3 ; idx=idx+1 )
	assign delta1_w[idx] = ( s2[idx][31] ) ? 0 : w2_delta2_r[idx] ;	
endgenerate

generate
for( idx=0 ; idx<3 ; idx=idx+1 )
	always@( posedge clk or negedge rst_n )
	begin
		if ( !rst_n ) delta1_r[idx] <= 0 ;
		else if( cur_stage[9] ) delta1_r[idx] <= delta1_w[idx] ;
	end	
endgenerate

//================================================================
//	UPDATE
//================================================================
generate
for( idx=0 ; idx<4 ; idx=idx+1 )
	fp_mult MULT_lrn_dp( .a(LEARNING_RATE), .b(s1_r[idx]), .z(learn_s1[idx]) );
endgenerate

generate
for( idx=0 ; idx<4 ; idx=idx+1 )
	always@( posedge clk or negedge rst_n )
	begin
		if ( !rst_n ) learn_s1_r[idx] <= 0 ;
		else if( cur_stage[9] ) learn_s1_r[idx] <= learn_s1[idx];
	end	
endgenerate

generate
for( idx=0 ; idx<3 ; idx=idx+1 )
	fp_mult MULT_lrn_y1( .a( LEARNING_RATE ), .b( y1_r[idx] ), .z( learn_s2[idx] ) );
endgenerate

generate
for( idx=0 ; idx<3 ; idx=idx+1 )
	always@( posedge clk or negedge rst_n )
	begin
		if ( !rst_n ) learn_s2_r[idx] <= 0;
		else if ( cur_stage[9] ) learn_s2_r[idx] <= learn_s2[idx];
	end	
endgenerate

generate
for( idx=0 ; idx<4 ; idx=idx+1 ) 
begin
	fp_mult MULT_fix_w1_0( .a( learn_s1_r[idx] ), .b( delta1_r[0] ), .z( pre_new_w1_1[idx] ) );
	fp_mult MULT_fix_w1_1( .a( learn_s1_r[idx] ), .b( delta1_r[1] ), .z( pre_new_w1_2[idx] ) );
	fp_mult MULT_fix_w1_2( .a( learn_s1_r[idx] ), .b( delta1_r[2] ), .z( pre_new_w1_3[idx] ) );
end	
endgenerate

generate
for( idx=0 ; idx<4 ; idx=idx+1 ) 
begin
	always@( posedge clk or negedge rst_n )
	begin
		if ( !rst_n ) 	pre_new_w1_1r[idx] <= 0;
		else if( cur_stage[0] ) pre_new_w1_1r[idx] <= pre_new_w1_1[idx];
	end
	always@( posedge clk or negedge rst_n )
	begin
		if ( !rst_n ) pre_new_w1_2r[idx] <= 0;
		else if ( cur_stage[0] ) pre_new_w1_2r[idx] <= pre_new_w1_2[idx];
	end
	always@( posedge clk or negedge rst_n )
	begin
		if ( !rst_n ) pre_new_w1_3r[idx] <= 0;
		else if ( cur_stage[0] ) pre_new_w1_3r[idx] <= pre_new_w1_3[idx];
	end
end	
endgenerate

generate
for( idx=0 ; idx<3 ; idx=idx+1 )
	fp_mult UPDATE_MULT_2_1( .a( learn_s2_r[idx] ), .b( delta2_r ), .z( pre_new_w2[idx] ) ); 
endgenerate

generate
for( idx=0 ; idx<3 ; idx=idx+1 )
	always@( posedge clk or negedge rst_n ) 
	begin
		if (!rst_n)	pre_new_w2_r[idx] <= 0;
		else if ( cur_stage[0] ) pre_new_w2_r[idx] <= pre_new_w2[idx];
	end	
endgenerate

//cur_stage[1] is high
generate
for( idx=0 ; idx<4 ; idx=idx+1 ) begin
	fp_sub UPDATE_SUB_w1_0( .a(w1_r[ idx+0 ]), .b( pre_new_w1_1r[idx] ), .z( new_w1[ idx+0 ] ) );	
	fp_sub UPDATE_SUB_w1_1( .a(w1_r[ idx+4 ]), .b( pre_new_w1_2r[idx] ), .z( new_w1[ idx+4 ] ) );	
	fp_sub UPDATE_SUB_w1_2( .a(w1_r[ idx+8 ]), .b( pre_new_w1_3r[idx] ), .z( new_w1[ idx+8 ] ) );	
end
endgenerate

generate
for( idx=0 ; idx<3 ; idx=idx+1 )
	fp_sub UPDATE_SUB_w2( .a( w2_r[idx] ), .b( pre_new_w2_r[idx] ), .z( new_w2[idx] ) );	
endgenerate
//================================================================
//  INPUT
//================================================================
//s10, s11, s12
//s13 replace by the last digit of data_point

always@( posedge clk or negedge rst_n )
begin
	if( !rst_n ) 
	begin
		for( i=0 ; i<4 ; i=i+1 ) s1_r[i] <= 0;
	end
	else if( in_valid_d ) s1_r[in_cnt] <= data_point;	
end
//input counter 
always@( posedge clk or negedge rst_n )
begin
	if( !rst_n ) in_cnt <= 0;
	else if( in_valid_d ) in_cnt <= in_cnt + 2'd1;
	else in_cnt <= 0;
end
//target 
always@( posedge clk or negedge rst_n )
begin
	if ( !rst_n ) 	to_r <= 0;
	else if( in_valid_t ) to_r <= target;
end

// reg flag;
always@( posedge clk or negedge rst_n )
begin
	if ( !rst_n ) flag <= 0 ;
	else if ( in_valid_w1 )	flag <= 1;
	else if ( out_valid ) flag <= 0;
end
//weight
always@( posedge clk or negedge rst_n )
begin
	if( !rst_n ) 
	begin
		for( i=0 ; i<12 ; i=i+1 ) w1_r[i] <= 0;
	end
	else if( in_valid_w1 ) w1_r[weight1_cnt] <= weight1;
	else if( cur_stage[1] && flag == 0 )
	begin
		for( i=0 ; i<12 ; i=i+1 ) w1_r[i] <= new_w1[i];
	end

end
always@( posedge clk or negedge rst_n )
begin
	if( !rst_n ) 
	begin
		for( i=0 ; i<3 ; i=i+1 ) w2_r[i] <= 0;
	end
	else if( in_valid_w2 ) w2_r[weight2_cnt] <= weight2;
	else if( cur_stage[1] && flag == 0 )
	begin
		for( i=0 ; i<3 ; i=i+1 ) w2_r[i] <= new_w2[i];
	end
end

//weight counter 
always@( posedge clk or negedge rst_n )
begin
	if( !rst_n ) weight1_cnt <= 0;
	else if( in_valid_w1 ) weight1_cnt <= weight1_cnt + 4'd1;
	else weight1_cnt <= 0;	
end
always@( posedge clk or negedge rst_n )
begin
	if( !rst_n ) weight2_cnt <= 0;
	else if( in_valid_w2 ) weight2_cnt <= weight2_cnt + 2'd1;
	else weight2_cnt <= 0;	
end

//================================================================
//  OUTPUT : out_valid & out
//================================================================

always@( posedge clk or negedge rst_n )
begin
	if ( !rst_n ) out_valid <= 0 ;
	else out_valid <= cur_stage[6] ;
end

always@( posedge clk or negedge rst_n )
begin
	if ( !rst_n ) out <= 0 ;
	else if ( cur_stage[6] ) out <= y2 ;
	else out <= 0 ;
end

//================================================================
//  PRE_OUTPUT
//================================================================

always@( posedge clk or negedge rst_n )
begin
	if (!rst_n) begin
		for( i=0 ; i<8 ; i=i+1 )
			cur_stage[i] <= 0 ;
	end
	else begin
		cur_stage[0] <= in_valid_t ;
		for( i=1 ; i<10 ; i=i+1 ) 
			cur_stage[i] <= cur_stage[i-1] ;
	end
end

endmodule

//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//  SUB MODULE
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

module fp_mult(
	//input signal
	a,
	b,
	//output signal
	z
); 
//================================================================
// IEEE floating point paramenters
//================================================================
parameter inst_sig_width = 23;
parameter inst_exp_width = 8;
parameter inst_ieee_compliance = 0;
parameter inst_total_width = inst_sig_width + inst_exp_width;

//================================================================
//  INPUT AND OUTPUT DECLARATION                         
//================================================================
input [inst_total_width:0] a, b;
output [inst_total_width:0] z;

DW_fp_mult #( inst_sig_width, inst_exp_width, inst_ieee_compliance ) 
		MULT( .a( a ), 
			  .b( b ), 
			  .rnd( 3'b000 ),
			  .z( z )
			);
endmodule


module fp_sum4(
	//input signal
	a,
	b,
	c,
	d,
	//output signal
	z
); 
//================================================================
// IEEE floating point paramenters
//================================================================
parameter inst_sig_width = 23;
parameter inst_exp_width = 8;
parameter inst_ieee_compliance = 0;
parameter inst_total_width = inst_sig_width + inst_exp_width;

//================================================================
//  INPUT AND OUTPUT DECLARATION                         
//================================================================
input [inst_total_width:0] a, b, c, d;
output [inst_total_width:0] z;

wire [inst_total_width:0] u1_out, u2_out;

DW_fp_add #( inst_sig_width, inst_exp_width, inst_ieee_compliance )
		U1 ( .a( a ), 
		     .b( b ), 
			 .z(u1_out), 
			 .rnd( 3'b000 )
		   );
		   
DW_fp_add #( inst_sig_width, inst_exp_width, inst_ieee_compliance )
		U2 ( .a( u1_out ), 
		     .b( c ), 
			 .z( u2_out ), 
			 .rnd( 3'b000 )
		   );
		   
		   		   
DW_fp_add #( inst_sig_width, inst_exp_width, inst_ieee_compliance )
	 ADDER ( .a( u2_out ), 
		     .b( d ), 
			 .z( z ), 
			 .rnd( 3'b000 )
		   );  
endmodule

module fp_sum3(
	//input signal
	a,
	b,
	c,
	//output signal
	z
); 
//================================================================
// IEEE floating point paramenters
//================================================================
parameter inst_sig_width = 23;
parameter inst_exp_width = 8;
parameter inst_ieee_compliance = 0;
parameter inst_total_width = inst_sig_width + inst_exp_width;

//================================================================
//  INPUT AND OUTPUT DECLARATION                         
//================================================================
input [inst_total_width:0] a, b, c;
output [inst_total_width:0] z;

wire [inst_total_width:0] u1_out;

DW_fp_add #( inst_sig_width, inst_exp_width, inst_ieee_compliance )
		U1 ( .a( a ), 
		     .b( b ), 
			 .z( u1_out ), 
			 .rnd( 3'b000 )
		   );
		   
DW_fp_add #( inst_sig_width, inst_exp_width, inst_ieee_compliance )
	 ADDER ( .a( u1_out ), 
		     .b( c ), 
			 .z( z ), 
			 .rnd( 3'b000 )
		   );	   		   
endmodule

module fp_sub(
	//input signal
	a,
	b,
	//output signal
	z
); 
//================================================================
// IEEE floating point paramenters
//================================================================
parameter inst_sig_width = 23;
parameter inst_exp_width = 8;
parameter inst_ieee_compliance = 0;
parameter inst_total_width = inst_sig_width + inst_exp_width;

//================================================================
//  INPUT AND OUTPUT DECLARATION                         
//================================================================
input [inst_total_width:0] a,b;
output [inst_total_width:0] z;

DW_fp_sub #( inst_sig_width, inst_exp_width, inst_ieee_compliance )
       SUB ( .a( a ),
			 .b( b ),
			 .z( z ),
			 .rnd( 3'b000 )
		   );
endmodule
