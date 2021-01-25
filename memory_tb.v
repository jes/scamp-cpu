/* Memory testbench */

`include "memory.v"

module test;
    reg clk;
    reg load;
    reg en;
    reg [15:0] address;

    reg [15:0] busreg;
    wire [15:0] bus = (en ? 16'bZ : busreg);

    Memory memory(clk, bus, load, en, address);

    initial begin
        load = 0; en = 1; clk = 0; busreg = 1234;

        /* Test reading from ROM */
        address = 0;
        #1 if (bus !== 16'h0101) $display("Bad: address 0 != 0x0101:",bus);

        address = 1;
        #1 if (bus !== 16'h0300) $display("Bad: address 1 != 0x0300:",bus);

        address = 2;
        #1 if (bus !== 16'h0102) $display("Bad: address 2 != 0x0102:",bus);
        en = 0;
        #1 if (bus !== 1234) $display("Bad: modified bus without en:",bus);

        /* Test writing to RAM */
        address = 500; busreg = 7890; load = 1; en = 1;
        #1 load = 0;
        #1 if (bus === 7890) $display("Bad: wrote to memory without clock edge:",bus);
        load = 1; en = 0;
        #1 clk = 1; en = 1;
        #1 load = 0; en = 1;
        #1 if (bus !== 7890) $display("Bad: didn't write to memory at clock edge:",bus);

        clk = 0;
        address = 600; busreg = 8907; en = 0; load = 1;
        #1
        clk = 1;
        #1 en = 1; load = 0;
        #1 if (bus !== 8907) $display("Bad: didn't write to memory at clock edge (2nd):",bus);

        clk = 0;
        address = 500; load = 0;
        #1 if (bus !== 7890) $display("Bad: couldn't retrieve previous value (before rising edge):",bus);
        clk = 1;
        #1 if (bus !== 7890) $display("Bad: couldn't retrieve previous value (after rising edge):",bus);

        /* Test writing to first page (ROM) and seeing that nothing changes */
        clk = 0;
        address = 0; busreg = 12345; load = 1;
        #1
        clk = 1;
        #1 if (bus !== 16'h0101) $display("Bad: looks like we overwrote ROM:",bus);

        /* Test asking for values on the bus and verifying that they change at positive edges */
        clk = 0;
        address = 600; en = 1; load = 0;
        #1
        clk = 1;
        #1 if (bus !== 8907) $display("Bad: didn't write value to bus:",bus);

        clk = 0;
        address = 500;
        clk = 1;
        #1 if (bus !== 7890) $display("Bad: didn't write new value to bus:",bus);
    end
endmodule
