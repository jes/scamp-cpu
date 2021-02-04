/* SCAMP ALU Card (LSB)

    Contains low byte of each of the ALU, X register, and Y register
*/

`include "ttl/74377.v"

module ALULow(clk, bus, XI_bar, YI_bar, EO_bar, ALU_op, carry_out, lsb_nz1, lsb_nz2,
        E_val, X_val, Y_val);
    input clk;
    inout [15:0] bus;
    input XI_bar, YI_bar, EO_bar;
    input [5:0] ALU_op;
    output carry_out, lsb_nz1, lsb_nz2;
    output [7:0] E_val;
    output [7:0] X_val;
    output [7:0] Y_val;

    assign E_val = val;
    assign X_val = X;
    assign Y_val = Y;

    wire [7:0] X;
    wire [7:0] Y;
    wire [7:0] val;

    ALU4 alu1 (X[3:0], Y[3:0], ALU_op, 1'b0, carry1, val[3:0], lsb_nz1);
    ALU4 alu2 (X[7:4], Y[7:4], ALU_op, carry1, carry_out, val[7:4], lsb_nz2);

    ttl_74244 buflow ({EO_bar,EO_bar}, val[7:0], bus[7:0]);

    ttl_74377 Xreg (XI_bar, bus[7:0], clk, X[7:0]);
    ttl_74377 Yreg (YI_bar, bus[7:0], clk, Y[7:0]);
endmodule
