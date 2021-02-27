#!/bin/bash

../compiler/slangc init.sl > init.s
../compiler/peepopt init.s | ../compiler/peepopt > init.opt.s
cat lib/head.s init.opt.s lib/foot.s | ../asm/asm -v > init.anhex &
cat lib/head.s init.opt.s lib/foot.s | ../asm/asm > init.hex
../util/hex2bin init.hex > init.bin
