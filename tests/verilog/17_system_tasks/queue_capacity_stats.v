// IEEE1364-2005 17.6.1–17.6.6: capacity2, current length code1, peak code3.
// Fill with two jobs, reject third with status1, remove both, then status3
// on empty removal. Maximum-length query gives2 in this run; configured
// capacity and achieved maximum coincide, so this does not distinguish them.
// Do not assert job/info outputs on failed removal.
//! lrm 9.9
//! lrm 9.9:1000
//! inherited IEEE 1364-2005 17.6
//! expect stdout queue_capacity_stats.expected.txt
module audit_queue_capacity_stats;
  integer status, full, count, peak, job, info;
  initial begin
    $q_initialize(51, 1, 2, status);
    $display("create=%0d", status);
    full = $q_full(51, status);
    $display("empty full=%0d status=%0d", full, status);
    $q_add(51, 8, 80, status);
    $display("add1=%0d", status);
    $q_add(51, 9, 90, status);
    $display("add2=%0d", status);
    full = $q_full(51, status);
    $display("filled full=%0d status=%0d", full, status);
    $q_add(51, 10, 100, status);
    $display("overflow=%0d", status);
    $q_exam(51, 1, count, status);
    $display("length=%0d status=%0d", count, status);
    $q_remove(51, job, info, status);
    $display("remove1=%0d/%0d status=%0d", job, info, status);
    $q_remove(51, job, info, status);
    $display("remove2=%0d/%0d status=%0d", job, info, status);
    $q_exam(51, 1, count, status);
    $display("drained length=%0d status=%0d", count, status);
    $q_exam(51, 3, peak, status);
    $display("peak=%0d status=%0d", peak, status);
    $q_remove(51, job, info, status);
    $display("underflow=%0d", status);
    $finish(0);
  end
endmodule
