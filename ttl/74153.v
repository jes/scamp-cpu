// Dual 4-input multiplexer

module ttl_74153 #(parameter BLOCKS = 2, WIDTH_IN = 4, WIDTH_SELECT = $clog2(WIDTH_IN),
                   DELAY_RISE = 0, DELAY_FALL = 0)
(
  input [BLOCKS-1:0] Enable_bar,
  input [WIDTH_SELECT-1:0] Select,
  input [WIDTH_IN-1:0] A,
  input [WIDTH_IN-1:0] B,
  output [BLOCKS-1:0] Y
);

//------------------------------------------------//
wire [WIDTH_IN-1:0] A [0:BLOCKS-1];
reg [BLOCKS-1:0] computed;
integer i;

always @(*)
begin
  for (i = 0; i < BLOCKS; i++)
  begin
    if (!Enable_bar[i])
      computed[i] = Select ? A[i] : B[i];
    else
      computed[i] = 1'b0;
  end
end
//------------------------------------------------//

assign #(DELAY_RISE, DELAY_FALL) Y = computed;

endmodule
