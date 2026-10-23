//! inherited IEEE 1364-2005 12.5
// A hierarchical task call into an uninstantiated top-level module suspends;
// the always block therefore has a timing control (pr2076425).
module triage_hierarchical_task_call_suspends;
  task delay;
    z.delay;
  endtask

  always begin
    delay;
  end

  initial begin
    #10 $display("PASSED");
    $finish(0);
  end
endmodule

module z;
  task delay;
    #1;
  endtask
endmodule
