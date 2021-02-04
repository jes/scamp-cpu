/* SCAMP Instruction Card

    Contains microcode ROM, control logic, sequencer, program counter, instruction register.
*/

`include "ttl/7404.v"
`include "ttl/7408.v"
`include "ttl/7432.v"
`include "ttl/74138.v"
`include "ttl/74161.v"

module Instruction(clk, bus, reset_bar,
        Z, LT,
        EO_bar, MO, DO, AI_bar, MI, XI_bar, YI_bar, DI, ALU_op,
        PO_bar, IOH_bar, IOL_bar, RT, PP, II_bar, JZ, JGT, JLT, IR_val, uinstr, T, PC_val);

    input clk;
    inout [15:0] bus;
    input reset_bar;
    input Z, LT;
    output EO_bar, MO, DO, AI_bar, MI, XI_bar, YI_bar, DI;
    output [5:0] ALU_op;

    output PO_bar, IOH_bar, IOL_bar, RT, PP, II_bar, JZ, JGT, JLT;
    output [15:0] IR_val;
    output [15:0] uinstr;
    output [2:0] T;
    output [15:0] PC_val;

    assign IR_val = instr;

    /* Microcode ROM (ttl-ucode.v): */

    wire [10:0] addr;
    assign addr = {instr[15:8], T};

    at28c16 #(.ROM_FILE("ucode-low.hex")) rom2 (addr, uinstr[7:0], 1'b0, 1'b0);
    at28c16 #(.ROM_FILE("ucode-high.hex")) rom1 (addr, uinstr[15:8], 1'b0, 1'b0);

    /* Control logic (ttl-control.v): */

    wire [2:0] bus_out;
    wire [7:0] bus_out_dec;
    wire [2:0] bus_in;
    wire [7:0] bus_in_dec;

    assign EO_bar = uinstr[15];

    // ALU has no side effects if EO_bar, so we can safely tie
    // the bus_out signals to ALU_op without checking EO
    assign ALU_op = uinstr[14:9];
    assign bus_out = uinstr[14:12];
    assign bus_in = uinstr[7:5];

    assign JZ = uinstr[4];
    assign JGT = uinstr[3];
    assign JLT = uinstr[2];

    ttl_7404 inverter ({Z_LT, JMP, inv_MO, inv_DO, inv_MI, inv_DI}, {not_Z_LT, JMP_bar, MO, DO, MI, DI});

    ttl_74138 out_decoder (1'b0, 1'b0, EO_bar, bus_out, bus_out_dec);
    ttl_74138 in_decoder (1'b0, 1'b0, 1'b1, bus_in, bus_in_dec);

    // bus_out decoding:
    assign PO_bar = bus_out_dec[0];  // PC out
    assign IOH_bar = bus_out_dec[1]; // IR out (high end)
    assign IOL_bar = bus_out_dec[2]; // IR out (low end)
    assign inv_MO = bus_out_dec[3];  // Memory out
    // spare: assign .. = bus_out_dec[4];
    // spare: assign .. = bus_out_dec[5];
    assign inv_DO = bus_out_dec[6];  // device out
    // spare: assign .. = bus_out_dec[7];

    // decode RT/P+
    ttl_7408 ander ({2'bZ, EO_bar, EO_bar}, {2'bZ, uinstr[11], uinstr[10]}, {nc,nc, RT, PP});

    // bus_in decoding:
    // bus_in == 0 means nobody inputs from bus
    assign AI_bar = bus_in_dec[1]; // Address in
    assign II_bar = bus_in_dec[2]; // IR in
    assign inv_MI = bus_in_dec[3]; // Memory in
    assign XI_bar = bus_in_dec[4]; // X in
    assign YI_bar = bus_in_dec[5]; // Y in
    assign inv_DI = bus_in_dec[6]; // device in
    // spare: assign .. = bus_in_dec[7]

    // JMP = (JZ&Z) | (JLT&LT) | (JGT&!Z&!LT)
    ttl_7408 ander1 ({1'bZ, JZ, JLT, JGT}, {1'bZ, Z, LT, not_Z_LT}, {nc, JZ_Z, JLT_LT, JGT_GT});
    ttl_7432 orer ({1'bZ, Z, JZ_Z, JLT_LT}, {1'bZ, LT, JGT_GT, jmp1}, {nc, Z_LT, jmp1, JMP});

    /* Sequencer (ttl-tstate.v): */

    ttl_7400 nander ({clk, RT, inv_reset1, wantreset}, {clk, RT, reset_bar, wantreset}, {inv_clk, inv_reset1, wantreset, wantreset_bar});

    wire [2:0] T;

    ttl_74161 counter (wantreset_bar, 1'b1, 1'b1, 1'b1, 4'bZZZZ, inv_clk, RCO, {nc, T});

    /* Program counter (ttl-pc.v): */

    wire [15:0] PC_val;

    ttl_74244 outbuflow ({PO_bar,PO_bar}, PC_val[7:0], bus[7:0]);
    ttl_74244 outbufhigh ({PO_bar,PO_bar}, PC_val[15:8], bus[15:8]);

    ttl_74161 counter1 (reset_bar, JMP_bar, PP, PP, bus[3:0], clk, RCO1, PC_val[3:0]);
    ttl_74161 counter2 (reset_bar, JMP_bar, RCO1, PP, bus[7:4], clk, RCO2, PC_val[7:4]);
    ttl_74161 counter3 (reset_bar, JMP_bar, RCO2, PP, bus[11:8], clk, RCO3, PC_val[11:8]);
    ttl_74161 counter4 (reset_bar, JMP_bar, RCO3, PP, bus[15:12], clk, RCO4, PC_val[15:12]);

    /* Instruction register (ttl-ir.v): */

    ttl_74244 outbuflow1 ({IOL_bar,IOL_bar}, instr[7:0], bus[7:0]);
    ttl_74244 outbufhigh1 ({IOL_bar,IOL_bar}, 8'h00, bus[15:8]);

    ttl_74244 outbuflow2 ({IOH_bar,IOH_bar}, instr[7:0], bus[7:0]);
    ttl_74244 outbufhigh2 ({IOH_bar,IOH_bar}, 8'hff, bus[15:8]);

    wire [15:0] instr;

    ttl_74377 reglow (II_bar, bus[7:0], clk, instr[7:0]);
    ttl_74377 reghigh (II_bar, bus[15:8], clk, instr[15:8]);
endmodule
