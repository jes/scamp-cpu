# Cards

## Physical dimensions

Cards are 237.49 mm long, 102.87 mm wide.

The backplane connector is at the back of the card, on the top side, in the centre. The rearmost holes
for the backplane connector pins are set forward 2.54 mm from the rear edge of the card.

Mounting holes for the front panel are set back 5.08 mm from the front edge of the card and set in 7.62 mm
from the side edge of the card. The holes are 3.2 mm in diameter, intended to take an M3 screw.

Leave a good few mm clear of components at each side of the card to slide in the guide rails.

For designing front panels, start with e.g. `front-panels/memory-panel.FCStd` and move the holes to suit
the card, then use e.g. `front-panels/memory-panel.svg` in Inkscape to lay out the text. Then engrave the
text in aluminium plate using the CNC machine (use gcodetools "path to gcode" in Inkscape) and then cut
the part out using a 4mm end mill.

Vertical spacing between cards in the backplane is 40 mm.

## ALU

The ALU is comprised of 2 identical PCBs, populated differently.

The lower card stores the low byte of the X and Y register,
and computes the low byte of the ALU output, and has the bus connection solder-jumpers connected to the low byte of the bus.

The upper card stores the high byte of the X and Y register, stores the flags register, computes the high byte of the ALU output,
and has the bus connection solder-jumpers connected to the high byte of the bus.

All parts not explicitly mentioned below must be populated on both cards (including LED connection headers and the backplane connector).

### Lower card

Do not populate U4 (flags register) or U6 (computes the Z flag). Do not populate the corresponding capacitors, C10 and C23.

Using either a male pin header or a wire, connect "carry" to "GND" on J6 (the "in" jumper). "nz"
on J6 can be left disconnected.

Install a male pin header on J7 (the "out" jumper).

Do not populate J5 (flags register LED header). Do not populate the corresponding resistors, R28 and R29.

### Upper card

Install a male pin header on J6 on the *bottom* of the card.

Do not populate J7.

### Assembly

Use 2 jumper wires to connect "nz" and "carry" from J7 of the lower card to J6 of the upper card.

Use standoffs and M3 screws to connect the two cards together using the mounting holes at the back.

Plug in the LED wires from the aluminium front panel to the appropriate headers.

Use standoffs, M3 screws, and the front panel to connect the two cards together using the
mounting holes at the front.

Hopefully the card can now slide into the chassis and connect to the backplane.

## Instruction

The EO, PO, IOH, IOL, ... header for LEDs has polarity reversed. The last pin has VCC instead of
ground, and the signals are active-low.

Unused microcode decodings can be exposed on the backplane via jumpers. The available decodings are:

| Label | Microcode | Backplane pin | Notes |
| :---- | :-------- | :------------ | :---- |
| i7    | bus_in==7 | 27            | |
| u8    | bit 8     | 37            | pin used for `DO` |
| o7    | bus_out==7 | 36           | |
| o5    | bus_out==5 | 35           | pin used for serial console |
| o4    | bus_out==4 | 34           | pin used for serial console |
| u1    | bit 1      | 33           | pin used for `RT` |

Microcode bit 0 is exposed on backplane pin 32 without a jumper, and the pin is now used for `DI`.

### Errata

ZIF socket holes are too small. My solution was to solder some clipped-off LED legs onto the ZIF socket
pins and then solder these to the PCB.

U8 and U9 (bus_in/out decode) should have pins 4 and 5 (chip enable) tied to VCC instead of GND.

U9 (bus_in decode) should have pin 6 (chip enable) tied to VCC instead of EO_bar.

U17 should have pin 3 output inverted:

 * pop pin 3 out of socket
 * connect pin 3 of IC to pins 9+10
 * connect pin 8 of IC to pin 3 of socket

`RT` needs to come directly from a microcode bit rather than being decoded, because it acts immediately and can "glitch".
To match current generated microcode:

 * pop pins 4+5 of U5 out of socket
 * connect pins 4+5 of U5 to the "u1" pin of "spare decodings"

We have the same problem with `DO`/`DI`, when device I/O can cause side effects. The solution is:

 * on the bottom of the card, solder a link between backplane connector pins for `DI` and `U0`
 * on the top of the card, stick a jumper on the "spare decodings" pin labelled "u8" and solder it on to the backplane
   connector pin for `DO`

## Memory

### Errata

ZIF socket holes are too small. Initially I just forced them into the holes, but this bent the legs of the
"high byte" ROM socket, and I had to replace it. Better solution is to solder clipped-off LED legs onto the
socket pins and then solder these to the PCB.

## Backplane

### Errata

Spare pin assignments:

 * 27: "spare_i7": **free**
 * 32: "U0": used for `DI`
 * 33: "spare_U1": used for `RT`
 * 34: "spare_o4": serial console
 * 35: "spare_o5": serial console
 * 36: "spare_o7": **free**
 * 37: "spare_U8": used for `DO`
 * 38: "unused": used for `WR` signal generated by serial card

## Serial

Initially, only populate the oscillator circuit on UART 0.

    Crystal: 1.8432 MHz
    Caps: 30 nF
    Resistor: 100 Ohm

Ideally, the 4 solder jumpers in the middle can be bridged, to share the 1.8432 MHz oscillator between
all of the UARTs. If that is not possible, then un-solder them and populate the other oscillators as well.

The 2x5 pin connector is for jumpers to allow easy disconnection of signals from the connector. The 1x6 connector
should go up with wires to the connector on the front panel.

Each UART has 8 addresses, consecutive starting from a base address. A7 (0x80) needs to be high to select the
UARTs, and then there's 1 bit (A3,A4,A5,A6) of address to select each UART.

Addresses:

    UART 0: A3+A7: base address = 136
    UART 1: A4+A7: base address = 144
    UART 2: A5+A7: base address = 160
    UART 3: A6+A7: base address = 192

It would probably work to initialise all of the UARTs by setting all 5 address bits high, which is base address = 248.

I plan to only install UART 0 at first, and then populate the rest of the slots as and when I want to use them.

### Errata

Use bodge wire to connect `WR` pin to backplane pin 38, marked "unused" on backplane.

Use bodge wire to connect `TX` pin of UART 0 to pin 34, marked "spare_o4" on backplane.

Use bodge wire to connect `RX` pin of UART 0 to pin 35, marked "spare_o5" on backplane.

LEDs need to be wired with signal on cathode and VCC on anode.

## Storage

1 card is internal, the other card is removable through the front panel.

Each card has 2 CS pins. A8 (0x100) needs to be high to select the CompactFlash, and then there's 1 bit
(A3,A4,A5,A6) of address to select each CS pin.

Addresses:

    Card 1, CS0: A3+A8: base address = 264
    Card 1, CS1: A4+A8: base address = 272
    Card 2, CS0: A5+A8: base address = 288
    Card 2, CS1: A6+A8: base address = 320
