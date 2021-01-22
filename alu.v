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
module ALU(X, Y, C, en, bus, val, C_in, C_flag, Z_flag, LT_flag);
    input [15:0] X;
    input [15:0] Y;
    input [5:0] C;
    input en;
    output [15:0] bus;
    output [15:0] val;
    input C_in;
    output C_flag, Z_flag, LT_flag;

    assign {ex,nx,ey,ny,f,no} = C;

    wire [15:0] inx;
    wire [15:0] iny;
    wire [15:0] argx;
    wire [15:0] argy;
    wire [15:0] fxy;

    assign inx = ex ? X : 0;
    assign argx = nx ? ~inx : inx;
    assign iny = ey ? Y : 0;
    assign argy = ny ? ~iny : iny;

    assign {C_flag, fxy} = f ? (C_in+argx+argy) : (argx&argy);

    assign val = no ? ~fxy : fxy;
    assign bus = en ? val : 16'hZZZZ;

    assign Z_flag = (val == 0);
    assign LT_flag = val[15];
endmodule
