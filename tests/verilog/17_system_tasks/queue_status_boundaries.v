// IEEE1364-2005 17.6.6 Table17-16: runtime errors return status, not a
// compile rejection. Isolate each invalid precondition: type3->4, length0/-1
// ->5, duplicateID->6, undefinedID->2. Never inspect unspecified result/payload
// values after failed queries. Memory exhaustion status7 needs a host seam.
//! lrm 9.9
//! lrm 9.9:1000
//! inherited IEEE 1364-2005 17.6.6
//! expect stdout queue_status_boundaries.expected.txt
module audit_queue_status_boundaries;
  integer status, job, info, value;
  initial begin
    $q_initialize(61, 3, 2, status);
    $display("bad type=%0d", status);
    $q_initialize(62, 1, 0, status);
    $display("zero length=%0d", status);
    $q_initialize(63, 1, -1, status);
    $display("negative length=%0d", status);
    $q_initialize(64, 1, 2, status);
    $display("legal create=%0d", status);
    $q_initialize(64, 1, 2, status);
    $display("duplicate=%0d", status);
    $q_add(65, 1, 10, status);
    $display("undefined add=%0d", status);
    $q_remove(65, job, info, status);
    $display("undefined remove=%0d", status);
    $q_exam(65, 1, value, status);
    $display("undefined exam=%0d", status);
    value = $q_full(65, status);
    $display("undefined full=%0d", status);
    $finish(0);
  end
endmodule
