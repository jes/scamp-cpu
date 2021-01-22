/* Decode: Turn an instruction into a microinstruction

    T0:  PO MI
    T1:  RO II P+
    T2+: look in DecodeROM at {T-2, instr[15:8]}
*/

module Decode(instr, T, uinstr);
    input [15:0] instr;
    input T;
    output [15:0] uinstr;

endmodule
