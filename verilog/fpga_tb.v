/* CPU testbench */
`include "fpga-cpu.v"

module test;
    reg clk, clk90;
    reg reset_bar = 1;
    wire [15:0] addr;
    wire [15:0] bus;

    wire [15:0] PC_val;
    wire [15:0] busin;

    CPU cpu (clk, clk90, reset_bar, addr, bus, busin, DI, DO, PC_val);

    reg [15:0] cycle = 0;

    parameter EXPECT_OUTPUTS = 24;
    reg [15:0] outputs = 0;

    initial begin
        reset_bar = 0; clk90 = 0; clk = 0;
        #1 clk = 1;
        #1 clk = 0; reset_bar = 1;

        /* run the CPU for 2000 cycles */
        while (cycle < 2000) begin
            cycle = cycle + 1;

            #1 clk90 = 1;
            #1 clk = 1;

            #1 if (addr == 0 && DI) begin
                if (bus !== outputs) $display("Bad: output ",outputs, " != ", outputs, ": ", bus);
                outputs = outputs + 1;
            end

            #1 clk90 = 0;
            #1 clk = 0;
        end

        if (outputs !== EXPECT_OUTPUTS) $display("Bad: got ", outputs, " outputs, expected ", EXPECT_OUTPUTS);
    end
endmodule
