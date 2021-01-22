/* T-state counter testbench */
`include "tstate.v"

module test;
    reg clk;
    reg reset;

    wire [2:0] T;

    TState tstate (clk, reset, T);

    initial begin
        clk = 1;
        reset = 1;
        #1 if (T !== 0) $display("Bad: reset didn't initialise to T0,",T);

        reset = 0;
        #1
        clk = 0;
        #1 if (T !== 1) $display("Bad: didn't reach T1 on falling edge");

        clk = 1;
        #1
        clk = 0;
        #1 if (T !== 2) $display("Bad: didn't reach T2 on falling edge");

        clk = 1;
        #1
        clk = 0;
        #1 if (T !== 3) $display("Bad: didn't reach T3 on falling edge");

        clk = 1;
        #1
        clk = 0;
        #1 if (T !== 4) $display("Bad: didn't reach T4 on falling edge");

        clk = 1;
        #1
        clk = 0;
        #1 if (T !== 5) $display("Bad: didn't reach T5 on falling edge");

        clk = 1;
        #1
        clk = 0;
        #1 if (T !== 6) $display("Bad: didn't reach T6 on falling edge");

        clk = 1;
        #1
        clk = 0;
        #1 if (T !== 7) $display("Bad: didn't reach T7 on falling edge");

        clk = 1;
        #1
        clk = 0;
        #1 if (T !== 0) $display("Bad: didn't reset to T0 on falling edge");

        clk = 1;
        #1
        clk = 0;
        #1
        clk = 1;
        #1
        clk = 0;
        #1 if (T !== 2) $display("Bad: didn't reach T2 after 2 falling edges");

        reset = 1;
        #1 if (T !== 0) $display("Bad: didn't reset back to T0");
    end
endmodule
