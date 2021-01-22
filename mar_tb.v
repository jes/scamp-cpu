/* MAR testbench */
`include "mar.v"

module test;
    reg clk;
    reg load;
    wire [15:0] value;

    reg [15:0] bus;

    assign load_bar = !load;

    MAR mar (clk, bus, load_bar, value);

    initial begin
        clk = 0;
        #1
        bus = 40400; load = 1;
        #1
        clk = 1;
        #1
        bus = 0; load = 0;
        #1 if (value !== 40400) $display("Bad: value didn't update on clock rising edge,", value);

        clk = 0;
        bus = 10101; load = 1;
        #100 if (value != 40400) $display("Bad: value updated without clock rising edge,",value);
        clk = 1;
        #1 if (value != 10101) $display("Bad: value didn't update on 2nd clock rising edge,",value);
    end
endmodule
