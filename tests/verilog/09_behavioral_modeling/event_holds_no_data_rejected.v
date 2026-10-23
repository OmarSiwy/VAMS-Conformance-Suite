// IEEE 1364-2005 §9.7.3, p. 134: "An event shall not hold any data." ... "A
// declared event is made to occur by the activation of an event triggering
// statement with the syntax given in Syntax 9-10."
//
// ev = 1 assigns a value to the named event ev, which holds none; an event is
// not a variable_lvalue. Legal neighbour: -> ev (named_event_digital.v).
//! inherited IEEE 1364-2005 9.7.3
//! reject E1100
//! reject named event
//! neighbour named_event_digital.v
module b_9_7_3_event_holds_no_data_rejected;
  event ev;
  initial ev = 1;
endmodule
