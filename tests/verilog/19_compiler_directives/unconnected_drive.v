// IEEE 1364-2005 §19.9, p. 360: "All unconnected input ports of a module
// appearing between the directives `unconnected_drive and
// `nounconnected_drive are pulled up or pulled down instead of the normal
// default. The directive `unconnected_drive takes one of two arguments—pull1
// or pull0. When pull1 is specified, all unconnected input ports are
// automatically pulled up. When pull0 is specified, unconnected ports are
// pulled down. It is advisable to pair each `unconnected_drive with a
// `nounconnected_drive, but it is not required. The latest occurrence of
// either directive in the source controls what happens to unconnected ports.
// These directives shall be specified in pairs outside of the module
// declarations."
//
// Each child has one unconnected input and prints it after one time unit
// (a read at time 0 would race the pull's own time-0 evaluation, §11.5):
//   b_19_9_up    under pull1 (unpaired: pull0 follows, and the latest
//                occurrence rules)                                  -> 1 at 1
//   b_19_9_down  under pull0                                        -> 0 at 2
//   b_19_9_free  after `nounconnected_drive: the normal default, a net with
//                no driver, z (§4.2.1, p. 21)                       -> z at 3
//   (The clause's last sentence says "in pairs", its fourth that pairing
//   "is not required"; the unpaired pull1 relies on the explicit fourth,
//   which the "latest occurrence" sentence only has a use for.)
//   b_19_9_bound under pull1 again, but its input is connected to a reg
//                holding 0: only unconnected ports are pulled       -> 0 at 4
//! inherited IEEE 1364-2005 19.9
`timescale 1ns/1ns
`unconnected_drive pull1
module b_19_9_up(input i);
  initial #1 $display("up i=%b", i);
endmodule
`unconnected_drive pull0
module b_19_9_down(input i);
  initial #2 $display("down i=%b", i);
endmodule
`nounconnected_drive
module b_19_9_free(input i);
  initial #3 $display("free i=%b", i);
endmodule
`unconnected_drive pull1
module b_19_9_bound(input i);
  initial #4 $display("bound i=%b", i);
endmodule
`nounconnected_drive
module b_19_9_unconnected_drive;
  reg zero;
  b_19_9_up u();
  b_19_9_down d();
  b_19_9_free f();
  b_19_9_bound b(zero);
  initial begin
    zero = 1'b0;
    #5 $finish(0);
  end
endmodule
