# FPU_add
#  scenario constraints func @ ff_m40

set_driving_cell -lib_cell INVX8_LVT [get_ports rclk]
set_driving_cell -libib_cell INVX8_RVT [remove_from_collection [all_inputs] [get_ports rclk]]
set_clock_uncertainty  -setup 0.3 [get_ports rclk]
set_clock_latency  0.4 [get_ports rclk]
set_clock_jitter  0.2 -corners {ff0p7vm40c}
