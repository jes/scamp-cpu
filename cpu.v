/* CPU */

`include "alu.v"
`include "pc.v"
`include "register.v"

module CPU(clk);
    input clk;

    // bus
    wire [15:0] bus;

    // connected to register values
    wire [15:0] X_val;
    wire [15:0] Y_val;
    wire [15:0] A_val;
    wire [15:0] IR_val;
    wire [15:0] PC_val;

    // control bits
    // TODO: split these into outputs from microcode (reg, for now), and
    // computed values (wire)
    reg [5:0] A_c;
    reg reset_bar;
    reg EO, XI, XO, YI, YO, JZ, JNZ, JGT, JLT, JC, PO, PA, II, IO;
    wire JMP;

    // TODO: assign JMP = (JC&C) | (JZ&Z) | (JNZ&!Z) | (JGT&GT) | (JLT&!Z&!GT);

    ALU alu (X_val, Y_val, A_c, EO, bus, A_val);

    Register x (clk, bus, XI, XO, X_val);
    Register y (clk, bus, YI, YO, Y_val);

    // TODO: "ir" needs special logic on its output to
    // put either:
    //   IR_val & 0xff (if IOL)
    // or:
    //   0xff00 | (IR_val & 0xff) (if IOH)
    // on the bus, instead of just IR_VAL
    Register ir (clk, bus, II, IO, IR_val);

    PC pc (clk, bus, JMP, PO, PC_val, PA, reset_bar);

endmodule
