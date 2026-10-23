// IEEE 1364-2005 §19.2, p. 350, Syntax 19-1:
//   default_nettype_compiler_directive ::=
//        `default_nettype default_nettype_value
//   default_nettype_value ::= wire | tri | tri0 | tri1 | wand | triand | wor |
//        trior | trireg | uwire | none
//
// reg is a variable type, not in the list. Legal neighbour:
// none_all_declared.v uses tri, none and wire.
//! inherited IEEE 1364-2005 19.2
//! reject E0140
//! reject `default_nettype takes one net type
//! neighbour none_all_declared.v
`default_nettype reg
module b_19_2_value_rejected;
  initial $display("accepted");
endmodule
