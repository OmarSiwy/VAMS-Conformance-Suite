// IEEE §9.7.3 and AMS §5.10.4: an event-controlled procedure waits for
// another procedure to execute the matching trigger. The event carries no
// stored data; a trigger before the wait does not release a later wait.
//
// DERIVATION: r is set to 0011 at t=0. The only trigger is at t=1,
// before the reader prints "armed 0011" and starts waiting at t=2.
// At t=5 the other process prints "end 0011" and terminates the run.
// The exact transcript therefore contains those two lines and no "resumed".
//
//! lrm 5.10
//! lrm 5.10.4
//! lrm A.6.5
//! lrm 5.10.4:2
//! lrm A.6.5:1000
//! timescale 1ns/1ps
//! inherited IEEE 1364-2005 9.7.3
`timescale 1ns/1ps
module d04_named_event_has_no_memory;
  event e;
  reg [3:0] r;

  initial begin
    #1 -> e;
  end

  initial begin
    r = 4'b0011;
    #2 $display("armed %b", r);
    @(e) $display("resumed %b", r);
  end

  initial begin
    #5 $display("end %b", r);
    $finish(0);
  end
endmodule
