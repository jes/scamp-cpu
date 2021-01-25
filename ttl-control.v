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
      8 | EO ? CE : (unused)
      7 | bus_in[2]
      6 | bus_in[1]
      5 | bus_in[0]
      4 | JZ
      3 | JGT
      2 | JLT
      1 | JC
      0 | (unused)

 */

`include "ttl/7404.v"
`include "ttl/7408.v"
`include "ttl/74138.v"

module Control(uinstr,
        EO_bar, PO_bar, IOH_bar, IOL_bar, MO, DO, RT, PP, AI_bar, II_bar, MI, XI_bar, YI_bar, DI, JC, JZ, JGT, JLT, ALU_flags);

    input [15:0] uinstr;
    output EO_bar, PO_bar, IOH_bar, IOL_bar, MO, DO, RT, PP, AI_bar, II_bar, MI, XI_bar, YI_bar, DI, JC, JZ, JGT, JLT;
    output [6:0] ALU_flags;

    wire [2:0] bus_out;
    wire [7:0] bus_out_dec;
    wire [2:0] bus_in;
    wire [7:0] bus_in_dec;

    assign EO_bar = uinstr[15];

    // ALU has no side effects if EO_bar, so we can safely tie
    // the bus_out signals to ALU_flags without checking EO
    assign ALU_flags = uinstr[14:8];
    assign bus_out = uinstr[14:12];
    assign bus_in = uinstr[7:5];

    assign JZ = uinstr[4];
    assign JGT = uinstr[3];
    assign JLT = uinstr[2];
    assign JC = uinstr[1];

    ttl_7404 inverter ({2'bZ, inv_MO, inv_DO, inv_MI, inv_DI}, {nc,nc, MO, DO, MI, DI});

    ttl_74138 out_decoder (1'b0, 1'b0, EO_bar, bus_out, bus_out_dec);
    ttl_74138 in_decoder (1'b0, 1'b0, 1'b1, bus_in, bus_in_dec);

    // bus_out decoding:
    assign PO_bar = bus_out_dec[0];  // PC out
    assign IOH_bar = bus_out_dec[1]; // IR out (high end)
    assign IOL_bar = bus_out_dec[2]; // IR out (low end)
    assign inv_MO = bus_out_dec[3];  // Memory out
    // spare: assign .. = bus_out_dec[4];
    // spare: assign .. = bus_out_dec[5];
    assign inv_DO = bus_out_dec[6];  // device out
    // spare: assign .. = bus_out_dec[7];

    // decode RT/P+
    ttl_7408 ander ({2'bZ, EO_bar, EO_bar}, {2'bZ, uinstr[11], uinstr[10]}, {nc,nc, RT, PP});

    // bus_in decoding:
    // bus_in == 0 means nobody inputs from bus
    assign AI_bar = bus_in_dec[1]; // Address in
    assign II_bar = bus_in_dec[2]; // IR in
    assign inv_MI = bus_in_dec[3]; // Memory in
    assign XI_bar = bus_in_dec[4]; // X in
    assign YI_bar = bus_in_dec[5]; // Y in
    assign inv_DI = bus_in_dec[6]; // device in
    // spare: assign .. = bus_in_dec[7]

endmodule
