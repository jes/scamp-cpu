/* Program Counter */

`include "ttl/7404.v"
`include "ttl/74161.v"
`include "ttl/74244.v"

module PC(clk, bus, load, en, value, inc, reset_bar);
    input clk;
    inout [15:0] bus;
    input load;
    input en;
    output [15:0] value;
    input inc;
    input reset_bar;

    ttl_7404 inverter ({4'b0, en, load}, {nc,nc,nc,nc, en_bar, load_bar});

    ttl_74244 outbuflow ({en_bar,en_bar}, value[7:0], bus[7:0]);
    ttl_74244 outbufhigh ({en_bar,en_bar}, value[15:8], bus[15:8]);

    ttl_74161 counter1 (reset_bar, load_bar, inc, inc, bus[3:0], clk, RCO1, value[3:0]);
    ttl_74161 counter2 (reset_bar, load_bar, inc, RCO1, bus[7:4], clk, RCO2, value[7:4]);
    ttl_74161 counter3 (reset_bar, load_bar, inc, RCO2, bus[11:8], clk, RCO3, value[11:8]);
    ttl_74161 counter4 (reset_bar, load_bar, inc, RCO3, bus[15:12], clk, RCO4, value[15:12]);
endmodule
