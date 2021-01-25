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

module CPU #(parameter DEBUG=0) (clk, RST_bar, addr, bus, DI, DO);
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
    ttl_7408 ander1 ({JC, JZ, JLT, JGT}, {C, Z, LT, not_Z_LT}, {JC_C, JZ_Z, JLT_LT, JGT_GT});
    ttl_7432 orer ({RT, jmp1, JC_C, JZ_Z}, {RST, jmp2, JLT_LT, JGT_GT}, {TState_reset, JMP, jmp1, jmp2});
    ttl_7402 norer ({1'bZ, RST_bar, JMP, Z}, {1'bZ, RST_bar, JMP, LT}, {nc, RST, JMP_bar, not_Z_LT});

    // C_in = C & CE
    ttl_7408 ander2 ({3'bZ, C}, {3'bZ, CE}, {nc,nc,nc, C_in});

    ALU alu (X_val, Y_val, ALU_flags, EO_bar, bus, E_val, C_in, C_flag, Z_flag, LT_flag);
    FR fr (clk, {C_flag, Z_flag, LT_flag}, EO_bar, {C, Z, LT});

    Register x (clk, bus, XI_bar, X_val);
    Register y (clk, bus, YI_bar, Y_val);

    PC pc (clk, bus, JMP_bar, PO_bar, PC_val, PP, RST_bar);
    IR ir (clk, bus, II_bar, IOL_bar, IOH_bar, IR_val);

    TState tstate (clk, TState_reset, T);
    Decode decode (IR_val, T, uinstr);
    Control control (uinstr, EO_bar, PO_bar, IOH_bar, IOL_bar, MO, DO, RT, PP, AI_bar, II_bar, MI, XI_bar, YI_bar, DI, JC, JZ, JGT, JLT, ALU_flags, CE);

    Register ar (clk, bus, AI_bar, AR_val);

    Memory memory (clk, bus, MI, MO, AR_val);

    always @ (posedge clk) begin
        if (DEBUG) begin
            $display("instr = ", IR_val);
            $display("uinstr = ", uinstr);
            $display("T = ", T);
            $display("bus = ", bus);
            $display("E_val = ", E_val);
            $display("PC = ", PC_val);
            $display("AR = ", AR_val);
            $display("X = ", X_val);
            $display("Y = ", Y_val);
            $display("C = ", C, " Z = ", Z, " LT = ", LT);
            if (!EO_bar) begin
                $write(" EO");
                if (ALU_flags[5]) $write(" EX");
                if (ALU_flags[4]) $write(" NX");
                if (ALU_flags[3]) $write(" EY");
                if (ALU_flags[2]) $write(" NY");
                if (ALU_flags[1]) $write(" F");
                if (ALU_flags[0]) $write(" NO");
            end
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
