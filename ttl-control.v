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
`include "ttl/7408.v"
`include "ttl/74138.v"

module Control(uinstr,
        EO_bar, PO_bar, IOH_bar, IOL_bar, RO, DO, RT, PP, MI_bar, II_bar, RI, XI_bar, YI_bar, DI, JC, JZ, JGT, JLT, ALU_flags);

    input [15:0] uinstr;
    output EO_bar, PO_bar, IOH_bar, IOL_bar, RO, DO, RT, PP, MI_bar, II_bar, RI, XI_bar, YI_bar, DI, JC, JZ, JGT, JLT;
    output [5:0] ALU_flags;

    wire [2:0] bus_out;
    wire [7:0] bus_out_dec;
    wire [7:0] inv_bus_out_dec;
    wire [2:0] bus_in;
    wire [7:0] bus_in_dec;
    wire [7:0] inv_bus_in_dec;

    assign EO_bar = uinstr[15];

    // ALU has no side effects if EO_bar, so we can safely tie
    // the bus_out signals to ALU_flags without checking EO
    assign ALU_flags = uinstr[14:9];
    assign bus_out = uinstr[14:12];
    assign bus_in = uinstr[8:6];

    assign JC = uinstr[5];
    assign JZ = uinstr[4];
    assign JGT = uinstr[3];
    assign JLT = uinstr[2];

    // XXX: we only need to invert some of each of bus_out/bus_in; could lose 1 inverter
    // XXX: refactor this so we assign to XX_bar from bus_out_dec and then invert only the
    // required signals, instead of the entire bus_out_dec
    ttl_7404 inverter1 ({2'bZ, bus_out_dec[7:6], bus_in_dec[7:6]}, {nc, nc, inv_bus_out_dec[7:6], inv_bus_in_dec[7:6]});
    ttl_7404 inverter2 (bus_out_dec[5:0], inv_bus_out_dec[5:0]);
    ttl_7404 inverter3 (bus_in_dec[5:0], inv_bus_in_dec[5:0]);

    ttl_74138 out_decoder (1'b0, 1'b0, EO_bar, bus_out, bus_out_dec);
    ttl_74138 in_decoder (1'b0, 1'b0, 1'b1, bus_in, bus_in_dec);

    // inv_bus_out decoding:
    assign PO_bar = bus_out_dec[0];  // PC out
    assign IOH_bar = bus_out_dec[1]; // IR out (high end)
    assign IOL_bar = bus_out_dec[2]; // IR out (low end)
    assign RO = inv_bus_out_dec[3];  // RAM out
    // spare: assign .. = bus_out_dec[4];  // X out
    // spare: assign .. = bus_out_dec[5];  // Y out
    assign DO = inv_bus_out_dec[6];  // device out
    // spare: assign .. = inv_bus_out_dec[7];

    // decode RT/P+
    ttl_7408 ander ({2'bZ, EO_bar, EO_bar}, {2'bZ, uinstr[11], uinstr[10]}, {nc,nc, RT, PP});

    // inv_bus_in decoding:
    // inv_bus_in == 0 means nobody inputs from bus
    assign MI_Bar = bus_in_dec[1]; // MAR in
    assign II_bar = bus_in_dec[2]; // IR in
    assign RI = inv_bus_in_dec[3]; // RAM in
    assign XI_bar = bus_in_dec[4]; // X in
    assign YI_Bar = bus_in_dec[5]; // Y in
    assign DI = inv_bus_in_dec[6]; // device in
    // spare: assign .. = inv_bus_in_dec[7]

endmodule
