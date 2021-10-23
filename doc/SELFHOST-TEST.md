# Self-hosting test

With the compiler-specific test no longer working properly, I think a good
end-to-end self-hosting test is in order.

It should load up the OS in the kernel, and run something like:

    cd /src
    ./build.sh
    cd /src/kernel
    ./build.sh
    kwr kernel.bin c400
    reboot
    echo "Great success"

The test harness should make some effort to ensure:

 * a new line of the input is given every time the shell prompts for one
 * the VM actually reboots when instructed
 * the new kernel is running instead of the old one (maybe check the `kernel-name.sl`
   output?)
 * any text output containing "error:" counts as an output
 * (bonus) we should have `install.sh` under `/src` to install the system utilities,
   and check that they still work when self-hosted
 * (bonus) rebuild the system again, using the toolchain that was built from under
   SCAMP/os

Probably just want a Perl script to fire up the emulator and manage input/output.
Input maybe needs to be "drip-fed" because of the slowness of the serial port?
