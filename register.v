/* General-purpose register for TTL CPU

   When "en" is 1, gives current value to the bus
   When "load" is 1 and clock edge rises, takes in new value from the bus
   Always gives current value to 'value'
*/
module Register(clk, bus, load_bar, value);
    input clk;
    input [15:0] bus;
    input load_bar;
    output [15:0] value;

    reg [15:0] val = 0;

    assign load = !load_bar;

    assign value = val;

    always @ (posedge clk) begin
        if (load) val <= bus;
    end
endmodule
