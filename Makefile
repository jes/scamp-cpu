SOURCES = alu.v

.PHONY: ttlcpu ucode test burn clean

ttlcpu: ucode
	yosys -p "synth_ice40 -top top -json ttlcpu.json" $(SOURCES)
	nextpnr-ice40 -r --hx8k --json ttlcpu.json --package cb132 --asc ttlcpu.asc --opt-timing --pcf iceFUN.pcf
	icepack ttlcpu.asc ttlcpu.bin

ucode: ucode/ucode.s
	ucode/uasm < ucode/ucode.s > ucode/ucode.hex

test:
	./run-tests.sh

burn:
	iceFUNprof ttlcpu.bin

clean:
	rm -f *.asc *.bin *blif a.out ttl-*_tb.v
