/* T-state counter

   Counts up through the output bits on the *negative* edge of the clock
 */

module TState (clk, reset, out);
    input clk;
    input reset;
    output [7:0] out;

    reg [2:0] val;

    assign out = (1 << val);

    always @ (negedge clk or posedge reset) begin
        if (reset) val <= 0;
        else val <= val + 1;
    end
endmodule
