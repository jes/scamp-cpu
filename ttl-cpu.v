/* CPU */

`include "ttl-alu.v"
`include "ttl-control.v"
`include "ttl-decode.v"
`include "ttl-fr.v"
`include "ttl-ir.v"
`include "ttl-memory.v"
`include "ttl-pc.v"
`include "ttl-tstate.v"
`include "ttl-register.v"

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
    wire [15:0] memory_val;

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

    // JMP_bar = !((JC&C) | (JZ&Z) | (JLT&LT) | (JGT&!Z&!LT))
    // TState_reset = RT|!RST_bar
    ttl_7408 ander ({JC, JZ, JLT, JGT}, {C, Z, LT, not_Z_LT}, {JC_C, JZ_Z, JLT_LT, JGT_GT});
    ttl_7432 orer ({RT, jmp1, JC_C, JZ_Z}, {RST, jmp2, JLT_LT, JGT_GT}, {TState_reset, JMP, jmp1, jmp2});
    ttl_7402 norer ({1'bZ, RST_bar, JMP, Z}, {1'bZ, RST_bar, JMP, LT}, {nc, RST, JMP_bar, not_Z_LT});

    ALU alu (X_val, Y_val, ALU_flags, EO_bar, bus, E_val, C, C_flag, Z_flag, LT_flag);
    FR fr (clk, {C_flag, Z_flag, LT_flag}, EO_bar, {C, Z, LT});

    Register x (clk, bus, XI_bar, X_val);
    Register y (clk, bus, YI_bar, Y_val);

    PC pc (clk, bus, JMP_bar, PO_bar, PC_val, PP, RST_bar);
    IR ir (clk, bus, II_bar, IOL_bar, IOH_bar, IR_val);

    TState tstate (clk, TState_reset, T);
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
            if (!EO_bar) $display("+ EO");
            if (!PO_bar) $display("+ PO");
            if (!IOH_bar) $display("+ IOH");
            if (!IOL_bar) $display("+ IOL");
            if (MO) $display("+ MO");
            if (DO) $display("+ DO");
            if (RT) $display("+ RT");
            if (PP) $display("+ P+");
            if (!AI_bar) $display("+ AI");
            if (!II_bar) $display("+ II");
            if (MI) $display("+ MI");
            if (!XI_bar) $display("+ XI");
            if (!YI_bar) $display("+ YI");
            if (DI) $display("+ DI");
        end
    end

    always @ (negedge clk) begin
        if (DEBUG) $display("");
    end

endmodule
