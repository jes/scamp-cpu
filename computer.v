/* CPU testbench */
`include "cpu.v"

`include "ttl/mos_6551.v"

module test;
    reg clk;
    reg reset_bar = 1;
    wire [15:0] addr;
    wire [15:0] bus;

    CPU cpu (clk, reset_bar, addr, bus, DI, DO);

    mos_6551 acia (clk, addr[1], !(DI | DO), reset_bar, {addr[3],addr[2]}, DO, bus[7:0]);

    reg [15:0] cycle = 0;

    parameter EXPECT_OUTPUTS = 24;
    reg [15:0] outputs = 0;

    initial begin
        reset_bar = 0; clk = 0;
        #1 clk = 1;
        #1 clk = 0; reset_bar = 1;

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

        if (outputs !== EXPECT_OUTPUTS) $display("Bad: got ", outputs, " outputs, expected ", EXPECT_OUTPUTS);
    end
endmodule