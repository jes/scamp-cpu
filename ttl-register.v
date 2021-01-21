/* General-purpose register for TTL CPU

   When "en" is 1, gives current value to the bus
   When "load" is 1 and clock edge rises, takes in new value from the bus
   Always gives current value to 'value'
*/

`include "ttl/7404.v"
`include "ttl/74126.v"
`include "ttl/74377.v"

module Register(clk, bus, load, en, value);
    input clk;
    inout [15:0] bus;
    input load;
    input en;
    output [15:0] value;

    wire load_bar;
    wire nc;

    ttl_7404 inverter ({5'b0, load}, {nc,nc,nc,nc,nc, load_bar});

    ttl_74126 outbuf1 ({en,en,en,en}, value[3:0], bus[3:0]);
    ttl_74126 outbuf2 ({en,en,en,en}, value[7:4], bus[7:4]);
    ttl_74126 outbuf3 ({en,en,en,en}, value[11:8], bus[11:8]);
    ttl_74126 outbuf4 ({en,en,en,en}, value[15:12], bus[15:12]);

    ttl_74377 lower (load_bar, bus[7:0], clk, value[7:0]);
    ttl_74377 upper (load_bar, bus[15:8], clk, value[15:8]);
endmodule
