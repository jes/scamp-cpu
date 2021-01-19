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
   */

`include "ttl-alu4.v"

module ALU(X, Y, C, out);
    input [15:0] X;
    input [15:0] Y;
    input [5:0] C;
    output [15:0] out;

    wire carry1, carry2, carry3, carry4;

    ALU4 alu1 (X[3:0], Y[3:0], C, 1'b0, carry1, out[3:0]);
    ALU4 alu2 (X[7:4], Y[7:4], C, carry1, carry2, out[7:4]);
    ALU4 alu3 (X[11:8], Y[11:8], C, carry2, carry3, out[11:8]);
    ALU4 alu4 (X[15:12], Y[15:12], C, carry3, carry4, out[15:12]);
endmodule
