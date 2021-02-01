/* My guess at part of the 6551 ACIA

    reset_bar: when low, internal registers are cleared
    clk: 6551 reads/writes bus while clk is high
    rw: when high, 6551 writes to bus; when low, 6551 reads from bus
    reg_sel:
        0: tx/rx data register (depending on rw)
        1: status register (for write: programmed reset, data ignored)
        2: command register
        3: control register

   Since this module is only intended for use within the test harness, it
   simply ignores all the baud rate, flow control, etc. stuff and just
   outputs values written to the "transmit data register" to stdout.
 */

module mos_6551 (clk, cs0, cs1_bar, reset_bar, reg_sel, rw, data_bus);
    input clk, cs0, cs1_bar, reset_bar, rw;
    input [1:0] reg_sel;
    inout [7:0] data_bus;

    wire [7:0] bus_write_val;

    reg [7:0] recv_data_reg;
    reg [7:0] status_reg;
    reg [7:0] command_reg;
    reg [7:0] control_reg;

    assign cs = cs0 && !cs1_bar;

    assign bus_write_val = (reg_sel == 0 ? recv_data_reg : (reg_sel == 1 ? status_reg : (reg_sel == 2 ? command_reg : control_reg)));

    assign data_bus = (cs && rw ? bus_write_val : 8'bZ);

    always @ (posedge clk or negedge reset_bar) begin
        if (!reset_bar) begin
            status_reg = 0;
            command_reg = 0;
            control_reg = 0;
        end else if (cs) begin
            if (!rw) begin // read from bus
                if (reg_sel == 0) begin // writing to tx register
                    $write("%c", data_bus);
                end else if (reg_sel == 1) begin // programmed reset
                    status_reg = 0;
                    command_reg = 0;
                    control_reg = 0;
                end else if (reg_sel == 2) begin // writing to command register
                    command_reg = data_bus;
                end else /* reg_sel == 3 */ begin // writing to control register
                    control_reg = data_bus;
                end
            end else begin // reading
                // TODO: something to put $fgetc into recv_data_reg ???
            end
        end
    end

endmodule
