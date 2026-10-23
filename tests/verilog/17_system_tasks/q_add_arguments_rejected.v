// IEEE 1364-2005 §17.6, p. 307: "The set of tasks and functions that create
// and manage queues follows: ... $q_add (q_id, job_id, inform_id, status) ;"
// §17.6.2, p. 307: "The status code reports on the success of the operation
// or error conditions as described in Table 17-16."
//
// The call passes three arguments, leaving out status. Legal neighbour:
// queue_order_payload.v passes all four.
//! inherited IEEE 1364-2005 17.6.2
//! reject E1100
//! reject the §17.6 queue tasks take four arguments
//! neighbour queue_order_payload.v
`timescale 1 ns / 1 ns
module b_17_6_2_q_add_arguments_rejected;
  integer status, job, info, v;
  initial begin
    $q_initialize(1, 1, 5, status);
    $q_add(1, 2, 3);
  end
endmodule
