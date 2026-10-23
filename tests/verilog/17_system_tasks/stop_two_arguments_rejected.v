// IEEE 1364-2005 §17.4.2, Syntax 17-12, p. 302:
//   stop_task ::= $stop [ ( n ) ] ;
// The task takes at most one argument, n.
//
// $stop(0, 1) passes two. The legal neighbour is $stop(0); no fixture runs
// it, because what a suspended simulation does next is the tool's (17.4.2 is
// implementation-defined in CLAUSES.tsv) and VerA's digital runner refuses
// $stop.
//! inherited IEEE 1364-2005 17.4.2
//! reject E1100
//! reject zero or one argument
`timescale 1 ns / 1 ns
module b_17_4_2_stop_two_arguments_rejected;
  initial $stop(0, 1);
endmodule
