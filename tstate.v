/* T-state counter

   Counts up on the *negative* edge of the clock
 */

module TState (clk, reset, T);
    input clk;
    input reset;
    output [2:0] T;

    reg [2:0] Treg;

    assign T = Treg;

    always @ (negedge clk or posedge reset) begin
        if (reset) Treg <= 0;
        else Treg <= Treg + 1;
    end
endmodule
