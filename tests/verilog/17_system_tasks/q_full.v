// IEEE 1364-2005 §17.6.4, p. 308: "The $q_full system function checks whether
// there is room for another entry on a queue. It returns 0 when the queue is
// not full and 1 when the queue is full. The status code reports on the
// success of the operation or error conditions as described in Table 17-16."
// Table 17-16: 0 "OK", 2 "Undefined q_id".
//
// Queue 7 is FIFO (q_type 1) with max_length 1:
//   empty:          $q_full -> 0, status 0
//   after one add:  $q_full -> 1 (no room for another), status 0
//   after a remove: $q_full -> 0, status 0
//   queue 8 was never created: status 2. What $q_full returns then is not
//   stated, so only the status is printed.
//! inherited IEEE 1364-2005 17.6.4
`timescale 1 ns / 1 ns
module b_17_6_4_q_full;
  integer status, full, job, info;
  initial begin
    $q_initialize(7, 1, 1, status);
    full = $q_full(7, status);
    $display("empty full=%0d status=%0d", full, status);
    $q_add(7, 1, 100, status);
    full = $q_full(7, status);
    $display("one full=%0d status=%0d", full, status);
    $q_remove(7, job, info, status);
    full = $q_full(7, status);
    $display("removed full=%0d status=%0d", full, status);
    full = $q_full(8, status);
    $display("undefined status=%0d", status);
    $finish(0);
  end
endmodule
