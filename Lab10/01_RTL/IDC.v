//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   2022 ICLAB Spring Course
//   Lab10			: Image Display Control (IDC)
//   Author         : Yao-Zhan Xu (xuyaozhan8905@gmail.com)
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   File Name   : IDC.v
//   Module Name : IDC
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

// synopsys translate_off 
`ifdef RTL
`include "GATED_OR.v"
`else
`include "Netlist/GATED_OR_SYN.v"
`endif
// synopsys translate_on

module IDC(
	// Input signals
	clk,
	rst_n,
	cg_en,
	in_valid,
	in_data,
	op,
	// Output signals
	out_valid,
	out_data
);
//================================================================
//  INPUT AND OUTPUT DECLARATION                         
//================================================================
input		clk;
input		rst_n;
input		in_valid;
input		cg_en;
input signed [6:0] in_data;
input [3:0] op;

output reg 		  out_valid;
output reg  signed [6:0] out_data;
//================================================================
//  parameter / genvar / integer                          
//================================================================
// FSM
parameter STATE_IDLE = 2'd0,
		  STATE_INPUT = 2'd1,
		  STATE_PROC = 2'd2,
		  STATE_OUTPUT = 2'd3;
// Operation Description
parameter OP_MID = 4'd0, OP_AVG = 4'd1, OP_CCR = 4'd2, OP_CR = 4'd3, OP_FLIP = 4'd4, OP_UP = 4'd5,
		  OP_LEFT = 4'd6, OP_DOWN = 4'd7, OP_RIGHT = 4'd8;
		  
integer idx;
//================================================================
//   Wires & Registers 
//================================================================
// FSM
reg [1:0] cur_state, nx_state;
// input
reg [3:0] operation[0:14];
reg signed [6:0] data[0:63];
reg [5:0] in_cnt;
// process
reg [2:0] x, y;
wire [5:0] addr;
reg [3:0] proc_cnt;

wire signed [6:0] a[0:1], b[0:1], c[0:1];
wire signed [6:0] mid;
wire signed [6:0] avg;
// pre_output
reg zoom_flag; // 0: zoom-in, 1: zoom-out
// output 
reg [3:0] out_cnt;
reg [5:0] out_addr;
//================================================================
//  INPUT
//================================================================
// clock gating
wire sleep_input, cg_clk_input;
assign sleep_input = !( cur_state == STATE_IDLE || cur_state == STATE_INPUT );
GATED_OR CG_IN( .CLOCK(clk), .SLEEP_CTRL( cg_en&&sleep_input ), .RST_N(rst_n), .CLOCK_GATED(cg_clk_input) );

always @( posedge cg_clk_input or negedge rst_n ) begin
	if( !rst_n ) begin
		for( idx=0 ; idx<15 ; idx=idx+1 ) operation[idx] <= 'd0;
	end
	else if( in_valid && in_cnt < 15 ) operation[in_cnt] <= op;
end

always @( posedge cg_clk_input or negedge rst_n ) begin
	if( !rst_n ) in_cnt <= 'd0;
	else if( in_valid ) in_cnt <= in_cnt + 'd1;
end

// clock gating
wire sleep_data, cg_clk_data;
assign sleep_data = !( cur_state == STATE_IDLE || cur_state == STATE_INPUT || cur_state == STATE_PROC);
GATED_OR CG_DATA ( .CLOCK(clk), .SLEEP_CTRL( cg_en&&sleep_data ), .RST_N(rst_n), .CLOCK_GATED(cg_clk_data) );

always @( posedge cg_clk_data or negedge rst_n ) begin
	if( !rst_n ) begin
		for( idx=0 ; idx<=63 ; idx=idx+1 ) data[idx] <= 'd0;
	end
	else if( in_valid ) data[in_cnt] <= in_data;
	else if( cur_state == STATE_PROC ) begin
		case( operation[proc_cnt] ) 
		OP_MID: begin
			data[ addr ] <= mid; data[ addr+'d1 ] <= mid;  data[ addr+'d8 ] <= mid; data[ addr+'d9 ] <= mid; 
		end
		OP_AVG: begin
			data[ addr ] <= avg; data[ addr+'d1 ] <= avg;  data[ addr+'d8 ] <= avg; data[ addr+'d9 ] <= avg; 
		end
		OP_CCR: begin
			data[ addr ] <= data[ addr+'d1 ]; data[ addr+'d1 ] <= data[ addr+'d9 ];  
			data[ addr+'d8 ] <= data[ addr ]; data[ addr+'d9 ] <= data[ addr+'d8 ];	
		end
		OP_CR: begin
			data[ addr ] <= data[ addr+'d8 ]; 		data[ addr+'d1 ] <= data[ addr ];  
			data[ addr+'d8 ] <= data[ addr+'d9 ]; 	data[ addr+'d9 ] <= data[ addr+'d1 ];	
		end
		OP_FLIP: begin
			data[ addr ] <= -data[ addr ]; 			data[ addr+1 ] <= -data[ addr+1 ];  
			data[ addr+'d8 ] <= -data[ addr+'d8 ];	data[ addr+'d9 ] <= -data[ addr+'d9 ];	
		end
		endcase
	end
end

//================================================================
//  PROCESS
//================================================================
// clock gating
wire sleep_proc, cg_clk_proc;
assign sleep_proc = !( cur_state == STATE_IDLE || cur_state == STATE_PROC);
GATED_OR CG_PROC( .CLOCK(clk), .SLEEP_CTRL( cg_en&&sleep_proc ), .RST_N(rst_n), .CLOCK_GATED(cg_clk_proc) );

assign addr = {y,x};

always @( posedge cg_clk_proc or negedge rst_n ) begin
	if( !rst_n ) begin
		x <= 'd3; y <= 'd3;
	end
	else if( cur_state == STATE_PROC ) begin
		case( operation[proc_cnt] )
		OP_UP: 		y <= ( y != 0 )? y-'d1 : 'd0 ;
		OP_LEFT: 	x <= ( x != 0 )? x-'d1 : 'd0 ;
		OP_DOWN: 	y <= ( y != 6 )? y+'d1 : 'd6 ;
		OP_RIGHT: 	x <= ( x != 6 )? x+'d1 : 'd6 ;
		endcase
	end
	else if( cur_state == STATE_IDLE )begin
		x <= 'd3; y <= 'd3;
	end
end

always @( posedge cg_clk_proc or negedge rst_n ) begin
	if( !rst_n ) proc_cnt <= 'd0;
	else if( cur_state == STATE_PROC ) proc_cnt <= proc_cnt + 'd1;
	else if( cur_state == STATE_IDLE ) proc_cnt <= 'd0;
end

// Midpoint
assign a[0] = ( data[addr] > data[addr+'d1] )? data[addr] : data[addr+'d1];
assign a[1] = ( data[addr] > data[addr+'d1] )? data[addr+'d1] : data[addr];
assign b[0] = ( data[addr+'d8] > data[addr+'d9] )? data[addr+'d8] : data[addr+'d9];
assign b[1] = ( data[addr+'d8] > data[addr+'d9] )? data[addr+'d9] : data[addr+'d8];

assign c[0] = ( a[0] > b[0] )? b[0] : a[0] ;
assign c[1] = ( a[1] > b[1] )? a[1] : b[1] ;

assign mid = ( c[0] + c[1] ) /2;
// Average 
assign avg = ( data[addr] + data[addr+'d1] + data[addr+'d8]+ data[addr+'d9] ) / 4;

//================================================================
//  PRE_OUTPUT
//================================================================
// clock gating
wire sleep_pre, cg_clk_pre;
assign sleep_pre = !( cur_state == STATE_PROC && proc_cnt == 'd14 );
GATED_OR CG_PRE( .CLOCK(clk), .SLEEP_CTRL( cg_en&&sleep_pre ), .RST_N(rst_n), .CLOCK_GATED(cg_clk_pre) );

always @( posedge cg_clk_pre or negedge rst_n ) begin
	if( !rst_n ) zoom_flag <= 'd0;
	else if( cur_state == STATE_PROC && proc_cnt == 'd14 ) begin
		if( operation[proc_cnt] == OP_UP ) begin
			if( x >= 4 || y >= 5 ) zoom_flag <= 'd1;
			else zoom_flag <= 'd0;
		end
		else if( operation[proc_cnt] == OP_LEFT ) begin
			if( x >= 5 || y >= 4 ) zoom_flag <= 'd1;
			else zoom_flag <= 'd0;
		end
		else if( operation[proc_cnt] == OP_DOWN ) begin
			if( x >= 4 || y >= 3 ) zoom_flag <= 'd1;
			else zoom_flag <= 'd0;
		end
		else if( operation[proc_cnt] == OP_RIGHT ) begin
			if( x >= 3 || y >= 4 ) zoom_flag <= 'd1;
			else zoom_flag <= 'd0;
		end
		else begin
			if( x >= 4 || y >= 4 ) zoom_flag <= 'd1;
			else zoom_flag <= 'd0;
		end
	end
end

//================================================================
//  OUTPUT
//================================================================
// clock gating
wire sleep_out, cg_clk_out;
assign sleep_out = !( cur_state == STATE_OUTPUT || cur_state == STATE_IDLE );
GATED_OR CG_OUTPUT( .CLOCK(clk), .SLEEP_CTRL( cg_en&&sleep_out ), .RST_N(rst_n), .CLOCK_GATED(cg_clk_out) );

always @( posedge cg_clk_out or negedge rst_n ) begin
	if( !rst_n ) begin
		out_valid <= 'd0; out_data <= 'd0;
	end	
	else if( cur_state == STATE_OUTPUT ) begin
		out_valid <= 'd1; out_data <= data[out_addr];
	end
	else if( cur_state == STATE_IDLE )begin 
		out_valid <= 'd0; out_data <= 'd0;
	end
end

wire [2:0] y_step, x_step;
assign y_step = out_cnt[3:2]*2 ;
assign x_step = out_cnt[1:0]*2 ; 

always @( * ) begin
	if( zoom_flag ) out_addr = {y_step , x_step} ; 
	else 			out_addr = {y+1'b1+out_cnt[3:2] , x+1'b1+out_cnt[1:0]} ; 
end

always @( posedge cg_clk_out or negedge rst_n ) begin
	if( !rst_n ) out_cnt <= 'd0;
	else if( cur_state == STATE_OUTPUT ) out_cnt <= out_cnt + 'd1;
	else if( cur_state == STATE_IDLE )out_cnt <= 'd0;
end

//================================================================
//  FSM
//================================================================
always @( posedge clk or negedge rst_n ) begin
	if( !rst_n ) cur_state <= STATE_IDLE;
	else cur_state <= nx_state;
end

always @( * ) begin
	case( cur_state )
	STATE_IDLE: nx_state = ( in_valid )? STATE_INPUT : STATE_IDLE ;
	STATE_INPUT: nx_state = ( !in_valid )? STATE_PROC : STATE_INPUT ;
	STATE_PROC: nx_state = ( proc_cnt == 'd14 )? STATE_OUTPUT : STATE_PROC ;
	STATE_OUTPUT: nx_state = ( out_cnt == 'd15 )? STATE_IDLE : STATE_OUTPUT ;
	endcase
end

endmodule 