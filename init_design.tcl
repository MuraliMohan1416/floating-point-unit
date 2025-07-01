set_host_options -max_cores 16
source ../scripts/design_setup.tcl 
set REPORT_QOR 0
set DESIGN_NAME fpu_add
set CURRENT_STEP init_design
file mkdir ../outputs/${CURRENT_STEP}
file mkdir ../reports/${CURRENT_STEP}
set link_library $LINK_LIBRARY
set target_library $LINK_LIBRARY
create_lib -ref_libs $REFERENCE_LIBRARY -technology $TECH_FILE ../work/${DESIGN_LIBRARY}

########################################
#        READ_VERILOG
##########################################

read_verilog ${VERILOG_NETLIST_FILES}
current_design ${DESIGN_NAME}
link

#########################################
#  DESIGN CREATION :READ UPF FILES
#########################################

## for golden UPF flow only (if supplemental UPF is provided): enable gloden UPF flow before reading UPF 

if {[file exists [which $UPF_SUPPLEMENTAL_FILE]]} {
set_app_options -name mv.upf.enable_golden_upf -value true  }

if {[file exists [which $UPF_FILE]]} {
   load_upf ${UPF_FILE}
## for gloden UPF flow only (if supplemental UPF is provided);

if {[file exists [which $UPF_SUPPLEMENTAL_FILE]]} {
load_upf -supplemental $UPF_SUPPLEMENTAL_FILE 
}  elseif { ${UPF_SUPPLEMENTAL_FILE}!= ""} {
    echo "Error: UPF_SUPPLEMENTAL_FILE($UPF_SUPPLEMENTAL_FILE) is invalid.please correct it."
}

puts "Info:Running commit_upf"
commit_upf

} elseif {$UPF_FILE != ""} {
   puts "Error: UPF file ($UPF_FILE) is invalid. please correct it."
}

########################################
# Timing and design constraints
#########################################

source ../inputs/mmmc/TCL_PARASITIC_SETUP_FILE.tcl 
source ../inputs/mmmc/TCL_MCMM_SETUP_FILE.explicit.tcl 

#########################################
## NDRs and Metal layer Direction
#########################################

source ../scripts/cts_ndr.tcl 
define_user_attribute -type string -name routing_direction -classes routing_rule
set_attribute -objects [get_layers {M2 M4 M6 M8 MRDL}] -name routing_direction -value vertical
set_attribute -objects [get_layers {M1 M3 M5 M7 M9 }] -name routing_direction -value horizontal

redirect ../reports/${CURRENT_STEP}/report_routing_rules {report_routing_rules -verbose} 
redirect ../reports/${CURRENT_STEP}/report_clock_routing_rules {report_clock_routing_rules}
redirect ../reports/${CURRENT_STEP}/report_clock_settings {report_clock_settings}

## Lib cell usage restrictions (set_lib_cell_purpose)

source ../scripts/set_lib_cell_purpose.tcl 
set_attribute [get_lib_cell */*AO*] dont_use true
set_app_var simplified_verification_mode true

 # define the verification  setup file for Formality

set_svf ${OUTPUTS_DIR}/${DESIGN_NAME}.mapped.svf

#########################################
## Sanity checks and Qor Reports
#########################################

if {$REPORT_QOR} {
        redirect ../reports/${CURRENT_STEP}/qor {source ../scripts/reports_qor.tcl}

}

report_msg -summary

print_message_info -ids * -summary

echo [date]> ../init_design

save_block -as fpu_add/init_design

save_lib

close_block

close_lib

exit






