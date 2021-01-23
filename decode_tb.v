/* Decode testbench */

`include "decode.v"

module test;
    reg [15:0] instr;
    reg [2:0] T;

    wire [15:0] uinstr;

    Decode decode(instr, T, uinstr);

    initial begin
        instr = 0; T = 0;
        #1 if (uinstr !== 16'h0040) $display("Bad: (0, T0) uinstr=",uinstr);

        instr = 0; T = 1;
        #1 if (uinstr !== 16'h3480) $display("Bad: (0, T1) uinstr=",uinstr);

        instr = 0; T = 2;
        #1 if (uinstr != 16'h8400) $display("Bad: (0, T2) uinstr=",uinstr);

        instr = 100<<8; T = 0;
        #1 if (uinstr !== 16'h0040) $display("Bad: (100, T0) uinstr=",uinstr);

        instr = 3<<8; T = 2;
        #1 if (uinstr !== 16'h4180) $display("Bad: (3, T2) uinstr=",uinstr);
    end
endmodule
