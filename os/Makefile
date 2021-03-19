SOURCES = *.sl

.PHONY: all prof test clean

all: os.disk os.anhex

prof: os.prof os.anhex
	../emulator/profhtml -x os.anhex < os.prof > os.prof.html
	xdg-open os.prof.html

os.prof: os.disk
	../emulator/scamp -i os.disk -c -p os.prof

os.disk: os.hex fs.in ../sys/*.bin motd
	../fs/mkfs < /dev/null > os.disk.tmp
	../fs/fs os.disk.tmp < fs.in
	mv os.disk.tmp os.disk

os.hex: head.s os.opt.s foot.s
	cat head.s os.opt.s foot.s | ../asm/asm > os.hex.tmp
	mv os.hex.tmp os.hex

os.anhex: head.s os.opt.s foot.s
	cat head.s os.opt.s foot.s | ../asm/asm -v > os.anhex.tmp
	mv os.anhex.tmp os.anhex

os.opt.s: os.s
	../compiler/peepopt os.s | ../compiler/peepopt > os.opt.s.tmp
	mv os.opt.s.tmp os.opt.s

os.s: $(SOURCES)
	../compiler/slangc os.sl > os.s.tmp
	mv os.s.tmp os.s

clean:
	rm -f os.disk os.prof os.hex os.anhex os.opt.s os.s *.tmp os.prof.html
