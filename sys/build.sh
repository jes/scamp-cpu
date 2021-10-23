#!/bin/sh

# XXX: This is a script to build inside SCAMP/os, *not* for cross-compiling

slc < aoc.sl > aoc
slc < asm.sl > asm
slc < baud.sl > baud
slc < cat.sl > cat
slc < cp.sl > cp
slc -lbigint < dc.sl > dc
slc -lfixed < df.sl > df
slc < slc.sl < diskid.sl > diskid
slc -lbigint < du.sl > du
slc < echo.sl > echo
slc -lfixed < fc.sl > fc
slc < grep.sl > grep
slc < hamurabi.sl > hamurabi
slc < hd.sl > hd
slc < head.sl > head
slc < init.sl > init
slc -lbigint < isprime.sl > isprime
slc < keys.sl > keys
slc < kilo.sl > kilo
slc < kwr.sl > kwr
slc < ls.sl > ls
slc -lbigint < mandel.sl > mandel
slc -lfixed < mandelfix.sl > mandelfix
slc < mkdir.sl > mkdir
slc < more.sl > more
slc < mv.sl > mv
slc < opts.sl > opts
slc < pwd.sl > pwd
slc < reboot.sl > reboot
slc < reset.sl > reset
slc < rm.sl > rm
slc < rx.sl > rx
slc < sh.sl > sh
slc < slangc.sl > slangc
slc < slc.sl > slc
slc < snake.sl > snake
slc -lbigint < sort.sl > sort
slc < stat.sl > stat
slc < sx.sl > sx
slc < true.sl > true
slc -lbigint < wc.sl > wc
slc < while.sl > while
