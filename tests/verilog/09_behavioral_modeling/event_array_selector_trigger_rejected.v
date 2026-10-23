// IEEE 1364-2005 §10.4.4(f): "A function shall not have any event triggers."
// The sole call is an event-array index, so the rule still applies to a
// selector evaluated on an occurrence. Triggering ev[0] from choose would
// recursively revisit the same event list; the frontend must reject it.
// Legal neighbor: event_array_native_effects.v, whose selector only
// makes blocking variable assignments and executes in the native runtime.
//! inherited IEEE 1364-2005 10.4.4
//! reject E1100
//! reject event trigger
//! neighbour event_array_native_effects.v
module b_9_7_3_event_array_selector_trigger_rejected;
  event ev [0:1];
  function integer choose(input integer i);
    begin -> ev[0]; choose = i; end
  endfunction
  initial @(ev[choose(0)]);
  initial #1 -> ev[0];
endmodule
