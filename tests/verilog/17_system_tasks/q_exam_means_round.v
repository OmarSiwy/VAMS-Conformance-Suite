// IEEE 1364-2005 §17.6.5, Table 17-15: "2 Mean interarrival time", "6 Average
// wait time in the queue". q_stat_value is an integer and the clause gives no
// conversion. §3.5.3: "Real numbers shall be converted to integers by rounding
// the real number to the nearest integer, rather than by truncating it."
// VerA's reading (specification/Vague_Decisions.md VD-052): each mean is the exact
// mean rounded that way, ties away from zero.
//
// HAND DERIVATION. Queue 1, FIFO, max_length 5, times in ns (1 ns / 1 ns):
//   t=0 add job 1, t=2 add job 2, t=5 add job 3
//     interarrivals 2 - 0 = 2 and 5 - 2 = 3: mean 2.5 -> 3 (truncation: 2)
//   t=6 remove: job 1 leaves after 6 - 0 = 6
//   t=9 remove: job 2 leaves after 9 - 2 = 7
//     completed waits 6 and 7: mean 6.5 -> 7 (truncation: 6)
// Code 6 counts only jobs that left; job 3 is still queued.
//
// No rejection fixture: the calls are the legal four-argument form, and a
// code outside Table 17-15 is q_exam_code_rejected.v.
//! inherited IEEE 1364-2005 17.6.5
`timescale 1 ns / 1 ns
module b_17_6_5_q_exam_means_round;
  integer status, v, job, info;
  initial begin
    $q_initialize(1, 1, 5, status);
    $q_add(1, 1, 0, status);
    #2 $q_add(1, 2, 0, status);
    #3 $q_add(1, 3, 0, status);
    #1 $q_remove(1, job, info, status);
    #3 $q_remove(1, job, info, status);
    $q_exam(1, 2, v, status);
    $display("interarrival=%0d status=%0d", v, status);
    $q_exam(1, 6, v, status);
    $display("wait=%0d status=%0d", v, status);
    $finish(0);
  end
endmodule
