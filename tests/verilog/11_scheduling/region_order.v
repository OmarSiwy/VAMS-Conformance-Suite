// IEEE 1364-2005 §11.3, p. 159: "b) Inactive events occur at the current
// simulation time, but shall be processed after all the active events are
// processed. c) Nonblocking assign update events have been evaluated during
// some previous simulation time, but shall be assigned at this simulation
// time after all the active and inactive events are processed. d) Monitor
// events shall be processed after all the active, inactive, and nonblocking
// assign update events are processed." ... "An explicit zero delay (#0)
// requires that the process be suspended and added as an inactive event for
// the current time so that the process is resumed in the next simulation
// cycle in the current time." ... "The $monitor and $strobe system tasks (see
// 17.1) create monitor events for their arguments."
// §11.4, p. 159, the reference model: "if (no active events) { if
// (there are inactive events) { activate all inactive events; } else if
// (there are nonblocking assign update events) { activate all nonblocking
// assign update events; } else if (there are monitor events) { activate all
// monitor events; } ..."
//
// One process, so nothing races (§11.4.1 a) orders its statements):
//   active:   a = 1; a <= 2 queues an NBA update; $strobe queues a monitor
//             event; $display prints "active: a=1".
//   #0:       the process becomes an inactive event. No active event is
//             left, and inactive events come before the NBA update, so it
//             resumes with a still 1: "inactive 1: a=1".
//   #0 again: a new inactive event while the NBA update is still pending;
//             the reference model again activates the inactive event first:
//             "inactive 2: a=1".
//   Nothing active or inactive remains: the NBA update sets a = 2. Then the
//             monitor event prints a's value now: "monitor: a=2".
//   #1:       "next time: a=2".
//! inherited IEEE 1364-2005 11.3 11.4
`timescale 1ns/1ns
module b_11_3_region_order;
  reg [7:0] a;
  initial begin
    a = 1;
    a <= 2;
    $strobe("monitor: a=%0d", a);
    $display("active: a=%0d", a);
    #0 $display("inactive 1: a=%0d", a);
    #0 $display("inactive 2: a=%0d", a);
    #1 $display("next time: a=%0d", a);
    $finish(0);
  end
endmodule
