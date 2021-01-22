/* Instruction register testbench */
`include "ir.v"

module test;
    reg clk;
    wire [15:0] bus;
    reg load;
    reg enl, enh;
    wire [15:0] value;

    reg [15:0] busreg;

    assign bus = (enl | enh) ? 16'hZZZZ : busreg;

    IR ir (clk, bus, load, enl, enh, value);

    initial begin
        clk = 0;
        #1
        busreg = 40400; load = 1; enl = 0; enh = 0;
        #1
        clk = 1;
        #1
        busreg = 0; load = 0; enl = 1;
        #1 if (value !== 40400) $display("Bad: value didn't update on clock rising edge,", value);

        clk = 0;
        #1
        enl = 1; load = 0;
        #1 if (bus !== 208) $display("Bad: enl doesn't drive bus,",bus);

        clk = 1;
        #1
        enl = 0; load = 0;
        #1 if (bus === 40400) $display("Bad: bus driven even without enl,",bus);

        clk = 0;
        #1
        busreg = 65535; load = 1; enl = 1;
        #1
        clk = 1;
        #1 if (bus !== 208) $display("Bad: loading with enl enabled shouldn't do anything,",bus);

        clk = 0;
        #1
        busreg = 65535; load = 1; enl = 0;
        #1
        clk = 1;
        #1 if (bus !== 65535) $display("Bad: loading 65535 didn't work",bus);
    end
endmodule
