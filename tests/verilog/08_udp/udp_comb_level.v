// A.5.3: a combinational_entry is a level_input_list, and level symbols are
// all it may hold. The legal twin of reject_udp_comb_edge.v: the same
// table with its edge (01) replaced by level 1. IEEE1364-2005 §8.1.4: rows
// have disjoint inputs, and missing combinations, including xx, default to x.
// The definition is not instantiated, so the claim is definition acceptance.
//! lrm A.5.3
//! inherited IEEE 1364-2005 8.1.4 8.2
primitive udp_good_level (o, a, b);
  output o;
  input a, b;
  table
    1 0 : 1;
    1 1 : 0;
  endtable
endprimitive
module audit_definition;
  initial begin $display("definition accepted"); $finish(0); end
endmodule
