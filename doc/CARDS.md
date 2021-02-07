# Cards

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
