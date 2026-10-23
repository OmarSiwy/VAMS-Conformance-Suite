// A.6.5 `disable_statement ::= disable hierarchical_task_identifier ;
//                             | disable hierarchical_block_identifier ;`
// with A.6.3 `seq_block ::= begin [ : block_identifier ... ] { statement } end`
// supplying the name being disabled.
//
// `disable <block>` terminates that block: control leaves it, the statements it
// has not reached are never executed, and — the part that costs an
// implementation real work — any event or delay the block is currently SUSPENDED
// on is cancelled, so the scheduled resumption never happens. VerA's executor
// rejects named blocks outright today ("block declarations/named scopes are not
// implemented"), so this fixture needs both halves.
//
// The analog side of `disable` is already pinned by tests/fixtures
// (annex_a_syntax/disable_statement.va at E0401, because A.6.4's
// `analog_statement` has no disable alternative). This is the DIGITAL side,
// where A.6.4's `statement` does list it and it is supposed to work.
//
// HAND DERIVATION.
//   t=0   work:   r<-0001, then suspends on `#4` — due to resume at t=4
//         killer: s<-0000, then delays to t=2
//   t=2   killer: `disable work;` — work's pending t=4 resumption is cancelled
//   t=4   nothing happens: had `work` survived it would have written r<-0010
//         here and then s<-1111
//   t=6   killer prints r and s: r is the 0001 written at t=0, s is the 0000
//         written at t=0
//         -> "disabled 0001 0000"
//
// A `disable` that is parsed and ignored gives "disabled 0010 1111".
// One that ends the block but leaves the queued event live gives the same.
// One that cancels the delay but still runs the trailing statement gives
// "disabled 0001 1111".
//
// The observation is at t=6, two nanoseconds past the resumption that must not
// happen, so the fixture cannot pass by merely being early.
//
//! lrm A.6.3
//! lrm A.6.4
//! lrm A.6.5
//! lrm A.6.3:1000
//! lrm A.6.5:1000
//! timescale 1ns/1ps
//! inherited IEEE 1364-2005 10.3
`timescale 1ns/1ps
module d04_disable_named_block;
  reg [3:0] r, s;

  initial begin : work
    r = 4'b0001;
    #4 r = 4'b0010;
    s = 4'b1111;
  end

  initial begin
    s = 4'b0000;
    #2 disable work;
    #4 $display("disabled %b %b", r, s);
    $finish(0);
  end
endmodule
