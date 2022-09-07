LIBS = lib/*.sl
BINS = cat.bin init.bin ls.bin mkdir.bin sh.bin pwd.bin echo.bin stat.bin rm.bin slangc.bin asm.bin hd.bin grep.bin more.bin wc.bin head.bin mv.bin slc.bin kilo.bin reboot.bin diskid.bin baud.bin cp.bin dc.bin keys.bin isprime.bin hamurabi.bin opts.bin mandel.bin sort.bin mandelfix.bin fc.bin snake.bin reset.bin true.bin while.bin rx.bin sx.bin du.bin aoc.bin df.bin kwr.bin ser.bin rsh.bin ps.bin rude.bin fsck.bin lisp.bin slangi.bin

.PHONY: all test clean

all: $(BINS) lib.o rude-globals.sl

.PRECIOUS: %.bin
%.bin: %.hex lib.o
	../util/hex2bin $*.hex > $*.bin.tmp
	mv $*.bin.tmp $*.bin

%.hex: lib/head.s %.opt.s lib/foot.s
	cat lib/head.s $*.opt.s lib/foot.s | ../asm/asm --verbose-file $*.anhex.tmp > $*.hex.tmp
	mv $*.hex.tmp $*.hex
	mv $*.anhex.tmp $*.anhex

%.opt.s: %.s
	../compiler/peepopt $*.s | ../compiler/peepopt > $*.opt.s.tmp
	mv $*.opt.s.tmp $*.opt.s

%.s: %.sl $(LIBS)
	../compiler/slangc $*.sl > $*.s.tmp
	mv $*.s.tmp $*.s

lib.o: $(LIBS) make-lib
	./make-lib

rude-globals.sl: lib.list mk-rude-globals
	./mk-rude-globals > rude-globals.sl

clean:
	rm -f *.bin *.hex *.anhex *.s *.tmp lib*.o lib*.s.build lib*.h
