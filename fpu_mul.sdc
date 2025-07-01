
set ip [remove_from_collection [all_inputs] [get_ports rclk]]

if {[shell_is_in_topographical_mode]} {

     set scenario turbo.ss0p72v125c_WC.RC_MAX

     create_scenario ${scenario} 

   create_clock -period 1.666 -name MAIN [get_ports rclk]

   set_input_delay 0.55 -clock MAIN [get_ports [all_inputs]]

   set_output_delay 0.55  -clock MAIN [get_ports [all_outputs]]

   set_load  0.004 [all_outputs]
 
   set_max_fanout 200 [current_design]

   set_max_transition 0.1 [current_design]

  set_max_capacitance 100 [current_design]

  set_voltage 0.6 -object_list {VDDH}
 set_voltage 0.72 -object_list {VDD} 
  set_voltage 0.0 -object_list {VSS}
  
  set_operating_conditions  -max ss0p72v125c
  
  set_tlu_plus_files -max_tluplus /home1/14_nmts/14_nmts/tech/star_rc/max/saed14nm_1p9m_Cmax.tluplus \
                     -min_tluplus /home1/14_nmts/14_nmts/tech/star_rc/min/saed14nm_1p9m_Cmin.tluplus \
                     -tech2itf_map /home1/14_nmts/14_nmts/tech/star_rc/saed14nm_tf_itf_tluplus.map

  #set_scenario_options -setup true -hold false -leakage_power false

  report_scenario_options
} else {
    create_clock -period 1.666 -name MAIN [get_ports rclk]
    
    set_input_delay 0.75 -clock MAIN  [get_ports [all_inputs]]

    set_output_delay 0.755 -clock MAIN [get_ports [all_outputs]]

    set_load 0.004 [all_outputs]

    set_max_fanout 200 [current_design]

    set_max_transition 0.1 [current_design]
 
    set_max_capacitance 100 [current_design]
     
    set_voltage 0.6 -object_list {VDDH}

 set_voltage 0.72 -object_list {VDD} 

    set_voltage 0.0 -object_list {VSS}
  
  #  set_operating_conditions -max ss0p72v125c

    #set_scenario_options -setup true -hold false -leakage_power false

    
}

