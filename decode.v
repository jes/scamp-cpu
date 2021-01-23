/* Decode: Turn an instruction into a microinstruction

    T0:  PO AI
    T1:  MO II P+
    T2+: look in DecodeROM at {T-2, instr[15:8]}
*/

module Decode(instr, T, uinstr);
    input [15:0] instr;
    input [2:0] T;
    output [15:0] uinstr;

    reg [15:0] rom [0:2047];

    wire [7:0] addr;
    assign addr = {instr[15:8], T};

    initial begin
        $readmemh("ucode.hex", rom);
    end

    assign uinstr = rom[addr];
endmodule
