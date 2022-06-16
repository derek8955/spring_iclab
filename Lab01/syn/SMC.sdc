set_operating_conditions slow -library slow
set_wire_load_model -name tsmc13_wl10 -library slow
set_max_delay 30  -to [get_ports {out_n}]