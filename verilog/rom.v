/* Boot ROM */

module ROM(address, value);
    input [7:0] address;
    output [15:0] value;

    reg [15:0] rom [0:255];

    initial begin
        $readmemh("bootrom.hex", rom);
    end

    assign value = rom[address];
endmodule
