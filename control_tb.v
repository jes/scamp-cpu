/* Control logic testbench */
`include "control.v"

module test;
    reg [15:0] uinstr;

    parameter vEO = 16'h8000;
    parameter vEX = 16'h4000;
    parameter vNX = 16'h2000;
    parameter vEY = 16'h1000;
    parameter vNY = 16'h0800;
    parameter vF  = 16'h0400;
    parameter vNO = 16'h0200;
    parameter vJC = 16'h0020;
    parameter vJZ = 16'h0010;
    parameter vJGT = 16'h0008;
    parameter vJLT = 16'h0004;

    parameter vPO = 0;
    parameter vIOH = vEY;
    parameter vIOL = vNX;
    parameter vMO = vNX|vEY;
    parameter vDO = vEX|vNX;
    parameter vRT = vNY;
    parameter vPP = vF;

    parameter vAI = 16'h0040;
    parameter vII = 16'h0080;
    parameter vMI = vAI|vII;
    parameter vXI = 16'h0100;
    parameter vYI = vXI|vAI;
    parameter vDI = vXI|vII;

    wire [5:0] ALU_flags;

    assign PO = !PO_bar;
    assign IOH = !IOH_bar;
    assign IOL = !IOL_bar;
    assign EO = !EO_bar;
    assign AI = !AI_bar;
    assign II = !II_bar;
    assign XI = !XI_bar;
    assign YI = !YI_bar;

    wire [15:0] real_uinstr = {!uinstr[15], uinstr[14:0]};

    Control control (real_uinstr, EO_bar, PO_bar, IOH_bar, IOL_bar, MO, DO, RT, PP, AI_bar, II_bar, MI, XI_bar, YI_bar, DI, JC, JZ, JGT, JLT, ALU_flags);

    initial begin
        uinstr = vIOH | vJC;
        #1 if (!IOH || !JC) $display("Bad: !IOH || !JC");

        uinstr = vPO | vAI;
        #1 if (!PO || !AI) $display("Bad: !PO || !AI");

        uinstr = vMO | vAI;
        #1 if (!MO || !AI) $display("Bad: !MO || !AI");

        uinstr = vMO | vYI | vPP;
        #1 if (!MO || !YI || !PP) $display("Bad: !MO || !YI || !PP");

        uinstr = vDO | vAI;
        #1 if (!DO || !AI) $display("Bad: !DO || !AI");

        uinstr = vEO | (vNX | vEY | vNY | vF | vNO) | vAI;
        #1 if (!EO || !AI || ALU_flags !== 31) $display("Bad: !EO || !AI || ALU_flags != 31,",ALU_flags);

        uinstr = vEO;
        #1 if (PO || IOH || IOL || MO || DO) $display("Bad: output flags set when not wanted");

        uinstr = vPO;
        #1 if (!PO || IOH || IOL || MO || DO) $display("Bad: output flags set wrong");

        uinstr = vDI;
        #1 if (!DI || AI || II || MI || XI || YI) $display("Bad: input flags set wrong");

        uinstr = vEO;
        #1 if (RT || PP || JC || JZ || JGT || JLT) $display("Bad: other flags set wrong");

        uinstr = 0;
        #1 if (EO || IOH || IOL || MO || DO || RT || PP || AI || II || MI || XI || YI || DI || JC || JZ || JGT || JLT) $display("Bad, some flags set but none asked for");
        #1 if (!PO) $display("Bad: PO doesn't work");

        uinstr = vEO;
        #1 if (!EO) $display("Bad: EO doesn't work");

        uinstr = vIOH;
        #1 if (!IOH) $display("Bad: IOH doesn't work");

        uinstr = vIOL;
        #1 if (!IOL) $display("Bad: IOL doesn't work");

        uinstr = vMO;
        #1 if (!MO) $display("MO doesn't work");

        uinstr = vDO;
        #1 if (!DO) $display("DO doesn't work");

        uinstr = vRT;
        #1 if (!RT) $display("RT doesn't work");

        uinstr = vPP;
        #1 if (!PP) $display("P+ doesn't work");

        uinstr = vAI;
        #1 if (!AI) $display("AI doesn't work");

        uinstr = vII;
        #1 if (!II) $display("II doesn't work");

        uinstr = vMI;
        #1 if (!MI) $display("MI doesn't work");

        uinstr = vXI;
        #1 if (!XI) $display("XI doesn't work");

        uinstr = vYI;
        #1 if (!YI) $display("YI doesn't work");

        uinstr = vDI;
        #1 if (!DI) $display("DI doesn't work");

        uinstr = vJC;
        #1 if (!JC) $display("JC doesn't work");

        uinstr = vJZ;
        #1 if (!JZ) $display("JZ doesn't work");

        uinstr = vJGT;
        #1 if (!JGT) $display("JGT doesn't work");

        uinstr = vJLT;
        #1 if (!JLT) $display("JLT doesn't work");
    end
endmodule
