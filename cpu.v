/* CPU */

`include "alu.v"
`include "control.v"
`include "decode.v"
`include "fr.v"
`include "ir.v"
`include "mar.v"
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
    wire [15:0] PC_val;
    wire [15:0] IR_val;
    wire [15:0] MAR_val;

    // state
    wire [2:0] T;
    wire reset_bar;
    wire JMP;
    wire [15:0] uinstr;

    // control bits
    wire EO_bar, PO_bar, IOH_bar, IOL_bar, RO, XO_bar, YO_bar, DO; // outputs to bus
    wire MI_bar, II_bar, RI, XI_bar, YI_bar, DI; // inputs from bus
    wire RT, PP; // reset T-state, increment PC
    wire JC, JZ, JGT, JLT; // jump flags
    wire [5:0] ALU_flags;

    assign JMP_bar = !((JC&C) | (JZ&Z) | (JLT&LT) | (JGT&!Z&!LT));

    ALU alu (X_val, Y_val, ALU_flags, EO_bar, bus, E_val, C_in, C_flag, Z_flag, LT_flag);
    FR fr (clk, {C_flag, Z_flag, LT_flag}, EO_bar, {C, Z, LT});

    Register x (clk, bus, XI_bar, XO_bar, X_val);
    Register y (clk, bus, YI_bar, YO_bar, Y_val);

    PC pc (clk, bus, JMP_bar, PO_bar, PC_val, PP, reset_bar);
    IR ir (clk, bus, II_bar, IOL_bar, IOH_bar, IR_val);

    TState tstate (clk, RT, T);
    Decode decode (IR_val, T, uinstr);
    Control control (uinstr, EO_bar, PO_bar, IOH, IOL, RO, XO_bar, YO_bar, DO, RT, PP, MI_bar, II_bar, RI, XI_bar, YI_bar, DI, JC, JZ, JGT, JLT, ALU_flags);

    MAR mar (clk, bus, MI_bar, MAR_val);

endmodule
