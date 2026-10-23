// IEEE 1364-2005 §3.7.3, p. 15, Syntax 3-2, footnote a: "The dollar sign ($)
// in a system_function_identifier or system_task_identifier shall not be
// followed by white space. A system_function_identifier or
// system_task_identifier shall not be escaped."
//
// `$ display` puts a blank after the $. Legal neighbour:
// system_task_forms.v, which writes $display.
//! inherited IEEE 1364-2005 3.7.3
//! reject E0209
//! reject found invalid token
//! neighbour system_task_forms.v
module b_3_7_3_space_after_dollar_rejected;
  initial $ display("x");
endmodule
