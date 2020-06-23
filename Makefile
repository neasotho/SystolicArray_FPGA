clean:
	rm -Rf a.out vivado.* overlay/tutorial transcript lab4.vcd dump.vcd vsim.wlf

iverilog:
	python make_mem.py $M $N
	iverilog -g2012 -Pdut_tb.M=$M -Pdut_tb.N=$N dut_tb.sv pipe.sv systolic.sv counter.v pe.v mem_read_m0.sv mem_read_m1.sv
	./a.out
	gtkwave lab4.vcd

iverilog-txt:
	python make_mem.py $M $N
	iverilog -g2012 -Pdut_tb.M=$M -Pdut_tb.N=$N dut_tb.sv pipe.sv systolic.sv counter.v pe.v mem_read_m0.sv mem_read_m1.sv
	./a.out

modelsim:
	python make_mem.py $M $N
	vsim -do "do lab4-sim.tcl $M $N"

modelsim-txt:
	vsim -c -do "do lab4-sim.tcl $M $N"

vivado:	
	rm -rf vivado*
	rm -rf overlay/tutorial
	echo "set M $M" > overlay/size.tcl
	echo "set N $N" >> overlay/size.tcl
	cd overlay && vivado -source build.tcl

board:
	scp lab4-board.py xilinx@pynq.eng.uwaterloo.ca:~/
	scp overlay/tutorial.* xilinx@pynq.eng.uwaterloo.ca:~/
	ssh -t xilinx@pynq.eng.uwaterloo.ca "sudo python3.6 lab4-board.py $M $N"

test:
	python make_mem.py $M $N
	iverilog -g2012 -Pdut_tb.M=$M -Pdut_tb.N=$N dut_tb.sv pipe.sv systolic.sv counter.v pe.v mem_read_m0.sv mem_read_m1.sv
	./a.out
	python test.py $N
