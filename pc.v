/* Program Counter */

module PC(clk, bus, load_bar, en_bar, value, inc, reset_bar);
    input clk;
    inout [15:0] bus;
    input load_bar;
    input en_bar;
    output [15:0] value;
    input inc;
    input reset_bar;

    assign load = !load_bar;
    assign en = !en_bar;

    reg [15:0] val;

    assign bus = en ? val : 16'hZZZZ;
    assign value = val;

    always @ (posedge clk or negedge reset_bar) begin
        if (reset_bar == 0) val <= 0;
        else if (load) val <= bus;
        else if (inc) val <= val + 1;
    end
endmodule
