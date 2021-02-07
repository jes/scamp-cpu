/* CPU */

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

    // state
    wire [2:0] T;
    wire [15:0] uinstr;
    wire [5:0] ALU_op;

    assign addr = AR_val;

    ALULow alu_low (clk, bus, XI_bar, YI_bar, EO_bar, ALU_op, carry, lsb_nz1, lsb_nz2,
        E_val[7:0], X_val[7:0], Y_val[7:0]);
    ALUHigh alu_high (clk, bus, XI_bar, YI_bar, EO_bar, ALU_op, carry, lsb_nz1, lsb_nz2, Z, LT,
        E_val[15:8], X_val[15:8], Y_val[15:8]);

    Memory memory (clk, bus, MI, MO, AI_bar, AR_val);

    Instruction instr (clk, bus, RST_bar,
        Z, LT, EO_bar, MO, DO, AI_bar, MI, XI_bar, YI_bar, DI, ALU_op,
        PO_bar, IOH_bar, IOL_bar, RT, PP, II_bar, JZ, JGT, JLT, IR_val, uinstr, T, PC_val);

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
            $display("Z = ", Z, " LT = ", LT);
            if (!EO_bar) begin
                $write(" EO");
                if (ALU_op[5]) $write(" EX");
                if (ALU_op[4]) $write(" NX");
                if (ALU_op[3]) $write(" EY");
                if (ALU_op[2]) $write(" NY");
                if (ALU_op[1]) $write(" F");
                if (ALU_op[0]) $write(" NO");
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
            if (JZ) $write(" JZ");
            if (JGT) $write(" JGT");
            if (JLT) $write(" JLT");
            $display("");
            $display("");
        end
    end
endmodule
