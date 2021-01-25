/* T-state counter

   Counts up on the *negative* edge of the clock
 */

`include "ttl/7404.v"
`include "ttl/7408.v"
`include "ttl/74138.v"
`include "ttl/74161.v"

module TState (clk, reset1, reset2_bar, T);
    input clk;
    input reset1, reset2_bar;
    output [2:0] T;

    ttl_7404 inverter1 ({4'bZZZZ, reset1, clk}, {nc,nc,nc,nc, reset1_bar, inv_clk});

    ttl_7408 ander ({3'bZ, reset1_bar}, {3'bZ, reset2_bar}, {nc,nc,nc, wantreset_bar});

    ttl_74161 counter (wantreset_bar, 1'b1, 1'b1, 1'b1, 4'bZZZZ, inv_clk, RCO, {nc, T});
endmodule
