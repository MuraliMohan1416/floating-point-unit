

create_clock -period 1.666 -name MAIN [get_ports rclk]

set_input_delay  -add_delay -max 0.75 -clock MAIN  [remove_from_collection [all_inputs] [get_ports rclk]]


set_output_delay -add_delay -max  0.75  -clock MAIN [get_ports [all_outputs]]


set_load 0.004 [all_outputs]

set_max_fanout 200 [get_ports -filter {direction==out}] 

set_max_transition 0.1 [current_design]

set_max_capacitance 100 [current_design]
