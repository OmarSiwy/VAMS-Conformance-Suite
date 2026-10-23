// IEEE 1364-2005 §12.2, p. 168, of its own example (reproduced below):
// "Parameter B is not a typed and/or ranged parameter; therefore, when its
// value is redefined, the parameter type and range take on the type and range
// of the new value. Therefore, the defparam of f1.B with the value 3.1415
// replaces B's current value of 3'h2 with the floating point number 3.1415."
// p. 167: "A parameter with a type specification, but with no range
// specification, shall be of the type specified. An override value shall be
// converted to the type of the parameter. A signed parameter shall default to
// the range of the final override value assigned to the parameter." "A
// parameter with a signed type specification and with a range specification
// shall be signed and shall be the range of its declaration. An override
// value shall be converted to the type and range of the parameter."
//
//   r1 = A: A is [2:0], 3.1415 -> 3 -> 3'b011, so r1 = 3.0.
//   r2 = B: B becomes the real 3.1415, so r2 = 3.1415.
//   -> "r1 is 3.000000 r2 is 3.141500" (%f, six decimals)
//   S (signed, no range) overridden with 4'hF: the value keeps its 4 bits,
//     converted to signed: 4'b1111 = -1.
//   SR (signed [7:0]) overridden with 9'h1FF: converted to the 8-bit signed
//     range: 8'hFF = -1.
//   -> "S=-1 SR=-1"
//! inherited IEEE 1364-2005 12.2
`timescale 1ns/1ns
module foo(a,b);
  input a, b;
  real r1,r2;
  parameter [2:0] A = 3'h2;
  parameter B = 3'h2;
  parameter signed S = 4'sb0000;
  parameter signed [7:0] SR = 0;
  initial begin
    r1 = A;
    r2 = B;
    $display("r1 is %f r2 is %f",r1,r2);
    $display("S=%0d SR=%0d", S, SR);
  end
endmodule
module b_12_2_real_and_signed_overrides;
  wire a,b;
  defparam f1.A = 3.1415;
  defparam f1.B = 3.1415;
  defparam f1.S = 4'hF;
  defparam f1.SR = 9'h1FF;
  foo f1(a,b);
endmodule
