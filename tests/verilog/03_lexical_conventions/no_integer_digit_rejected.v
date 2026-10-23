// IEEE 1364-2005 §3.5.2, p. 12: "Real numbers expressed with a decimal point
// shall have at least one digit on each side of the decimal point." ... "The
// following are invalid forms of real numbers because they do not have at
// least one digit on each side of the decimal point: .12 9. 4.E3 .2e-7"
//
// .12 has no digit left of the point. Legal neighbour: 0.1 in
// real_constants.v.
//! inherited IEEE 1364-2005 3.5.2
//! reject E0209
//! reject found `.`
//! neighbour real_constants.v
module b_3_5_2_no_integer_digit_rejected;
  real r;
  initial begin
    r = .12;
    $display("%f", r);
  end
endmodule
