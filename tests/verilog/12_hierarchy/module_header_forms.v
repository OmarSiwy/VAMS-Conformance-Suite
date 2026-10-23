// IEEE 1364-2005 §12.1, p. 163: "A module definition shall be enclosed
// between the keywords module and endmodule. The identifier following the
// keyword module shall be the name of the module being defined. The optional
// list of parameter definitions shall specify an ordered list of the
// parameters for the module. The optional list of ports or port declarations
// shall specify an ordered list of the ports for the module." ... "The keyword
// macromodule can be used interchangeably with the keyword module to define a
// module." Syntax 12-3 (§12.3.1, p. 173): "list_of_port_declarations ::=
// ( port_declaration { , port_declaration } ) | ( )".
//
// Four headers, one per form (the fourth, b_12_1_module_header_forms itself,
// has no port list at all):
//   b_12_1_adder: macromodule, a module_parameter_port_list #(parameter P = 1)
//     and a list_of_port_declarations. u0 keeps P = 1, u1 passes #(2), the
//     first (only) entry of the ordered parameter list.
//   b_12_1_plain: a list_of_ports (a, y) with the directions in the body.
//   b_12_1_noports: the empty list_of_port_declarations ( ).
// With a = 3 (4'b0011): y0 = 3 + 1 = 4, y1 = 3 + 2 = 5,
//   y2 = ~4'b0011 = 4'b1100 = 12. At t = 2 b_12_1_noports prints "noports".
//! inherited IEEE 1364-2005 12.1 12.3.1
`timescale 1ns/1ns
macromodule b_12_1_adder #(parameter P = 1) (input [3:0] a, output [3:0] y);
  assign y = a + P;
endmodule
module b_12_1_plain(a, y);
  input [3:0] a;
  output [3:0] y;
  assign y = ~a;
endmodule
module b_12_1_noports();
  initial #2 $display("noports");
endmodule
module b_12_1_module_header_forms;
  reg [3:0] a;
  wire [3:0] y0, y1, y2;
  b_12_1_adder u0(a, y0);
  b_12_1_adder #(2) u1(a, y1);
  b_12_1_plain u2(a, y2);
  b_12_1_noports u3();
  initial begin
    a = 4'd3;
    #1 $display("%0d %0d %0d", y0, y1, y2);
  end
endmodule
