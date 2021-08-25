# SCAMP Boot Process

When the machine is reset, the program counter becomes 0. The first 256 words are ROM, and contain the bootloader.

The bootloader loads the kernel from disk, see `bootrom.s`.

The first 3 words of the disk should be:

  1. magic number (0x5343)
  2. start address
  3. length

The bootloader adds together all the 16-bit values that it reads (that is magic number, start address, length,
and then `length` words). So the kernel data should be followed by a 16-bit checksum value that will make
this all sum to 0. The checksum value can actually be anywhere in the kernel, as long as all the data sums to 0.

So the disk will look like:

    [magic][start addr][length][kernel code][checksum][ ... gap ... ][filesystem data]

The "... gap ..." is there to allow the kernel code to be replaced with a longer one without
having to relocate the filesystem.

Once the kernel is loaded, its job is:

  1. initialise system call jump vectors or whatever
  2. initialise peripherals
  3. load init and execute it

Init's job is currently just to display `/etc/motd/` and execute the shell, at which point the system is booted and ready
to use.

The program in `util/hex2disk` can take in a machine code program and turn it into a disk image
that will load it into address 0x100.

Example usage:

    $ asm/asm < prog.s > prog.hex
    $ util/hex2disk < prog.hex > prog.disk
    $ cd emulator/; ./scamp -i ../prog.disk
