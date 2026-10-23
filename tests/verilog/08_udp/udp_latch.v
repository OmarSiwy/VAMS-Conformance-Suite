// D08 — level-sensitive sequential UDP: `output reg`, the `initial` statement,
// the `-` (no change) next state, and the unmatched-row rule on a UDP that has
// state to lose.
//
// Verilog-AMS 2.4 Annex A.5.2:
//     udp_output_declaration ::= { attribute_instance } output port_identifier
//         | { attribute_instance } output [ discipline_identifier ] reg
//               port_identifier [ = constant_expression ]
// Annex A.5.3:
//     sequential_body ::= [ udp_initial_statement ] table sequential_entry
//         { sequential_entry } endtable
//     udp_initial_statement ::= initial output_port_identifier = init_val ;
//     init_val ::= 1'b0 | 1'b1 | 1'bx | 1'bX | 1'B0 | 1'B1 | 1'Bx | 1'BX | 1 | 0
//     sequential_entry ::= seq_input_list : current_state : next_state ;
//     seq_input_list ::= level_input_list | edge_input_list
//     current_state ::= level_symbol
//     next_state ::= output_symbol | -
// §1.1 makes IEEE Std 1364-2005 clause 8 the normative execution rules.
//
// THE UDP UNDER TEST is a transparent-low D latch. Three rows and no edge
// descriptors, so this is the LEVEL-sensitive half of sequential UDP execution;
// udp_dff.v is the edge half.
//
// FOUR RULES, AND THE STEP THAT PINS EACH.
//
// 1. `initial q = 1'b0;` seeds the state. Step s1 samples q at t=1 before ANY
//    input has changed — both driving regs are still at their own initial x and
//    were never written, so no input event has occurred and the table has never
//    been consulted. q must read the seeded 0, not the x a bare reg starts at.
//    A compiler that ignores the udp_initial_statement prints x here.
//
// 2. `-` retains the current state. Steps s2, s5 and s6 all land on the
//    `1 ? : ? : -` row while q holds a value that the row does not name; q must
//    come out unchanged rather than take some default.
//
// 3. A sequential UDP evaluates on an input EVENT, and the state it reads is
//    the one it last produced. Steps s3/s4 and s6/s7 walk d through the
//    transparent window and back, so the value asserted at each step depends on
//    the whole history, not on the current inputs alone.
//
// 4. No matching entry sets the output to x — including when a perfectly good
//    state is already stored. Step s8 drives clk to x, which matches neither of
//    the `0` rows nor the `1` row; q must be destroyed to x. Step s9 then
//    re-establishes 1 through the ordinary `0 1` row, so the fixture also shows
//    the UDP recovering rather than latching x forever.
//
// HAND-DERIVED EXPECTED VALUES. Each step lists the entry it selects and the
// resulting state; the state column carries forward from the row above.
//
//   step  clk d | entry matched   | q after
//   s1    x   x | (no input event, initial value stands) | 0
//   s2    1   1 | 1 ? : ? : -     | 0
//   s3    0   1 | 0 1 : ? : 1     | 1
//   s4    0   0 | 0 0 : ? : 0     | 0
//   s5    1   0 | 1 ? : ? : -     | 0
//   s6    1   1 | 1 ? : ? : -     | 0
//   s7    0   1 | 0 1 : ? : 1     | 1
//   s8    x   1 | none            | x
//   s9    0   1 | 0 1 : ? : 1     | 1
//
// s2 and s6 have identical inputs and both hold, but s2 holds a 0 that came
// from the initial statement and s6 holds a 0 that came from the table, so an
// implementation that only seeds the state lazily still fails s1.
//
//! lrm A.5.1
//! lrm A.5.2
//! lrm A.5.3
//! lrm 1.1
//! lrm A.5.1:1000
//! lrm A.5.3:1000
//! inherited IEEE 1364-2005 8.1.4 8.3 8.5
`timescale 1ns/1ns

primitive udp_latch (q, clk, d);
  output reg q;
  input     clk, d;
  initial q = 1'b0;
  table
  // clk  d  : state :  q
       0   1  :  ?    :  1  ;
       0   0  :  ?    :  0  ;
       1   ?  :  ?    :  -  ;
  endtable
endprimitive

module d08_udp_latch;
  reg  clk, d;
  wire q;

  udp_latch u1 (q, clk, d);

  initial begin
    #1
      $display("s1 no input event yet got q=%b want 0", q);
    clk = 1'b1; d = 1'b1; #1
      $display("s2 clk=1 d=1 hold got q=%b want 0", q);
    clk = 1'b0; #1
      $display("s3 clk=0 d=1 transparent got q=%b want 1", q);
    d = 1'b0; #1
      $display("s4 clk=0 d=0 transparent got q=%b want 0", q);
    clk = 1'b1; #1
      $display("s5 clk=1 d=0 hold got q=%b want 0", q);
    d = 1'b1; #1
      $display("s6 clk=1 d=1 hold got q=%b want 0", q);
    clk = 1'b0; #1
      $display("s7 clk=0 d=1 transparent got q=%b want 1", q);
    clk = 1'bx; #1
      $display("s8 clk=x d=1 unmatched got q=%b want x", q);
    clk = 1'b0; #1
      $display("s9 clk=0 d=1 recover got q=%b want 1", q);
  end
endmodule
