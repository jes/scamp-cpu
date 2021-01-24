/* Memory

   When "en" is 1, gives current value to the bus
   When "load" is 1 and clock edge rises, RAM takes in new value from the bus
   Always gives current value to 'value'
*/

// XXX: ttl-rom.v and ttl-ram.v don't exist yet; in reality
// they will just be ROM/RAM chips, with no associated logic
`include "rom.v"
`include "ram.v"

`include "ttl/7400.v"
`include "ttl/7432.v"
`include "ttl/74244.v"

module Memory(clk, bus, load_bar, en, address, value);
    input clk;
    inout [15:0] bus;
    input load_bar;
    input en;
    input [15:0] address;
    output [15:0] value;

    wire [15:0] rom_value;
    wire [15:0] ram_value;

    ROM rom (address[7:0], rom_value);
    RAM ram (clk, bus, load_bar, address, ram_value);

    ttl_74244 rombuf1 ({romen_bar,romen_bar}, rom_value[7:0], bus[7:0]);
    ttl_74244 rombuf2 ({romen_bar,romen_bar}, rom_value[15:8], bus[15:8]);

    ttl_74244 rambuf1 ({ramen_bar,ramen_bar}, ram_value[7:0], bus[7:0]);
    ttl_74244 rambuf2 ({ramen_bar,ramen_bar}, ram_value[15:8], bus[15:8]);

    // we want the RAM chip if any of the first 8 bits are 1, and the ROM
    // chip otherwise (i.e. ROM if address < 256, else RAM)
    ttl_7432 orer1 ({address[15], address[14], address[13], address[12]}, {address[11], address[10], address[9], address[8]}, {or1, or2, or3, or4});
    ttl_7432 orer2 ({1'bZ, or5, or1, or2}, {1'bZ, or6, or3, or4}, {nc, want_ram, or5, or6});

    // ramen_bar = want_ram NAND en
    // want_rom = want_ram NAND want_ram = !want_ram
    // romen_bar = want_rom NAND en
    ttl_7400 nander ({1'bZ, en, en, want_ram}, {1'bZ, want_ram, want_rom, want_ram}, {nc, ramen_bar, romen_bar, want_rom});

    // XXX: long-term, we can get rid of the "value" output, but for now it is
    // useful for testing; but we don't need to implement it with TTL as long
    // as we don't use it for anything
    assign value = want_rom ? rom_value : ram_value;
endmodule
