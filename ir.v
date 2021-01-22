/* Instruction register

   When "enl" is 1, gives val&0xff on to bus
   When "enh" is 1, gives 0xff00 + (val&0xff) on to bus
   When "load" is 1 and clock edge rises, takes in new value from the bus
   Always gives current value to 'value'
*/
module IR(clk, bus, load, enl, enh, value);
    input clk;
    inout [15:0] bus;
    input load;
    input enl;
    input enh;
    output [15:0] value;

    reg [15:0] val;

    assign bus = enl ? (16'h0000 | (val&8'hff)) : (enh ? (16'hff00 | (val&8'hff)) : 16'hZZZZ);
    assign value = val;

    always @ (posedge clk) begin
        if (load) val <= bus;
    end
endmodule
