// IEEE1364-2005 17.6.1–17.6.3 Tables17-14/16: type1 FIFO, type2 LIFO.
// Enqueue (job,info)=(13,130),(27,270) in each independent queue.
// FIFO returns13 then27; LIFO returns27 then13. Payload must stay with job.
// Every successful task overwrites status with0; no default-zero assumption.
//! lrm 9.9
//! lrm 9.9:1000
//! inherited IEEE 1364-2005 17.6.1,17.6.2,17.6.3
//! expect stdout queue_order_payload.expected.txt
module audit_queue_order_payload;
  integer status, job, info;
  initial begin
    status = 99;
    $q_initialize(41, 1, 2, status);
    $display("fifo create=%0d", status);
    $q_initialize(42, 2, 2, status);
    $display("lifo create=%0d", status);
    $q_add(41, 13, 130, status);
    $display("fifo add1=%0d", status);
    $q_add(41, 27, 270, status);
    $display("fifo add2=%0d", status);
    $q_add(42, 13, 130, status);
    $display("lifo add1=%0d", status);
    $q_add(42, 27, 270, status);
    $display("lifo add2=%0d", status);
    $q_remove(41, job, info, status);
    $display("fifo first=%0d/%0d status=%0d", job, info, status);
    $q_remove(42, job, info, status);
    $display("lifo first=%0d/%0d status=%0d", job, info, status);
    $q_remove(41, job, info, status);
    $display("fifo second=%0d/%0d status=%0d", job, info, status);
    $q_remove(42, job, info, status);
    $display("lifo second=%0d/%0d status=%0d", job, info, status);
    $finish(0);
  end
endmodule
