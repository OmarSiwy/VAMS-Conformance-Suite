//! inherited IEEE 1364-2005 A.4.1
//! reject expected an expression: found `,`
// An ordered_parameter_assignment is an expression, so #( , 4) has an empty
// slot and is illegal (pr1716276).
module triage_empty_ordered_parameter_slot_rejected;
  sub #( , 4) u();
endmodule

module sub;
  parameter P = 1;
  parameter Q = 2;
endmodule
