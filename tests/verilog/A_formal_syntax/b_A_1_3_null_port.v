// IEEE 1364-2005 A.1.3, p. 487-488:
//   list_of_ports ::= ( port { , port } )
//   port ::= [ port_expression ] | . port_identifier ( [ port_expression ] )
// The port_expression is optional, so `(a, , y)` is a list of three ports
// whose second is empty. §12.3.2, p. 174 (quoted for context): "The port
// expression is optional because ports can be defined that do not connect to
// anything internal to the module."
//
// b_A_1_3_np copies a to y; the top connects all three positions by order,
// the second to nothing: y = a = 1 -> "y=1".
//! inherited IEEE 1364-2005 A.1.3
`timescale 1ns/1ns
module b_A_1_3_np (a, , y);
  input a;
  output y;
  assign y = a;
endmodule
module b_A_1_3_null_port;
  wire y;
  b_A_1_3_np n (1'b1, , y);
  initial #1 begin
    $display("y=%b", y);
    $finish(0);
  end
endmodule
