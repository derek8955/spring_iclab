clear -all 
#set_proofmaster : achieving better convergence, faster results
set_proofmaster on

check_sec -analyze -sv -spec ../01_RTL/IDC_wocg.v
check_sec -analyze -sv -imp ../01_RTL/GATED_OR.v
check_sec -analyze -sv -imp ../01_RTL/IDC.v
check_sec -elaborate -spec -top IDC  -disable_auto_bbox
check_sec -elaborate -imp  -top IDC  -disable_auto_bbox
check_sec -setup

clock clk -both_edge
reset ~rst_n

check_sec -generate_verification
check_sec -interface

assume IDC_imp.cg_en==0 
assume {in_data[6:2]==0}
check_sec -waive -waive_signals IDC_imp.cg_en

check_sec -interface


set_sec_autoprove_strategy design_style
set_sec_autoprove_design_style_type clock_gating




check_sec -prove -bg
