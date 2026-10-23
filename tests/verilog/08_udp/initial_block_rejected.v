// IEEE 1364-2005 §8.5, p. 111, Table 8-2, initial statements in UDPs:
// "Contents limited to one procedural assignment statement"
// Syntax 8-1, p. 106: "udp_initial_statement ::= initial
// output_port_identifier = init_val ;"
//
// The initial statement is a begin-end block around the assignment. Legal
// neighbour: initial_values.v, the bare assignment.
//! inherited IEEE 1364-2005 8.5
//! reject E0208
//! reject found `begin`
//! neighbour initial_values.v
primitive block_init(q, g, d);
  output q;
  reg q;
  input g, d;
  initial begin q = 1; end
  table
    1 0 : ? : 0;
    1 1 : ? : 1;
    0 ? : ? : -;
  endtable
endprimitive

module b_8_5_initial_block_rejected;
  initial $finish(0);
endmodule
