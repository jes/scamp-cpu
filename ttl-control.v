/* Control logic: turn a 16-bit microinstruction into control signals

    Bit | Meaning
    ----+--------
     15 | EO
     14 | EO ? EX : bus_out[2]
     13 | EO ? NX : bus_out[1]
     12 | EO ? EY : bus_out[0]
     11 | EO ? NY : RT
     10 | EO ? F  : P+
      9 | EO ? NO : (unused)
      8 | bus_in[2]
      7 | bus_in[1]
      6 | bus_in[0]
      5 | JC
      4 | JZ
      3 | JGT
      2 | JLT
      1 | (unused)
      0 | (unused)

 */

`include "ttl/7404.v"
`include "ttl/74138.v"

module Control(uinstr,
        EO, PO, IOH, IOL, RO, XO, YO, DO, RT, PA, MI, II, RI, XI, YI, DI, JC, JZ, JGT, JLT, ALU_flags);

    input [15:0] uinstr;
    output EO, PO, IOH, IOL, RO, XO, YO, DO, RT, PA, MI, II, RI, XI, YI, DI, JC, JZ, JGT, JLT;
    output [5:0] ALU_flags;

    wire [2:0] bus_out;
    wire [7:0] bus_out_dec;
    wire [7:0] inv_bus_out_dec;
    wire [2:0] bus_in;
    wire [7:0] bus_in_dec;
    wire [7:0] inv_bus_in_dec;

    assign EO = uinstr[15];

    // ALU has no side effects if not_EO, so we can safely tie
    // the bus_out signals to ALU_flags without checking EO
    assign ALU_flags = uinstr[14:9];
    assign bus_out = uinstr[14:12];
    assign bus_in = uinstr[8:6];

    assign JC = uinstr[5];
    assign JZ = uinstr[4];
    assign JGT = uinstr[3];
    assign JLT = uinstr[2];

    ttl_7404 inverter1 ({1'bZ, bus_out_dec[7:6], bus_in_dec[7:6], EO}, {nc, inv_bus_out_dec[7:6], inv_bus_in_dec[7:6], not_EO});
    ttl_7404 inverter2 (bus_out_dec[5:0], inv_bus_out_dec[5:0]);
    ttl_7404 inverter3 (bus_in_dec[5:0], inv_bus_in_dec[5:0]);

    ttl_74138 out_decoder (1'b0, 1'b0, not_EO, bus_out, bus_out_dec);
    ttl_74138 in_decoder (1'b0, 1'b0, 1'b1, bus_in, bus_in_dec);

    // inv_bus_out decoding:
    assign PO = inv_bus_out_dec[0];  // PC out
    assign IOH = inv_bus_out_dec[1]; // IR out (high end)
    assign IOL = inv_bus_out_dec[2]; // IR out (low end)
    assign RO = inv_bus_out_dec[3];  // RAM out
    assign XO = inv_bus_out_dec[4];  // X out
    assign YO = inv_bus_out_dec[5];  // Y out
    assign DO = inv_bus_out_dec[6];  // device out
    // spare: assign .. = inv_bus_out_dec[7];

    // decode RT/P+
    assign RT = not_EO && uinstr[11];
    assign PA = not_EO && uinstr[10];

    // inv_bus_in decoding:
    // inv_bus_in == 0 means nobody inputs from bus
    assign MI = inv_bus_in_dec[1]; // MAR in
    assign II = inv_bus_in_dec[2]; // IR in
    assign RI = inv_bus_in_dec[3]; // RAM in
    assign XI = inv_bus_in_dec[4]; // X in
    assign YI = inv_bus_in_dec[5]; // Y in
    assign DI = inv_bus_in_dec[6]; // device in
    // spare: assign .. = inv_bus_in_dec[7]

endmodule
