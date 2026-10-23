// IEEE 1364-2005 §9.7.3, p. 133: "An event name shall be declared explicitly
// before it is used."
//
// @ev is used on the line before `event ev;` declares it. Legal neighbour:
// the same module with the declaration moved first
// (named_event_digital.v declares its event before any use).
//! inherited IEEE 1364-2005 9.7.3
//! reject E1100
//! reject named event
//! neighbour named_event_digital.v
module b_9_7_3_event_used_before_declaration_rejected;
  initial @ev $display("fired");
  event ev;
  initial #1 -> ev;
endmodule
