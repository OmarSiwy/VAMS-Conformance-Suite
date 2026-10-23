// D08 — edge-sensitive sequential UDP: edge descriptors, one-input-changes-at-
// a-time evaluation, and the difference between an edge row and a level row.
//
// Verilog-AMS 2.4 Annex A.5.3:
//     sequential_entry ::= seq_input_list : current_state : next_state ;
//     seq_input_list ::= level_input_list | edge_input_list
//     edge_input_list ::= { level_symbol } edge_indicator { level_symbol }
//     edge_indicator ::= ( level_symbol level_symbol ) | edge_symbol
//     level_symbol ::= 0 | 1 | x | X | ? | b | B
//     edge_symbol ::= r | R | f | F | p | P | n | N | *
//     next_state ::= output_symbol | -
// Annex A.5.2 supplies `output reg q` and A.5.3's udp_initial_statement seeds
// it. §1.1 makes IEEE Std 1364-2005 clause 8 normative.
//
// THE UDP UNDER TEST is a rising-edge D flip-flop. Note the grammar: an
// edge_input_list contains EXACTLY ONE edge_indicator surrounded by level
// symbols, which is the syntax encoding the execution rule — a sequential UDP
// is evaluated once per input event, and in each evaluation exactly one input
// has an edge while all the others are read as levels. Every stimulus step
// below changes exactly one reg, so no step depends on how simultaneous input
// changes would be ordered.
//
// FIVE RULES, AND THE STEP THAT PINS EACH.
//
// 1. `initial q = 1'b0;` seeds the state; step s1 samples it before any input
//    event has happened at all (both regs are still at their untouched x).
//
// 2. An `(01)` row fires on that transition ONLY. Steps s4 and s7 are the two
//    rising clock edges that carry data through, and they carry through
//    DIFFERENT values (1 then 0), so a flip-flop stuck at "load whatever d is
//    now" cannot pass both while also passing s5.
//
// 3. A change on a non-edge input holds the state. Steps s3, s5 and s8 change
//    only d, and the `? (??) : ? : -` row keeps q. s5 is the discriminating
//    one: d falls to 0 while q is 1 and the clock is idle at 1, so a compiler
//    that re-evaluates the (01) rows on any event would corrupt q to 0.
//
// 4. A falling clock holds. Step s6 takes clk 1->0 and q must stay 1; an
//    implementation that treats `(01)` as "any clk change" fails here, because
//    d is 0 by then and q would drop to 0 one step early.
//
// 5. Edges out of x are ordinary edges. Step s2 takes clk from its initial x to
//    0, matched by `(x0)`, and must hold rather than fall through to no match
//    and set q to x — the `(0x)`, `(1x)`, `(x0)` and `(x1)` rows exist for
//    exactly that reason and this fixture exercises `(x0)`.
//
// HAND-DERIVED EXPECTED VALUES. Each step names the single input that changed,
// the entry that matches, and the resulting state carried forward:
//
//   step  change      clk d | entry matched     | q after
//   s1    (none)      x   x | initial statement | 0
//   s2    clk x->0    0   x | (x0) ? : ? : -    | 0
//   s3    d   x->1    0   1 | ? (??) : ? : -    | 0
//   s4    clk 0->1    1   1 | (01) 1 : ? : 1    | 1
//   s5    d   1->0    1   0 | ? (??) : ? : -    | 1
//   s6    clk 1->0    0   0 | (10) ? : ? : -    | 1
//   s7    clk 0->1    1   0 | (01) 0 : ? : 0    | 0
//   s8    d   0->1    1   1 | ? (??) : ? : -    | 0
//   s9    clk 1->0    0   1 | (10) ? : ? : -    | 0
//   s10   clk 0->1    1   1 | (01) 1 : ? : 1    | 1
//
// The transcript is therefore 0 0 0 1 1 1 0 0 0 1 — a value that changes only
// at s4, s7 and s10, the three rising clock edges, and never at a d event.
//
//! lrm A.5.1
//! lrm A.5.2
//! lrm A.5.3
//! lrm 1.1
//! lrm A.5.1:1000
//! lrm A.5.2:1000
//! lrm A.5.3:1000
//! inherited IEEE 1364-2005 8.4 8.5
`timescale 1ns/1ns

primitive udp_dff (q, clk, d);
  output reg q;
  input     clk, d;
  initial q = 1'b0;
  table
  // clk     d   : state :  q
      (01)   0   :  ?    :  0  ;
      (01)   1   :  ?    :  1  ;
      (0x)   ?   :  ?    :  -  ;
      (1x)   ?   :  ?    :  -  ;
      (10)   ?   :  ?    :  -  ;
      (x0)   ?   :  ?    :  -  ;
      (x1)   ?   :  ?    :  -  ;
       ?   (??)  :  ?    :  -  ;
  endtable
endprimitive

module d08_udp_dff;
  reg  clk, d;
  wire q;

  udp_dff u1 (q, clk, d);

  initial begin
    #1
      $display("s1 no input event yet got q=%b want 0", q);
    clk = 1'b0; #1
      $display("s2 clk x->0 got q=%b want 0", q);
    d = 1'b1; #1
      $display("s3 d x->1 clk idle got q=%b want 0", q);
    clk = 1'b1; #1
      $display("s4 clk 0->1 with d=1 got q=%b want 1", q);
    d = 1'b0; #1
      $display("s5 d 1->0 clk idle got q=%b want 1", q);
    clk = 1'b0; #1
      $display("s6 clk 1->0 got q=%b want 1", q);
    clk = 1'b1; #1
      $display("s7 clk 0->1 with d=0 got q=%b want 0", q);
    d = 1'b1; #1
      $display("s8 d 0->1 clk idle got q=%b want 0", q);
    clk = 1'b0; #1
      $display("s9 clk 1->0 got q=%b want 0", q);
    clk = 1'b1; #1
      $display("s10 clk 0->1 with d=1 got q=%b want 1", q);
  end
endmodule
