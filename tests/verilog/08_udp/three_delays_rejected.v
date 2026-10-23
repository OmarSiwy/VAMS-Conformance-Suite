// IEEE 1364-2005 §8.6, p. 113: "Only two delays may be specified because z
// is not supported for UDPs."
// Syntax 8-2, p. 113: "udp_instantiation ::= udp_identifier [ drive_strength
// ] [ delay2 ] udp_instance { , udp_instance } ;"
//
// g gives three delays. Legal neighbour: two_delays.v, #(2, 3).
//! inherited IEEE 1364-2005 8.6
//! reject E1100
//! reject two delays
//! neighbour two_delays.v
`timescale 1ns/1ns
primitive inv(q, a);
  output q;
  input a;
  table
    0 : 1;
    1 : 0;
  endtable
endprimitive

module b_8_6_three_delays_rejected;
  reg a;
  wire q;
  inv #(1, 2, 3) g(q, a);
  initial begin
    a = 0;
    #5 $display("%b", q);
    $finish(0);
  end
endmodule
