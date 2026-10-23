// IEEE 1364-2005 A.2.3, p. 491:
//   list_of_defparam_assignments ::= defparam_assignment { , defparam_assignment }
//   list_of_event_identifiers ::= event_identifier { dimension } { , event_identifier { dimension } }
//   list_of_net_decl_assignments ::= net_decl_assignment { , net_decl_assignment }
//   list_of_net_identifiers ::= net_identifier { dimension } { , net_identifier { dimension } }
//   list_of_param_assignments ::= param_assignment { , param_assignment }
//   list_of_port_identifiers ::= port_identifier { , port_identifier }
//   list_of_real_identifiers ::= real_type { , real_type }
//   list_of_specparam_assignments ::= specparam_assignment { , specparam_assignment }
//   list_of_variable_identifiers ::= variable_type { , variable_type }
//   list_of_variable_port_identifiers ::= port_identifier [ = constant_expression ]
//     { , port_identifier [ = constant_expression ] }
//
// Each list with at least two members. Values:
//   defparam c.A = 2, c.B = 3                        -> c.s = A + B = 5
//   event e1, e2          (list of two events)
//   wire p = 1'b1, q = 1'b0                          -> p=1 q=0
//   wire [1:0] na [0:1], nb   (a net with a dimension, then a plain net)
//   parameter M = 4, N = M + 1                       -> N = 5
//   input a, b (port identifiers of b_A_2_3_sum)
//   real x = 0.5, y                                   -> x = 0.50
//   specparam S1 = 1, S2 = S1 + 1                     -> S2 = 2
//   reg [3:0] v1 = 4'd6, v2                           -> v1 = 6
//   output reg [3:0] o1 = 4'd7, o2 = 4'd8 (variable port identifiers with
//   initializers)                                     -> o1 = 7, o2 = 8
// Output: "s=5 p=1 q=0 N=5 x=0.50 S2=2 v1=6 o1=7 o2=8".
//! inherited IEEE 1364-2005 A.2.3
`timescale 1ns/1ns
module b_A_2_3_child;
  parameter A = 0, B = 0;
  wire [3:0] s = A + B;
endmodule
module b_A_2_3_sum (a, b, o1, o2);
  input a, b;
  output reg [3:0] o1 = 4'd7, o2 = 4'd8;
endmodule
module b_A_2_3_declaration_lists;
  defparam c.A = 2, c.B = 3;
  event e1, e2;
  wire p = 1'b1, q = 1'b0;
  wire [1:0] na [0:1], nb;
  parameter M = 4, N = M + 1;
  real x = 0.5, y;
  specparam S1 = 1, S2 = S1 + 1;
  reg [3:0] v1 = 4'd6, v2;
  wire [3:0] o1, o2;
  b_A_2_3_child c ();
  b_A_2_3_sum u (p, q, o1, o2);
  initial #1 begin
    $display("s=%0d p=%b q=%b N=%0d x=%.2f S2=%0d v1=%0d o1=%0d o2=%0d",
             c.s, p, q, N, x, S2, v1, o1, o2);
    $finish(0);
  end
endmodule
