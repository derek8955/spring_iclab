//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//      (C) Copyright NYCU SI2 Lab      
//            All Right Reserved
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   2022 ICLAB SPRING Course
//   Lab05		: SRAM, Template Matching with Image Processing
//   Author     : Yu-Wei Lu
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   File Name   : TESTBED.v
//   Module Name : TESTBED
//   Release version : v2.0
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################
`ifdef RTL
	`timescale 1ns/10ps
	`include "TMIP.v"
	`define CYCLE_TIME 8.0
`endif
`ifdef GATE
	`timescale 1ns/10ps
	`include "../02_SYN/Netlist/TMIP_SYN.v"
	`define CYCLE_TIME 8.0
`endif

module PATTERN(
// output signals
    clk,
    rst_n,
    in_valid,
	in_valid_2,
    image,
    img_size,
    template, 
    action,
// input signals
    out_valid,
    out_x,
    out_y,
    out_img_pos,
    out_value
);

// ===============================================================
// Parameters & Integer Declaration
// ===============================================================
integer a, i;
integer input_file;
integer curr_pat,total_pat;
integer calc_cycle, total_calc_cycle, output_cycle, gap;

integer input_size, image_data[255:0];
integer template_data[8:0];
integer action_len, action_list[15:0];

integer result_size, result_data[255:0];
integer result_x, result_y;
integer match_pos_len, match_pos_list[8:0];

//================================================================
// Input & Output Declaration
//================================================================
output reg        clk, rst_n, in_valid, in_valid_2;
output reg signed [15:0] image, template;
output reg [4:0]  img_size;
output reg [2:0]  action;

input         out_valid;
input [3:0]   out_x, out_y; 
input [7:0]   out_img_pos;
input signed[39:0]  out_value;

// ===============================================================
// Wire & Reg Declaration
// ===============================================================
reg signed [15:0] test;

//================================================================
// clock
//================================================================
always	#(`CYCLE_TIME/2.0) clk = ~clk;
initial	clk = 0;

// ===============================================================
// Initial
// ===============================================================
initial begin
    // test = 'd94;
    // test = test / 3;
    // $display("%d",test);

    // test = -'d19;
    // test = test / 3;
    // $display("%d",test);

    // test = -'d199;
    // test = (test / 2) - (((test[15]==1) && (test[0]==1)) ? 1 : 0);
    // $display("%d",test);

    // test = 'd89;
    // test = (test / 2) - (((test[15]==1) && (test[0]==1)) ? 1 : 0);
    // $display("%d",test);

    // test = -'d38;
    // test = test * 2 / 3 + 20;
    // $display("%d",test);

    // test = 'd94;
    // test = test * 2 / 3 + 20;
    // $display("%d",test);

    // test = 'd27;
    // test = (test / 2) - (((test[15]==1) && (test[0]==1)) ? 1 : 0) + 50;
    // $display("%d",test);

    // test = -'d199;
    // test = (test / 2) - (((test[15]==1) && (test[0]==1)) ? 1 : 0) + 50;
    // $display("%d",test);

    // $finish;

	input_file  = $fopen("../00_TESTBED/input.txt","r");
	a = $fscanf(input_file, "%d", total_pat);

    rst_n = 1'b1;
	in_valid = 1'b0;
	in_valid_2 = 1'b0;
	image = 16'bx;
	template = 16'bx;
	img_size = 5'bx;
	action = 3'bx;

    force clk = 0;
    reset_task;
    @(negedge clk);

    total_calc_cycle = 0;
    // for (curr_pat=0; curr_pat<total_pat; curr_pat=curr_pat+1) begin
    for (curr_pat=0; curr_pat<10; curr_pat=curr_pat+1) begin
        input_data;
        check_process;
        $display("PASS PATTERN NO.%4d, Cycles: %4d", curr_pat , calc_cycle); // could be more accurate
    end
    YOU_PASS_task;
end

always @(*) begin
	if (((in_valid===1) || (in_valid_2===1)) && (out_valid===1)) begin // TBD confirm that it could correctly detect the defect!
		$display("---------------------------------------------");
		$display("               SPEC 8 IS FAIL!               ");
		$display("---------------------------------------------");
        $display("The out_valid cannot overlap with in_valid.");
        $display("in_valid %b", in_valid);
        $display("in_valid_2 %b", in_valid_2);
        $display("out_valid %b", out_valid);
		$display($time);
		$finish;
	end
end

// 0-5,6,7
// SPEC  3 (Done)
// SPEC  8 (Done)
// SPEC  9 (Done)
// SPEC 14 (Done)

//================================================================
// PATTERN
//================================================================

task check_process; begin
	calc_cycle = 0;
    while (!out_valid) begin
        if (calc_cycle == 10000) begin // 10000
            $display("---------------------------------------------");
            $display("               SPEC 9 IS FAIL!               ");
            $display("---------------------------------------------");
            $display("The execution latency is limited in 10000 cycles.");
            $display($time);
            $finish;
        end
		calc_cycle = calc_cycle + 1;
        @(negedge clk);
    end
    total_calc_cycle = total_calc_cycle + calc_cycle;

    output_cycle = 0;
	while (out_valid) begin
		if (output_cycle >= result_size*result_size) invalid_output_signal; // out_valid be high too long
        if (
            (out_value !== result_data[output_cycle]) ||
            ((output_cycle <  match_pos_len) && (out_img_pos !== match_pos_list[output_cycle])) ||
            ((output_cycle >= match_pos_len) && (out_img_pos !== 0)) ||
            (out_x !== result_x) ||
            (out_y !== result_y)
        ) begin
            invalid_output_value;
            $finish;
        end
		output_cycle = output_cycle + 1;
		@(negedge clk);
	end
	if (output_cycle != result_size*result_size) invalid_output_signal; // out_valid be high too short
end endtask

task invalid_output_signal; begin
	$display("---------------------------------------------");
	$display("               SPEC 14 IS FAIL!              ");
	$display("---------------------------------------------");
    $display("SPEC 14.0 Every output signal should be correct when out_valid is high.");
	$display("The cycles of output signal is wrong, %d / %d",output_cycle,result_size*result_size);
	$display($time);
	$finish;
end
endtask

task invalid_output_value; begin
    $display("---------------------------------------------");
    $display("               SPEC 14 IS FAIL!              ");
    $display("---------------------------------------------");
    $display("SPEC 14 Every output signal should be correct when out_valid is high.");
    $display($time);
    $display("out_value should be %d rather than %d",result_data[output_cycle],out_value);
    if (output_cycle <  match_pos_len)  $display("out_img_pos should be %d rather than %d",match_pos_list[output_cycle],out_img_pos);
    else                                $display("out_img_pos should be %d rather than %d",0,out_img_pos);
    $display("out_x should be %d rather than %d",result_x,out_x);
    $display("out_y should be %d rather than %d",result_y,out_y);
    $finish;
end
endtask

task input_data; begin
	// read input pattern in order from file
    a = $fscanf(input_file, "%d", input_size);
    for (i=0;i<input_size*input_size;i=i+1) a = $fscanf(input_file, "%d", image_data[i]);
    for (i=0;i<9;i=i+1) a = $fscanf(input_file, "%d", template_data[i]);
    a = $fscanf(input_file, "%d", action_len);
    for (i=0;i<action_len;i=i+1) a = $fscanf(input_file, "%d", action_list[i]);
    a = $fscanf(input_file, "%d", result_size);
    for (i=0;i<result_size*result_size;i=i+1) a = $fscanf(input_file, "%d", result_data[i]);
    a = $fscanf(input_file, "%d", result_x);
    a = $fscanf(input_file, "%d", result_y);
    a = $fscanf(input_file, "%d", match_pos_len);
    for (i=0;i<match_pos_len;i=i+1) a = $fscanf(input_file, "%d", match_pos_list[i]);

    gap = $urandom_range(2,5);
    repeat(gap) @(negedge clk);
    in_valid = 1'b1;
    for (i=0;i<input_size*input_size;i=i+1) begin
        // image template image_size
        image = image_data[i];
        template = (i<9) ? template_data[i] : 16'bx;
        img_size = (i==0) ? input_size : 5'bx;
        @(negedge clk);
    end
	in_valid = 1'b0;
	image = 16'bx;
	template = 16'bx;
	img_size = 5'bx;

    @(negedge clk);

    in_valid_2 = 1'b1;
	for (i=0;i<action_len;i=i+1) begin
        action = action_list[i];
		@(negedge clk);
	end
	in_valid_2 = 1'b0;
	action = 3'bx;
end endtask

task reset_task; begin
    #(15) rst_n = 0; // TBD confirm the #(timing) usage
    #(10); // TBD what if it is shorten
    if ((out_valid !== 0) || (out_x !== 0) || (out_y !== 0) || (out_img_pos !== 0) || (out_value !== 0))  begin
        $display("---------------------------------------------");
        $display("               SPEC 3 IS FAIL!               ");
        $display("---------------------------------------------");
        $display("The reset signal (rst_n) would be given only once at the beginning of simulation.");
        $display("All output signals should be reset after the reset signal is asserted.");
        $display("out_valid %b", out_valid);
        $display("out_x %b", out_x);
        $display("out_y %b", out_y);
        $display("out_img_pos %b", out_img_pos);
        $display("out_value %b", out_value);
        $display($time);
        $finish;
    end
    #(10); rst_n = 1;
    #(3.0); release clk;
end endtask

task YOU_PASS_task;begin
$display ("----------------------------------------------------------------------------------------------------------------------");
$display ("                                                  Congratulations!                                                    ");
$display ("                                           You have passed all patterns!                                              ");
$display ("                                                                                                                      ");
$display ("                                        Your execution cycles   = %5d cycles                                          ", total_calc_cycle);
$display ("                                        Your clock period       = %.1f ns                                             ", `CYCLE_TIME);
$display ("                                        Total latency           = %.1f ns                                             ", total_calc_cycle*`CYCLE_TIME );
$display ("----------------------------------------------------------------------------------------------------------------------");
$finish; 
// TBD calc_cycle
end endtask

endmodule