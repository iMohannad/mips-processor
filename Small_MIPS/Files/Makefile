# if using Makefile for iverilog:
# - change $stop to $finish is testbenches
# - uncomment "initial $dumpvars(0, tb_name);" to get waveforms
source=pd2_tb.sv memory.sv regfile.sv mips.sv
iFlags=-g2005-sv

.PHONY: run
run: SimpleAdd

# tb_SimpleAdd
.PHONY: SimpleAdd
SimpleAdd: tb_SimpleAdd.vvp
	vvp $<

.PHONY: SimpleAdd-debug
SimpleAdd-debug: tb_SimpleAdd.lx2
	gtkwave -A $< &

tb_SimpleAdd.vvp: $(source) SimpleAdd.x
	iverilog $(iFlags) -s tb_SimpleAdd -o $@ $(source)

%.lx2: %.vvp
	vvp $< -lxt2
	mv dump.lx2 $@

clean:
	rm -f *.vvp *.lx2 *.vcd
