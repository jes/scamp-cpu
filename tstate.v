/* T-state counter

   Counts up on the *negative* edge of the clock
 */

module TState (clk, reset_bar, T);
    input clk;
    input reset_bar;
    output [2:0] T;

    reg [2:0] Treg;

    assign T = Treg;

    always @ (negedge clk or negedge reset_bar) begin
        if (!reset_bar) Treg <= 0;
        else Treg <= Treg + 1;
    end
endmodule
