// A.6.3 Parallel and sequential blocks:
//
//     par_block ::= fork [ : block_identifier { block_item_declaration } ]
//                       { statement } join
//     seq_block ::= begin [ : block_identifier { block_item_declaration } ]
//                       { statement } end
//
// and A.6.4 `statement ::= ... | par_block | ... | seq_block`. The two blocks
// differ in one thing and this fixture measures exactly that thing: every
// statement of a `fork` starts at the time the fork is ENTERED, not after its
// predecessor finishes, and the `join` is passed only when all of them are done.
// VerA implements `begin`/`end`; `fork` is unparsed, and the first plausible
// wrong implementation is "fork is begin with a different keyword".
//
// HAND DERIVATION — two statements whose delays are deliberately out of order,
// so sequential and concurrent execution disagree at BOTH observation points.
//   t=0   a<-0000, b<-0000, c<-0000, then the fork is entered.
//         Arm A is `#3 a = 0001` -> due at t=3.
//         Arm B is `#1 b = 0010` -> due at t=1. Concurrent: from the fork's own
//         entry time, so t=0+1. Sequential would make it t=3+1 = 4.
//   t=1   b<-0010
//   t=2   the observer prints a and b: a is still 0000, b is already 0010
//         -> "at2 0000 0010"
//   t=3   a<-0001; both arms are now finished, so `join` completes and the
//         statement after it runs at t=3: c<-0100
//         -> "fork 0001 0010 0100"
//
// Sequential semantics print "at2 0000 xxxx" at t=2 (b not written until t=4)
// and the second line at t=4.
// A `join` that does not wait for the longest arm runs `c = 4'b0100` at t=1 and
// prints "fork 0000 0010 0100" at t=1, ahead of the observer's line.
//
// The line ORDER is part of the assertion: "at2" at t=2 must precede "fork" at
// t=3.
//
//! lrm A.6.3
//! lrm A.6.4
//! lrm 1.2
//! lrm A.6.3:1000
//! timescale 1ns/1ps
//! inherited IEEE 1364-2005 9.8.2 9.8.4
`timescale 1ns/1ps
module d04_fork_join_is_concurrent;
  reg [3:0] a, b, c;

  initial begin
    a = 4'b0000;
    b = 4'b0000;
    c = 4'b0000;
    fork
      #3 a = 4'b0001;
      #1 b = 4'b0010;
    join
    c = 4'b0100;
    $display("fork %b %b %b", a, b, c);
    $finish(0);
  end

  initial begin
    #2 $display("at2 %b %b", a, b);
  end
endmodule
