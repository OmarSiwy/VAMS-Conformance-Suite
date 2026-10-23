// IEEE 1364-2005 §17.10.2, p. 321: "The user_string shall be of the following
// form: "plusarg_string format_string". The format strings are the same as
// the $display system tasks. These are the only valid ones (uppercase and
// lowercase as well as leading 0 forms are valid): %d ... %o ... %h ... %b
// ... %e ... %f ... %g ... %s"
//
// %t is a $display format (§17.1.1.2) but not one of the eight, and the
// user_string is a literal, so the call is invalid as written. Legal
// neighbour: value_plusargs_absent.v uses %d and %h.
//! inherited IEEE 1364-2005 17.10.2
//! reject E1100
//! reject %t
//! neighbour value_plusargs_absent.v
`timescale 1 ns / 1 ns
module b_17_10_2_value_plusargs_format_rejected;
  integer r, v;
  initial begin
    r = $value$plusargs("N=%t", v);
    $display("%0d", r);
  end
endmodule
