/* CPU */

module CPU(clk);
    input clk;

    wire [15:0] bus;

    wire [15:0] X_val;
    wire [15:0] Y_val;

    wire [15:0] A_val;

    reg [5:0] A_c;
    reg EO, XI, XO, YI, YO;

    ALU alu(X_val, Y_val, A_c, EO, bus, A_val);

    Register XRegister (clk, bus, XI, XO, X_val);
    Register YRegister (clk, bus, YI, YO, Y_val);

endmodule
