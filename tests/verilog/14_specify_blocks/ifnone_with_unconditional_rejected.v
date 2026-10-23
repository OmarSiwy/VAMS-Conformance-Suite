// IEEE 1364-2005 §14.2.4.4, p. 218: "It is illegal to specify both an
// ifnone condition for a module path and an unconditional simple module path
// for the same module path." Its Example 2: "The following module path
// description combination is illegal because it combines a state-dependent
// path using an ifnone condition and an unconditional path for the same
// module path:
//   if (a) (b => out) = (2,2);
//   if (b) (a => out) = (2,2);
//   ifnone (a => out) = (1,1);
//   (a => out) = (1,1);"
//
// The cell is that example. Legal neighbour: ifnone.v, the
// clause's Example 1.
//! inherited IEEE 1364-2005 14.2.4.4
//! reject ifnone
//! neighbour ifnone.v
`timescale 1ns/1ns
module b_14_2_4_4_ifnone_with_unconditional_rejected(a, b, out);
  input a, b;
  output out;
  xor x1 (out, a, b);
  specify
    if (a) (b => out) = (2,2);
    if (b) (a => out) = (2,2);
    ifnone (a => out) = (1,1);
    (a => out) = (1,1);
  endspecify
endmodule
