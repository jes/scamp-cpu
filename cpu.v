/* CPU */

`include "alu.v"
`include "pc.v"
`include "register.v"

module CPU(clk);
    input clk;

    // bus
    wire [15:0] bus;

    // register values
    wire [15:0] X_val;
    wire [15:0] Y_val;
    wire [15:0] E_val;
    wire [15:0] IR_val;
    wire [15:0] PC_val;

    // control bits
    wire EO, PO, IOH, IOL, RO, XO, YO, DO; // outputs to bus
    wire MI, II, RI, XI, YI, DI; // inputs from bus
    wire RT, PP; // reset T-state, increment PC
    wire JC, JZ, JGT, JLT; // jump flags
    wire reset;
    wire JMP;
    wire [5:0] ALU_flags;

    // TODO: assign JMP = (JC&C) | (JZ&Z) | (JNZ&!Z) | (JGT&GT) | (JLT&!Z&!GT);

    ALU alu (X_val, Y_val, ALU_flags, EO, bus, E_val);

    Register x (clk, bus, XI, XO, X_val);
    Register y (clk, bus, YI, YO, Y_val);

    // TODO: "ir" needs special logic on its output to
    // put either:
    //   IR_val & 0xff (if IOL)
    // or:
    //   0xff00 | (IR_val & 0xff) (if IOH)
    // on the bus, instead of just IR_VAL
    Register ir (clk, bus, II, IO, IR_val);

    PC pc (clk, bus, !JMP, !PO, PC_val, PP, !reset);

    TState tstate (!clk, RT, T);

    Control control (uinstr, EO, PO, IOH, IOL, RO, XO, YO, DO, RT, PP, MI, II, RI, XI, YI, DI, JC, JZ, JGT, JLT, ALU_flags);

    Decode decode (IR_val, T, uinstr);

endmodule
