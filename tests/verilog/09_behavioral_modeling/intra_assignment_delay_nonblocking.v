// A.6.2 `nonblocking_assignment ::= variable_lvalue <= [ delay_or_event_control ]
// expression`.
//
// §8.5.3.4 Non blocking assignment: "A nonblocking assignment statement (see
// 9.2.2 of IEEE Std 1364 Verilog) always computes the updated value and
// schedules the update as a nonblocking assign update event, either in this time
// step if the delay is zero or as a future event if the delay is nonzero. The
// values in effect when the update is placed on the event queue are used to
// compute both the right-hand value and the left-hand target."
//
// "Always computes ... and schedules" — there is no suspension anywhere in that
// sentence. This is the one structural difference from fixture 05: the same
// `#5` written after `<=` instead of after `=` leaves the process RUNNING.
// VerA already implements `b <= a;` with zero delay; the delayed form is what
// is missing, and it is the form where "does not suspend" becomes visible.
//
// HAND DERIVATION — one process, no races at all.
//   t=0   a<-0001
//         `b <= #5 a;` computes 0001 and queues an update for t=5; the process
//         does NOT stop
//         a<-1111 executes immediately, still at t=0
//         display -> a = 1111, b untouched since declaration = xxxx
//                 -> "t0 1111 xxxx"
//   t=5   the queued NBA update lands: b<-0001 (captured before a became 1111)
//   t=6   display -> "t6 1111 0001"
//
// Suspending like a blocking assignment gives a first line of "t0 0001 xxxx"
// printed at t=5 with a = 0001. Capturing the RHS at update time gives
// "t6 1111 1111".
//
//! lrm A.6.2
//! lrm 8.5.3.4
//! lrm 8.5.1
//! lrm 8.5.3.4:1000
//! lrm A.6.2:1000
//! timescale 1ns/1ps
//! inherited IEEE 1364-2005 9.2.2 9.7.7 11.6.4
`timescale 1ns/1ps
module d04_intra_assignment_delay_nonblocking;
  reg [3:0] a, b;

  initial begin
    a = 4'b0001;
    b <= #5 a;
    a = 4'b1111;
    $display("t0 %b %b", a, b);
    #6 $display("t6 %b %b", a, b);
    $finish(0);
  end
endmodule
