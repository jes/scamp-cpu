/* Program Counter testbench */
`include "pc.v"

module test;
    reg clk;
    wire [15:0] bus;
    reg load;
    reg en;
    wire [15:0] value;
    reg inc;
    reg reset_bar;

    reg [15:0] busreg;

    assign bus = en ? 16'hZZZZ : busreg;

    wire en_bar, load_bar;
    assign en_bar = !en;
    assign load_bar = !load;

    PC pc (clk, bus, load_bar, en_bar, value, inc, reset_bar);

    initial begin
        clk = 0;
        #1
        reset_bar = 0; load = 0; en = 0; inc = 0;
        #1 if (value !== 0) $display("Bad: value should be 0 at reset,",value);
        clk = 1;
        #1

        clk = 0;
        reset_bar = 1; load = 1; busreg = 1500;
        #1
        clk = 1;
        #1 if (value !== 1500) $display("Bad: didn't load value at posedge clk,",value);

        clk = 0;
        #1
        inc = 1; load = 0;
        #1
        clk = 1;
        #1 if (value !== 1501) $display("Bad: value didn't increment,",value);

        clk = 0;
        #1
        inc = 0;
        #1
        clk = 1;
        #1 if (value !== 1501) $display("Bad: value changed while inc=0,",value);

        clk = 0;
        #1
        inc = 1;
        #100
        inc = 0;
        #1
        clk = 1;
        #1 if (value !== 1501) $display("Bad: value incremented without posedge of clock,",value);

        inc = 1;
        #100
        clk = 0;
        #1
        inc = 0;
        #1
        clk = 1;
        #1 if (value !== 1501) $display("Bad: value incremented at negedge of clock,",value);

        clk = 0;
        reset_bar = 0;
        #1 if (value !== 0) $display("Bad: value didn't reset,",value);

        reset_bar = 1;
        #1
        load = 1; busreg = 65535;
        #1
        clk = 1;
        #1 if (value !== 65535) $display("Bad: didn't load value from bus,",value);

        busreg = 100;
        load = 1;
        #1 if (value !== 65535) $display("Bad: loaded from bus without clock edge?,",value);
        clk = 0;
        #1 if (value !== 65535) $display("Bad: loaded from bus on negedge?,",value);
        load = 0;
        #1
        clk = 1;
        #1 if (value !== 65535) $display("Bad: changed value on posedge?,",value);
        clk = 0;
        #1
        inc = 1;
        #1
        clk = 1;
        #1 if (value !== 0) $display("Didn't increment at posedge?,",value);

        clk = 0;
        #1
        inc = 0; load = 1; busreg = 6502;
        #1
        clk = 1;
        #1
        if (value !== 6502) $display("Bad: didn't load from bus,",value);

        clk = 0;
        #1
        busreg = 2056;
        load = 0; en = 1;
        #1
        clk = 1;
        #1 if (bus !== 6502) $display("Bad: didn't put value on bus with en=1,",value);

        clk = 0;
        #1
        en = 0;
        #1
        clk = 1;
        #1 if (bus !== 2056) $display("Bad: put value on bus without en=1,",value);

        clk = 0;
        #1
        inc = 0; load = 1; busreg = 240;
        #1
        clk = 1;
        #1 if (value !== 240) $display("Bad: didn't load 240,",value);

        clk = 0;
        #1
        inc = 1; load = 0;
        #1
        clk = 1;
        #1 if (value !== 241) $display("Bad: didn't increment 240 to 241,",value);
    end
endmodule
