// IEEE 1364-2005 §19.10, p. 360, Syntax 19-9:
//   pragma ::= `pragma pragma_name [ pragma_expression { , pragma_expression } ]
//   pragma_name ::= simple_identifier
// "The pragma specification is identified by the pragma_name, which follows
// the `pragma directive."
//
// The `pragma below has no pragma_name: nothing follows it on its line, so it
// is not a pragma of Syntax 19-9 at all (the "no effect" rule is for pragma
// names a tool does not recognize, not for a missing one). Legal neighbour:
// pragma_unrecognized_no_effect.v, whose two `pragma lines each name one.
//! inherited IEEE 1364-2005 19.10
//! reject requires a pragma name
//! neighbour pragma_unrecognized_no_effect.v
`pragma
module b_19_10_pragma_without_name_rejected;
  initial $display("accepted");
endmodule
