/* ALU testbench */
`include "alu.v"

module test;
    reg [15:0] X;
    reg [15:0] Y;
    reg [5:0] C;

    wire [15:0] out;

    ALU alu (X, Y, C, out);

    parameter ex=32, nx=16, ey=8, ny=4, f=2, no=1;

    integer x, y;

    initial begin
        for (x = 0; x < 65536; x = x + 255) begin
            for (y = 0; y < 65536; y = y + 567) begin
                X = x; Y = y;

                // X+Y
                C = ex+ey+f;
                #1 if (out != X+Y) $display("Bad: X+Y: got ",x,"+",y,"=",out);

                // X-Y
                C = ex+ey+nx+f+no;
                #1 if (out != X-Y) $display("Bad: X-Y: got ",x,"-",y,"=",out);

                // Y-X
                C = ex+ey+ny+f+no;
                #1 if (out != Y-X) $display("Bad: Y-X: got ",y,"-",x,"=",out);

                // X&Y
                C = ex+ey;
                #1 if (out != (X&Y)) $display("Bad: X&Y: got ",x,"&",y,"=",out);

                // X|Y
                C = ex+ey+nx+ny+no;
                #1 if (out != (X|Y)) $display("Bad: X|Y: got ",x,"|",y,"=",out);

                // 0
                C = f;
                #1 if (out != 0) $display("Bad: 0: got 0=",out);

                // 1
                C = nx+ny+f+no;
                #1 if (out != 1) $display("Bad: 1: got 1=",out);

                // -1
                C = nx+ny;
                #1 if (out != 16'hffff) $display("Bad: -1: got -1=",out);

                // X
                C = ex+f;
                #1 if (out != X) $display("Bad: X: got ",x,"=",out);

                // Y
                C = ey+f;
                #1 if (out != Y) $display("Bad: Y: got ",y,"=",out);

                // !X
                C = nx+ex+f;
                #1 if (out != ~X) $display("Bad: !X: got !",x,"=",out);

                // !Y
                C = ey+ny+f;
                #1 if (out != ~Y) $display("Bad: !Y: got !",y,"=",out);

                // -X
                C = ex+ny+f+no;
                #1 if (out != -X) $display("Bad: -X: got -",x,"=",out);

                // -Y
                C = ey+nx+f+no;
                #1 if (out != -Y) $display("Bad: -Y: got -",y,"=",out);

                // X+1
                C = nx+ex+ny+f+no;
                #1 if (out != (X+1)%65536) $display("Bad: X+1: got ",x,"+1=",out);

                // Y+1
                C = ny+ey+nx+f+no;
                #1 if (out != (Y+1)%65536) $display("Bad: Y+1: got ",y,"+1=",out);

                // X-1
                C = ex+ny+f;
                #1 if (out != (65536+X-1)%65536) $display("Bad: X-1: got ",x,"-1=",out);

                // Y-1
                C = ey+nx+f;
                #1 if (out != (65536+Y-1)%65536) $display("Bad: Y-1: got ",y,"-1=",out);
            end
        end
    end
endmodule
