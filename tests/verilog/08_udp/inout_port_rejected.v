// IEEE 1364-2005 §8.1.1, p. 107: "UDPs have multiple input ports and exactly
// one output port; bidirectional inout ports are not permitted on UDPs."
//
// Port b is declared inout. Legal neighbour: header_forms.v, whose
// and_a declares the same two-input table with both inputs as input.
//! inherited IEEE 1364-2005 8.1.1
//! reject E0207
//! reject found `inout`
//! neighbour header_forms.v
primitive bidir(q, a, b);
  output q;
  input a;
  inout b;
  table
    0 ? : 0;
    ? 0 : 0;
    1 1 : 1;
  endtable
endprimitive

module b_8_1_1_inout_port_rejected;
  initial $finish(0);
endmodule
