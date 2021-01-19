SOURCES = alu.v

.PHONY: ttlcpu test burn clean

ttlcpu:
	yosys -p "synth_ice40 -top top -json ttlcpu.json" $(SOURCES)
	nextpnr-ice40 -r --hx8k --json ttlcpu.json --package cb132 --asc ttlcpu.asc --opt-timing --pcf iceFUN.pcf
	icepack ttlcpu.asc ttlcpu.bin

test:
	./run-tests.sh

burn:
	iceFUNprof ttlcpu.bin

clean:
	rm *.asc *.bin *blif a.out
