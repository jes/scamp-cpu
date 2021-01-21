/* Program Counter */

module PC(clk, bus, load, en, value, inc, reset_bar);
    input clk;
    inout [15:0] bus;
    input load;
    input en;
    output [15:0] value;
    input inc;
    input reset_bar;

    reg [15:0] val;

    assign bus = en ? val : 16'hZZZZ;
    assign value = val;

    always @ (posedge clk or negedge reset_bar) begin
        if (reset_bar == 0) val <= 0;
        else if (load) val <= bus;
        else if (inc) val <= val + 1;
    end
endmodule
