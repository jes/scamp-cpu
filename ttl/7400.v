// Quad 2-input NAND gate

module ttl_7400 #(parameter BLOCKS = 4, WIDTH_IN = 2, DELAY_RISE = 0, DELAY_FALL = 0)
(
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
    computed[i] = ~(A[i]&B[i]);
end
//------------------------------------------------//

assign #(DELAY_RISE, DELAY_FALL) Y = computed;

endmodule
