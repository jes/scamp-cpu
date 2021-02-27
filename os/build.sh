#!/bin/bash

../compiler/slangc os.sl > os.s
../compiler/peepopt os.s | ../compiler/peepopt > os.opt.s
cat head.s os.opt.s foot.s | ../asm/asm -v > os.anhex &
cat head.s os.opt.s foot.s | ../asm/asm > os.hex
../util/hex2disk --start 0xe000 os.hex | ../fs/mkfs > os.disk
../util/unix2scamp motd > motd.scamp
../util/hex2bin init.hex > init.bin
echo -ne | ../fs/fs os.disk <<END
    mkdir etc
    put motd.scamp /etc/motd
    mkdir bin
    put init.bin /bin/init
END
