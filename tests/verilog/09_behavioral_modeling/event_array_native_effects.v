// IEEE 1364-2005 §§9.7.3–9.7.4: one occurrence resumes a suspended
// event-or statement once. An index function may make blocking writes;
// those writes can satisfy another term of that same suspension.
// §10.4.4(f) prohibits event triggers in functions, so a selector cannot
// recursively trigger this named-event list. Its invalid neighbor is
// event_array_selector_trigger_rejected.v.
//
// DERIVATION: ev[0] at t=1 invokes each selected waiter's choose function.
// Each writes its own flag from 0 to 1, satisfying its flag term before
// evaluation of the event term returns. Each suspension still resumes
// once: a=b=1. Resetting both flags at t=2 resumes each again; ev[0] at
// t=3 raises both flags and resumes each a third time. ev[1] at t=4 does
// not match either selected index, but does wake its fixed waiter and the
// event-or waiter. Thus at t=5 a=b=3, passive=2, other=1, either=3.
// The fixed waiters and repeated suspensions exercise live, stale and
// recycled entries together; all displays follow their active events.
//! inherited IEEE 1364-2005 9.7.3
//! inherited IEEE 1364-2005 9.7.4
//! inherited IEEE 1364-2005 10.4.4
// native-required
`timescale 1ns/1ns
module b_9_7_3_event_array_native_effects;
  event ev [0:1];
  integer flag_a, flag_b, a, b, passive, other, either;
  function automatic integer choose(input integer which);
    begin
      if (which == 0) flag_a = 1;
      else flag_b = 1;
      choose = 0;
    end
  endfunction
  initial begin
    flag_a = 0; flag_b = 0; a = 0; b = 0;
    passive = 0; other = 0; either = 0;
    #1 -> ev[0];
    #1 begin
      $display("first: a=%0d b=%0d passive=%0d other=%0d either=%0d", a, b, passive, other, either);
      flag_a = 0; flag_b = 0;
    end
    #1 -> ev[0];
    #1 begin
      $display("repeat: a=%0d b=%0d passive=%0d other=%0d either=%0d", a, b, passive, other, either);
      -> ev[1];
    end
    #1 begin
      $display("final: a=%0d b=%0d passive=%0d other=%0d either=%0d", a, b, passive, other, either);
      $finish(0);
    end
  end
  always @(ev[choose(0)] or flag_a) a = a + 1;
  always @(ev[choose(1)] or flag_b) b = b + 1;
  always @(ev[0]) passive = passive + 1;
  always @(ev[1]) other = other + 1;
  always @(ev[0] or ev[1]) either = either + 1;
endmodule
