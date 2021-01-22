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

   Output to bus is enabled when en is high. Output to val always.
   */

`include "ttl/7402.v"
`include "ttl/7404.v"
`include "ttl/74244.v"
`include "ttl-alu4.v"

module ALU(X, Y, C, en, bus, val, C_in, C_flag, Z_flag, LT_flag);
    input [15:0] X;
    input [15:0] Y;
    input [5:0] C;
    input en;
    output [15:0] bus;
    output [15:0] val;
    input C_in;
    output C_flag, Z_flag, LT_flag;

    wire carry1, carry2, carry3, carry4;

    ALU4 alu1 (X[3:0], Y[3:0], C, C_in, carry1, val[3:0], nonzero1);
    ALU4 alu2 (X[7:4], Y[7:4], C, carry1, carry2, val[7:4], nonzero2);
    ALU4 alu3 (X[11:8], Y[11:8], C, carry2, carry3, val[11:8], nonzero3);
    ALU4 alu4 (X[15:12], Y[15:12], C, carry3, C_flag, val[15:12], nonzero4);

    ttl_7404 inverter ({5'b0, en}, {nc,nc,nc,nc,nc, en_bar});

    ttl_74244 buflow ({en_bar,en_bar}, val[7:0], bus[7:0]);
    ttl_74244 bufhigh ({en_bar,en_bar}, val[15:8], bus[15:8]);

    assign LT_flag = val[15];

    ttl_7402 norer ({nonzero1,nonzero2,nor1,1'bZ},{nonzero3,nonzero4,nor2,1'bZ},{nor1,nor2,NZ_flag,nc});
endmodule
