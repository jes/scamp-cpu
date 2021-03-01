SOURCES = *.sl

.PHONY: all prof test clean userspace

all: os.disk os.anhex

prof: os.prof os.anhex
	../emulator/profhtml -x os.anhex < os.prof > os.prof.html
	xdg-open os.prof.html

os.prof: os.disk
	../emulator/scamp -i os.disk -c -p os.prof

userspace:
	make -C ../sys/

os.disk: os.hex fs.in userspace
	../util/hex2disk --start 0xd000 os.hex | ../fs/mkfs > os.disk
	../util/unix2scamp motd > motd.scamp
	../fs/fs os.disk < fs.in

os.hex: head.s os.opt.s foot.s
	cat head.s os.opt.s foot.s | ../asm/asm > os.hex

os.anhex: head.s os.opt.s foot.s
	cat head.s os.opt.s foot.s | ../asm/asm -v > os.anhex

os.opt.s: os.s
	../compiler/peepopt os.s | ../compiler/peepopt > os.opt.s

os.s: $(SOURCES)
	../compiler/slangc os.sl > os.s

clean:
	rm -f os.disk os.prof os.hex os.anhex os.opt.s os.s
