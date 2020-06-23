add_files ../mm_axi.v ../mm.sv ../mem_read_m0.sv ../mem_read_m1.sv ../systolic.sv ../counter.v ../pe.v ../mem_write.sv ../pipe.sv
read_xdc floorplan.xdc
set depth 1024

create_ip -name blk_mem_gen -vendor xilinx.com -library ip -version 8.4 -module_name blk_mem_gen_0
set_property -dict [list CONFIG.Memory_Type {True_Dual_Port_RAM} CONFIG.Write_Width_A {16} CONFIG.Write_Depth_A $depth CONFIG.Read_Width_A {16} CONFIG.Write_Width_B {16} CONFIG.Read_Width_B {16} CONFIG.Enable_B {Use_ENB_Pin} CONFIG.Register_PortA_Output_of_Memory_Primitives {false} CONFIG.Register_PortB_Output_of_Memory_Primitives {false} CONFIG.Port_B_Clock {100} CONFIG.Port_B_Write_Rate {50} CONFIG.Port_B_Enable_Rate {100}] [get_ips blk_mem_gen_0]
generate_target {instantiation_template} [get_files ./tutorial/tutorial.srcs/sources_1/ip/blk_mem_gen_0/blk_mem_gen_0.xci]
set_property generate_synth_checkpoint 0 [get_files blk_mem_gen_0.xci]

set_property source_mgmt_mode All [current_project]
update_compile_order -fileset sources_1
