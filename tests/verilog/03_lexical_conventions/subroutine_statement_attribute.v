// IEEE 1364-2005 §3.8, p. 16: "An attribute_instance can appear in the
// Verilog description as a prefix attached to a declaration, a module item,
// a statement, or a port connection." A.6.4 `function_statement ::=
// { attribute_instance } function_blocking_assignment | ...` and `statement
// ::= { attribute_instance } ...`: an instance may prefix the one statement
// of a function body (A.2.6) or of a task body (A.2.7).
//
// Legal neighbour of function_attribute_before_endfunction_rejected.v
// and task_attribute_before_endtask_rejected.v: the same (* a *) now
// prefixes the body's statement. §3.8 standardizes no attribute, so each runs
// as if it were absent:
//   f(1) returns 1 + 1 -> 2, printed by the initial block as "f 2"
//   t(3) displays 3 * 2 -> "t 6"
// Printed, in that order: "f 2" then "t 6".
//! inherited IEEE 1364-2005 3.8.2
module b_3_8_2_subroutine_statement_attribute;
  function integer f(input integer x);
    (* a *) f = x + 1;
  endfunction
  task t;
    input integer x;
    (* a *) $display("t %0d", x * 2);
  endtask
  initial begin
    $display("f %0d", f(1));
    t(3);
  end
endmodule
