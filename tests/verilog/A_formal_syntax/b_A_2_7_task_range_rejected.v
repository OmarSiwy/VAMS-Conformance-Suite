// IEEE 1364-2005 A.2.7, p. 492:
//   task_declaration ::= task [ automatic ] task_identifier ; ...
//     | task [ automatic ] task_identifier ( [ task_port_list ] ) ; ...
// Unlike A.2.6's function_declaration, a task_declaration has no
// function_range_or_type: a task returns no value, so nothing sizes it.
//
// `task [7:0] t;` gives a task a range. Legal neighbour:
// b_A_2_7_task_declarations.v (`task old;`).
//! lrm A.2.7
//! lrm A.2.7:1000
//! inherited IEEE 1364-2005 A.2.7
//! reject E0208
//! neighbour b_A_2_7_task_declarations.v
module b_A_2_7_task_range_rejected;
  task [7:0] t;
    ;
  endtask
  initial $display("unreachable");
endmodule
