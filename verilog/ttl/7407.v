// Hex buffer/driver (OC)

module ttl_7407 #(parameter BLOCKS = 6, DELAY_RISE = 0, DELAY_FALL = 0)
(
  input [BLOCKS-1:0] A,
  output [BLOCKS-1:0] Y
);

//------------------------------------------------//
reg [BLOCKS-1:0] computed;

always @(*)
begin
  computed = A;
end
//------------------------------------------------//

assign #(DELAY_RISE, DELAY_FALL) Y = computed;

endmodule
