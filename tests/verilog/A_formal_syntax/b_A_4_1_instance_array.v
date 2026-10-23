// IEEE 1364-2005 A.4.1, p. 495:
//   module_instance ::= name_of_module_instance ( [ list_of_port_connections ] )
//   name_of_module_instance ::= module_instance_identifier [ range ]
// §12.1.2, p. 165 (quoted for context): "The instantiations of modules can
// contain a range specification. This allows an array of instances to be
// created. ... The syntax and semantics of arrays of instances defined for
// gates and primitives apply for modules as well." (§7.1.6's bit-by-bit
// connection, as in b_A_3_1_gate_instantiations.v's `and ga [1:0]`.)
//
// b_A_4_1_inv inverts one bit; `b_A_4_1_inv ia [1:0] (y, a)` with the 2-bit a
// = 2'b10 gives ia[1] a[1] -> y[1] = 0 and ia[0] a[0] -> y[0] = 1.
// Output: "y=01".
//! inherited IEEE 1364-2005 A.4.1
`timescale 1ns/1ns
module b_A_4_1_inv (o, i);
  input i;
  output o;
  assign o = ~i;
endmodule
module b_A_4_1_instance_array;
  wire [1:0] a = 2'b10;
  wire [1:0] y;
  b_A_4_1_inv ia [1:0] (y, a);
  initial #1 begin
    $display("y=%b", y);
    $finish(0);
  end
endmodule
