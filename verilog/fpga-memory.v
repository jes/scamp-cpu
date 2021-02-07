/* Memory

   When "en" is 1, gives current value to the bus
   When "load" is 1 and clock edge rises, RAM takes in new value from the bus
   Always gives current value to 'value'
*/

`include "fpga-rom.v"
`include "fpga-ram.v"

module Memory(clk, bus, load, en, address, value);
    input clk;
    input [15:0] bus;
    input load;
    input en;
    input [15:0] address;
    output [15:0] value;

    wire [15:0] rom_value;
    wire [15:0] ram_value;

    ROM rom (clk, address[7:0], rom_value);
    RAM ram (clk, bus, !load, address, ram_value);

    assign value = address < 256 ? rom_value : ram_value;
endmodule
