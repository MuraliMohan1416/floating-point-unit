# FPU_ADD 
# SCENARIO CONSTRAINTS SS0P6V125C

set_driving_cell -lib_cell INVX8_LVT [get_ports rclk]

set_driving_cell -lib_cell  INVX8_RVT [remove_from_collection [all_inputs] [get_ports rclk]]

set_clock_uncertainty -setup 0.3 [get_ports rclk]

set_clock_latency  0.6 [get_ports rclk]

set_clock_uncertainty -hold 0.1 [get_ports rclk]

set_clock_jitter 0.1 -corners ss0p6v125c