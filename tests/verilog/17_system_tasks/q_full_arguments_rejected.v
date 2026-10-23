// IEEE 1364-2005 §17.6, p. 307: "The set of tasks and functions that create
// and manage queues follows: ... $q_full (q_id, status)" §17.6.4, p. 308:
// "The status code reports on the success of the operation or error
// conditions as described in Table 17-16."
//
// The call passes only q_id, leaving out status. Legal neighbour:
// q_full.v passes both.
//! inherited IEEE 1364-2005 17.6.4
//! reject E1100
//! reject $q_full takes (q_id, status)
//! neighbour q_full.v
`timescale 1 ns / 1 ns
module b_17_6_4_q_full_arguments_rejected;
  integer status, job, info, v;
  initial begin
    $q_initialize(1, 1, 5, status);
    v = $q_full(1);
  end
endmodule
