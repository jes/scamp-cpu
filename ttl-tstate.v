/* T-state counter

   Counts up on the *negative* edge of the clock
 */

`include "ttl/7404.v"
`include "ttl/74138.v"
`include "ttl/74161.v"

module TState (clk, reset_bar, T);
    input clk;
    input reset_bar;
    output [2:0] T;

    ttl_7404 inverter1 ({5'bZZZZZ, clk}, {nc,nc,nc,nc,nc, inv_clk});

    ttl_74161 counter (reset_bar, 1'b1, 1'b1, 1'b1, 4'bZZZZ, inv_clk, RCO, {nc, T});
endmodule
