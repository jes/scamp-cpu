# Cards

## Physical dimensions

Cards are 237.49 mm long, 102.87 mm wide.

The backplane connector is at the back of the card, on the top side, in the centre. The rearmost holes
for the backplane connector pins are set forward 2.54 mm from the rear edge of the card.

Mounting holes for the front panel are set back 5.08 mm from the front edge of the card and set in 7.62 mm
from the side edge of the card. The holes are 3.2 mm in diameter, intended to take an M3 screw.

Leave a good few mm at each side of the card to slide in the guide rails.

What dimensions to use for the 3d printed front panel? In particular, we need to ensure that the ALU card
has space for wires to pass between the upper and lower decks to connect to the LEDs.

What vertical spacing between cards? We only really need room to fit:

 * a populated ZIF socket
 * plugged-in pin header for LED wires

If the backplane is going to be made of multiple PCBs connected together, then it's worth thinking about
how (if) the uniform connector spacing is going to be maintained across the join.

Also worth thinking about how the case is going to be constructed. We want:

 * a power supply
 * guide rails to guide the cards onto the backplane connector
 * some mechanism to cause the cards to unplug from the backplane without being unduly inconvenient

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

### Front panel

At time of writing, I have not designed the front panel. I envisage a plastic part that will:

 * house LEDs for the front display, split into groups of 4 bits, and labelled
 * somehow grab around the front standoffs so that pulling on the plastic part mechanically pulls
   the card, and doesn't just slip off
 * have some mechanism to apply some force to disconnect the backplane connector without just having
   to pull on the cards

Preparing the front panel will involve installing the LEDs (maybe they'll need to be glued?), connecting
the LED grounds of each group together, and connecting wires to them (1 for each LED positive side, and 1 for
ground for each group). The groups of wires will then go to female pin headers (mostly 9 pins, but 3 for flags).
The pin headers should be labelled:

 * X lower
 * X upper
 * Y lower
 * Y upper
 * Result lower
 * Result upper
 * Flags

### Assembly

Use 2 jumper wires to connect "nz" and "carry" from J7 of the lower card to J6 of the upper card.

Use standoffs and M3 screws to connect the two cards together using the mounting holes at the back.

Plug in the LED wires from the 3d-printed front panel to the appropriate headers.

Use standoffs, M3 screws, and the 3d-printed front panel to connect the two cards together using the
mounting holes at the front.

Hopefully the card can now slide into the chassis and connect to the backplane.

## Instruction

The EO, PO, IOH, IOL, ... header for LEDs has polarity reversed. The last pin has VCC instead of
ground, and the signals are active-low.

Unused microcode decodings can be exposed on the backplane via jumpers. The available decodings are:

| Label | Microcode | Backplane pin |
| :---- | :-------- | :------------ |
| i7    | bus_in==7 | 27 |
| u8    | bit 8     | 37 |
| o7    | bus_out==7 | 36 |
| o5    | bus_out==5 | 35 |
| o4    | bus_out==4 | 34 |
| u1    | bit 1      | 33 |

Microcode bit 0 is exposed on backplane pin 32 without a jumper, even though it is currently unused.

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

We may have the same problem with `DO`, if reading from a device can cause side effects.

## Memory

### Errata

ZIF socket holes are too small. Initially I just forced them into the holes, but this bent the legs of the
"high byte" ROM socket, and I had to replace it. Better solution is to solder clipped-off LED legs onto the
socket pins and then solder these to the PCB.

## Backplane

I plan to (at least attempt to) make the backplane on the CNC machine.

Traces are all on the back-side copper layer. There is also silkscreen labelling the pins on the top side. It's not the
end of the world if I can't have the text. My vague plan is to spray-paint the non-copper side of the board black and then
engrave the text into it, so the paint is removed where the text goes.

The backplane board is 302.0 mm by 102.80 mm.

The connectors are spaced 40 mm apart.

There is a 3.2 mm mounting hole lined up with the centre of each connector, spaced apart horizontally by 92.0 mm.

CNC order of operations:

    1. drill mounting holes from back side, into bed by a couple of mm, to use for alignment later
    2. cut out copper on back side
    3. remove from machine and spray paint front side
    4. put board back on machine, front-side-up, and pick up alignment holes
    5. cut silkscreen text
    6. cut edges

If it doesn't work... there's always JLCPCB.

## Serial

Initially, only populate the oscillator circuit on UART 0.

    Crystal: 1.8432 MHz
    Caps: 30 nF
    Resistor: 100 Omh

Ideally, the 4 solder jumpers in the middle can be bridged, to share the 1.8432 MHz oscillator between
all of the UARTs. If that is not possible, then un-solder them and populate the other oscillators as well.

The 2x5 pin connector is for jumpers to allow easy disconnection of signals from the connector. The 1x6 connector
should do up with wires to the connector on the front panel.

Each UART has 8 addresses, consecutive starting from a base address. A7 (0x80) needs to be high to select the
UARTs, and then there's 1 bit (A3,A4,A5,A6) of address to select each UART.

Addresses:

    UART 0: A3+A7: base address = 136
    UART 1: A4+A7: base address = 144
    UART 2: A5+A7: base address = 160
    UART 3: A6+A7: base address = 192

It would probably work to initialise all of the UARTs by setting all 5 address bits high, which is base address = 248.

I plan to only install UART 0 at first, and then populate the rest of the slots as and when I want to use them.

In the event that the clock signal does not want to be inverted for the WR pulse, then pin 2 of U2 (inv_CLK) can be popped out
of the socket and bridged to pin 1 (CLK). But I think it does want to be inverted.
