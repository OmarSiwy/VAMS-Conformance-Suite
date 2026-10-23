// IEEE 1364-2005 §3.8.2, p. 18: "The syntax for legal statements with
// attributes is shown in Syntax 3-4 through Syntax 3-9." Syntax 3-4:
// "module_declaration ::= { attribute_instance } module_keyword
// module_identifier ..." Every box puts the attribute before the element it
// is attached to (§3.8: "as a prefix attached to a declaration, a module
// item, a statement, or a port connection").
//
// The (* orphan *) after endmodule is followed by the end of the file: no
// module, primitive or config declaration follows for it to prefix. Legal
// neighbour: attribute_positions.v, whose (* keep *) prefixes a
// module declaration.
//! inherited IEEE 1364-2005 3.8.2
//! reject attribute instance prefixes nothing
//! neighbour attribute_positions.v
module b_3_8_2_dangling_attribute_rejected;
  initial $display("ran");
endmodule
(* orphan *)
