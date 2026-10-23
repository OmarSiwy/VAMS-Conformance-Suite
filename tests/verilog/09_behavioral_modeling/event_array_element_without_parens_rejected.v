//! inherited IEEE 1364-2005 A.6.5 A.9.3
//! reject-only E0209
// event_control ::= @ hierarchical_event_identifier | @ ( event_expression ),
// and A.9.3's hierarchical_identifier takes no index on its final segment, so
// an event-array element needs the parentheses: @(ev[0]) is the legal
// neighbour (triage_event_array).
module triage_event_array_element_without_parens_rejected;
  event ev [0:1];

  initial @ev[0] $display("not reached");
endmodule
