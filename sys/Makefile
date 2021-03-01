SOURCES = *.sl lib/*.sl
BINS = cat.bin init.bin ls.bin mkdir.bin

.PHONY: all test clean

all: $(BINS)

%.bin: %.hex %.anhex
	../util/hex2bin $*.hex > $*.bin

%.hex: lib/head.s %.opt.s lib/foot.s
	cat lib/head.s $*.opt.s lib/foot.s | ../asm/asm > $*.hex

%.anhex: lib/head.s %.opt.s lib/foot.s
	cat lib/head.s $*.opt.s lib/foot.s | ../asm/asm -v > $*.anhex

%.opt.s: %.s
	../compiler/peepopt $*.s | ../compiler/peepopt > $*.opt.s

%.s: %.sl $(SOURCES)
	../compiler/slangc $*.sl > $*.s

clean:
	rm -f *.bin *.hex *.anhex *.s
