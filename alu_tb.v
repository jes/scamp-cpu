/* ALU testbench */
`include "alu.v"

module test;
    reg [15:0] X;
    reg [15:0] Y;
    reg [5:0] C;

    wire [15:0] out;
    wire [15:0] bus;

    reg [15:0] sum;

    reg en;

    reg C_in = 0;

    assign en_bar = !en;
    ALU alu (X, Y, C, en_bar, bus, out, C_in, C_flag, Z_flag, LT_flag);

    parameter ex=32, nx=16, ey=8, ny=4, f=2, no=1;

    integer x, y;

    parameter THOROUGH = 0;
    parameter X_INC = THOROUGH ? 255 : 4080;
    parameter Y_INC = THOROUGH ? 567 : 15381;

    initial begin
        for (x = 0; x < 65536; x = x + X_INC) begin
            for (y = 119; y < 65536; y = y + Y_INC) begin
                X = x; Y = y; en = 1;

                // X+Y
                C = ex+ey+f;
                #1 if (out !== X+Y) $display("Bad: X+Y: got ",x,"+",y,"=",out);
                #1 if (Z_flag!==0 && out !==0) $display("Bad: X+Y: Z_flag is set but output=",out);

                // X-Y
                C = ex+ey+nx+f+no;
                #1 if (out !== X-Y) $display("Bad: X-Y: got ",x,"-",y,"=",out);
                #1 if (Z_flag!==0 && out !==0) $display("Bad: X-Y: Z_flag is set but output=",out);

                // Y-X
                C = ex+ey+ny+f+no;
                #1 if (out !== Y-X) $display("Bad: Y-X: got ",y,"-",x,"=",out);
                #1 if (Z_flag!==0 && out !==0) $display("Bad: Y-X: Z_flag is set but output=",out);

                // X&Y
                C = ex+ey;
                #1 if (out !== (X&Y)) $display("Bad: X&Y: got ",x,"&",y,"=",out);

                // X|Y
                C = ex+ey+nx+ny+no;
                #1 if (out !== (X|Y)) $display("Bad: X|Y: got ",x,"|",y,"=",out);

                // 0
                C = f;
                #1 if (out !== 0) $display("Bad: 0: got 0=",out);
                #1 if (Z_flag!==1) $display("Bad: 0 doesn't set Z_flag");
                #1 if (LT_flag!==0) $display("Bad: 0 sets LT_flag");
                #1 if (C_flag!==0) $display("Bad: 0 sets C_flag");
                // 1
                C = nx+ny+f+no;
                #1 if (out !== 1) $display("Bad: 1: got 1=",out);
                #1 if (Z_flag!==0) $display("Bad: 1 sets Z_flag");
                #1 if (LT_flag!==0) $display("Bad: 1 sets LT_flag");

                // -1
                C = nx+ny;
                #1 if (out !== 65535) $display("Bad: -1: got -1=",out);
                #1 if (LT_flag!==1) $display("Bad: -1 does not set LT_flag");

                // X
                C = ex+f;
                #1 if (out !== X) $display("Bad: X: got ",x,"=",out);
                #1 if (Z_flag!==0 && out !==0) $display("Bad: X: Z_flag is set but output=",out);

                // Y
                C = ey+f;
                #1 if (out !== Y) $display("Bad: Y: got ",y,"=",out);
                #1 if (Z_flag!==0 && out !==0) $display("Bad: Y: Z_flag is set but output=",out);

                // !X
                C = nx+ex+f;
                #1 if (out !== ~X) $display("Bad: !X: got !",x,"=",out);

                // !Y
                C = ey+ny+f;
                #1 if (out !== ~Y) $display("Bad: !Y: got !",y,"=",out);

                // -X
                C = ex+ny+f+no;
                #1 if (out !== -X) $display("Bad: -X: got -",x,"=",out);
                #1 if (Z_flag!==0 && out !==0) $display("Bad: -X: Z_flag is set but output=",out);

                // -Y
                C = ey+nx+f+no;
                #1 if (out !== -Y) $display("Bad: -Y: got -",y,"=",out);
                #1 if (Z_flag!==0 && out !==0) $display("Bad: -Y: Z_flag is set but output=",out);

                // X+1
                C = nx+ex+ny+f+no;
                #1 if (out !== (X+1)%65536) $display("Bad: X+1: got ",x,"+1=",out);
                #1 if (Z_flag!==0 && out !==0) $display("Bad: X+1: Z_flag is set but output=",out);

                // Y+1
                C = ny+ey+nx+f+no;
                #1 if (out !== (Y+1)%65536) $display("Bad: Y+1: got ",y,"+1=",out);
                #1 if (Z_flag!==0 && out !==0) $display("Bad: Y+1: Z_flag is set but output=",out);

                // X-1
                C = ex+ny+f;
                #1 if (out !== (65536+X-1)%65536) $display("Bad: X-1: got ",x,"-1=",out);
                #1 if (Z_flag!==0 && out !==0) $display("Bad: X-1: Z_flag is set but output=",out);

                // Y-1
                C = ey+nx+f;
                #1 if (out !== (65536+Y-1)%65536) $display("Bad: Y-1: got ",y,"-1=",out);
                #1 if (Z_flag!==0 && out !==0) $display("Bad: Y-1: Z_flag is set but output=",out);

                // test that bus output works
                C = nx+ny; en = 1;
                #1 if (bus !== 65535) $display("Bad: not outputting to bus, ",bus);

                // test that bus output can be disabled
                en = 0;
                #1 if (bus !== 16'bZ) $display("Bad: still outputting to bus, ",bus);

                // test that carry out works
                C=ex+ey+f;
                #1
                sum = out;
                C_in = 1;
                #1 if (out !== sum+1) $display("Bad: C_in not working on X+Y",out);
                C_in = 0;

                // test that carry out works
                C=nx+ny+f;
                #1 if (out !== 65534) $display("Bad: -1+-1 got,",out);
                if (C_flag!==1) $display("Bad: C_flag not set");
            end
        end
    end
endmodule
