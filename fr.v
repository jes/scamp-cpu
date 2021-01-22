/* Flags register

   Loads content if "load", on rising edge of clock
 */

module FR(clk, in, load_bar, out);
    input clk;
    input [2:0] in;
    input load_bar;
    output [2:0] out;

    reg [2:0] val;

    assign out = val;

    always @ (posedge clk) begin
        if (!load_bar) val <= in;
    end
endmodule
