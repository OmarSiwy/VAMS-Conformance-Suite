// IEEE 1364-2005 §8.1.2, p. 107: "Sequential UDPs shall contain a reg
// declaration for the output port, either in addition to the output
// declaration, when the UDP is declared using the first form of a UDP
// Header, or as part of the output_declaration."
// §8.3, p. 110: "Level-sensitive sequential behavior is represented the same
// way as combinational behavior, except that the output is declared to be of
// type reg and there is an additional field in each table entry."
//
// latch_no_reg is the clause's latch table (with its current-state field)
// under `output q;` alone, without `reg q;`. Legal neighbour:
// header_forms.v's latch_a, a level-sensitive latch table (loading
// on g=1 rather than the clause's clock=0) under `reg q;`.
//! inherited IEEE 1364-2005 8.1.2 8.3
//! reject E1100
//! reject reg declaration
//! neighbour header_forms.v
`timescale 1ns/1ns
primitive latch_no_reg(q, clock, data);
  output q;
  input clock, data;
  table
    0 1 : ? : 1;
    0 0 : ? : 0;
    1 ? : ? : -;
  endtable
endprimitive

module b_8_1_2_sequential_without_reg_rejected;
  reg c, d;
  wire q;
  latch_no_reg u(q, c, d);
  initial begin
    c = 0;
    d = 1;
    #1 $display("%b", q);
    $finish(0);
  end
endmodule
