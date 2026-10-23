// IEEE 1364-2005 §11.2, p. 158: "Every change in value of a net or variable
// in the circuit being simulated, as well as the named event, is considered
// an update event." ... "Processes are sensitive to update events. When an
// update event is executed, all the processes that are sensitive to that
// event are evaluated in an arbitrary order."
//
// Each waiter arms at t = 1 or t = 4, strictly between the writes, so no
// arming races a write (§11.5). The writer runs at t = 2, 3, 5 and 6.
//   t = 2: -> go is an update event; the @(go) waiter (armed at 1) resumes:
//          "named event at 2".
//   t = 3: v = 5; the continuous assignment w = v + 1 changes w from x to 6,
//          an update event on a net; the @(w) waiter (armed at 1) resumes:
//          "net update at 3: w=6".
//   t = 5: v = 5 again. v does not change, so there is no update event and
//          the @(v) waiter (armed at 4) stays suspended.
//   t = 6: v = 6 changes v; the waiter resumes: "variable update at 6: v=6".
// Each line prints at its own time, so the transcript order is fixed.
//! inherited IEEE 1364-2005 11.2
`timescale 1ns/1ns
module b_11_2_update_events;
  event go;
  reg [3:0] v;
  wire [3:0] w;
  assign w = v + 4'd1;
  initial #1 @(go) $display("named event at %0d", $time);
  initial #1 @(w) $display("net update at %0d: w=%0d", $time, w);
  initial #4 @(v) $display("variable update at %0d: v=%0d", $time, v);
  initial begin
    #2 -> go;
    #1 v = 4'd5;
    #2 v = 4'd5;
    #1 v = 4'd6;
    #1 $finish(0);
  end
endmodule
