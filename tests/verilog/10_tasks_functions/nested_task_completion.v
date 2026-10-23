// IEEE 1364-2005 §10.2, p. 145: "Control shall be passed back to the enabling
// process after the task has completed. Thus, if a task has timing controls
// inside it, then the time of enabling a task can be different from the time
// at which the control is returned. A task can enable other tasks, which in
// turn can enable still other tasks—with no limit on the number of tasks
// enabled. Regardless of how many tasks have been enabled, control shall not
// return until all enabled tasks have completed."
//
// outer (enabled at t = 1) appends 1, enables middle; middle appends 2 and
// enables inner; inner waits #2 (t = 3) and appends 3; middle waits #1
// (t = 4) and appends 4; outer waits #3 (t = 7) and appends 5.
//   trace = 12345, and control returns to the initial block at t = 7:
//   "enabled 1 returned 7 trace 12345".
// Had control returned when outer's own statements were reached but inner or
// middle still waited, the return time would be below 7 or trace would miss
// digits.
//! inherited IEEE 1364-2005 10.2
`timescale 1ns/1ns
module b_10_2_nested_task_completion;
  integer trace, t0;

  task inner;
    begin
      #2 trace = trace * 10 + 3;
    end
  endtask

  task middle;
    begin
      trace = trace * 10 + 2;
      inner;
      #1 trace = trace * 10 + 4;
    end
  endtask

  task outer;
    begin
      trace = trace * 10 + 1;
      middle;
      #3 trace = trace * 10 + 5;
    end
  endtask

  initial begin
    trace = 0;
    #1 t0 = $time;
    outer;
    $display("enabled %0d returned %0d trace %0d", t0, $time, trace);
    $finish(0);
  end
endmodule
