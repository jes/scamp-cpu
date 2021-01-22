// 3-line to 8-line decoder/demultiplexer (inverted outputs)

module ttl_74138 #(parameter WIDTH_OUT = 8, WIDTH_IN = $clog2(WIDTH_OUT),
                   DELAY_RISE = 0, DELAY_FALL = 0)
(
  input Enable1_bar,
  input Enable2_bar,
  input Enable3,
  input [WIDTH_IN-1:0] A,
  output [WIDTH_OUT-1:0] Y
);

//------------------------------------------------//
reg [WIDTH_OUT-1:0] computed;
integer i;

always @(*)
begin
  for (i = 0; i < WIDTH_OUT; i++)
  begin
    if (!Enable1_bar && !Enable2_bar && Enable3 && i == A)
      computed[i] = 1'b0;
    else
      computed[i] = 1'b1;
  end
end
//------------------------------------------------//

assign #(DELAY_RISE, DELAY_FALL) Y = computed;

endmodule
