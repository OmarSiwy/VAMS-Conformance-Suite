// Verilog-AMS LRM 2.4 §6.5.3 Real valued ports, verbatim:
//
//   "Ports may be declared as real-valued with a discrete-time discipline using
//    the net type wreal (defined in 3.7). There can be a maximum of one driver
//    of a real-valued net."
//
// and §6.5.2's port direction productions, which admit the net type INLINE:
//
//   input_declaration ::=
//     input [ discipline_identifier ] [ net_type | wreal ] [ signed ] [ range ]
//     list_of_port_identifiers
//   output_declaration ::= output [ discipline_identifier ] [ net_type | wreal ]
//     ...
//
// so there are TWO legal spellings of a real-valued port and a conforming tool
// owes both:
//
//   (a) `input wreal a;`                   — the net type on the direction line
//   (b) `input b;` plus `wreal b;`         — direction and net type separately
//
// which is the spelling §6.5.3's own example uses ("input in, clk; wreal in;").
// This file uses (a) for `a` and (b) for `b` in the SAME child module so that
// one of them cannot quietly be the only one implemented.
//
// WHAT IS PINNED BEYOND ACCEPTANCE. A real crossing a module boundary must
// cross it bit-exactly. 0.1 is chosen because it is NOT representable in binary
// — its double is 0.1000000000000000055511151231257827 — so any tool that
// round-trips the value through a decimal string, a 32-bit float or a fixed
// point grid produces a different double, and `%g` at six significant digits is
// too coarse to see that. So the exactness is asserted through $realtobits,
// which §3.7 names for exactly this purpose, and printed as 64 binary digits:
// the check is on all 64 bits of the value that came back out of the child.
//
//! lrm 6.5.3
//! lrm 6.5.3:1
//! lrm 6.5.2
//! lrm 3.7
//! lrm 3.7:2
//! lrm 6.5.2:1000
//! lrm 6.5.5
//! lrm 6.5.5:1
//! timescale 1ns/1ns
//
// HAND DERIVATION
//   top drives `feed = 0.1` and `gain_in = 0.1` through the two wreal inputs.
//   The child drives its wreal output `s` with `a + b`.
//     a = b = 0.1 (double 0x3FB999999999999A)
//     a + b: the exact sum 0.2000000000000000111022302462515654 is itself the
//            double nearest 0.2, so a + b == 0.2 exactly, bit pattern
//            0x4004... no — 0.2 is 0x3FC999999999999A.
//   %g of 0.1 is "0.1"; %g of 0.2 is "0.2".
//   $realtobits(0.1) = 64'h3FB999999999999A
//     = 0011111110111001100110011001100110011001100110011001100110011010
//   $realtobits(0.2) = 64'h3FC999999999999A
//     = 0011111111001001100110011001100110011001100110011001100110011010
//   The two patterns differ only in the exponent field (0x3FB vs 0x3FC), which
//   is the whole point: the mantissa survived the port crossing untouched.
//
//   The unconnected third port `unused` is declared wreal and left with no
//   driver in the child: §3.7's "If no driver is connected to a wreal net, its
//   value shall be zero (0.0)" applies to a PORT net too, so the parent reads 0.

`timescale 1ns/1ns

module m04_wreal_scaler(a, b, s, unused);
  // (a) net type on the direction line
  input wreal a;
  // (b) direction and net type declared separately, as in §6.5.3's example
  input b;
  wreal b;
  output s;
  wreal s;
  // driven by nothing inside this module -> §3.7 zero, seen by the parent
  output unused;
  wreal unused;

  assign s = a + b;
endmodule

module m04_wreal_port_round_trip;
  real feed;
  real gain_in;
  wreal fa, fb, sum, dangling;

  assign fa = feed;
  assign fb = gain_in;

  m04_wreal_scaler u(.a(fa), .b(fb), .s(sum), .unused(dangling));

  initial begin
    feed = 0.1; gain_in = 0.1;
    #1;
    $display("value_crossed_two_port_boundaries %g", sum);
    $display("input_bits_survived %b", $realtobits(fa));
    $display("output_bits_are_the_exact_double_sum %b", $realtobits(sum));
    $display("undriven_wreal_output_port_reads_zero %g", dangling);
    $finish(0);
  end
endmodule
