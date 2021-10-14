# Advent of Code

I want to be able to read Advent of Code problem statements, and submit solutions, directly from
SCAMP. This means having my Linux computer expose an interface to Advent of Code over the serial port,
and that means we need a protocol for this.

I think we could use some extension of Xmodem (YModem? ZModem?) to implement arbitrary "protocols"
by acting like GET or POST to "paths" that specify a protocol. For example, to download a file from the
Linux computer, the path would begin with "file:", e.g. "file:/path/to/file". To grab an Advent of
Code problem statement, the path would begin "aoc:" and name the year and problem number, like
"aoc:/2021/01", and to submit an answer you'd just "upload a file" containing the solution,
to the same path.

Then we could put the extended Xmodem implementation in a library for convenient access, and make
a handy CLI for grabbing problem statements and submitting solutions.
