#Read All Files
read_file -format verilog  ../src/SMC.v
current_design SMC
link

#Setting Clock Constraints
source -echo -verbose SMC.sdc
check_design

compile

write -format ddc     -hierarchy -output "SMC_syn.ddc"
write_sdf -version 1.0  SMC_syn.sdf
write -format verilog -hierarchy -output SMC_syn.v
report_area > area.log
report_timing > timing.log
report_qor   >  SMC_syn.qor

exit
