// IEEE 1364-2005 §17.6.5, p. 308: "The $q_exam system task provides
// statistical information about activity at the queue q_id. It returns a
// value in q_stat_value depending on the information requested in
// q_stat_code." Table 17-15: 1 "Current queue length", 5 "Longest wait time
// for jobs still in the queue". "The status code reports on the success of
// the operation or error conditions as described in Table 17-16."
//
// Codes 2, 4 and 6 (means and the shortest wait "ever") and code 3 (whether
// "maximum" is the configured or the observed length) have readings the
// clause does not settle, so only codes 1 and 5 are asked. Everything is in
// one module at 1 ns / 1 ns, so a time in module units and a time in
// simulation ticks are the same number.
// Queue 3 is FIFO (q_type 1), max_length 4:
//   t=0   add job 1                          length 1
//   t=10  add job 2                          length 2
//   t=25  exam: code 1 -> 2; code 5 -> job 1 has waited 25 - 0 = 25
//   t=25  remove (FIFO: job 1 leaves)
//         exam: code 1 -> 1; code 5 -> job 2, still queued, 25 - 10 = 15
// Every call succeeds: status 0.
//! inherited IEEE 1364-2005 17.6.5
`timescale 1 ns / 1 ns
module b_17_6_5_q_exam;
  integer status, v, job, info;
  initial begin
    $q_initialize(3, 1, 4, status);
    $q_add(3, 1, 10, status);
    #10 $q_add(3, 2, 20, status);
    #15 $q_exam(3, 1, v, status);
    $display("length=%0d status=%0d", v, status);
    $q_exam(3, 5, v, status);
    $display("longest=%0d status=%0d", v, status);
    $q_remove(3, job, info, status);
    $q_exam(3, 1, v, status);
    $display("length=%0d status=%0d", v, status);
    $q_exam(3, 5, v, status);
    $display("longest=%0d status=%0d", v, status);
    $finish(0);
  end
endmodule
