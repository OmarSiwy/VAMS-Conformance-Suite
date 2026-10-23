// Verilog-AMS LRM 2.4 annex A.4.1 `module_instantiation`, annex A.2.2.2
// `drive_strength`, and §1.1's "complete IEEE Std 1364 Verilog specification".
//
// IEEE Std 1364 Verilog clause 12 makes a port a CONNECTION and not a value
// copy: an `output` port contributes its module's driver to the net it is
// attached to, and an `input` port is a receiver only — the instantiated module
// puts no driver on it. Two instances attached to one net are therefore two
// independent drivers of that net, and they are resolved by clause 7's strength
// order like any other pair.
//
// That is the D03 requirement "maintain independent drivers and receiver
// connectivity, including strengths" stated across a hierarchy boundary, plus
// "resolution after driver removal" — line 2 removes the strong driver by
// driving its INPUT to z, which is only observable if the port really is a
// connection: a value copy would latch the child's last output.
//
//! lrm annex A.4.1
//! lrm annex A.2.2.2
//! lrm 1.1
//! timescale 1ns/1ns
//! inherited IEEE 1364-2005 6.1.4 7.10.1 12.3.9.2
//
// HAND DERIVATION — levels strong = 6, weak = 3.
//   t=1  s=1: u1 asserts s1=6.  w=0: u2 asserts s0=3.   6 > 3     -> y = 1
//   t=2  s=z: u1's `assign` evaluates z, so u1 contributes nothing;
//             u2 still asserts s0=3                                -> y = 0
//   t=3  s=0: u1 asserts s0=6.  w=z: u2 contributes nothing        -> y = 0
//   t=4  s=z: neither instance contributes; `y` is a plain wire     -> y = z
//
// Line 3 and line 4 differ only in which instance is silent, and line 4 is the
// one that proves an undriven net is z rather than the last resolved value.
//
// BLOCKED: `vera --run` accepts exactly one ordinary module today
// (src/sim/digital.zig, E1100 "digital execution requires exactly one ordinary
// module"). D07 owns the instance elaboration this needs.

`timescale 1ns/1ns
module d03_port_driver_resolution;
  reg s, w;
  wire y;

  strong_drv u1(y, s);
  weak_drv u2(y, w);

  initial begin
    s = 1'b1; w = 1'b0;
    #1 $display("strong_wins %b", y);
    s = 1'bz;
    #1 $display("weak_shows_after_removal %b", y);
    s = 1'b0; w = 1'bz;
    #1 $display("strong_alone %b", y);
    s = 1'bz;
    #1 $display("no_driver_left %b", y);
    $finish(0);
  end
endmodule

module strong_drv(o, v);
  output o;
  input v;
  assign (strong1, strong0) o = v;
endmodule

module weak_drv(o, v);
  output o;
  input v;
  assign (weak1, weak0) o = v;
endmodule
