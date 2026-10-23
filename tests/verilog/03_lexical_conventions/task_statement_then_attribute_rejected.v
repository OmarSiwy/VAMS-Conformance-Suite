// IEEE 1364-2005 §3.8, p. 16: "An attribute_instance can appear in the
// Verilog description as a prefix attached to a declaration, a module item,
// a statement, or a port connection." Annex A.2.7: `task_declaration ::=
// task [ automatic ] task_identifier ; { task_item_declaration }
// statement_or_null endtask`, and A.6.4 `statement ::= { attribute_instance }
// ...`: an instance inside the body prefixes a declaration or the statement.
//
// The (* a *) below comes after the body's statement and right before
// `endtask`: no declaration or statement follows it for it to prefix. That is
// E0207 ("an attribute instance prefixes nothing"), the code the same
// instance gets right after the declarations
// (task_attribute_before_endtask_rejected.v, #50). Before #66 the
// body's statement loop took it for the start of a statement and refused
// `endtask` as E0209 "expected an expression". A parse error stops the run
// before elaboration, so E0207 is the only error.
//
// Legal neighbour: subroutine_statement_attribute.v, whose task has
// the same instance prefixing its statement.
//! inherited IEEE 1364-2005 3.8.2
//! reject-only E0207
//! neighbour subroutine_statement_attribute.v
module b_3_8_2_task_statement_then_attribute_rejected;
  task t;
    input integer x;
    $display("%0d", x);
    (* a *)
  endtask
  initial t(1);
endmodule
