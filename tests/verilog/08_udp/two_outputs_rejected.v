// IEEE 1364-2005 §8.1.1, p. 107: "UDPs have multiple input ports and exactly
// one output port; bidirectional inout ports are not permitted on UDPs."
// §8, p. 105: "Each UDP has exactly one output".
//
// two_out declares q1 and q2 both as outputs; its table has one field for
// its one input a. Legal neighbour: header_forms.v, one output each.
//! inherited IEEE 1364-2005 8 8.1.1
//! reject E1100
//! reject exactly one output
//! neighbour header_forms.v
primitive two_out(q1, q2, a);
  output q1, q2;
  input a;
  table
    0 : 1;
    1 : 0;
  endtable
endprimitive

module b_8_1_1_two_outputs_rejected;
  reg a;
  wire q1, q2;
  two_out u(q1, q2, a);
  initial begin
    a = 0;
    #1 $display("%b %b", q1, q2);
    $finish(0);
  end
endmodule
