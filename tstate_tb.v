/* T-state counter testbench */
`include "tstate.v"

module test;
    reg clk;
    reg reset;

    wire [7:0] val;

    TState tstate (clk, reset, val);

    initial begin
        clk = 1;
        reset = 1;
        #1 if (val !== 1) $display("Bad: reset didn't initialise to T0");

        reset = 0;
        #1
        clk = 0;
        #1 if (val !== 2) $display("Bad: didn't reach T1 on falling edge");

        clk = 1;
        #1
        clk = 0;
        #1 if (val !== 4) $display("Bad: didn't reach T2 on falling edge");

        clk = 1;
        #1
        clk = 0;
        #1 if (val !== 8) $display("Bad: didn't reach T3 on falling edge");

        clk = 1;
        #1
        clk = 0;
        #1 if (val !== 16) $display("Bad: didn't reach T4 on falling edge");

        clk = 1;
        #1
        clk = 0;
        #1 if (val !== 32) $display("Bad: didn't reach T5 on falling edge");

        clk = 1;
        #1
        clk = 0;
        #1 if (val !== 64) $display("Bad: didn't reach T6 on falling edge");

        clk = 1;
        #1
        clk = 0;
        #1 if (val !== 128) $display("Bad: didn't reach T7 on falling edge");

        clk = 1;
        #1
        clk = 0;
        #1 if (val !== 1) $display("Bad: didn't reset to T0 on falling edge");

        clk = 1;
        #1
        clk = 0;
        #1
        clk = 1;
        #1
        clk = 0;
        #1 if (val !== 4) $display("Bad: didn't reach T2 after 2 falling edges");

        reset = 1;
        #1 if (val !== 1) $display("Bad: didn't reset back to T0");
    end
endmodule
