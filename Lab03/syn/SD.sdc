set cycle 7.0
create_clock -name clk  -period $cycle   [get_ports  clk] 

set_dont_touch_network      [all_clocks]
set_fix_hold                [all_clocks]
set_clock_uncertainty  0.1  [all_clocks]
set_clock_latency      0.5  [all_clocks]
set_ideal_network           [get_ports clk]


#Don't touch the basic env setting as below
set_input_delay  3.5   -clock clk [remove_from_collection [all_inputs] [get_ports clk]] 
set_output_delay 3.5    -clock clk [all_outputs]  

set_load         0.05   [all_outputs]

set_operating_conditions -max_library slow -max slow
set_wire_load_model -name tsmc13_wl10 -library slow
