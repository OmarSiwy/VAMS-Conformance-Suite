//! inherited IEEE 1364-2005 10.2.1
// A non-ANSI task input may be typed real by a following declaration
// (task_nonansi_real1).
module triage_nonansi_task_real_port;
  task t;
    input x;
    real x;
    if (x == 1.23)
      $display("PASSED");
    else
      $display("FAILED");
  endtask

  initial t(1.23);
endmodule
