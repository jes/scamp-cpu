/* CPU */

`include "alu.v"
`include "control.v"
`include "decode.v"
`include "fr.v"
`include "ir.v"
`include "pc.v"
`include "tstate.v"
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

    // state
    wire [2:0] T;
    wire reset;
    wire JMP;
    wire [15:0] uinstr; // XXX: delete

    // control bits
    wire EO, PO, IOH, IOL, RO, XO, YO, DO; // outputs to bus
    wire MI, II, RI, XI, YI, DI; // inputs from bus
    wire RT, PP; // reset T-state, increment PC
    wire JC, JZ, JGT, JLT; // jump flags
    wire [5:0] ALU_flags;

    assign JMP = (JC&C) | (JZ&Z) | (JLT&LT) | (JGT&!Z&!LT);

    ALU alu (X_val, Y_val, ALU_flags, !EO, bus, E_val, C_in, C_flag, Z_flag, LT_flag);
    FR fr (clk, {C_flag, Z_flag, LT_flag}, !EO, {C, Z, LT});

    Register x (clk, bus, !XI, !XO, X_val);
    Register y (clk, bus, !YI, !YO, Y_val);

    IR ir (clk, bus, II, IOL, IOH, IR_val);

    PC pc (clk, bus, !JMP, !PO, PC_val, PP, !reset);

    TState tstate (!clk, RT, T);

    Control control (uinstr, EO, PO, IOH, IOL, RO, XO, YO, DO, RT, PP, MI, II, RI, XI, YI, DI, JC, JZ, JGT, JLT, ALU_flags);

    Decode decode (IR_val, T, uinstr);

endmodule
