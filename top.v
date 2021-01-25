`include "ttl-cpu.v"

module top(clk);
    input clk;

    wire [15:0] addr;
    wire [15:0] bus;

    CPU cpu(clk, 1'b1, addr, bus, DI, DO);

endmodule
