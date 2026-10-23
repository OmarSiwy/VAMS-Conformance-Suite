// IEEE 1364-2005 §12.3.6, p. 178: "Multiple module instance port connections
// are not allowed, e.g., the following example is illegal: Example 3 ... a ia
// (.i (a), .i (b), // illegal connection of input port twice."
//
// u connects the input a twice. Legal neighbour: explicit_port_names.v
// (each port named once).
//! inherited IEEE 1364-2005 12.3.6
//! reject E1100
//! reject connected twice
//! neighbour explicit_port_names.v
module m(a, y);
  input a;
  output y;
  assign y = a;
endmodule
module b_12_3_6_port_connected_twice_rejected;
  reg r, s;
  wire w;
  m u(.a(r), .a(s), .y(w));
endmodule
