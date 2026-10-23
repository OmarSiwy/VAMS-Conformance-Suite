// IEEE 1364-2005 §6.2.2, Syntax 6-2, p. 73:
//   real_type ::= real_identifier { dimension }
//               | real_identifier = constant_expression
// A real_type is either a real with dimensions or a real with a declaration
// assignment, never both.
//
// r has a dimension and a declaration assignment. Legal neighbours:
// declaration_forms.v's `real ra [0:1]` and `real rr = 1.5`.
//! inherited IEEE 1364-2005 6.2.2
//! reject E1100
//! reject an unpacked array declaration takes no initializer
//! neighbour declaration_forms.v
module b_6_2_2_real_array_initializer_rejected;
  real r [0:1] = 0.0;
  initial #1 $display("%f", r[0]);
endmodule
