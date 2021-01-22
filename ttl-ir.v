/* Instruction register

   When "enl" is 1, gives val&0xff on to bus
   When "enh" is 1, gives 0xff00 + (val&0xff) on to bus
   When "load" is 1 and clock edge rises, takes in new value from the bus
   Always gives current value to 'value'
*/

`include "ttl/74244.v"
`include "ttl/74377.v"

module IR(clk, bus, load_bar, enl_bar, enh_bar, value);
    input clk;
    inout [15:0] bus;
    input load_bar;
    input enl_bar, enh_bar;
    output [15:0] value;

    wire load_bar;
    wire nc;

    ttl_74244 outbuflow1 ({enl_bar,enl_bar}, value[7:0], bus[7:0]);
    ttl_74244 outbufhigh1 ({enl_bar,enl_bar}, 8'h00, bus[15:8]);

    ttl_74244 outbuflow2 ({enh_bar,enh_bar}, value[7:0], bus[7:0]);
    ttl_74244 outbufhigh2 ({enh_bar,enh_bar}, 8'hff, bus[15:8]);

    ttl_74377 reglow (load_bar, bus[7:0], clk, value[7:0]);
    ttl_74377 reghigh (load_bar, bus[15:8], clk, value[15:8]);
endmodule
