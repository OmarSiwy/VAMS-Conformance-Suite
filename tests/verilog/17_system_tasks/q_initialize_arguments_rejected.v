// IEEE 1364-2005 §17.6, p. 307: "The set of tasks and functions that create
// and manage queues follows: $q_initialize (q_id, q_type, max_length,
// status) ;" §17.6.1, p. 307: "The success or failure of the creation of the
// queue is returned as an integer value in status."
//
// The call passes three arguments and so has no status to return the result
// in. Legal neighbour: queue_order_payload.v passes all four.
//! inherited IEEE 1364-2005 17.6.1
//! reject E1100
//! reject the §17.6 queue tasks take four arguments
//! neighbour queue_order_payload.v
`timescale 1 ns / 1 ns
module b_17_6_1_q_initialize_arguments_rejected;
  integer status, job, info, v;
  initial begin
    $q_initialize(1, 1, 5);
  end
endmodule
