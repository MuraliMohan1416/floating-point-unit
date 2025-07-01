set_host_options -max_cores 16
source ../scripts/design_setup.tcl
set REPORT_QOR 1
set PREVIOUS_STEP powerplan
set CURRENT_STEP placement
file mkdir ../outputs/${CURRENT_STEP}
file mkdir ../outputs/${CURRENT_STEP}
###set_app_options -name formality.svf.integrate_in_ndm -value true
open_lib ${DESIGN_LIBRARY}
copy_block -from ${DESIGN_NAME}/${PREVIOUS_STEP} -to ${DESIGN_NAME}/${CURRENT_STEP}
current_block ${DESIGN_NAME}/${CURRENT_STEP}
link_block
set_dont_touch [get_cells -hier *latch] true
set_vsdc ${OUTPUTS_DIR}/${DESIGN_NAME}.${CURRENT_STEP}.vsdc

##### set active scenarios for the step (please include CTS and hold scenario for CCD)

if {$PLACE_OPT_ACTIVE_SCENARIO_LIST != ""} {
	set_scenario_status -active false [get_scenarios -filter active]
     	set_scenario_status -active true $PLACE_OPT_ACTIVE_SCENARIO_LIST}

#############ABOVE FLOWER BRACES ADD BY U

if {[sizeof_collection [get_scenarios -filter "hold && setup"]] == 0} {
	puts "Warning: No active hold scenario is found. recommended to enable hold scenario here such that CCD skewing can consider them."
	puts "Info : Please activated hold scenario for place_opt if they are available." }

######################################
############# variables
######################################

set_app_options -name place.coarse.max_density -value 0.4
set_app_options -name place.coarse.continue_on_missing_scandef -value true

########################################
########## IO BUFFERS
#######################################

catch {add_buffer [get_nets -of[get_ports]] [get_lib_cells */*SAEDRVT*BUF_20]}
magnet_placement [get_ports *]
set_attribute [get_lib_cells eco_cells*] physical_status fixed

########################################
######### placenment
####################################

create_placement  -effort high -congestion -floorplan -timing_driven
legalize_placement
check_legality -verbose

set_attribute [get_lib_cells *lvt*/*] threshold_voltage_group LVT
set_threshold_voltage_group_type -type low_vt LVT
set_multi_vth_constraint -low_vt_percentage 8 -cost cell_count
place_opt -to final_opto
connect_pg_net

#########################################
#### sanity checks and QOR Report 
##########################################
set CURRENT_STEP placement
if {$REPORT_QOR} {redirect > ../reports/${CURRENT_STEP}/report_qor {source ../scripts/report_qor.tcl}}

#######################################
############# save
########################################
        
save_block -as fpu_add/placement
create_abstract -read_only
create_frame -block_all true
save_lib
echo [date] > ../placement
#close_blocks -f 
#close_lib
#exit