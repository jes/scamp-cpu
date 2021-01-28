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
    parameter vS8 = 16'h0100;
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

    parameter vAI = 16'h0020;
    parameter vII = 16'h0040;
    parameter vMI = vAI|vII;
    parameter vXI = 16'h0080;
    parameter vYI = vXI|vAI;
    parameter vDI = vXI|vII;

    wire [5:0] ALU_flags;

    assign PO = !PO_bar;
    assign IOH = !IOH_bar;
    assign IOL = !IOL_bar;
    assign EO = !EO_bar;
    assign S8 = !S8_bar;
    assign AI = !AI_bar;
    assign II = !II_bar;
    assign XI = !XI_bar;
    assign YI = !YI_bar;

    wire [15:0] real_uinstr = {!uinstr[15], uinstr[14:9], !uinstr[8], uinstr[7:0]};

    Control control (real_uinstr, Z, LT, EO_bar, S8_bar, PO_bar, IOH_bar, IOL_bar, MO, DO, RT, PP, AI_bar, II_bar, MI, XI_bar, YI_bar, DI, JZ, JGT, JLT, ALU_flags, JMP_bar);

    initial begin
        uinstr = vIOH | vJZ;
        #1 if (IOH!==1 || JZ!==1) $display("Bad: !IOH || !JZ");

        uinstr = vPO | vAI;
        #1 if (PO!==1 || AI!==1) $display("Bad: !PO || !AI");

        uinstr = vMO | vAI;
        #1 if (MO!==1 || AI!==1) $display("Bad: !MO || !AI");

        uinstr = vMO | vYI | vPP;
        #1 if (MO!==1 || YI!==1 || PP!==1) $display("Bad: !MO || !YI || !PP");

        uinstr = vDO | vAI;
        #1 if (DO!==1 || AI!==1) $display("Bad: !DO || !AI");

        uinstr = vEO | (vNX | vEY | vNY | vF | vNO) | vAI;
        #1 if (EO!==1 || AI!==1 || ALU_flags !== 31) $display("Bad: !EO || !AI || ALU_flags != 31,",ALU_flags);

        uinstr = vEO;
        #1 if (PO!==0 || IOH!==0 || IOL!==0 || MO!==0 || DO!==0) $display("Bad: output flags set when not wanted");

        uinstr = vPO;
        #1 if (PO!==1 || IOH!==0 || IOL!==0 || MO!==0 || DO!==0) $display("Bad: output flags set wrong");

        uinstr = vDI;
        #1 if (DI!==1 || AI!==0 || II!==0 || MI!==0 || XI!==0 || YI!==0) $display("Bad: input flags set wrong");

        uinstr = vEO;
        #1 if (RT!==0 || PP!==0 || JZ!==0 || JGT!==0 || JLT!==0) $display("Bad: other flags set wrong");

        uinstr = 0;
        #1 if (EO!==0 || S8!==0 || IOH!==0 || IOL!==0 || MO!==0 || DO!==0 || RT!==0 || PP!==0 || AI!==0 || II!==0 || MI!==0 || XI!==0 || YI!==0 || DI!==0 || JZ!==0 || JGT!==0 || JLT!==0) $display("Bad, some flags set but none asked for");
        #1 if (!PO) $display("Bad: PO doesn't work");

        uinstr = vEO;
        #1 if (EO!==1) $display("Bad: EO doesn't work");

        uinstr = vIOH;
        #1 if (IOH!==1) $display("Bad: IOH doesn't work");

        uinstr = vIOL;
        #1 if (IOL!==1) $display("Bad: IOL doesn't work");

        uinstr = vMO;
        #1 if (MO!==1) $display("Bad: MO doesn't work");

        uinstr = vDO;
        #1 if (DO!==1) $display("Bad: DO doesn't work");

        uinstr = vRT;
        #1 if (RT!==1) $display("Bad: RT doesn't work");

        uinstr = vPP;
        #1 if (PP!==1) $display("Bad: P+ doesn't work");

        uinstr = vAI;
        #1 if (AI!==1) $display("Bad: AI doesn't work");

        uinstr = vII;
        #1 if (II!==1) $display("Bad: II doesn't work");

        uinstr = vMI;
        #1 if (MI!==1) $display("Bad: MI doesn't work");

        uinstr = vXI;
        #1 if (XI!==1) $display("Bad: XI doesn't work");

        uinstr = vYI;
        #1 if (YI!==1) $display("Bad: YI doesn't work");

        uinstr = vDI;
        #1 if (DI!==1) $display("Bad: DI doesn't work");

        uinstr = vJZ;
        #1 if (JZ!==1) $display("Bad: JZ doesn't work");

        uinstr = vJGT;
        #1 if (JGT!==1) $display("Bad: JGT doesn't work");

        uinstr = vJLT;
        #1 if (JLT!==1) $display("Bad: JLT doesn't work");

        uinstr = vS8;
        #1 if (S8!==1) $display("Bad: S8 doesn't work");

        // TODO: test JMP_bar calculation based on Z,LT
    end
endmodule
