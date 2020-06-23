vlib work
vlog -sv rtl/dut_tb.sv rtl/pipe.sv rtl/systolic.sv rtl/mem_read_m0.sv rtl/mem_read_m1.sv
vlog rtl/counter.v rtl/pe.v
vsim -GM=$1 -GN=$2 dut_tb
log -r /*
add wave sim:/dut_tb/*
config wave -signalnamewidth 1
run 10250 ns
