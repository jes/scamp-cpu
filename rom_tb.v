/* Boot ROM testbench */

`include "rom.v"

module test;
    wire [15:0] out;
    reg [7:0] address;
    reg en;

    ROM rom (address, !en, out);

    initial begin
        address = 0; en = 1;
        #1 if (out !== 1) $display("Bad: address 0 != 1:",out);

        address = 1; en = 1;
        #1 if (out !== 2) $display("Bad: address 1 != 2:",out);

        address = 2; en = 1;
        #1 if (out !== 3) $display("Bad: address 2 != 3:",out);

        address = 2; en = 0;
        #1 if (out !== 16'bz) $display("Bad: en=0 does not disconnect rom from bus:",out);
    end
endmodule
