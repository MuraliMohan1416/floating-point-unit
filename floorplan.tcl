set_host_options  -max_cores 16
source ../scripts/design_setup.tcl
set REPORT_QOR 0
set PREVIOUS_STEP init_design
set CURRENT_STEP floorplan
open_lib ${DESIGN_LIBRARY}
copy_block -from ${DESIGN_NAME}/${PREVIOUS_STEP} -to ${DESIGN_NAME}/${CURRENT_STEP}
current_block ${DESIGN_NAME}/${CURRENT_STEP}
 set_early_data_check_policy -policy lenient -if_not_exists
set_svf ${OUTPUTS_DIR}/${DESIGN_NAME}.${CURRENT_STEP}.svf

#######################################
##ports information
#######################################
get_ports > ../reports/get_ports.rpt
sizeof_collection [get_ports *] > ../sanity_check/get_ports_count.rpt
get_ports -filter {direction==in} ../sanity_check/get_ports_input.rpt
sizeof_collection [get_ports -filter {direction==in}] > ../sanity_check/get_ports_input_count.rpt
get_ports -filter {direction==out} > ../sanity_check/get_ports_output.rpt
sizeof_collection [get_ports -filter {direction==out}] > ../reports/get_output_ports_count.rpt

###################################
## Floorpan_constraints
###################################

initialize_floorplan -core_utilization 0.50 -core_offset {1}
set_block_pin_constraints -self -allowed_layers {M4 M6} -sides 2
place_pins -ports [get_ports -filter direction==out]
set_block_pin_constraints -self -allowed_layers {M3 M5} -sides 3
place_pins -ports [get_ports -filter direction==in]
set_attribute [get_ports  *] physical_status fixed
get_attribute [get_ports *] is_fixed 
get_attribute [get_ports *] is_fixed > ../reports/ports_physical_status.rpt

########## Track
create_track -layer M1 -coord 1.11 -space 0.03
report_track
report_track > ../reports/report_track.rpt
connect_pg_net  -automatic 

#############################################
## Fix Macros status
#############################################

set_attribute [get_cells -physical_context -filter design_type==macro] physical_status fixed

############################################
## Boundary and tap cells 
###########################################

set_boundary_cell_rules\
             -top_boundary_cells [get_lib_cells */*CAPT2] \
             -bottom_boundary_cells [get_lib_cells */*CAPB2] \
             -right_boundary_cell [get_lib_cells */*CAPBIN13] \
             -left_boundary_cell [get_lib_cells */*CAPBTAP6] \
             -prefix ENDCAP

compile_targeted_boundary_cells -target_objects  [get_voltage_areas]

create_tap_cells \
      -lib_cell saed14lvt_ff0p7vm40c/SAEDLVT14_CAPTTAP6 \
      -distance 30 \
      -pattern every_row 
      
# remove_cells *tap*

check_legality -cells [get_cells  bound*]
check_legality -cells [get_cells tap*]

################################
## save
################################

save_block
#create_abstract -read_only
create_frame -block_all true
save_block -as fpu_add/floorplan
save_lib
close_block -f
close_lib
