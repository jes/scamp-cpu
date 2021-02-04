/* SCAMP ALU Card (MSB)

    Contains high byte of each of the ALU, X register, and Y register.
    Also contains flags register.
*/

`include "ttl/7402.v"
`include "ttl/7432.v"
`include "ttl/74244.v"
`include "ttl/74377.v"

module ALUHigh(clk, bus, XI_bar, YI_bar, EO_bar, ALU_op, carry_in, lsb_nz1, lsb_nz2, Z, LT,
        E_val, X_val, Y_val);
    input clk;
    inout [15:0] bus;
    input XI_bar, YI_bar, EO_bar;
    input [5:0] ALU_op;
    input carry_in, lsb_nz1, lsb_nz2;
    output Z, LT;
    output [7:0] E_val;
    output [7:0] X_val;
    output [7:0] Y_val;

    assign E_val = val;
    assign X_val = X;
    assign Y_val = Y;

    wire [7:0] X;
    wire [7:0] Y;
    wire [7:0] val;

    ALU4 alu1 (X[3:0], Y[3:0], ALU_op, carry_in, carry1, val[3:0], nonzero1);
    ALU4 alu2 (X[7:4], Y[7:4], ALU_op, carry1, nc, val[7:4], nonzero2);

    ttl_74244 buflow ({EO_bar,EO_bar}, val[7:0], bus[15:8]);

    ttl_74377 Xreg (XI_bar, bus[15:8], clk, X[7:0]);
    ttl_74377 Yreg (YI_bar, bus[15:8], clk, Y[7:0]);

    assign LT_flag = val[7];

    ttl_7432 orer ({1'bZ, nonzero1, nonzero2, or1}, {1'bZ, lsb_nz1, lsb_nz2, or2}, {nc, or1, or2, nonzero});
    ttl_7402 norer ({3'bZ, nonzero}, {3'bZ, nonzero}, {nc,nc,nc, Z_flag});

    ttl_74377 flags (EO_bar, {6'bZ, Z_flag, LT_flag}, clk, {nc,nc,nc,nc,nc,nc, Z, LT});
endmodule
