// Verilog-AMS LRM 2.4 §6.5.7.1 *Matching size rule*, in full:
//
//   "A scalar port can be connected to a scalar net and a vector port can be
//    connected to a vector net or concatenated net expression of the matching
//    width. The sizes of the ports and net must match."
//
// plus annex A.4.1 `module_instantiation` for the syntax. This fixture pins the
// HALF of that sentence with observable content: a vector port connected to a
// CONCATENATED NET EXPRESSION of the matching width, on both directions of the
// connection. A port connection is a connection between nets, not an
// assignment, so the concatenation is a bit-for-bit join, leftmost operand
// highest-order, in both directions.
//
// WITHDRAWN CLAIM — this file replaces `10_port_width_conversion.v`, which
// asserted that a port may be connected to an expression of a DIFFERENT width
// (low-order bit to low-order bit, surplus outer bits idle, surplus port bits
// z). The sentence quoted above forbids exactly that: under the shipped
// Verilog-AMS 2.4 document a size mismatch is not a legal connection at all, so
// no conforming implementation owes anyone a value for it. The permissive rule
// is IEEE Std 1364-2005's by composition, not a sentence of §12.3.6 (which is
// connection by name): §12.3.9.2 makes each port connection "a continuous
// assignment of source to sink", and §5.6 truncates or extends an assignment
// and says "Implementations are not required to warn or report any errors
// related to assignment size mismatch". §6.5.7.1 narrows that. No row owns the
// claim now. It can come back only if someone resolves the conflict with
// §6.5.7.1 in favour of the base standard — a fixture cannot assume that
// resolution. See tests/fixtures/ieee1364/07_gate_switch_level/d03_SPEC.md at 8b1514d4.
//
// NOT asserted here: that a mismatched connection is DIAGNOSED. §6.5.7.1 states
// a constraint on legal source and names no diagnostic, and the inherited
// 1364-2005 §12.3.9.2 with §5.6 permits the mismatch and requires no warning.
// Demanding a refusal would pin a rule neither document states.
//
//! lrm 6.5.7.1
//! lrm 6.5.7.1:1
//! lrm annex A.4.1
//! timescale 1ns/1ns
//! inherited IEEE 1364-2005 12.3.5 12.3.9.2
//
// HAND DERIVATION — `nibble` is `output [3:0] o; input [3:0] i; assign o = i;`
//
//   u1(q, {h, l})   4-bit input port fed by a 2+2 concatenated net expression:
//     h = 2'b10, l = 2'b01
//     {h, l}  = 4'b1001      (h is the leftmost operand, so bits [3:2])
//     i       = 1001
//     o = i   = 1001 -> q    -> "in_concat 1001"
//
//   u2({oh, ol}, s) 4-bit output port driving a 2+2 concatenated net
//     expression:
//     s  = 4'b1100, so o = 1100
//     oh = o[3:2] = 11, ol = o[1:0] = 00   -> "out_concat 11 00"
//
// Both lines discriminate: an implementation that assembles a port-side
// concatenation in operand order rather than in bit order prints
// "in_concat 0110" and "out_concat 00 11", and one that connects only the first
// operand prints x's or z's in the other half. The two directions are separate
// code paths (receiver vs driver), hence one line each.
//
// BLOCKED: `vera --run` accepts exactly one ordinary module today
// (src/sim/digital.zig, E1100 "digital execution requires exactly one ordinary
// module"), so this fixture needs D07's instance elaboration before it can
// reach the rule it tests.

`timescale 1ns/1ns
module d03_port_concat_matching_width;
  reg  [1:0] ha, la;
  reg  [3:0] src;
  wire [1:0] h, l;
  wire [3:0] s;
  wire [3:0] q;
  wire [1:0] oh, ol;

  assign h = ha;
  assign l = la;
  assign s = src;

  nibble u1(q, {h, l});
  nibble u2({oh, ol}, s);

  initial begin
    ha = 2'b10;
    la = 2'b01;
    src = 4'b1100;
    #1 $display("in_concat %b", q);
    $display("out_concat %b %b", oh, ol);
    $finish(0);
  end
endmodule

module nibble(o, i);
  output [3:0] o;
  input [3:0] i;
  assign o = i;
endmodule
