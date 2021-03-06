/* Control logic: turn a 16-bit microinstruction into control signals

    Bit | Meaning
    ----+--------
     15 | !EO
     14 | EO ? EX : bus_out[2]
     13 | EO ? NX : bus_out[1]
     12 | EO ? EY : bus_out[0]
     11 | EO ? NY : RT
     10 | EO ? F  : P+
      9 | EO ? NO : (unused)
      8 | (unused)
      7 | bus_in[2]
      6 | bus_in[1]
      5 | bus_in[0]
      4 | JZ
      3 | JGT
      2 | JLT
      1 | (unused)
      0 | (unused)

 */

module Control(uinstr, Z, LT,
        EO_bar, PO_bar, IOH_bar, IOL_bar, MO, DO, RT, PP, AI_bar, II_bar, MI, XI_bar, YI_bar, DI, JZ, JGT, JLT, ALU_flags, JMP_bar);

    input [15:0] uinstr;
    input Z, LT;
    output EO_bar, PO_bar, IOH_bar, IOL_bar, MO, DO, RT, PP, AI_bar, II_bar, MI, XI_bar, YI_bar, DI, JZ, JGT, JLT, JMP_bar;
    output [5:0] ALU_flags;

    wire [2:0] bus_out;
    wire [2:0] bus_in;

    assign EO_bar = uinstr[15];

    // ALU has no side effects if EO_bar, so we can safely tie
    // the bus_out signals to ALU_flags without checking EO
    assign ALU_flags = uinstr[14:9];
    assign bus_out = uinstr[14:12];
    assign bus_in = uinstr[7:5];

    // bus_out decoding:
    assign PO_bar = !(EO_bar && bus_out == 0);  // PC out
    assign IOH_bar = !(EO_bar && bus_out == 1); // IR out (high end)
    assign IOL_bar = !(EO_bar && bus_out == 2); // IR out (low end)
    assign MO = (EO_bar && bus_out == 3);  // RAM out
    // spare: assign .. = !(EO_bar && bus_out == 4);
    // spare: assign .. = !(EO_bar && bus_out == 5);
    assign DO = (EO_bar && bus_out == 6);  // device out
    // spare: assign .. = (EO_bar && bus_out == 7)

    // decode RT/P+
    assign RT = EO_bar && uinstr[11];
    assign PP = EO_bar && uinstr[10];

    // bus_in decoding:
    // bus_in == 0 means nobody inputs from bus
    assign AI_bar = !(bus_in == 1); // MAR in
    assign II_bar = !(bus_in == 2); // IR in
    assign MI = (bus_in == 3); // RAM in
    assign XI_bar = !(bus_in == 4); // X in
    assign YI_bar = !(bus_in == 5); // Y in
    assign DI = (bus_in == 6); // device in
    // spare: assign .. = (bus_in == 7)

    assign JZ = uinstr[4];
    assign JGT = uinstr[3];
    assign JLT = uinstr[2];

    assign JMP_bar = !((JZ&Z) | (JLT&LT) | (JGT&!Z&!LT));
endmodule
