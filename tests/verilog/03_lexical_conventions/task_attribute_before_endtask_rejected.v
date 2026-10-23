// IEEE 1364-2005 §3.8, p. 16: "An attribute_instance can appear in the
// Verilog description as a prefix attached to a declaration, a module item,
// a statement, or a port connection." Annex A.2.7: `task_declaration ::=
// task [ automatic ] task_identifier ; { task_item_declaration }
// statement_or_null endtask`, and A.6.4 `statement ::= { attribute_instance }
// ...`: an instance inside the body prefixes a declaration or the statement.
//
// The (* a *) below comes after the formal's declaration and right before
// `endtask`: no declaration or statement follows it for it to prefix. That is
// E0207 ("an attribute instance prefixes nothing"), as before `endmodule` or
// end of file (dangling_attribute_rejected.v). A.2.7's
// `statement_or_null` lets a task body be a bare `;`, but an attribute does
// not stand in for one. Before #50 the task body dropped it silently. A parse
// error stops the run before elaboration, so E0207 is the only error.
//
// Legal neighbour: subroutine_statement_attribute.v, whose task has
// the same instance prefixing its statement.
//! inherited IEEE 1364-2005 3.8.2
//! reject-only E0207
//! neighbour subroutine_statement_attribute.v
module b_3_8_2_task_attribute_before_endtask_rejected;
  task t;
    input integer x;
    (* a *)
  endtask
  initial t(1);
endmodule
