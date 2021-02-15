/* SCAMP Memory Card

    Contains ROM, RAM, and address register.
*/

`include "ttl/7400.v"
`include "ttl/7432.v"
`include "ttl/74377.v"
`include "ttl/at28c16.v"
`include "ttl/w24512a.v"

module Memory(clk, bus, MI, MO, AI_bar, AR_val);
    input clk;
    inout [15:0] bus;
    input MI, MO, AI_bar;
    output [15:0] AR_val;

    wire [15:0] rom_value;
    wire [15:0] ram_value;

    at28c16 #(.ROM_FILE("testrom-low.hex"), .ROM_BYTES(256)) rom1 ({3'b0, AR_val[7:0]}, bus[7:0], romen_bar, 1'b0);
    at28c16 #(.ROM_FILE("testrom-high.hex"), .ROM_BYTES(256)) rom2 ({3'b0, AR_val[7:0]}, bus[15:8], romen_bar, 1'b0);

    w24512a ram1 (AR_val, bus[7:0], 1'b0, 1'b1, load_clk_bar, ramen_bar);
    w24512a ram2 (AR_val, bus[15:8], 1'b0, 1'b1, load_clk_bar, ramen_bar);

    // we want the RAM chip if any of the first 8 bits are 1, and the ROM
    // chip otherwise (i.e. ROM if AR_val < 256, else RAM)
    ttl_7432 orer1 ({AR_val[15], AR_val[14], AR_val[13], AR_val[12]}, {AR_val[11], AR_val[10], AR_val[9], AR_val[8]}, {or1, or2, or3, or4});
    ttl_7432 orer2 ({1'bZ, or5, or1, or2}, {1'bZ, or6, or3, or4}, {nc, want_ram, or5, or6});

    // ramen_bar = want_ram NAND MO
    // want_rom = want_ram NAND want_ram = !want_ram
    // romen_bar = want_rom NAND MO
    ttl_7400 nander ({MI, MO, MO, want_ram}, {clk, want_ram, want_rom, want_ram}, {load_clk_bar, ramen_bar, romen_bar, want_rom});

    ttl_74377 arlow (AI_bar, bus[7:0], clk, AR_val[7:0]);
    ttl_74377 arhigh (AI_bar, bus[15:8], clk, AR_val[15:8]);
endmodule
