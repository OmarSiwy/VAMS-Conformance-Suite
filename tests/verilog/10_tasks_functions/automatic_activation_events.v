//! inherited IEEE 1364-2005 10.2.3
// Each activation of an automatic task has its own variables, so the event
// declared inside one activation is not the event another activation waits on
// (automatic_task3/recursive_task).
module triage_automatic_activation_events;
  task automatic t;
    input integer id;
    event ev;
    begin
      if (id == 1) begin
        #1 -> ev;
        $display("t1 done");
      end else begin
        @ev $display("t2 woke");
      end
    end
  endtask

  initial fork
    t(1);
    t(2);
  join

  initial begin
    #2 $display("PASSED");
  end
endmodule
