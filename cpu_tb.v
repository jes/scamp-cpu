/* CPU testbench */
`include "cpu.v"

module test;
    reg clk;
    reg reset_bar = 1;
    wire [15:0] addr;
    wire [15:0] bus;

    CPU cpu (clk, reset_bar, addr, bus, DI, DO);

    reg [15:0] cycle = 0;

    initial begin
        reset_bar = 0; clk = 0;
        #1 clk = 1;
        #1 clk = 0; reset_bar = 1;

        /* run the CPU for 1000 cycles */
        while (cycle < 1000) begin
            cycle = cycle + 1;

            #1 clk = 1;

            #1 if (DI) $display("output: ", bus);

            clk = 0;
        end
    end
endmodule
