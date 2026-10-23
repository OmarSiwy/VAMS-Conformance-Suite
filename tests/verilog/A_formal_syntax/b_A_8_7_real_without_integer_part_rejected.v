// IEEE 1364-2005 A.8.7, p. 506-507:
//   real_number ::= unsigned_number . unsigned_number
//     | unsigned_number [ . unsigned_number ] exp [ sign ] unsigned_number
//   unsigned_number ::= decimal_digit { _ | decimal_digit }
// A real number starts with an unsigned_number: there is a digit before the
// decimal point.
//
// `.5` has none. Legal neighbour: b_A_8_7_numbers.v (`2.5E-1`).
//! inherited IEEE 1364-2005 A.8.7
//! reject E0209
//! reject expected an expression: found `.`
//! neighbour b_A_8_7_numbers.v
module b_A_8_7_real_without_integer_part_rejected;
  real x;
  initial begin
    x = .5;
    $display("%g", x);
  end
endmodule
