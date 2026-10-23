// IEEE 1364-2005 §8.6, p. 113: "Instances of UDPs are specified inside
// modules in the same manner as gates (see 7.1)." ... "The port connection
// rules remain the same as outlined in 7.1."
// A.3.3, p. 494: "output_terminal ::= net_lvalue"; A.8.5, p. 506:
// "net_lvalue ::= hierarchical_net_identifier [ { [ constant_expression ] }
// [ constant_range_expression ] ]" -- a constant bit-select of a vector net
// is an output terminal.
//
// Two inverters drive the two bits of q; q = ~{a1, a0}.
//   a1 = 0, a0 = 1 -> q = 10;  a1 = 1 -> q = 00
//! inherited IEEE 1364-2005 8.6
`timescale 1ns/1ns
primitive inv(q, a);
  output q;
  input a;
  table
    0 : 1;
    1 : 0;
  endtable
endprimitive

module b_8_6_output_bit_select;
  reg a1, a0;
  wire [1:0] q;
  inv g1(q[1], a1);
  inv g0(q[0], a0);
  initial begin
    a1 = 0;
    a0 = 1;
    #1 $display("%b", q);
    a1 = 1;
    #1 $display("%b", q);
    $finish(0);
  end
endmodule
