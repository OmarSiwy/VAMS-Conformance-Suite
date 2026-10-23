// IEEE 1364-2005 §4.8, p. 33: "Except for the following restrictions,
// variables declared as real can be used in the same places that integer and
// time variables are used:" ... "— Real variables shall not use range in the
// declaration." Syntax 4-3 (p. 32): real_declaration ::= real
// list_of_real_identifiers ; with no range.
//
// `real [3:0] r;` gives a real a range. Legal neighbour:
// integer_time_real.v's `real re;`.
//! inherited IEEE 1364-2005 4.8
//! reject E0208
//! neighbour integer_time_real.v
module b_4_8_real_range_rejected;
  real [3:0] r;
  initial $display("%f", r);
endmodule
