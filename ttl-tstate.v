/* T-state counter

   Counts up on the *negative* edge of the clock
 */

`include "ttl/7404.v"
`include "ttl/74138.v"
`include "ttl/74161.v"

module TState (clk, reset, T);
    input clk;
    input reset;
    output [2:0] T;

    ttl_7404 inverter1 ({4'bZZZZ, reset, clk}, {nc,nc,nc,nc, reset_bar, inv_clk});

    ttl_74161 counter (reset_bar, 1'b1, 1'b1, 1'b1, 4'bZZZZ, inv_clk, RCO, {nc, T});
endmodule
