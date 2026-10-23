// IEEE 1364-2005 §8.6, p. 113: "Instances of UDPs are specified inside
// modules in the same manner as gates (see 7.1). The instance name is
// optional, just as for gates. The port connection order is as specified in
// the UDP definition."
//
// gt is a two-input "a and not b" table, so swapping the inputs changes the
// output. u1 is named and connects (y1, x, z); the second instance has no
// name and connects (y2, z, x), the inputs swapped.
//   x = 1, z = 0: y1 = 1 & ~0 = 1; y2 = 0 & ~1 = 0     -> "1 0"
//   x = 0, z = 1: y1 = 0;         y2 = 1 & ~0 = 1      -> "0 1"
//   x = 1, z = 1: y1 = 0;         y2 = 0               -> "0 0"
//! inherited IEEE 1364-2005 8.6
`timescale 1ns/1ns
primitive gt(y, a, b);
  output y;
  input a, b;
  table
    1 0 : 1;
    0 ? : 0;
    ? 1 : 0;
  endtable
endprimitive

module b_8_6_instances;
  reg x, z;
  wire y1, y2;
  gt u1(y1, x, z);
  gt (y2, z, x);
  initial begin
    x = 1;
    z = 0;
    #1 $display("%b %b", y1, y2);
    x = 0;
    z = 1;
    #1 $display("%b %b", y1, y2);
    x = 1;
    #1 $display("%b %b", y1, y2);
    $finish(0);
  end
endmodule
