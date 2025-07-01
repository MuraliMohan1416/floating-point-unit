read_parasitic_tech -tlup /home1/14_nmts/14_nmts/tech/star_rc/min/saed14nm_1p9m_Cmin.tluplus \
                    -layermap /home1/14_nmts/14_nmts/tech/star_rc/saed14nm_tf_itf_tluplus.map \
                    -name tlup_min
                         

set_parasitic_parameters -early_spec tlup_min\
                         -late_spec tlup_min \
                         -early_temperature -40 \
                         -late_temperature -40\
                         -corners {ff0p7vm40c}

set_voltage 0.6 -object_list VDD
set_voltage 0.0 -object_list VSS
set_process_label fast
set_process_number 0.96
set_operating_conditions -min {ff0p7vm40c} -max {ss0p6v125c}
