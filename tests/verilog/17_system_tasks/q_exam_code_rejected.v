// IEEE 1364-2005 §17.6.5: $q_exam "returns a value in q_stat_value depending
// on the information requested in q_stat_code", and Table 17-15 defines the
// codes 1 to 6. A constant code 7 requests nothing the table defines; VerA's
// reading (specification/Vague_Decisions.md VD-050) refuses it at compile time.
// Legal neighbours: q_exam.v (codes 1 and 5) and
// q_exam_code_runtime.v (a code 7 known only at run time: status 2).
//! inherited IEEE 1364-2005 17.6.5
//! reject E1100
//! reject a $q_exam q_stat_code is one of Table 17-15's codes 1 to 6
//! neighbour q_exam.v
//! neighbour q_exam_code_runtime.v
`timescale 1 ns / 1 ns
module b_17_6_5_q_exam_code_rejected;
  integer status, v;
  initial begin
    $q_initialize(1, 1, 5, status);
    $q_exam(1, 7, v, status);
  end
endmodule
