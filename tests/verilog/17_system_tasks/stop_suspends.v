// IEEE 1364-2005 §17.4.2, p. 301: "The $stop system task causes simulation to
// be suspended." What a suspended run does next and the text of each
// diagnostic level are the tool's (CLAUSES.tsv: implementation-defined).
// VerA's choice for a batch run is print-and-exit-0 (specification/Vague_Decisions.md
// VD-070), its diagnostic going to stderr, so stdout holds what ran before
// the $stop and nothing after it. That is VerA's choice, not the clause's,
// so the tag below names the construct the fixture exercises without claiming
// the transcript as the clause's outcome. The runner prints `$stop at tick 1,
// <file> byte <n>` on stderr and exits 0.
//! inherited IEEE 1364-2005 17.4.2
`timescale 1ns/1ns
module b_17_4_2_stop_suspends;
  initial begin
    $display("before");
    #1 $stop;
    $display("after");
  end
endmodule
