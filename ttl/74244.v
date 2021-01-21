// Octal buffer with 3-state output

module ttl_74244 #(parameter WIDTH = 8, DELAY_RISE = 0, DELAY_FALL = 0)
(
  input [(WIDTH-1)/4:0] G_bar,
  input [WIDTH-1:0] A,
  output [WIDTH-1:0] Y
);

//------------------------------------------------//
integer i;
reg [WIDTH-1:0] computed;

always @(*)
begin
  for (i = 0; i < WIDTH; i++)
    computed[i] = G_bar[i/4] ? 1'bZ : A[i];
end
//------------------------------------------------//

assign #(DELAY_RISE, DELAY_FALL) Y = computed;

endmodule
