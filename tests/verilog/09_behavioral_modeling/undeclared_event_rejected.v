// IEEE 1364-2005 §9.7.3, p. 133: "An event name shall be declared explicitly
// before it is used."
//
// -> ev triggers a name no declaration introduces. Legal neighbour:
// named_event_digital.v declares its event before triggering it.
//! inherited IEEE 1364-2005 9.7.3
//! reject E1100
//! reject undeclared named event
//! neighbour named_event_digital.v
module b_9_7_3_undeclared_event_rejected;
  initial -> ev;
endmodule
