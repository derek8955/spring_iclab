`ifdef RTL
	`timescale 1ns/1ps
	`define CYCLE_TIME_clk1 2
	`define CYCLE_TIME_clk2 4
`endif
`ifdef GATE
	`timescale 1ns/1ps
	`define CYCLE_TIME_clk1 2
	`define CYCLE_TIME_clk2 4
`endif


module PATTERN #(parameter DSIZE = 8,
			   parameter ASIZE = 4)(
	//Output Port
	rst_n,
	clk1,
    clk2,
	in_valid,
	in_account,
	in_A,
	in_T,

    //Input Port
	ready,
    out_valid,
	out_account
); 
//================================================================
// Input & Output Declaration
//================================================================
output reg				rst_n, clk1, clk2, in_valid;
output reg [DSIZE-1:0] 	in_account,in_A,in_T;

input 				ready, out_valid;
input [DSIZE-1:0] 	out_account;

// ===============================================================
// Parameters & Integer Declaration
// ===============================================================
integer a, i;
integer input_file;
integer current_input;
integer current_output;
integer current_cycle;
integer remaining_wait, current_wait;
integer account_arr	[4000-1:0];
integer area_arr	[4000-1:0];
integer latency_arr	[4000-1:0];
integer answer_arr	[3996-1:0];

parameter TOTAL_INPUT = 4000;

// ===============================================================
// Wire & Reg Declaration
// ===============================================================

//================================================================
// clock
//================================================================
always	#(`CYCLE_TIME_clk1/2.0) clk1 = ~clk1;
initial	clk1 = 0;

always	#(`CYCLE_TIME_clk2/2.0) clk2 = ~clk2;
initial	clk2 = 0;
//================================================================
// initial
//================================================================

initial begin
	input_file  = $fopen("../00_TESTBED/input.txt","r");

	for (i=0;i<4000;i=i+1) a = $fscanf(input_file, "%d", account_arr[i]);
	for (i=0;i<4000;i=i+1) a = $fscanf(input_file, "%d", area_arr[i]);
	for (i=0;i<4000;i=i+1) a = $fscanf(input_file, "%d", latency_arr[i]);
	for (i=0;i<3996;i=i+1) a = $fscanf(input_file, "%d", answer_arr[i]);

    rst_n = 1'b1;
	in_valid = 1'b0;
	in_account = 'bx;
	in_A = 'bx;
	in_T = 'bx;

    force clk1 = 0;
	force clk2 = 0;
    reset_task;
    @(negedge clk1);

    current_input = 0;
	current_output = 0;
	current_cycle = 0;
	remaining_wait = 500;
	while (current_input<TOTAL_INPUT) begin
		// wait until ready is high
		while (ready!==1) begin
			@(negedge clk1);
		end

		// specify a random wait gap
		if ($urandom_range(0,3)==0)	current_wait = 0; // 75% chance nonstop feeding in signals
		else						current_wait = $urandom_range(0, (remaining_wait<150) ? remaining_wait : 150);		
		remaining_wait = remaining_wait - current_wait;
		repeat(current_wait) @(negedge clk1);

		// output the in_* signals
		in_valid = 1'b1;
		in_account = account_arr[current_input];
		in_A = area_arr[current_input];
		in_T = latency_arr[current_input];
		@(negedge clk1);

		in_valid = 1'b0;
		in_account = 'bx;
		in_A = 'bx;
		in_T = 'bx;

		current_input = current_input + 1;
	end
end

always @(posedge clk2) begin
	current_cycle = current_cycle + 1;
	if (current_cycle==100000) begin
		$display("---------------------------------------------");
		$display("               SPEC 6 IS FAIL!               ");
		$display("---------------------------------------------");
		$display("TA’s PATTERN will totally give 4000 inputs. And the total latency, which is the time from first in_valid to last out_valid, can not over 100000 clk2 cycles.");
		$display($time);
		$finish;
	end
	else if (out_valid===1'b1) begin
		if (out_account!==answer_arr[current_output]) begin
			$display("---------------------------------------------");
			$display("              SPEC 16 IS FAIL!               ");
			$display("---------------------------------------------");
			$display("First 4 inputs don’t have to output the best account.");
			$display("After that, the best account signal is not corrent.");
			$display("The %d th should be %d rather than %d", current_output+1,answer_arr[current_output],out_account);
			$display($time);
			$finish;
		end
		else begin
			$display("The %d th is %d is correct", current_output+1,out_account);
		end
		current_output = current_output + 1;
	end
	else if (out_valid===1'b0) begin
		if (out_account!==8'b0) begin
			$display("---------------------------------------------");
			$display("              SPEC 16 IS FAIL!               ");
			$display("---------------------------------------------");
			$display("The output should be 0 when out_valid is 0");
			$display("The out_account should be %d rather than %d", 0, out_account);
			$display($time);
			$finish;
		end
	end

	if (current_output==3996) YOU_PASS_task;
end

// SPEC 0 
// SPEC 4 (Done)
// SPEC 6 (Done)
// SPEC 16 (Done)

//================================================================
// task
//================================================================

task reset_task; begin
    #(15) rst_n = 0;
    #(10);
    if ((ready !== 0) || (out_valid !== 0) || (out_account !== 0))  begin
        $display("---------------------------------------------");
        $display("               SPEC 4 IS FAIL!               ");
        $display("---------------------------------------------");
        $display("All your output registers should be set zero after reset.");
        $display("ready %b", ready);
        $display("out_valid %b", out_valid);
        $display("out_account %b", out_account);
        $display($time);
        $finish;
    end
    #(10); rst_n = 1;
    #(3.0); release clk1; release clk2;
end endtask

task YOU_PASS_task;begin
$display ("----------------------------------------------------------------------------------------------------------------------");
$display ("                                                  Congratulations!                                                    ");
$display ("                                           You have passed all patterns!                                              ");
$display ("                                                                                                                      ");
$display ("                                        Your execution cycles   = %5d cycles                                          ", current_cycle);
$display ("                                        Your clock1 period       = %.1f ns                                            ", `CYCLE_TIME_clk1);
$display ("                                        Your clock2 period       = %.1f ns                                            ", `CYCLE_TIME_clk2);
$display ("                                        Total latency           = %.1f ns                                             ", current_cycle*`CYCLE_TIME_clk2 );
$display ("----------------------------------------------------------------------------------------------------------------------");
$finish; 
end endtask

endmodule 