/* 4-bit slice of Nand2Tetris ALU, but with zx/zy inverted

   This ALU is purely combinational.

   X,Y are 4-bit inputs

   C is 6 control bits:
    5   4   3   2   1   0
    ex  nx  ey  ny  f   no

    ex,ey: enable the respective operand (instead of using 0)
    nx,ny: invert the bits of the operand (applied after ex,ey)
    f: function select: 0 for '&', 1 for '+'
    no: invert the bits of the output
   */

`include "ttl/7408.v"
`include "ttl/7486.v"
`include "ttl/74157.v"
`include "ttl/74283.v"

module ALU4(X, Y, C, carry_in, carry_out, out);
    input [3:0] X;
    input [3:0] Y;
    input [5:0] C;
    input carry_in;
    output carry_out;
    output [3:0] out;

    wire ex,nx,ey,ny,f,no;

    assign ex = C[5];
    assign nx = C[4];
    assign ey = C[3];
    assign ny = C[2];
    assign f = C[1];
    assign no = C[0];

    wire [3:0] inx;
    wire [3:0] iny;
    wire [3:0] argx;
    wire [3:0] argy;
    wire [3:0] val;
    wire [3:0] add_result;
    wire [3:0] and_result;

    ttl_7408 andx ({ex,ex,ex,ex}, X, inx);
    ttl_7408 andy ({ey,ey,ey,ey}, Y, iny);

    ttl_7486 xorx ({nx,nx,nx,nx}, inx, argx);
    ttl_7486 xory ({ny,ny,ny,ny}, iny, argy);

    ttl_74283 adder (argx, argy, carry_in, add_result, carry_out); 
    ttl_7408 ander (argx, argy, and_result);

    ttl_74157 mux (1'b0, f, and_result, add_result, val);
    ttl_7486 outputxor ({no,no,no,no}, val, out);
endmodule
