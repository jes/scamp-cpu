/* Boot ROM testbench */

`include "rom.v"

module test;
    wire [15:0] out;
    reg [7:0] address;

    ROM rom (address, out);

    initial begin
        address = 0;
        #1 if (out !== 16'h0700) $display("Bad: address 0 != 0x0700:",out);

        address = 1;
        #1 if (out !== 16'h0100) $display("Bad: address 1 != 0x0100:",out);

        address = 2;
        #1 if (out !== 3) $display("Bad: address 2 != 3:",out);
    end
endmodule
