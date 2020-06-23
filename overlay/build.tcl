source size.tcl
source tutorial.tcl
add_files -norecurse [make_wrapper -files [get_files "[current_bd_design].bd"] -top]
update_compile_order -fileset sources_1
set_property top tutorial_wrapper [current_fileset]
update_compile_order -fileset sources_1
launch_runs synth_1 -jobs 3 
wait_on_run synth_1
launch_runs impl_1 -to_step write_bitstream -jobs 3
wait_on_run impl_1
file copy -force tutorial/tutorial.runs/impl_1/tutorial_wrapper.bit tutorial.bit
file copy -force tutorial/tutorial.srcs/sources_1/bd/tutorial/hw_handoff/tutorial.hwh tutorial.hwh
close_project
