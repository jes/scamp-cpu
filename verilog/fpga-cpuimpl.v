/* CPU */

module CPU #(parameter DEBUG=0) (clk, clk90, RST_bar, addr, bus, busin, DI, DO, PC_val);
    input clk;
    input clk90;
    input [15:0] busin;
    input RST_bar;
    output [15:0] addr;
    output [15:0] bus;
    output DI, DO;
    output [15:0] PC_val;

    // register values
    wire [15:0] X_val;
    wire [15:0] Y_val;
    wire [15:0] E_val;
    //wire [15:0] PC_val;
    wire [15:0] IR_val;
    wire [15:0] AR_val;

    // state
    wire [2:0] T;
    wire [15:0] uinstr;
    wire [5:0] ALU_op;

    ALU alu (X_val, Y_val, ALU_op, EO_bar, bus, E_val, Z_new, LT_new);
    FR fr (clk, {Z_new, LT_new}, EO_bar, {Z, LT});

    Register x (clk, bus, XI_bar, X_val);
    Register y (clk, bus, YI_bar, Y_val);

    PC pc (clk, bus, JMP_bar, PO_bar, PC_val, PP, RST_bar);
    IR ir (clk, bus, II_bar, IOL_bar, IOH_bar, IR_val);

    TState tstate (clk, RT, RST_bar, T);
    Ucode ucode (clk90, IR_val, T, uinstr);
    Control control (uinstr, Z, LT, EO_bar, PO_bar, IOH_bar, IOL_bar, MO, DO, RT, PP, AI_bar, II_bar, MI, XI_bar, YI_bar, DI, JZ, JGT, JLT, ALU_op, JMP_bar);

    Register ar (clk, bus, AI_bar, AR_val);

    assign addr = AR_val;

    assign bus = (!PO_bar ? PC_val : (MO ? memory_val : (DO ? busin : (!EO_bar ? E_val : (!IOH_bar ? (16'hff00 | IR_val[7:0]) : (!IOL_bar ? (IR_val[7:0]) : 0))))));

    wire [15:0] memory_val;

    Memory memory (clk90, bus, MI, MO, AR_val, memory_val);

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
