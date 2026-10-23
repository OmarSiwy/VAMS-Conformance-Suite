// IEEE 1364-2005 A.4.1, p. 495:
//   module_instantiation ::= module_identifier [ parameter_value_assignment ]
//     module_instance { , module_instance } ;
//   parameter_value_assignment ::= # ( list_of_parameter_assignments )
//   list_of_parameter_assignments ::= ordered_parameter_assignment { , ordered_parameter_assignment }
//     | named_parameter_assignment { , named_parameter_assignment }
//   ordered_parameter_assignment ::= expression
//   named_parameter_assignment ::= . parameter_identifier ( [ mintypmax_expression ] )
//   module_instance ::= name_of_module_instance ( [ list_of_port_connections ] )
//   name_of_module_instance ::= module_instance_identifier [ range ]
//   list_of_port_connections ::= ordered_port_connection { , ordered_port_connection }
//     | named_port_connection { , named_port_connection }
//   ordered_port_connection ::= { attribute_instance } [ expression ]
//   named_port_connection ::= { attribute_instance } . port_identifier ( [ expression ] )
//
// b_A_4_1_add has parameters A = 1, B = 2 and ports (x, y, s): s = x + A + B
// (4 bits), y unused.
//   u1: ordered parameters #(3, 4), ordered ports with an empty second one:
//       s1 = 1 + 3 + 4 = 8
//   u2, u3 in one statement share its named parameters #(.A(5), .B());
//       §12.2.2.2, p. 171: "The parameter expression is optional ... The
//       parentheses are required, and in this case the parameter retains its
//       default value", so B = 2. Named ports, u3 with an empty .y():
//       s2 = 2 + 5 + 2 = 9, s3 = 3 + 5 + 2 = 10
//   u4: no parameter_value_assignment, empty connections (): s4 is never
//       connected; the instance only has to elaborate.
// (An instance array, name_of_module_instance's [ range ], is
// b_A_4_1_instance_array.v.)
// Output: "s1=8 s2=9 s3=10".
//! inherited IEEE 1364-2005 A.4.1
`timescale 1ns/1ns
module b_A_4_1_add (x, y, s);
  parameter A = 1, B = 2;
  input [3:0] x, y;
  output [3:0] s;
  assign s = x + A + B;
endmodule
module b_A_4_1_module_instantiation;
  wire [3:0] s1, s2, s3;
  b_A_4_1_add #(3, 4) u1 (4'd1, , s1);
  b_A_4_1_add #(.A(5), .B()) u2 (.x(4'd2), .y(4'd0), .s(s2)), u3 (.x(4'd3), .y(), .s(s3));
  b_A_4_1_add u4 ();
  initial #1 begin
    $display("s1=%0d s2=%0d s3=%0d", s1, s2, s3);
    $finish(0);
  end
endmodule
