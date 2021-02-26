#!/bin/bash

../compiler/slangc os.sl > os.s
../compiler/peepopt os.s | ../compiler/peepopt > os.opt.s
cat head.s os.opt.s foot.s | ../asm/asm -v > os.anhex &
cat head.s os.opt.s foot.s | ../asm/asm > os.hex
../util/hex2disk --start 0xe000 os.hex | ../fs/mkfs > os.disk
../util/unix2scamp motd > motd.scamp
echo -ne "mkdir etc\nput motd.scamp /etc/motd\n" | ../fs/fs os.disk
