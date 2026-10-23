// IEEE1364-2005 §9.7.6 Syntax 9-11: `wait ( expression ) statement`. The legal
// twin of sched_wait_empty_rejected.v: with an expression that is already
// true, the wait continues at once and the statement prints `ready`.
//! lrm A.6.5
//! lrm A.6.5:1000
//! inherited IEEE 1364-2005 9.7.6
module audit_sched_wait_expression;
  reg flag;
  initial begin
    flag = 1;
    wait (flag) $display("ready");
    $finish(0);
  end
endmodule
