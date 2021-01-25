/* Atmel AT28C16, 2K*8bit EEPROM

   (Writing mode not implemented)

   Pass the ROM contents as a parameter, e.g.:

     at28c16 rom #(ROM_FILE="bootrom.hex") (addr, bus, oe_bar, ce_bar);
*/

module at28c16 #(parameter ROM_FILE = "/dev/null", parameter ROM_BYTES = 2048) (addr, bus, oe_bar, ce_bar);
    input [10:0] addr;
    output [7:0] bus;
    input oe_bar, ce_bar;

    reg [7:0] rom [0:2047];

    initial begin
        $readmemh(ROM_FILE, rom, 0, ROM_BYTES-1);
    end

    assign en = !oe_bar && !ce_bar;

    assign bus = en ? rom[addr] : 8'bZ;
endmodule
