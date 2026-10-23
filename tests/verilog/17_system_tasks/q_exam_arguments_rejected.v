// IEEE 1364-2005 §17.6, p. 307: "The set of tasks and functions that create
// and manage queues follows: ... $q_exam (q_id, q_stat_code, q_stat_value,
// status) ;" §17.6.5, p. 308: "The status code reports on the success of the
// operation or error conditions as described in Table 17-16."
//
// The call passes three arguments, leaving out status. Legal neighbour:
// q_exam.v passes all four.
//! inherited IEEE 1364-2005 17.6.5
//! reject E1100
//! reject the §17.6 queue tasks take four arguments
//! neighbour q_exam.v
`timescale 1 ns / 1 ns
module b_17_6_5_q_exam_arguments_rejected;
  integer status, job, info, v;
  initial begin
    $q_initialize(1, 1, 5, status);
    $q_exam(1, 1, v);
  end
endmodule
