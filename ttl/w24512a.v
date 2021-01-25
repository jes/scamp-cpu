/* Winbond W24512A, 64k*8bit SRAM */

module w24512a (addr, bus, cs1_bar, cs2, we_bar, oe_bar);
    input [15:0] addr;
    inout [7:0] bus;
    input cs1_bar, cs2, we_bar, oe_bar;

    reg [7:0] ram [0:65535];

    assign we = !cs1_bar & cs2 & !we_bar;
    assign oe = !cs1_bar & cs2 & !oe_bar & we_bar;

    assign bus = oe ? ram[addr] : 8'bZ;

    always @ (negedge we_bar or posedge cs2 or negedge cs1_bar or posedge oe) begin
        if (we) ram[addr] <= bus;
    end

endmodule
