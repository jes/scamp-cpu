/* Boot ROM testbench */

`include "rom.v"

module test;
    wire [15:0] out;
    reg [7:0] address;

    ROM rom (address, out);

    initial begin
        address = 0;
        #1 if (out !== 1) $display("Bad: address 0 != 1:",out);

        address = 1;
        #1 if (out !== 2) $display("Bad: address 1 != 2:",out);

        address = 2;
        #1 if (out !== 3) $display("Bad: address 2 != 3:",out);
    end
endmodule
