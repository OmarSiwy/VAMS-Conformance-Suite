// IEEE 1364-2005 §3.5.2, p. 12: "Real numbers expressed with a decimal point
// shall have at least one digit on each side of the decimal point." ... "The
// following are invalid forms of real numbers because they do not have at
// least one digit on each side of the decimal point: .12 9. 4.E3 .2e-7"
//
// 4.E3 has no digit between the point and the exponent. Legal neighbour:
// 1.2E12 in real_constants.v.
//! inherited IEEE 1364-2005 3.5.2
//! reject E0207
//! reject found `.`
//! neighbour real_constants.v
module b_3_5_2_no_fraction_digit_rejected;
  real r;
  initial begin
    r = 4.E3;
    $display("%f", r);
  end
endmodule
