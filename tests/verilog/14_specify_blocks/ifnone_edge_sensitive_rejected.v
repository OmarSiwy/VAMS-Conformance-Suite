// IEEE 1364-2005 §14.2.4, Syntax 14-5, p. 215:
//   state_dependent_path_declaration ::=
//       if ( module_path_expression ) simple_path_declaration
//     | if ( module_path_expression ) edge_sensitive_path_declaration
//     | ifnone simple_path_declaration
// and §14.2.4.4, p. 218: "Only simple module paths may be described with an
// ifnone condition."
//
// ifnone prefixes an edge-sensitive path, which only `if` may. Legal
// neighbour: ifnone.v's ifnone (CLK => Q) = (2,2), the simple
// path beside the edge-sensitive (posedge CLK => (Q +: D)).
//! inherited IEEE 1364-2005 14.2.4 14.2.4.4
//! reject ifnone
//! neighbour ifnone.v
`timescale 1ns/1ns
module b_14_2_4_ifnone_edge_sensitive_rejected(CLK, D, Q);
  input CLK, D;
  output Q;
  reg Q;
  always @(posedge CLK) Q <= D;
  specify
    ifnone (posedge CLK => (Q +: D)) = (2,2);
  endspecify
endmodule
