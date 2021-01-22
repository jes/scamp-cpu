// 3-to-8 line decoder

module ttl_74138 #(parameter DELAY_RISE = 0, DELAY_FALL = 0)
(
  input G1, G2A_bar, G2B_bar,
  input [2:0] A, // {C,B,A}
  output [7:0] Y // {Y7,Y6,Y5,Y4,Y3,Y2,Y1,Y0}
);

//------------------------------------------------//
reg [7:0] computed;
wire enable;

assign enable = G1 && !G2A_bar && !G2B_bar;

always @(*)
begin
    computed = ~(enable ? 1 << A : 0);
end
//------------------------------------------------//

assign #(DELAY_RISE, DELAY_FALL) Y = computed;

endmodule
