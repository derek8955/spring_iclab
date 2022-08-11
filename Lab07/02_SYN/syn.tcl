#======================================================
#
# Synopsys Synthesis Scripts (Design Vision dctcl mode)
#
#======================================================

#======================================================
#  Set Libraries
#======================================================

set search_path { ./../01_RTL/ \
                  /home/cell_lib/CBDK_TSMC018_Arm_v4.0/CIC/SynopsysDC/db/ \
				  /usr/cad/synopsys/synthesis/2019.12/libraries/syn/ \
				  /usr/cad/synopsys/synthesis/2019.12/dw/
                }

set synthetic_library {dw_foundation.sldb}
set link_library {* dw_foundation.sldb standard.sldb slow.db }
set target_library {slow.db}

#report_lib slow
#======================================================
#  Global Parameters
#======================================================
set DESIGN "CDC"
set CYCLE 3

#set IN_DLY [expr 0.5*$CLK_period]
#set OUT_DLY [expr 0.5*$CLK_period]


#======================================================
#  Read RTL Code
#======================================================
#set hdlin_auto_save_templates TRUE

analyze -f verilog $DESIGN\.v
elaborate $DESIGN
current_design $DESIGN

#======================================================
#  Global Setting
#======================================================
set_wire_load_mode top
#======================================================
#  Set Design Constraints
#======================================================

#set_dont_touch core_register_reg[*]
create_clock -name "clk1" -period $CYCLE clk1
create_clock -name "clk2" -period 3  clk2

#set_input_delay  [ expr $CYCLE*0.5 ] -clock clk [all_inputs]
#set_output_delay [ expr $CYCLE*0.5 ] -clock clk [all_outputs]
set_input_delay  1.5 -clock clk1 [all_inputs]
set_output_delay 1.5  -clock clk2 [all_outputs]

set_input_delay 0 -clock clk1 clk1

set_input_delay 0 -clock clk1 rst_n

set_load 0.05 [all_outputs]

set_dont_use slow/JKFF*

source -echo -verbose CDC.sdc

#set hdlin_ff_always_sync_set_reset true
#report_clock -skew clk
#======================================================
#  Optimization
#======================================================

uniquify
check_design > Report/$DESIGN\.check
set_fix_multiple_port_nets -all -buffer_constants
#set_fix_hold [all_clocks]
compile_ultra

#compile
#======================================================
#  Output Reports 
#======================================================
report_timing >  Report/$DESIGN\.timing
report_area >  Report/$DESIGN\.area
report_resource >  Report/$DESIGN\.resource

#======================================================
#  Change Naming Rule
#======================================================
set bus_inference_style "%s\[%d\]"
set bus_naming_style "%s\[%d\]"
set hdlout_internal_busses true
change_names -hierarchy -rule verilog
define_name_rules name_rule -allowed "a-z A-Z 0-9 _" -max_length 255 -type cell
define_name_rules name_rule -allowed "a-z A-Z 0-9 _[]" -max_length 255 -type net
define_name_rules name_rule -map {{"\\*cell\\*" "cell"}}
change_names -hierarchy -rules name_rule

#======================================================
#  Output Results
#======================================================

set verilogout_higher_designs_first true

write -format verilog -output Netlist/$DESIGN\_SYN.v -hierarchy
write_sdc Netlist/$DESIGN\_SYN.sdc

write_sdf -version 3.0 -context verilog -load_delay cell Netlist/$DESIGN\_SYN.sdf -significant_digits 6

#======================================================
#  Finish and Quit
#======================================================
report_area
report_timing

exit

