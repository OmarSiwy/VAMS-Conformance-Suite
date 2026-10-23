// IEEE 1364-2005 §3.7.3, p. 15, Syntax 3-2, footnote a: "The dollar sign ($)
// in a system_function_identifier or system_task_identifier shall not be
// followed by white space. A system_function_identifier or
// system_task_identifier shall not be escaped."
//
// \$display is an escaped identifier (§3.7.1), so it cannot name the system
// task $display; it names a user task $display, which no module declares.
// Legal neighbour: system_task_forms.v, which writes $display.
//! inherited IEEE 1364-2005 3.7.3
//! reject E1100
//! reject undeclared task
//! neighbour system_task_forms.v
module b_3_7_3_escaped_system_task_rejected;
  initial \$display ("x");
endmodule
