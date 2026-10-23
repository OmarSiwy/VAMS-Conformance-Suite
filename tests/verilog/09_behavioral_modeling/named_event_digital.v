// §5.10.4 Named events, and A.2.1.3 `event_declaration ::= event
// list_of_event_identifiers ;` / A.6.5 `event_trigger ::= ->
// hierarchical_event_identifier { [ expression ] } ;`.
//
// §5.10.4: "An event-controlled statement (for example, @trig rega = regb;)
// shall cause simulation of its containing procedure to wait until some other
// procedure executes the appropriate event-triggering statement (for example,
// -> trig)." The same clause's own example is the digital shape used here —
//
//     initial #10 -> dig_event;
//     always @(ana_event) $display("Event: ana_event detected in digital");
//
// The analog half of §5.10.4 is already pinned by tests/fixtures (see
// ch05_analog_behavior/named_event_unsupported.va and
// annex_a_syntax/named_event_trigger.va). NOTHING pins the digital half,
// which is the one §5.10.4's sentence above is actually about — a named event
// used to synchronize two concurrently active procedures.
//
// HAND DERIVATION — three processes, one event.
//   t=0   waiter: r<-0000, then blocks at @(tick)
//         marker: mark<-0000, then delays to t=3
//         driver: delays to t=5
//   t=3   mark<-0001
//   t=5   -> tick   resumes the waiter, which assigns r<-1010 and displays
//                   r = 1010 and mark = 0001
//
// `mark` is the clock in this fixture: it is 0000 before t=3 and 0001 after, so
// printing it proves the waiter resumed at the trigger (t=5) rather than
// falling straight through at t=0. A `@(named_event)` silently treated as a
// no-op prints "resumed 1010 0000"; one treated as a never-true guard prints
// nothing at all and the run ends without the line.
//
//! lrm 5.10.4
//! lrm A.2.1.3
//! lrm A.6.5
//! lrm 5.10.4:2
//! lrm A.2.1.3:1000
//! lrm A.6.5:1000
//! timescale 1ns/1ps
//! inherited IEEE 1364-2005 9.7.3
`timescale 1ns/1ps
module d04_named_event_digital;
  event tick;
  reg [3:0] r, mark;

  initial begin
    r = 4'b0000;
    @(tick) r = 4'b1010;
    $display("resumed %b %b", r, mark);
    $finish(0);
  end

  initial begin
    mark = 4'b0000;
    #3 mark = 4'b0001;
  end

  initial begin
    #5 -> tick;
  end
endmodule
