###########################################
####       creating_workspace
###########################################

create_workspace -technology  /home1/14_nmts/14_nmts/tech/milkyway/saed14nm_1p9m_mw.tf -flow normal fpu_add_ndm

############################################
####          reding_gds_files
############################################

read_gds /home1/PD06/SmuraliM/RM_FPU/RM/FPU/pnr/fpu_add/outputs/fpu-add.gds

##########################################
#####  checking_workspace
#########################################
 

check_workspace


#########################################
#####   commiting workspace
########################################

file delete -force fpu_add.ndm
commit_workspace -output fpu_add.ndm

########################################
#####         opening_lib
#########################################

open_lib ./fpu_add.ndm

open_block fpu_add.frame

close_lib

create_workspace -flow edit ./fpu_add.ndm

set_attribute [get_lib_cells fpu_add] design_type macro