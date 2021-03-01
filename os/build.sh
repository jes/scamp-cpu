#!/bin/bash

../compiler/slangc os.sl > os.s
../compiler/peepopt os.s | ../compiler/peepopt > os.opt.s
cat head.s os.opt.s foot.s | ../asm/asm -v > os.anhex &
cat head.s os.opt.s foot.s | ../asm/asm > os.hex
../util/hex2disk --start 0xd000 os.hex | ../fs/mkfs > os.disk
../util/unix2scamp motd > motd.scamp
echo -ne | ../fs/fs os.disk <<END
    mkdir etc
    put motd.scamp /etc/motd
    mkdir bin
    put ../sys/init.bin /bin/init
    put ../sys/cat.bin /bin/cat
    put ../sys/mkdir.bin /bin/mkdir
    put ../sys/ls.bin /bin/ls
END
