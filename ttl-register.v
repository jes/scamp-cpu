/* General-purpose 16-bit register for TTL CPU

   Likely to be used for:
    X register, Y register, instruction register

   When "en" is 1, gives current value to the bus
   When "load" is 1 and clock edge rises, takes in new value from the bus
   Always gives current value to 'value'
*/

`include "ttl/7404.v"
`include "ttl/74244.v"
`include "ttl/74377.v"

module Register(clk, bus, load, en, value);
    input clk;
    inout [15:0] bus;
    input load;
    input en;
    output [15:0] value;

    wire load_bar;
    wire nc;

    ttl_7404 inverter ({4'b0, en, load}, {nc,nc,nc,nc, en_bar, load_bar});

    ttl_74244 outbuflow ({en_bar,en_bar}, value[7:0], bus[7:0]);
    ttl_74244 outbufhigh ({en_bar,en_bar}, value[15:8], bus[15:8]);

    ttl_74377 reglow (load_bar, bus[7:0], clk, value[7:0]);
    ttl_74377 reghigh (load_bar, bus[15:8], clk, value[15:8]);
endmodule
