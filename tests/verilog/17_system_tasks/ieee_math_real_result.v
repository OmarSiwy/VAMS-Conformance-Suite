// IEEE1364-2005 17.11.2: math functions accept and RETURN reals.
// sqrt(2.25)=1.5 exactly, so comparison against1.25 distinguishes a real
// result from integer truncation. pow(-2.0,3.0)=-8; floor(-1.25)=-2;
// ceil(-1.25)=-1. These inputs are in-domain and independently derived.
// Integer comparison outputs avoid depending on real-number display precision.
//! lrm 9.14
//! inherited IEEE 1364-2005 17.11.2
module audit_ieee_math_real_result;
  initial begin
    $display("sqrt %0d", $sqrt(2.25) > 1.25 && $sqrt(2.25) < 1.75);
    $display("pow %0d floor %0d ceil %0d", $pow(-2.0,3.0) == -8.0,
             $floor(-1.25) == -2.0, $ceil(-1.25) == -1.0);
    $finish(0);
  end
endmodule
