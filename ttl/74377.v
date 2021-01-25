// Octal D flip-flop with enable

`ifndef TTL_74377
`define TTL_74377

module ttl_74377 #(parameter WIDTH = 8, DELAY_RISE = 0, DELAY_FALL = 0)
(
  input Enable_bar,
  input [WIDTH-1:0] D,
  input Clk,
  output [WIDTH-1:0] Q
);

//------------------------------------------------//
reg [WIDTH-1:0] Q_current = 0; // XXX: initialise to *something* so that Icarus Verilog doesn't propagate "unknown" everywhere

always @(posedge Clk)
begin
  if (!Enable_bar)
    Q_current <= D;
end
//------------------------------------------------//

assign #(DELAY_RISE, DELAY_FALL) Q = Q_current;

endmodule

`endif
