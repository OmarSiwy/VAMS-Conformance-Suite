// IEEE 1364-2005 §17.6.5, Table 17-15: q_stat_code 1 to 6. §17.6.6: "All of
// the queue management tasks and functions return an output status code",
// and Table 17-16 has no row for a code outside Table 17-15. VerA's reading
// (specification/Vague_Decisions.md VD-050): such a code known only at run time
// returns status 2 ("Undefined q_id", the nearest row) and leaves
// q_stat_value unchanged. A constant one is refused at compile time
// (q_exam_code_rejected.v).
//
// HAND DERIVATION. Queue 1, FIFO, max_length 5, one job added at t=0.
//   code = 1: length 1, status 0
//   v = 99; code = 7: status 2, v stays 99
//   code = 0: status 2, v stays 99 (below the table, too)
//! inherited IEEE 1364-2005 17.6.5
//! inherited IEEE 1364-2005 17.6.6
`timescale 1 ns / 1 ns
module b_17_6_5_q_exam_code_runtime;
  integer status, v, code;
  initial begin
    $q_initialize(1, 1, 5, status);
    $q_add(1, 1, 10, status);
    code = 1;
    $q_exam(1, code, v, status);
    $display("code=%0d v=%0d status=%0d", code, v, status);
    v = 99;
    code = 7;
    $q_exam(1, code, v, status);
    $display("code=%0d v=%0d status=%0d", code, v, status);
    code = 0;
    $q_exam(1, code, v, status);
    $display("code=%0d v=%0d status=%0d", code, v, status);
    $finish(0);
  end
endmodule
