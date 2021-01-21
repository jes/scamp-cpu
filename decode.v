/* Instruction decoding */

module Decode(instr, bus_out, PA);
    input [15:0] instr;

    output [2:0] bus_out; // output to bus selection
    output [2:0] bus_in;  // input from bus selection
    output PA;            // increment PC

    

endmodule
