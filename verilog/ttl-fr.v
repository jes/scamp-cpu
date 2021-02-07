/* Flags register

   Loads content if "load", on rising edge of clock
 */

`include "ttl/74377.v"

module FR(clk, in, load_bar, out);
    input clk;
    input [1:0] in;
    input load_bar;
    output [1:0] out;

    ttl_74377 register (load_bar, {6'bZ, in}, clk, {nc,nc,nc,nc,nc,nc, out});
endmodule
