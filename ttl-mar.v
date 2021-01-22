/* Memory Address Register */

`include "ttl/74377.v"

module MAR(clk, bus, load_bar, value);
    input clk;
    input [15:0] bus;
    input load_bar;
    output [15:0] value;

    ttl_74377 reglow (load_bar, bus[7:0], clk, value[7:0]);
    ttl_74377 reghigh (load_bar, bus[15:8], clk, value[15:8]);
endmodule
