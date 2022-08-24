clear -all 
set_proofmaster on

set_proofgrid_max_local_jobs 10
check_sec -analyze -sv -both ../01_RTL/GATED_OR.v
check_sec -analyze -sv -both ../01_RTL/IDC.v 
check_sec -elaborate -both  -top IDC  -disable_auto_bbox
check_sec -setup


clock clk  -both_edge
reset ~rst_n

clock -rate [get_design_info -list input] clk

check_sec -gen
check_sec -interface


assume cg_en==0
assume IDC_imp.cg_en==1
assume {in_data[6:2]==0}
check_sec -waive -waive_signals cg_en
check_sec -waive -waive_signals IDC_imp.cg_en

check_sec -interface


set_sec_autoprove_strategy design_style
set_sec_autoprove_design_style_type clock_gating


check_sec -prove -bg
