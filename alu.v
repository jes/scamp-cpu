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

    assign val = f ? (argx+argy) : (argx&argy);

    assign out = no ? ~val : val;
endmodule
