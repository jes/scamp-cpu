SOURCES = verilog/fpga.v

.PHONY: all test burn clean emulator kernel sys web

all: doc/table.html emulator kernel sys bootrom.hex ucode.hex testrom.hex web

ttlcpu.bin: ucode.hex testrom.hex
	yosys -p "synth_ice40 -top top -json ttlcpu.json" $(SOURCES)
	nextpnr-ice40 -r --hx8k --json ttlcpu.json --package cb132 --asc ttlcpu.asc --opt-timing --pcf verilog/iceFUN.pcf
	icepack ttlcpu.asc ttlcpu.bin

ucode.hex: ucode/ucode.s
	./ucode/uasm < ucode/ucode.s > ucode.hex.tmp
	util/pad-lines 2048 0000 < ucode.hex.tmp > ucode.hex
	rm ucode.hex.tmp

testrom.hex: testrom.s asm/instructions.json
	./asm/asm < testrom.s > testrom.hex.tmp
	util/pad-lines 256 0000 < testrom.hex.tmp > testrom.hex
	rm testrom.hex.tmp

bootrom.hex: bootrom.s asm/instructions.json
	./asm/asm < bootrom.s > bootrom.hex.tmp
	util/pad-lines 256 0000 < bootrom.hex.tmp > bootrom.hex
	rm bootrom.hex.tmp

test8250.hex: test8250.s
	./asm/asm < test8250.s > test8250.hex.tmp
	mv test8250.hex.tmp test8250.hex

ucode-low.hex: ucode.hex
	sed 's/^..//' ucode.hex > ucode-low.hex
ucode-high.hex: ucode.hex
	sed 's/..$$//' ucode.hex > ucode-high.hex

testrom-low.hex: testrom.hex
	sed 's/^..//' testrom.hex > testrom-low.hex
testrom-high.hex: testrom.hex
	sed 's/..$$//' testrom.hex > testrom-high.hex

bootrom-low.hex: bootrom.hex
	sed 's/^..//' bootrom.hex > bootrom-low.hex
bootrom-high.hex: bootrom.hex
	sed 's/..$$//' bootrom.hex > bootrom-high.hex

test8250-low.hex: test8250.hex
	sed 's/^..//' test8250.hex > test8250-low.hex
test8250-high.hex: test8250.hex
	sed 's/..$$//' test8250.hex > test8250-high.hex

test: ucode-low.hex ucode-high.hex testrom-low.hex testrom-high.hex emulator
	make -C emulator/ test
	cd compiler/ && ./run-test.sh
	cd fs/ && ./run-test.sh
	cd verilog/ && ./run-tests.sh

asm/instructions.json: ucode/ucode.s
	./ucode/mk-instructions-json < ucode/ucode.s > asm/instructions.json.tmp
	mv ./asm/instructions.json.tmp ./asm/instructions.json

sys/asmparser.sl: asm/instructions.json
	./asm/mk-asm-parser > ./sys/asmparser.sl.tmp
	mv ./sys/asmparser.sl.tmp ./sys/asmparser.sl

doc/table.html: asm/instructions.json
	./asm/mk-table-html > doc/table.html.tmp
	mv ./doc/table.html.tmp ./doc/table.html

emulator:
	make -C emulator/

kernel:
	make -C kernel/

sys: sys/asmparser.sl
	make -C sys/

web:
	make -C web/

burn: ttlcpu.bin
	iceFUNprog ttlcpu.bin

clean:
	rm -f *.asc *.bin *blif verilog/a.out verilog/ttl-*_tb.v ucode.hex ucode-low.hex ucode-high.hex bootrom.hex testrom.hex testrom-low.hex testrom-high.hex *.tmp asm/instructions.json sys/asmparser.sl ttlcpu.json
	make -C emulator/ clean
	make -C kernel/ clean
	make -C sys/ clean
