// Quad 2-input multiplexer

// if select is high we get B on the output, if select is low we get A

module ttl_74157 #(parameter BLOCKS = 4, WIDTH_IN = 2, WIDTH_SELECT = $clog2(WIDTH_IN),
                   DELAY_RISE = 0, DELAY_FALL = 0)
(
  input Enable_bar,
  input [WIDTH_SELECT-1:0] Select,
  input [BLOCKS-1:0] A,
  input [BLOCKS-1:0] B,
  output [BLOCKS-1:0] Y
);

//------------------------------------------------//
reg [BLOCKS-1:0] computed;
integer i;

always @(*)
begin
  for (i = 0; i < BLOCKS; i++)
  begin
    if (!Enable_bar)
      computed[i] = Select ? B[i] : A[i];
    else
      computed[i] = 1'b0;
  end
end
//------------------------------------------------//

assign #(DELAY_RISE, DELAY_FALL) Y = computed;

endmodule
