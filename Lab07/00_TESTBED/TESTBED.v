`timescale 1ns/10ps

`include "PATTERN.v"
`ifdef RTL
  `include "CDC.v"
`endif
`ifdef GATE
  `include "../02_SYN/Netlist/CDC_SYN.v"
`endif 
	  		  	
module TESTBED;

parameter DSIZE = 8; // word size - 8 bit
parameter ASIZE = 4; // address size - 4 bit

wire				clk1, clk2, in_valid, out_valid, ready, rst_n;
wire [DSIZE-1:0]	in_account,in_A,in_T;
wire [DSIZE-1:0]	out_account;


initial begin
  `ifdef RTL
    $fsdbDumpfile("CDC.fsdb");
	$fsdbDumpvars(0,"+mda");
  `endif
  `ifdef GATE
    $sdf_annotate("../02_SYN/Netlist/CDC_SYN_pt.sdf", u_CDC,,,"maximum");
    $fsdbDumpfile("CDC_SYN.fsdb");
	$fsdbDumpvars(0,"+mda"); 
  `endif
  
end



CDC u_CDC(
    .clk1(clk1),
    .clk2(clk2),
    .in_valid(in_valid),
	.in_account(in_account),
    .in_A(in_A),
    .in_T(in_T),
    .rst_n(rst_n),
    .ready(ready),
    .out_valid(out_valid),
	.out_account(out_account)
    );
	
PATTERN u_PATTERN(
    .clk1(clk1),
    .clk2(clk2),
    .in_valid(in_valid),
	.in_account(in_account),
    .in_A(in_A),
    .in_T(in_T),
    .rst_n(rst_n),
    .ready(ready),
    .out_valid(out_valid),
	.out_account(out_account)
    );
  
endmodule
