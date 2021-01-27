/* Flags register

   Loads content if "load", on rising edge of clock
 */

module FR(clk, in, load_bar, out);
    input clk;
    input [1:0] in;
    input load_bar;
    output [1:0] out;

    reg [1:0] val = 0;

    assign out = val;

    always @ (posedge clk) begin
        if (!load_bar) val <= in;
    end
endmodule
