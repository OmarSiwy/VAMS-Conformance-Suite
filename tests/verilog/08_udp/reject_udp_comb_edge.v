// D08 — REJECT: an edge descriptor in a COMBINATIONAL UDP table.
//
// Verilog-AMS 2.4 Annex A.5.3 splits the two bodies at the top and never lets
// them mix:
//
//     udp_body ::= combinational_body | sequential_body
//     combinational_body ::= table combinational_entry { combinational_entry }
//         endtable
//     combinational_entry ::= level_input_list : output_symbol ;
//     level_input_list ::= level_symbol { level_symbol }
//     level_symbol ::= 0 | 1 | x | X | ? | b | B
//
// A combinational entry's inputs are a `level_input_list`, and `level_symbol`
// contains no edge alternative; `edge_indicator` and `edge_symbol` appear only
// under `edge_input_list`, which only a `sequential_entry` can reach. `(01)`
// below therefore derives from no production of `combinational_body`.
//
// The grammar is stating a semantic impossibility, which is why this is worth a
// fixture rather than a parser footnote: an edge is a statement about the
// PREVIOUS value of an input, and a combinational UDP has no previous value to
// compare against. This primitive also has no `output reg` and no
// `current_state` column, so there is nowhere for that history to live even if
// the entry were read. A compiler that accepts the edge here has either
// silently promoted the primitive to sequential — inventing state the source
// never declared — or is matching `(01)` as if it were a level, which would
// make the first entry fire on a steady a=0 and change the function.
//
// The old `? ? : 0` fallback also covered all-x with a known output and could
// conflict with another row. IEEE8.1.4 forbids those independent defects.
// The replacement `1 1 : 0` is disjoint from the first row's b=0. A matching
// legal definition changes only `(01)` to level1; see
// udp_comb_level.v. The edge descriptor is
// now the isolated table-shape defect (UDP-SHAPE-001 in the audit report).
//
// WHAT THE DIRECTIVES DEMAND, AND WHY THEY ARE NOT `DiagnosticsReported`.
// This file carried `//! reject DiagnosticsReported` until review. That label
// matches ANY diagnostic (`tests/suite.zig:223`), so once `primitive` parses,
// a UDP parser that tripped over the port list or over `?` would satisfy it
// without ever having looked at `(01)`. Worse for this fixture specifically: an
// implementation that landed SEQUENTIAL UDPs first and refused combinational
// bodies wholesale would have passed too — the exact opposite of the rule being
// tested, since the rule presupposes that a combinational body is legal.
//
// The two lines below are a CONJUNCTION — `verifyRejected`
// (analog.zig:142-150) fails the fixture unless every `//! reject` line
// matches — and a non-code pattern is matched against each diagnostic's
// message, caret label, notes and catalogue title (analog.zig:235-243). The
// refusal must therefore name BOTH halves of A.5.3's split: that the body is
// `combinational`, and that the offending construct is an `edge`. "Combinational
// UDPs are not supported" satisfies the first and not the second; a generic
// parse error satisfies neither.
//
// Current parser code E0234 identifies table shape violations. The two
// distinctive phrases below remain required, preserving the existing strict
// diagnostic oracle rather than accepting any unrelated unsupported feature.
//
//! lrm A.5.3
//! lrm A.5.3:1000
//! reject-only combinational
//! reject edge
//! neighbour udp_comb_level.v
//! inherited IEEE 1364-2005 A.5.3
`timescale 1ns/1ns

primitive udp_bad_edge (o, a, b);
  output o;
  input  a, b;
  table
  //  a     b  :  o
     (01)   0  :  1  ;
      1     1  :  0  ;
  endtable
endprimitive

module d08_reject_udp_comb_edge;
  reg  a, b;
  wire o;

  udp_bad_edge u1 (o, a, b);

  initial begin
    a = 1'b0; b = 1'b0; #1
    a = 1'b1; #1
      $display("unreachable got o=%b", o);
  end
endmodule
