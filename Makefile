SOURCES = verilog/fpga.v

.PHONY: all test burn clean

all: ttlcpu.bin doc/table.html emulator/scamp

ttlcpu.bin: ucode.hex bootrom.hex
	yosys -p "synth_ice40 -top top -json ttlcpu.json" $(SOURCES)
	nextpnr-ice40 -r --hx8k --json ttlcpu.json --package cb132 --asc ttlcpu.asc --opt-timing --pcf verilog/iceFUN.pcf
	icepack ttlcpu.asc ttlcpu.bin

ucode.hex: ucode/ucode.s
	./ucode/uasm < ucode/ucode.s > ucode.hex.tmp
	util/pad-lines 2048 0000 < ucode.hex.tmp > ucode.hex

bootrom.hex: bootrom.s asm/instructions.json
	./asm/asm < bootrom.s > bootrom.hex.tmp
	util/pad-lines 256 0000 < bootrom.hex.tmp > bootrom.hex

ucode-low.hex: ucode.hex
	sed 's/^..//' ucode.hex > ucode-low.hex
ucode-high.hex: ucode.hex
	sed 's/..$$//' ucode.hex > ucode-high.hex

bootrom-low.hex: bootrom.hex
	sed 's/^..//' bootrom.hex > bootrom-low.hex
bootrom-high.hex: bootrom.hex
	sed 's/..$$//' bootrom.hex > bootrom-high.hex

test: ucode-low.hex ucode-high.hex bootrom-low.hex bootrom-high.hex emulator/scamp
	cd emulator/ && ./scamp -t
	cd verilog && ./run-tests.sh

asm/instructions.json: ucode/ucode.s
	./ucode/mk-instructions-json < ucode/ucode.s > asm/instructions.json.tmp
	mv ./asm/instructions.json.tmp ./asm/instructions.json

doc/table.html: asm/instructions.json
	./asm/mk-table-html > doc/table.html.tmp
	mv ./doc/table.html.tmp ./doc/table.html

emulator/scamp: emulator/scamp.c
	cc -o emulator/scamp $< -Wall -Wextra

burn: ttlcpu.bin
	iceFUNprog ttlcpu.bin

clean:
	rm -f *.asc *.bin *blif verilog/a.out verilog/ttl-*_tb.v ucode.hex ucode-low.hex ucode-high.hex bootrom.hex bootrom-low.hex bootrom-high.hex *.tmp asm/instructions.json ttlcpu.json emulator/scamp
