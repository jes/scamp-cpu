/* T-state counter

   Counts up on the *negative* edge of the clock
 */

`include "ttl/7400.v"
`include "ttl/74161.v"

module TState (clk, reset1, reset2_bar, T);
    input clk;
    input reset1, reset2_bar;
    output [2:0] T;

    ttl_7400 nander ({clk, reset1, inv_reset1, wantreset}, {clk, reset1, reset2_bar, wantreset}, {inv_clk, inv_reset1, wantreset, wantreset_bar});

    ttl_74161 counter (wantreset_bar, 1'b1, 1'b1, 1'b1, 4'bZZZZ, inv_clk, RCO, {nc, T});
endmodule
