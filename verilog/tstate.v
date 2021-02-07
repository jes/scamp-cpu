/* T-state counter

   Counts up on the *negative* edge of the clock
 */

module TState (clk, reset1, reset2_bar, T);
    input clk;
    input reset1, reset2_bar;
    output [2:0] T;

    reg [2:0] Treg;

    assign T = Treg;

    always @ (negedge clk or posedge reset1 or negedge reset2_bar) begin
        if (reset1 || !reset2_bar) Treg <= 0;
        else Treg <= Treg + 1;
    end
endmodule
