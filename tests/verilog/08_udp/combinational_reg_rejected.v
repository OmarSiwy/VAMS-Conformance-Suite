// IEEE 1364-2005 §8.1.2, p. 107: "Sequential UDPs shall contain a reg
// declaration for the output port, either in addition to the output
// declaration, when the UDP is declared using the first form of a UDP
// Header, or as part of the output_declaration. Combinational UDPs cannot
// contain a reg declaration."
//
// comb_reg has a combinational table (one field per input, then the output,
// no current-state field) and declares `reg q;`. Legal neighbour:
// definition_placement.v, the same table without the reg.
//! inherited IEEE 1364-2005 8.1.2
//! reject E1100
//! reject cannot contain a reg declaration
//! neighbour definition_placement.v
`timescale 1ns/1ns
primitive comb_reg(q, a);
  output q;
  reg q;
  input a;
  table
    0 : 1;
    1 : 0;
  endtable
endprimitive

module b_8_1_2_combinational_reg_rejected;
  reg a;
  wire y;
  comb_reg u(y, a);
  initial begin
    a = 0;
    #1 $display("%b", y);
    $finish(0);
  end
endmodule
