SOURCES = top.v

.PHONY: ttlcpu test burn clean

ttlcpu: ucode.hex
	yosys -p "synth_ice40 -top top -json ttlcpu.json" $(SOURCES)
	nextpnr-ice40 -r --hx8k --json ttlcpu.json --package cb132 --asc ttlcpu.asc --opt-timing --pcf iceFUN.pcf
	icepack ttlcpu.asc ttlcpu.bin

ucode.hex: ucode/ucode.s
	./ucode/uasm < ucode/ucode.s > ucode.hex.tmp
	mv ucode.hex.tmp ucode.hex

ucode-low.hex: ucode.hex
	sed 's/^..//' ucode.hex > ucode-low.hex
ucode-high.hex: ucode.hex
	sed 's/..$$//' ucode.hex > ucode-high.hex

bootrom-low.hex: bootrom.hex
	sed 's/^..//' bootrom.hex > bootrom-low.hex
bootrom-high.hex: bootrom.hex
	sed 's/..$$//' bootrom.hex > bootrom-high.hex

test: ucode-low.hex ucode-high.hex bootrom-low.hex bootrom-high.hex
	./run-tests.sh

asm/instructions.json: ucode/ucode.s
	./ucode/mk-instructions-json < ucode/ucode.s > asm/instructions.json.tmp
	mv ./asm/instructions.json.tmp ./asm/instructions.json

burn:
	iceFUNprof ttlcpu.bin

clean:
	rm -f *.asc *.bin *blif a.out ttl-*_tb.v ucode.hex ucode-low.hex ucode-high.hex bootrom-low.hex bootrom-high.hex *.tmp asm/instructions.json
