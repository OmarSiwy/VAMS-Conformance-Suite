// IEEE 1364-2005 §4.2.2, p. 23: "A variable shall store a value from one
// assignment to the next." ... "The initialization value for reg, time, and
// integer data types shall be the unknown value, x. The default
// initialization value for real and realtime variable data types shall be
// 0.0. If a variable declaration assignment is used (see 6.2.1), the variable
// shall take this value as if the assignment occurred in a blocking
// assignment in an initial construct."
//
// Read at time 0, before any procedural assignment:
//   reg [3:0] r -> xxxx;  integer i, bits [3:0] -> xxxx;  time tm, [3:0] -> xxxx
//   real re -> 0.000000;  realtime rt -> 0.000000
// reg [3:0] d = 4'h4 (declaration assignment), read at time 1: the implied
//   initial assignment and this initial block run in an unspecified order at
//   time 0 (§6.2.1), so d is not read then -> 4
// Stores from one assignment to the next: r = 4'd9 at time 0, read at
// time 2 with no assignment between -> 1001.
//! inherited IEEE 1364-2005 4.2.2
module b_4_2_2_variable_initial_values;
  reg [3:0] r;
  integer i;
  time tm;
  real re;
  realtime rt;
  reg [3:0] d = 4'h4;
  initial begin
    $display("%b %b %b %f %f", r, i[3:0], tm[3:0], re, rt);
    r = 4'd9;
    #1 $display("%h", d);
    #1 $display("%b", r);
    $finish(0);
  end
endmodule
