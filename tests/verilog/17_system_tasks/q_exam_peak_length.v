// IEEE 1364-2005 §17.6.5: "The $q_exam system task provides statistical
// information about activity at the queue q_id." Table 17-15: "3 Maximum
// queue length". VerA's reading (specification/Vague_Decisions.md VD-051): code 3 is
// the largest length the queue has reached, a statistic of its activity like
// codes 2, 4, 5 and 6, not the max_length given to $q_initialize.
//
// HAND DERIVATION. Queue 1, FIFO, max_length 4; the three readings differ:
//   add job 1, add job 2           length 2, peak 2
//   remove (job 1 leaves)          length 1, peak 2
//   code 1 -> 1 (current length); code 3 -> 2 (peak), not 4 (max_length)
//
// No rejection fixture: the call is the legal four-argument form, and a code
// outside Table 17-15 is q_exam_code_rejected.v.
//! inherited IEEE 1364-2005 17.6.5
`timescale 1 ns / 1 ns
module b_17_6_5_q_exam_peak_length;
  integer status, v, job, info;
  initial begin
    $q_initialize(1, 1, 4, status);
    $q_add(1, 1, 10, status);
    $q_add(1, 2, 20, status);
    $q_remove(1, job, info, status);
    $q_exam(1, 1, v, status);
    $display("length=%0d status=%0d", v, status);
    $q_exam(1, 3, v, status);
    $display("peak=%0d status=%0d", v, status);
    $finish(0);
  end
endmodule
