/* Nand2Tetris ALU */
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

    wire inx, iny, argx, argy, val;

    assign inx = zx ? 0 : X;
    assign argx = nx ? ~inx : inx;
    assign iny = zy ? 0 : Y;
    assign argy = ny ? ~iny : iny;

    assign val = f ? (X+Y) : (X&Y);

    assign out = no ? ~val : val;
endmodule
