/* Instruction register

   When "enl" is 1, gives val&0xff on to bus
   When "enh" is 1, gives 0xff00 + (val&0xff) on to bus
   When "load" is 1 and clock edge rises, takes in new value from the bus
   Always gives current value to 'value'
*/

`include "ttl/7404.v"
`include "ttl/74244.v"
`include "ttl/74377.v"

module IR(clk, bus, load, enl, enh, value);
    input clk;
    inout [15:0] bus;
    input load;
    input enl, enh;
    output [15:0] value;

    wire load_bar;
    wire nc;

    ttl_7404 inverter ({3'b0, enl, enh, load}, {nc,nc,nc, enl_bar, enh_bar, load_bar});

    ttl_74244 outbuflow1 ({enl_bar,enl_bar}, value[7:0], bus[7:0]);
    ttl_74244 outbufhigh1 ({enl_bar,enl_bar}, 8'h00, bus[15:8]);

    ttl_74244 outbuflow2 ({enh_bar,enh_bar}, value[7:0], bus[7:0]);
    ttl_74244 outbufhigh2 ({enh_bar,enh_bar}, 8'hff, bus[15:8]);

    ttl_74377 reglow (load_bar, bus[7:0], clk, value[7:0]);
    ttl_74377 reghigh (load_bar, bus[15:8], clk, value[15:8]);
endmodule
