SOURCES = *.sl lib/*.sl
BINS = cat.bin init.bin ls.bin mkdir.bin

.PHONY: all test clean

all: $(BINS)

.PRECIOUS: %.bin
%.bin: %.hex %.anhex
	../util/hex2bin $*.hex > $*.bin.tmp
	mv $*.bin.tmp $*.bin

.PRECIOUS: %.hex
%.hex: lib/head.s %.opt.s lib/foot.s
	cat lib/head.s $*.opt.s lib/foot.s | ../asm/asm > $*.hex.tmp
	mv $*.hex.tmp $*.hex

.PRECIOUS: %.anhex
%.anhex: lib/head.s %.opt.s lib/foot.s
	cat lib/head.s $*.opt.s lib/foot.s | ../asm/asm -v > $*.anhex.tmp
	mv $*.anhex.tmp $*.anhex

.PRECIOUS: %.opt.s
%.opt.s: %.s
	../compiler/peepopt $*.s | ../compiler/peepopt > $*.opt.s.tmp
	mv $*.opt.s.tmp $*.opt.s

.PRECIOUS: %.s
%.s: %.sl $(SOURCES)
	../compiler/slangc $*.sl > $*.s.tmp
	mv $*.s.tmp $*.s

clean:
	rm -f *.bin *.hex *.anhex *.s *.tmp
