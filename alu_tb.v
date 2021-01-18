/* ALU testbench */
`include "alu.v"

module test;
    reg [15:0] X;
    reg [15:0] Y;
    reg [5:0] C;

    wire [15:0] out;

    ALU alu (X, Y, C, out);

    initial begin
        X = 10;
        Y = 10;
        C = 6'b000010;

        #1000 // excessive

        if (out != 20) $display("Bad: got 10+10=", out);
    end
endmodule
