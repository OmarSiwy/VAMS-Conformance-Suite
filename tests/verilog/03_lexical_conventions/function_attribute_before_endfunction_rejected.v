// IEEE 1364-2005 §3.8, p. 16: "An attribute_instance can appear in the
// Verilog description as a prefix attached to a declaration, a module item,
// a statement, or a port connection." Annex A.2.6: `function_declaration ::=
// function [ automatic ] [ function_range_or_type ] function_identifier ;
// function_item_declaration { function_item_declaration } function_statement
// endfunction`, and A.6.4 `function_statement ::= { attribute_instance }
// function_blocking_assignment | ...`: an instance inside the body prefixes a
// declaration or the statement.
//
// The (* a *) below comes after the formal's declaration and right before
// `endfunction`: no declaration or statement follows it for it to prefix.
// That is E0207 ("an attribute instance prefixes nothing"), the code the same
// instance gets before `endmodule` or end of file
// (dangling_attribute_rejected.v). Before #50 the function body
// dropped it silently. Nothing else is checked: a parse error stops the run
// before elaboration, so E0207 is the only error.
//
// Legal neighbour: subroutine_statement_attribute.v, whose function
// has the same instance prefixing its statement.
//! inherited IEEE 1364-2005 3.8.2
//! reject-only E0207
//! neighbour subroutine_statement_attribute.v
module b_3_8_2_function_attribute_before_endfunction_rejected;
  function integer f(input integer x);
    (* a *)
  endfunction
  initial $display("%0d", f(1));
endmodule
