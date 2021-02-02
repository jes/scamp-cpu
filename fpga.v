/* CPU testbench */
`include "fpga-cpu.v"
`include "ledscan.v"

module top(clk,led1,led2,led3,led4,led5,led6,led7,led8,lcol1,lcol2,lcol3,lcol4,key1,key2,key3,key4);
    input clk;
    output led1;
    output led2;
    output led3;
    output led4;
    output led5;
    output led6;
    output led7;
    output led8;
    output lcol1;
    output lcol2;
    output lcol3;
    output lcol4;
    input key1;
    input key2;
    input key3;
    input key4;

    /* LED output */
    reg [7:0] leds1;
    reg [7:0] leds2;
    reg [7:0] leds3;
    reg [7:0] leds4;
    wire [7:0] leds;
    wire [3:0] lcol;
    assign { led8, led7, led6, led5, led4, led3, led2, led1 } = leds[7:0];
    assign { lcol4, lcol3, lcol2, lcol1 } = lcol[3:0];
    LedScan scan (
        .clk12MHz(clk),
        .leds1(leds1),
        .leds2(leds2),
        .leds3(leds3),
        .leds4(leds4),
        .leds(leds),
        .lcol(lcol)
    );

    reg reset_bar = 0;
    wire [15:0] addr;
    wire [15:0] bus;

    reg slowclk = 0;
    reg slowclk90 = 0;
    reg [31:0] count = 1000000; // needs to be long at first because rams don't work for 3 usec
    reg [31:0] count90 = 0;
    parameter clockdelay = 10000;

    wire [15:0] busin;
    assign busin = ((DO && addr == 0) ? (key1|(key2<<1)|(key3<<2)|(key4<<3)) : 0);

    CPU cpu (slowclk, slowclk90, reset_bar, addr, bus, busin, DI, DO, PC_val);

    reg [15:0] cycle = 0;

    always @ (posedge clk) begin
        if (count > 0) begin
            count <= count - 1;
        end else begin
            count <= clockdelay;
            slowclk <= !slowclk;
            reset_bar <= 1;
        end

        // We need a second clock 90 degrees out of phase, for controlling
        // reads from memory, because the FPGA RAM doesn't support continuous
        // assignment
        if (count90 > 0) begin
            count90 <= count90 - 1;
        end else begin
            count90 <= clockdelay;
            slowclk90 <= !slowclk90;
        end

        /*leds1 <= ~(bus[7:0]);
        leds2 <= ~(bus[15:8]);
        leds3 <= ~(addr[7:0]);
        leds4 <= ~(PC_val[7:0]);*/

        if (DI && addr == 0)
            leds1 <= bus[7:0];
        if (DI && addr == 1)
            leds2 <= bus[7:0];
        if (DI && addr == 2)
            leds3 <= bus[7:0];
        if (DI && addr == 3)
            leds4 <= bus[7:0];
    end
endmodule
