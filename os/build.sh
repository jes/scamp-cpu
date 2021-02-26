#!/bin/sh

../compiler/slangc os.sl > os.s
../compiler/peepopt os.s | ../compiler/peepopt > os.opt.s
cat head.s os.opt.s foot.s | ../asm/asm -v > os.anhex &
cat head.s os.opt.s foot.s | ../asm/asm > os.hex
../util/hex2disk --start 0xf000 os.hex | ../fs/mkfs > os.disk
