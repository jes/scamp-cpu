/* CPU testbench */
`include "cpu.v"

module test;
    reg clk;
    reg reset_bar = 1;
    wire [15:0] addr;
    wire [15:0] bus;

    CPU #(.DEBUG(1)) cpu (clk, reset_bar, addr, bus, DI, DO);

    reg [15:0] cycle = 0;

    reg [15:0] outputs = 0;

    initial begin
        reset_bar = 0; clk = 0;
        #1 clk = 1;
        #1 clk = 0; #1 reset_bar = 1;

        /* run the CPU for 2000 cycles */
        while (cycle < 2000) begin
            cycle = cycle + 1;

            #1 clk = 1;

            #1 if (addr == 0 && DI) begin
                if (bus !== outputs) $display("Bad: output ",outputs, " != ", outputs, ": ", bus);
                outputs = outputs + 1;
            end

            clk = 0;
        end

        $display("Got ", outputs, " outputs");
    end
endmodule
