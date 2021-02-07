// Quad bus buffer, positive enable

module ttl_74126 #(parameter BLOCKS = 4, DELAY_RISE = 0, DELAY_FALL = 0)
(
  input [BLOCKS-1:0] C,
  input [BLOCKS-1:0] A,
  output [BLOCKS-1:0] Y
);

//------------------------------------------------//
integer i;
reg [BLOCKS-1:0] computed;

always @(*)
begin
  for (i = 0; i < BLOCKS; i++)
    computed[i] = C[i] ? A[i] : 1'bZ;
end
//------------------------------------------------//

assign #(DELAY_RISE, DELAY_FALL) Y = computed;

endmodule
