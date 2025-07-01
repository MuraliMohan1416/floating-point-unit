set_host_options -max_core 16
source ../scripts/design_setup.tcl
set REPORT_QOR 1
set PREVOIUS_STEP placement
set CURRENT_STEP cts
file mkdir ../reports/${CURRENT_STEP}
file mkdir ../outputs/${CURRENT_STEP}
open_lib ${DESIGN_LIBRARY}
copy_block -from ${DESIGN_NAME}/${PREVOIUS_STEP} -to ${DESIGN_NAME}/${CURRENT_STEP}
current_block ${DESIGN_NAME}/${CURRENT_STEP}
link_block

set_svf ${OUTPUTS_DIR}/${DESIGN_NAME}.${CURRENT_STEP}.svf

##### set active scenarios for the step (please include CTS and hold scenario for CCD)

if { ${CLOCK_OPT_CTS_ACTIVE_SCENARIO_LIST} != ""} {
	set_scenario_status -active false [get_scenarios -filter active]
     	set_scenario_status -active true $CLOCK_OPT_CTS_ACTIVE_SCENARIO_LIST
}
#############ABOVE FLOWER BRACES ADD BY U

if {[sizeof_collection [get_scenarios -filter "hold && active"]] == 0} {
	puts "Warning: No active hold scenario is found. recommended to enable hold scenario here such that CCD skewing can consider them."
	puts "Info : Please activated hold scenario for place_opt if they are available." 
}
######################################
####### Variables
######################################

set_app_options -name  cts.common.user_instance_name_prefix -value clock_opt_cts_
set_app_options -name cts.common.user_instance_name_prefix -value clock_opt_cts_opt_
set_app_options -name  cts.common.max_fanout -value 100

################################
### clock_opt CTS flow
################################

## clock_opt -from build_clock -to build_clock
## clock_opt -from route_clock -to route_clock
clock_opt
connect_pg_net

set_scenario_status func::ss0p6v125c -hold true -setup true -active true
set_scenario_status func_turbo::ss0p6v125c -hold true -setup true -active true
set_scenario_status func_turbo::ff0p7vm40c -hold true -setup true -active true
#####################################
##### sanity_checks and Qor reports
####################################

if {$REPORT_QOR} {
	redirect ../reports/${CURRENT_STEP}/qor {source ../scripts/report_qor.tcl}
}

#######################################
############# save
########################################
        
save_block -as fpu_add/cts
create_abstract -read_only
create_frame -block_all true
save_lib
echo [date] > ../cts
#close_blocks -f 
#close_lib
#exit