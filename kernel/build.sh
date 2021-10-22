#!/bin/sh

# XXX: This is a script to build the kernel inside SCAMP/os, *not* for cross-compiling

echo slangc...
slangc < kernel.sl > /tmp/1.s
echo cat...
cat head.s /tmp/1.s foot.s > /tmp/2.s
echo asm...
asm < /tmp/2.s > kernel.bin
rm /tmp/1.s /tmp/2.s
