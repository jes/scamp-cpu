#!/bin/sh

# XXX: This is a script to build the kernel inside SCAMP/os, *not* for cross-compiling
# XXX: The assembler runs out of memory before successfully building the kernel, so this doesn't work yet

echo slangc...
slangc < kernel.sl > /tmp/1.s
echo cat...
cat head.s /tmp/1.s foot.s > /tmp/2.s
echo asm...
asm < /tmp/2.s > kernel.bin
rm /tmp/1.s /tmp/2.s
