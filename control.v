/* Control logic

    bus_out: select which module outputs to bus
    bus_in: select which module inputs from bus
 */

module Control(bus_out, bus_in,
        PO, IOH, IOL, RO, XO, YO, EO, MI, RI, II, XI, YI);

    input [2:0] bus_out;
    input [2:0] bus_in;
    output PO, IOH, IOL, RO, XO, YO, EO, MI, RI, II, XI, YI, JC, JZ, JGT, JLT;

    // bus_out decoding:
    assign PO = (bus_out == 0);  // PC out
    assign IOH = (bus_out == 1); // IR out (high end)
    assign IOL = (bus_out == 2); // IR out (low end)
    assign RO = (bus_out == 3);  // RAM out
    assign XO = (bus_out == 4);  // X out
    assign YO = (bus_out == 5);  // Y out
    assign EO = (bus_out == 6);  // ALU out
    // spare: assign .. = (bus_out == 7)

    assign MI = (bus_in == 0); // MAR in
    assign RI = (bus_in == 1); // RAM in
    assign II = (bus_in == 2); // IR in
    assign XI = (bus_in == 3); // X in
    assign YI = (bus_in == 4); // Y in
    // spare: assign .. = (bus_in == 5)
    // spare: assign .. = (bus_in == 6)
    // spare: assign .. = (bus_in == 7)

endmodule
