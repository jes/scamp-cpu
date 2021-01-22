/* General-purpose register for TTL CPU

   When "en" is 1, gives current value to the bus
   When "load" is 1 and clock edge rises, takes in new value from the bus
   Always gives current value to 'value'
*/
module Register(clk, bus, load_bar, en_bar, value);
    input clk;
    inout [15:0] bus;
    input load_bar;
    input en_bar;
    output [15:0] value;

    reg [15:0] val;

    assign load = !load_bar;
    assign en = !en_bar;

    assign bus = en ? val : 16'hZZZZ;
    assign value = val;

    always @ (posedge clk) begin
        if (load) val <= bus;
    end
endmodule
