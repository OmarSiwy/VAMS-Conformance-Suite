// D08 — REJECT: `z` is not a UDP output symbol.
//
// Verilog-AMS 2.4 Annex A.5.3 enumerates the output alphabet exhaustively:
//
//     combinational_entry ::= level_input_list : output_symbol ;
//     output_symbol ::= 0 | 1 | x | X
//
// `z` derives from no alternative of `output_symbol`, and it is absent by
// design rather than by omission: `level_symbol ::= 0 | 1 | x | X | ? | b | B`
// has no z either, so the whole UDP value set is three-valued on both sides of
// the colon. A UDP models a logic function, not a connection; high impedance is
// what the switch primitives in switch_mos.v and bidirectional.v exist
// to produce.
//
// This is the reject that keeps udp_comb.v honest. That fixture asserts
// that an unmatched combinational entry yields x and specifically not z; the
// rule only means something if a table cannot request z in the first place.
//
// The rest of this primitive is well formed — one output first, two inputs
// after it (A.5.2), a complete two-input table — so the only thing a compiler
// can be refusing here is the `z` in the third entry's output column.
//
// WHAT THE DIRECTIVE DEMANDS, AND WHY IT IS NOT `DiagnosticsReported`.
// This file carried `//! reject DiagnosticsReported` until review. That label
// is satisfied by ANY diagnostic (`tests/suite.zig:223`), so the day
// `primitive` starts parsing, a UDP parser that choked on the port list, on
// `table`, or on an entry width would still mark this file green while saying
// nothing whatever about `z`. It asserted "something went wrong", which is not
// a claim A.5.3 supports.
//
// The line below names the reason instead. `//! reject` lines are a
// CONJUNCTION — `verifyRejected` (analog.zig:142-150) fails the fixture unless
// every one matches — and a non-code pattern is matched against each
// diagnostic's message, its caret label, its notes and its catalogue title
// (analog.zig:235-243). So the refusal has to be worded as one about the
// entry's OUTPUT SYMBOL, which is the only thing A.5.3 makes illegal here:
// every other column, and the whole primitive around it, is well formed.
//
// No `E0xxx` is written, and that is deliberate rather than lazy:
// The refusal is E0233 ("a UDP table symbol is outside the alphabet its column
// admits"), pinned by code with the symbol named, so the fixture holds the
// rule and the offending output symbol rather than a phrase of the message.
//
//! lrm A.5.3
//! lrm A.5.3:1000
//! reject-only E0233
//! reject `z` is not a UDP output symbol
//! neighbour udp_comb.v
//! inherited IEEE 1364-2005 8.1.4 8.1.5
`timescale 1ns/1ns

primitive udp_bad_z (o, a, b);
  output o;
  input  a, b;
  table
  //  a  b  :  o
      0  0  :  0  ;
      0  1  :  1  ;
      1  0  :  z  ;
      1  1  :  1  ;
  endtable
endprimitive

module d08_reject_udp_z_output;
  reg  a, b;
  wire o;

  udp_bad_z u1 (o, a, b);

  initial begin
    a = 1'b1; b = 1'b0; #1
      $display("unreachable got o=%b", o);
  end
endmodule
