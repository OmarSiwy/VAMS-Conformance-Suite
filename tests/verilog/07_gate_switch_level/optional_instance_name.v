// IEEE 1364-2005 §7.1.4, p. 77: "An optional name can be given to a gate or
// switch instance. If multiple instances are declared as an array of
// instances, an identifier shall be used to name the instances."
//
// u0 is an unnamed and; n0 a named and; arr[1:0] a named array of two xor
// gates; a list mixes an unnamed and a named or instance.
//   a=1 b=1: u0 = n0 = 1; arr: {a,b} ^ {b,a} = 11 ^ 11 = 00; or: 1, 1.
//   a=1 b=0: u0 = n0 = 0; arr: 10 ^ 01 = 11; or: 1, 1.
// Lines: "11 00 11", "00 11 11".
//! inherited IEEE 1364-2005 7.1.4
`timescale 1ns/1ns
module b_7_1_4_optional_instance_name;
  reg a, b;
  wire u, n, o1, o2;
  wire [1:0] x;
  and (u, a, b);
  and n0 (n, a, b);
  xor arr[1:0] (x, {a, b}, {b, a});
  or (o1, a, b), named_or (o2, a, b);
  initial begin
    a = 1; b = 1;
    #1 $display("%b%b %b %b%b", u, n, x, o1, o2);
    b = 0;
    #1 $display("%b%b %b %b%b", u, n, x, o1, o2);
    $finish(0);
  end
endmodule
