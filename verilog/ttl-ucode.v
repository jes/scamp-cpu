/* Ucode: Turn an instruction into a microinstruction

    T0:  PO AI
    T1:  MO II P+
    T2+: look in DecodeROM at {instr[15:8],T}
*/

`include "ttl/at28c16.v"

module Ucode(instr, T, uinstr);
    input [15:0] instr;
    input [2:0] T;
    output [15:0] uinstr;

    wire [10:0] addr;
    assign addr = {instr[15:8], T};

    at28c16 #(.ROM_FILE("ucode-low.hex")) rom2 (addr, uinstr[7:0], 1'b0, 1'b0);
    at28c16 #(.ROM_FILE("ucode-high.hex")) rom1 (addr, uinstr[15:8], 1'b0, 1'b0);
endmodule
