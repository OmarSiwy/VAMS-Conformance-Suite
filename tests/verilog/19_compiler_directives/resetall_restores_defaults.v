// IEEE 1364-2005 §19.6, p. 356: "When `resetall compiler directive is
// encountered during compilation, all compiler directives are set to the
// default values." ... "The recommended usage is to place `resetall at the
// beginning of each source text file, followed immediately by the directives
// desired in the file." §19.9, p. 360: "The `resetall directive includes the
// effects of a `nounconnected_drive directive." §19.3, p. 350: "The text
// macro facility is not affected by the compiler directive `resetall."
//
// b_19_6_pulled is compiled under `unconnected_drive pull1: its unconnected
//   input i is pulled up -> "pulled i=1" at time 1.
// `resetall ends that region with no `nounconnected_drive, so b_19_6_reset's
//   unconnected input has the normal default: its net has no driver, and
//   §4.2.1 (p. 21): "If no driver is connected to a net, its value shall be
//   high-impedance (z)" -> "reset i=z" at time 2.
// `resetall also resets `timescale, and §19.8 makes it an error for some
//   modules to have a `timescale and others not, so the `timescale is given
//   again right after the `resetall, as the recommended usage says.
// `KEEP, defined before the `resetall, is still 7 after it -> "KEEP=7" at 3.
//! inherited IEEE 1364-2005 19.3 19.6 19.9
`timescale 1ns/1ns
`define KEEP 7
`unconnected_drive pull1
module b_19_6_pulled(input i);
  initial #1 $display("pulled i=%b", i);
endmodule
`resetall
`timescale 1ns/1ns
module b_19_6_reset(input i);
  initial #2 $display("reset i=%b", i);
endmodule
module b_19_6_resetall_restores_defaults;
  b_19_6_pulled p();
  b_19_6_reset r();
  initial #3 $display("KEEP=%0d", `KEEP);
endmodule
