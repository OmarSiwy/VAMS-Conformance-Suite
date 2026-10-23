// IEEE 1364-2005 §18.3.1, p. 338, on $dumpports' scope_list: "One or more
// module identifiers. Only modules are allowed (not variables)." Syntax
// 18-21: `scope_list ::= module_identifier { , module_identfier }`.
//
// a is a reg, not a module instance. Legal neighbour: the module instance
// scope of dumpports_control_tasks.v.
//! inherited IEEE 1364-2005 18.3.1
//! reject E1100
//! reject module
//! neighbour dumpports_control_tasks.v
`timescale 1ns/1ns
module b_18_3_1_dumpports_variable_scope_rejected_dev(a, y);
  input a;
  output y;
  assign y = ~a;
endmodule

module b_18_3_1_dumpports_variable_scope_rejected;
  reg a;
  wire y, w;
  b_18_3_1_dumpports_variable_scope_rejected_dev u(a, y);
  b_18_3_1_dumpports_variable_scope_rejected_dev v(a, w);
  initial begin
    a = 1'b0;
    $dumpports(a, "b_18_3_1_variable.evcd");
    #1 a = 1'b1;
  end
endmodule
