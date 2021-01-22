/* Register testbench */
`include "register.v"

module test;
    reg clk;
    wire [15:0] bus;
    reg load;
    reg en;
    wire [15:0] value;

    reg [15:0] busreg;

    assign bus = en ? 16'hZZZZ : busreg;

    assign en_bar = !en;
    assign load_bar = !load;

    Register register (clk, bus, load_bar, en_bar, value);

    initial begin
        clk = 0;
        #1
        busreg = 40400; load = 1; en = 0;
        #1
        clk = 1;
        #1
        busreg = 0; load = 0; en = 1;
        #1 if (value !== 40400) $display("Bad: value didn't update on clock rising edge,", value);

        clk = 0;
        #1
        en = 1; load = 0;
        #1 if (bus !== 40400) $display("Bad: en doesn't drive bus,",bus);

        clk = 1;
        #1
        en = 0; load = 0;
        #1 if (bus === 40400) $display("Bad: bus driven even without en,",bus);

        clk = 0;
        #1
        busreg = 65535; load = 1; en = 1;
        #1
        clk = 1;
        #1 if (bus !== 40400) $display("Bad: loading with en enabled shouldn't do anything,",bus);

        clk = 0;
        #1
        busreg = 65535; load = 1; en = 0;
        #1
        clk = 1;
        #1 if (bus !== 65535) $display("Bad: loading 65535 didn't work",bus);
    end
endmodule
