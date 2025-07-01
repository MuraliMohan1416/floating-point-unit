set_host_options -max_cores 16
source ../scripts/design_setup.tcl

set REPORT_QOR 1
set PREVIOUS_STEP floorplan
set CURRENT_STEP powerplan
file mkdir ${OUTPUTS_DIR}/${CURRENT_STEP}
file mkdir ${REPORTS_DIR}/${CURRENT_STEP}
open_lib ${DESIGN_LIBRARY}
copy_block -from ${DESIGN_NAME}/${PREVIOUS_STEP} -to ${DESIGN_NAME}/${CURRENT_STEP}
current_block ${DESIGN_NAME}/${CURRENT_STEP}

set_svf ${OUTPUTS_DIR}/${DESIGN_NAME}.${CURRENT_STEP}.svf
set_attribute [get_lib_cells */*TIE*] dont_touch false
set_lib_cell_purpose -include optimization [get_lib_cells */*TIE*]

remove_pg_strategies -all
remove_pg_patterns -all
remove_pg_regions -all
remove_pg_via_master_rules -all
remove_pg_strategy_via_rules -all
connect_pg_net 


###########  MESH_CREATION ##################

create_pg_mesh_pattern mesh_pattern \
   -layers {{{vertical_layer: M8} {width: 0.12}\
	{spacing: interleaving} {trim: true} \
             {pitch: 4.8} {offset: 1.6}}\
            {{horizontal_layer: M9} {width: 0.12}\
	{spacing: interleaving} {trim: true} \
             {pitch: 4.8} {offset: 1.6}}}

set_pg_strategy fpu_add_mesh \
   -pattern {{name: mesh_pattern} {nets: VDD VSS}} \
   -extension {{{stop:design_boundary_and_generate_pin}}} \
	-core
set_pg_strategy_via_rule rail_via_rule -via_rule \
                         {{intersection: all} {via_master: DEFAULT}}
compile_pg -strategies {fpu_add_mesh} -via_rule  rail_via_rule



########## std cell rail creation ###############

create_pg_std_cell_conn_pattern std_pattern \
 			-rail_width 0.096 -layers M1
set_pg_strategy fpu_add_rails -core \
	-pattern {{name: std_pattern} {nets:"VDD VSS"}}

set_pg_strategy_via_rule rail_via_rule -via_rule \
                         {{intersection: all} {via_master: DEFAULT}}
compile_pg -strategies {fpu_add_rails rail_via_rule}




#########################################
### Verification
#########################################
check_pg_connectivity check_pg_conn.rpt  > ../reports/check_pg_conn.rpt

check_pg_drc > ../powerplan/check_pg_drc.rpt



##########################################
## sanity_checks
#########################################

set CURRENT_STEP powerplan

if {$REPORT_QOR} {redirect ../reports/${CURRENT_STEP}/report_qor {source ../scripts/reports_qor.tcl}}

save_block -as fpu_add/powerplan
save_lib
echo [date] > ../powerplan
close_block -f
close_lib