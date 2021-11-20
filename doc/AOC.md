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

## Usage

This is roughly implemented now.

Go into `aoc/`. For the emulator, start the proxy with:

    scamp-cpu/aoc$ socat pty,raw,echo=0,link=../serial exec:./aocproxy

And run the emulator with:

    scamp-cpu/kernel$ ./run --serial ../serial

For the real computer, something like:

    scamp-cpu/aoc$ socat /dev/ttyUSB0,raw,echo=0 exec:./aocproxy

## Serial protocol

All requests are initiated from the SCAMP side ("client") and handled by the Linux side ("server").

### Request

All requests take the form:

    METHOD TYPE SIZE PATH
    BODY

Where `METHOD` is typically `get` or `put`, `TYPE` is the type of request, e.g. `aoc` for Advent of
Code, `SIZE` is the size of the request `BODY`, and `PATH` is the path to request.

Examples:

    get aoc 0 /2020/1

This request has no body (`SIZE == 0`).

    put aoc 5 /2020/1/1
    12345

This request has a body of length 5.
