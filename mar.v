/* Memory Address Register */

module MAR(clk, bus, load_bar, value);
    input clk;
    input [15:0] bus;
    input load_bar;
    output [15:0] value;

    reg [15:0] val;

    assign value = val;

    always @ (posedge clk) begin
        if (!load_bar) val <= bus;
    end
endmodule
