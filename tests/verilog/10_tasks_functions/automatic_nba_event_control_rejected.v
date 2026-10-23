//! inherited IEEE 1364-2005 10.2.3
//! reject-only cannot name a variable of an automatic task or function
// An automatic task's local variable is read by an NBA intra-assignment event
// control; §10.2.3 forbids it (automatic_error3), with the notAutomatic
// check's message. VerA currently accepts this use; the fixture is expected to
// FAIL, verifying the vera-bug claim.
// Under `--run` VerA accepts this use (the claim); a `--check` probe does not
// reach the rule either (the generated device fails to compile).
module triage_automatic_nba_event_control_rejected;
  reg global;

  task automatic auto_task;
    reg local;
    begin : block
      global <= @(local) 0;
    end
  endtask
endmodule
