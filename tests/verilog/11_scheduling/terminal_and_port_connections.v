// IEEE 1364-2005 §11.6.6, p. 162: "Ports can always be represented as
// declared objects connected as follows: - If an input port, then a
// continuous assignment from an outside expression to a local (input) net -
// If an output port, then a continuous assignment from a local output
// expression to an outside net" ... "Input terminals connected to other
// kinds of expressions are represented as implicit continuous assignments
// from the expression to an implicit net that is connected to the input
// terminal."
//
// Gate g's first input terminal is the expression a & b; child c's input
// port is the expression a | b and its output drives the outside net z.
//   a = 1, b = 1, c = 1: y = (1 & 1) & 1 = 1; z = ~(1 | 1) = 0
//   b = 0:               y = (1 & 0) & 1 = 0; z = ~(1 | 0) = 0
//   a = 0:               y = 0;               z = ~(0 | 0) = 1
// Each display is one time step after the change, so both implicit
// continuous assignments and the gate have updated.
//! inherited IEEE 1364-2005 11.6.6
`timescale 1ns/1ns
module b_11_6_6_child(input i, output o);
  assign o = ~i;
endmodule
module b_11_6_6_terminal_and_port_connections;
  reg a, b, c;
  wire y, z;
  and g(y, a & b, c);
  b_11_6_6_child u(.i(a | b), .o(z));
  initial begin
    a = 1; b = 1; c = 1;
    #1 $display("y=%b z=%b", y, z);
    b = 0;
    #1 $display("y=%b z=%b", y, z);
    a = 0;
    #1 $display("y=%b z=%b", y, z);
    $finish(0);
  end
endmodule
