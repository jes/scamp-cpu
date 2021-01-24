/* Boot ROM */

module ROM(address, en_bar, bus);
    input [7:0] address;
    input en_bar;
    output [15:0] bus;

    reg [15:0] rom [0:255];

    initial begin
        $readmemh("bootrom.hex", rom);
    end

    assign bus = en_bar? 16'bZ : rom[address];
endmodule
