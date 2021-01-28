/* Nand2Tetris ALU, but with zx/zy inverted

   This ALU is purely combinational.

   X,Y are 16-bit inputs

   C is 6 control bits:
    5   4   3   2   1   0
    ex  nx  ey  ny  f   no

    ex,ey: enable the respective operand (instead of using 0)
    nx,ny: invert the bits of the operand (applied after ex,ey)
    f: function select: 0 for '&', 1 for '+'
    no: invert the bits of the output

   Output to bus is enabled when en_bar is lo. Output to val always.
   */

`include "ttl/7402.v"
`include "ttl/7432.v"
`include "ttl/74244.v"
`include "ttl-alu4.v"

module ALU(X, Y, C, en_bar, shr8_bar, bus, val, Z_flag, LT_flag);
    input [15:0] X;
    input [15:0] Y;
    input [5:0] C;
    input en_bar, shr8_bar;
    output [15:0] bus;
    output [15:0] val;
    output Z_flag, LT_flag;

    ALU4 alu1 (X[3:0], Y[3:0], C, 1'b0, carry1, val[3:0], nonzero1);
    ALU4 alu2 (X[7:4], Y[7:4], C, carry1, carry2, val[7:4], nonzero2);
    ALU4 alu3 (X[11:8], Y[11:8], C, carry2, carry3, val[11:8], nonzero3);
    ALU4 alu4 (X[15:12], Y[15:12], C, carry3, nc, val[15:12], nonzero4);

    ttl_74244 buflow1 ({en_bar,en_bar}, val[7:0], bus[7:0]);
    ttl_74244 bufhigh1 ({en_bar,en_bar}, val[15:8], bus[15:8]);

    ttl_74244 buflow2 ({shr8_bar,shr8_bar}, val[15:8], bus[7:0]);
    ttl_74244 bufhigh2 ({shr8_bar,shr8_bar}, 8'b0, bus[15:8]);

    assign LT_flag = val[15];

    ttl_7432 orer ({1'bZ, nonzero1, nonzero2, or1}, {1'bZ, nonzero3, nonzero4, or2}, {nc, or1, or2, nonzero});
    ttl_7402 norer ({3'bZ, nonzero}, {3'bZ, nonzero}, {nc,nc,nc, Z_flag});
endmodule
