// Quad 2-input XOR gate

// Note: For WIDTH_IN > 2, this is the "parity checker" interpretation of multi-input XOR
// - conforms to chaining of XOR to create arbitrary wider input, e.g. "(A XOR B) XOR C"

`ifndef TTL_7486
`define TTL_7486

module ttl_7486 #(parameter BLOCKS = 4, WIDTH_IN = 2, DELAY_RISE = 0, DELAY_FALL = 0)
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
    computed[i] = A[i] ^ B[i];
end
//------------------------------------------------//

assign #(DELAY_RISE, DELAY_FALL) Y = computed;

endmodule

`endif
