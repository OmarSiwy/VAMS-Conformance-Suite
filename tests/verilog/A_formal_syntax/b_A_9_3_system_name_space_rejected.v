// IEEE 1364-2005 A.9.3, p. 508:
//   system_task_identifier ::= $[ a-zA-Z0-9_$ ]{ [ a-zA-Z0-9_$ ] }
// Details, p. 509: "4) The dollar sign ($) in a system_function_identifier or
// system_task_identifier shall not be followed by white_space."
//
// `$ display("x");` puts a space after the dollar sign. Legal neighbour:
// every `$display(...)` in this directory.
//! inherited IEEE 1364-2005 A.9.3
//! reject E0209
//! reject found invalid token
module b_A_9_3_system_name_space_rejected;
  initial $ display("unreachable");
endmodule
