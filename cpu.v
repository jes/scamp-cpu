/* CPU */

`include "alu.v"
`include "control.v"
`include "decode.v"
`include "fr.v"
`include "ir.v"
`include "memory.v"
`include "pc.v"
`include "tstate.v"
`include "register.v"

module CPU(clk, RST_bar, addr, bus, DI, DO);
    input clk;
    input RST_bar;
    output [15:0] addr;
    inout [15:0] bus;
    output DI, DO;

    // register values
    wire [15:0] X_val;
    wire [15:0] Y_val;
    wire [15:0] E_val;
    wire [15:0] PC_val;
    wire [15:0] IR_val;
    wire [15:0] AR_val;

    // state
    wire [2:0] T;
    wire JMP;
    wire [15:0] uinstr;

    // control bits
    wire EO_bar, PO_bar, IOH_bar, IOL_bar, MO, DO; // outputs to bus
    wire AI_bar, II_bar, MI, XI_bar, YI_bar, DI; // inputs from bus
    wire RT, PP; // reset T-state, increment PC
    wire JC, JZ, JGT, JLT; // jump flags
    wire [5:0] ALU_flags;

    assign JMP_bar = !((JC&C) | (JZ&Z) | (JLT&LT) | (JGT&!Z&!LT));

    ALU alu (X_val, Y_val, ALU_flags, EO_bar, bus, E_val, C, C_flag, Z_flag, LT_flag);
    FR fr (clk, {C_flag, Z_flag, LT_flag}, EO_bar, {C, Z, LT});

    Register x (clk, bus, XI_bar, X_val);
    Register y (clk, bus, YI_bar, Y_val);

    PC pc (clk, bus, JMP_bar, PO_bar, PC_val, PP, RST_bar);
    IR ir (clk, bus, II_bar, IOL_bar, IOH_bar, IR_val);

    TState tstate (clk, RT|(!RST_bar), T);
    Decode decode (IR_val, T, uinstr);
    Control control (uinstr, EO_bar, PO_bar, IOH_bar, IOL_bar, MO, DO, RT, PP, AI_bar, II_bar, MI, XI_bar, YI_bar, DI, JC, JZ, JGT, JLT, ALU_flags);

    Register ar (clk, bus, AI_bar, AR_val);

    Memory memory (clk, bus, MI, MO, AR_val);

    parameter DEBUG = 0;

    always @ (posedge clk) begin
        if (DEBUG) begin
            $display("instr = ", IR_val);
            $display("uinstr = ", uinstr);
            $display("T = ", T);
            $display("bus = ", bus);
            $display("E_val = ", E_val);
            $display("PC = ", PC_val);
            $display("AR = ", AR_val);
            $display("C = ", C, " Z = ", Z, " LT = ", LT);
            if (!EO_bar) $write(" EO");
            if (!PO_bar) $write(" PO");
            if (!IOH_bar) $write(" IOH");
            if (!IOL_bar) $write(" IOL");
            if (MO) $write(" MO");
            if (DO) $write(" DO");
            if (RT) $write(" RT");
            if (PP) $write(" P+");
            if (!AI_bar) $write(" AI");
            if (!II_bar) $write(" II");
            if (MI) $write(" MI");
            if (!XI_bar) $write(" XI");
            if (!YI_bar) $write(" YI");
            if (DI) $write(" DI");
            if (JC) $write(" JC");
            if (JZ) $write(" JZ");
            if (JGT) $write(" JGT");
            if (JLT) $write(" JLT");
            $display("");
            $display("");
        end
    end
endmodule
