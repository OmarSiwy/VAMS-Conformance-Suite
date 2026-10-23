// IEEE 1364-2005 §3.8, p. 16: "An attribute_instance can appear in the
// Verilog description as a prefix attached to a declaration, a module item,
// a statement, or a port connection." Annex A.6.7: `case_statement ::= case
// ( expression ) case_item { case_item } endcase` with `case_item ::=
// expression { , expression } : statement_or_null | default [ : ]
// statement_or_null`: an instance may prefix an item's statement, and no
// production puts one before `endcase`.
//
// The (* a *) below comes after the last case item and right before
// `endcase`: nothing follows it for it to prefix. That is E0207 ("an
// attribute instance prefixes nothing"), as before the `end` of a block
// (seq_block_attribute_before_end_rejected.v). Before #69 the arm
// loop took it for the start of a case item and refused `endcase` as E0209
// "expected an expression". A parse error stops the run before elaboration,
// so E0207 is the only error.
//
// Legal neighbour: case_item_statement_attribute.v, whose case,
// casez and casex items have the same instance prefixing their statements.
//! inherited IEEE 1364-2005 3.8.2
//! reject-only E0207
//! neighbour case_item_statement_attribute.v
module b_3_8_2_case_attribute_before_endcase_rejected;
  integer v;
  initial case (v)
    1: v = 2;
    default: v = 3;
    (* a *)
  endcase
endmodule
