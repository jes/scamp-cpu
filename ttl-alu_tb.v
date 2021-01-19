/* ALU testbench */
`include "ttl-alu.v"

module test;
    reg [15:0] X;
    reg [15:0] Y;
    reg [5:0] C;

    wire [15:0] out;

    ALU alu (X, Y, C, out);

    parameter zx=32, nx=16, zy=8, ny=4, f=2, no=1;

    integer x, y;

    initial begin
        for (x = 0; x < 65536; x = x + 100) begin
            for (y = 0; y < 65536; y = y + 567) begin
                X = x; Y = y;

                // X+Y
                C = f;
                #1 if (out != X+Y) $display("Bad: X+Y: got ",x,"+",y,"=",out);

                // X-Y
                C = nx+f+no;
                #1 if (out != X-Y) $display("Bad: X-Y: got ",x,"-",y,"=",out);

                // Y-X
                C = ny+f+no;
                #1 if (out != Y-X) $display("Bad: Y-X: got ",y,"-",x,"=",out);

                // X&Y
                C = 0;
                #1 if (out != (X&Y)) $display("Bad: X&Y: got ",x,"&",y,"=",out);

                // X|Y
                C = nx+ny+no;
                #1 if (out != (X|Y)) $display("Bad: X|Y: got ",x,"|",y,"=",out);

                // 0
                C = zx+zy+f;
                #1 if (out != 0) $display("Bad: 0: got 0=",out);

                // 1
                C = zx+nx+zy+ny+f+no;
                #1 if (out != 1) $display("Bad: 1: got 1=",out);

                // -1
                C = zx+nx+zy+ny;
                #1 if (out != 16'hffff) $display("Bad: -1: got -1=",out);

                // X
                C = zy+f;
                #1 if (out != X) $display("Bad: X: got ",x,"=",out);

                // Y
                C = zx+f;
                #1 if (out != Y) $display("Bad: Y: got ",y,"=",out);

                // !X
                C = nx+zy+f;
                #1 if (out != ~X) $display("Bad: !X: got !",x,"=",out);

                // !Y
                C = zx+ny+f;
                #1 if (out != ~Y) $display("Bad: !Y: got !",y,"=",out);

                // -X
                C = zy+ny+f+no;
                #1 if (out != -X) $display("Bad: -X: got -",x,"=",out);

                // -Y
                C = zx+nx+f+no;
                #1 if (out != -Y) $display("Bad: -Y: got -",y,"=",out);

                // X+1
                C = nx+zy+ny+f+no;
                #1 if (out != X+1) $display("Bad: X+1: got ",x,"+1=",out);

                // Y+1
                C = ny+zx+nx+f+no;
                #1 if (out != Y+1) $display("Bad: Y+1: got ",y,"+1=",out);

                // X-1
                C = zy+ny+f;
                #1 if (out != (65536+X-1)%65536) $display("Bad: X-1: got ",x,"-1=",out);

                // Y-1
                C = zx+nx+f;
                #1 if (out != (65536+Y-1)%65536) $display("Bad: Y-1: got ",y,"-1=",out);
            end
        end
    end
endmodule
