/* Nand2Tetris ALU

   This ALU is purely combinational.

   X,Y are 16-bit inputs

   C is 6 control bits:
    5   4   3   2   1   0
    zx  nx  zy  ny  f   no

    zx,zy: replace the respective operand with 0
    nx,ny: invert the bits of the operand (applied after zx,zy)
    f: function select: 0 for '&', 1 for '+'
    no: invert the bits of the output
   */

`include "ttl/74283.v"

module ALU(X, Y, C, out);
    input [15:0] X;
    input [15:0] Y;
    input [5:0] C;
    output [15:0] out;

    wire zx,nx,zy,ny,f,no;

    assign zx = C[5];
    assign nx = C[4];
    assign zy = C[3];
    assign ny = C[2];
    assign f = C[1];
    assign no = C[0];

    wire [15:0] inx;
    wire [15:0] iny;
    wire [15:0] argx;
    wire [15:0] argy;
    wire [15:0] val;

    assign inx = zx ? 0 : X;
    assign argx = nx ? ~inx : inx;
    assign iny = zy ? 0 : Y;
    assign argy = ny ? ~iny : iny;

    wire [15:0] add_result;

    ttl_74283 adder1 (argx[3:0], argy[3:0], 1'b0, add_result[3:0], carry1); 
    ttl_74283 adder2 (argx[7:4], argy[7:4], carry1, add_result[7:4], carry2);
    ttl_74283 adder3 (argx[11:8], argy[11:8], carry2, add_result[11:8], carry3);
    ttl_74283 adder4 (argx[15:12], argy[15:12], carry3, add_result[15:12], carry4);

    assign val = f ? add_result : (argx&argy);

    assign out = no ? ~val : val;
endmodule
