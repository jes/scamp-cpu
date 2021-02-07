/* Boot ROM */

module ROM(clk, address, value);
    input clk;
    input [7:0] address;
    output [15:0] value;

    reg [15:0] rom [0:255];

    initial begin
        $readmemh("bootrom.hex", rom);
    end

    reg [15:0] out;
    assign value = out;

    always @ (posedge clk) begin
        out <= rom[address];
    end
endmodule
