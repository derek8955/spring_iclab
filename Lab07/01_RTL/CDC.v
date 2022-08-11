//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   2022 ICLAB Spring Course
//   Lab07			: Clock Domain Crossing (CDC)
//   Author         : Yao-Zhan Xu (xuyaozhan8905@gmail.com)
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   File Name   : CDC.v
//   Module Name : CDC
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################
`include "AFIFO.v"
module CDC #(parameter DSIZE = 8, parameter ASIZE = 4)(
	//Input Port
	rst_n,
	clk1,
    clk2,
	in_valid,
	in_account,
	in_A,
	in_T,

    //Output Port
	ready,
    out_valid,
	out_account
); 
//================================================================
//  INPUT AND OUTPUT DECLARATION                         
//================================================================
input 				rst_n, clk1, clk2, in_valid;
input [DSIZE-1:0] 	in_account,in_A,in_T;
output reg				out_valid;
output ready;
output reg [DSIZE-1:0] 	out_account;
//================================================================
//  parameter / genvar / integer                          
//================================================================
integer idx; 
genvar i;
//================================================================
//   Wires & Registers 
//================================================================
wire r_inc;
reg  w_inc;
reg [11:0] in_cnt;
reg [DSIZE-1:0] account[0:4];
wire[DSIZE-1:0] r_data;
reg [DSIZE*2-1:0] performance[0:4], best;
wire [DSIZE-1:0] best_account;
wire [2:0] nums_perf;
wire r_empty, w_full;

reg [DSIZE-1:0] A_buffer, T_buffer, acc_buffer;
//================================================================
//  AFIFO
//================================================================
AFIFO #( .DSIZE(8), .ASIZE (4) )
	u_AFIFO ( 	.rst_n(rst_n), 
				.rclk(clk2), 
				.rinc(r_inc), 
				.wclk(clk1), 
				.winc(w_inc), 
				.wdata(best_account), 
				.rempty(r_empty), 
				.rdata(r_data), 
				.wfull(w_full) );

//================================================================
//  INPUT
//================================================================
always@( posedge clk1 or negedge rst_n ) begin
	if( !rst_n ) begin
		A_buffer <= 0; T_buffer <= 0; acc_buffer <= 0;
	end
	else if( in_valid ) begin
		A_buffer <= in_A;
		T_buffer <= in_T;
		acc_buffer <= in_account;
	end
end

always@( posedge clk1 or negedge rst_n ) begin
	if( !rst_n ) in_cnt <= 0;
	else if( in_valid || (( in_cnt == 4000 || in_cnt == 4001 || in_cnt == 4002 ) && !w_full) ) in_cnt <= in_cnt + 1;
end

always@( posedge clk1 or negedge rst_n ) begin
	if( !rst_n ) begin
		for( idx=0; idx<5 ; idx=idx+1 ) account[idx] <= 0;
	end
	else if( in_valid || ( in_cnt == 4000 && !w_full ) ) begin
		account[0] <= acc_buffer;
		for( idx=0 ;idx<4 ; idx=idx+1 ) account[idx+1] <= account[idx];
	end
end

always@(posedge clk1 or negedge rst_n) begin
    if (!rst_n) begin
		for( idx=0; idx<5 ; idx=idx+1 ) performance[idx] <= 0;
    end
    else begin
        if ( in_valid || ( in_cnt == 4000 && !w_full ) ) begin
            performance[0] <= A_buffer * T_buffer;
			for( idx=0 ;idx<4 ; idx=idx+1 ) performance[idx+1] <= performance[idx];
        end
    end
end

//================================================================
//  ready
//================================================================
assign ready = ( rst_n && w_full == 0 )? 1'b1 : 1'b0 ;

//================================================================
//  PRE_OUTPUT
//================================================================
always @(*) begin
    if ( in_cnt > 6 && in_cnt < 4003 && !w_full ) begin
        if ( in_valid || (in_cnt == 4000 || in_cnt == 4001 || in_cnt == 4002 ) ) w_inc = 1'b1;
        else w_inc = 1'b0;
    end
    else w_inc = 1'b0;
end

assign r_inc = !r_empty;
			
always @(posedge clk1 or negedge rst_n) begin
    if (!rst_n) best <= 0;
    else if ((in_valid && in_cnt > 5) || ( (in_cnt == 4000 || in_cnt == 4001) && !w_full)) begin
		if ( performance[4] < performance[3] && performance[4] < performance[2] && performance[4] < performance[1] && performance[4] < performance[0] ) best <= account[4];
		else if( performance[3] < performance[4] && performance[3] < performance[2] && performance[3] < performance[1] && performance[3] < performance[0] ) best <= account[3];
		else if( performance[2] < performance[4] && performance[2] < performance[3] && performance[2] < performance[1] && performance[2] < performance[0] ) best <= account[2];
		else if( performance[1] < performance[4] && performance[1] < performance[3] && performance[1] < performance[2] && performance[1] < performance[0] ) best <= account[1];
		else best <= account[0];
	end 
end		

assign best_account = best;
		
//================================================================
//  OUTPUT
//================================================================
always @(posedge clk2 or negedge rst_n) begin
    if (!rst_n) begin
        out_valid <= 0;
        out_account <= 0;
    end
    else if ( r_inc ) begin
		out_valid <= 1;
		out_account <= r_data;
	end
	else begin
		out_valid <= 0;
		out_account <= 0;
	end
end


endmodule