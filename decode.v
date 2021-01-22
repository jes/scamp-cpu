/* Decode: Turn an instruction into a microinstruction */

module Decode(instr, T_state);
    input [15:0] instr;

    output [2:0] bus_out; // output to bus selection
    output [2:0] bus_in;  // input from bus selection
    output PA;            // increment PC

    

endmodule
