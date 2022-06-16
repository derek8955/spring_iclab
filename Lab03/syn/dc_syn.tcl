#Read All Files
read_file -format verilog  ../src/SD.v
current_design SD
link

#Setting Clock Constraints
source -echo -verbose SD.sdc
check_design

compile

write -format ddc     -hierarchy -output "SD_syn.ddc"
write_sdf -version 1.0  SD_syn.sdf
write -format verilog -hierarchy -output SD_syn.v
report_area > area.log
report_timing > timing.log
report_qor   >  SD_syn.qor

exit
