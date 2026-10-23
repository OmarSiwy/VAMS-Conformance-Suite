//! inherited IEEE 1364-2005 10.2.1 A.2.7
//! reject-only E0207
// A.2.7's tf_port_item starts with a direction. IEEE 1800 makes it optional,
// 1364-2005 does not; br1027a. VerA accepts the directionless form as an
// input (the IEEE 1800 default); the fixture is expected to FAIL, verifying
// the vera-bug claim.
module triage_task_port_item_needs_direction_rejected;
  task t(a, b);
    begin end
  endtask
endmodule
