SOURCES = fpga.v

.PHONY: test burn clean

ttlcpu.bin: ucode.hex bootrom.hex
	yosys -p "synth_ice40 -top top -json ttlcpu.json" $(SOURCES)
	nextpnr-ice40 -r --hx8k --json ttlcpu.json --package cb132 --asc ttlcpu.asc --opt-timing --pcf iceFUN.pcf
	icepack ttlcpu.asc ttlcpu.bin

ucode.hex: ucode/ucode.s
	./ucode/uasm < ucode/ucode.s > ucode.hex.tmp
	./pad-lines 2048 0000 < ucode.hex.tmp > ucode.hex

bootrom.hex: bootrom.s asm/instructions.json
	./asm/asm < bootrom.s > bootrom.hex.tmp
	./pad-lines 256 0000 < bootrom.hex.tmp > bootrom.hex

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

asm/table.html: asm/instructions.json
	./asm/mk-table-html > asm/table.html.tmp
	mv ./asm/table.html.tmp ./asm/table.html

burn: ttlcpu.bin
	iceFUNprog ttlcpu.bin

clean:
	rm -f *.asc *.bin *blif a.out ttl-*_tb.v ucode.hex ucode-low.hex ucode-high.hex bootrom-low.hex bootrom-high.hex *.tmp asm/instructions.json asm/table.html
