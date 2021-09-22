SOURCES = *.sl

.PHONY: all prof test clean

all: os.disk

prof: kernel.prof kernel.anhex
	../emulator/profhtml -x kernel.anhex < kernel.prof > kernel.prof.html
	xdg-open kernel.prof.html

kernel.prof: os.disk
	../emulator/scamp -i os.disk -c -p kernel.prof

os.disk: kernel.hex fs.in ../sys/*.bin motd os.disk.blank ../sys/lib.o
	cp os.disk.blank os.disk.tmp
	../fs/fs os.disk.tmp < fs.in
	mv os.disk.tmp os.disk

os.disk.blank:
	../fs/mkfs > os.disk.blank

kernel.hex: head.s kernel.opt.s foot.s
	cat head.s kernel.opt.s foot.s | ../asm/asm --verbose-file kernel.anhex.tmp > kernel.hex.tmp
	mv kernel.hex.tmp kernel.hex
	mv kernel.anhex.tmp kernel.anhex

kernel.opt.s: kernel.s
	../compiler/peepopt kernel.s | ../compiler/peepopt > kernel.opt.s.tmp
	mv kernel.opt.s.tmp kernel.opt.s

kernel.s: $(SOURCES)
	./mk-kernel-name > kernel-name.sl
	../compiler/slangc kernel.sl > kernel.s.tmp
	mv kernel.s.tmp kernel.s

clean:
	rm -f os.disk os.disk.blank kernel.prof kernel.hex kernel.anhex kernel.opt.s kernel.s *.tmp kernel.prof.html
