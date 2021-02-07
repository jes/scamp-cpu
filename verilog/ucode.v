/* Ucode: Turn an instruction into a microinstruction

    T0:  PO AI
    T1:  MO II P+
    T2+: look in DecodeROM at {instr[15:8],T}
*/

module Ucode(instr, T, uinstr);
    input [15:0] instr;
    input [2:0] T;
    output [15:0] uinstr;

    reg [15:0] rom [0:2047];

    wire [10:0] addr;
    assign addr = {instr[15:8], T};

    initial begin
        $readmemh("ucode.hex", rom);
    end

    assign uinstr = rom[addr];
endmodule
