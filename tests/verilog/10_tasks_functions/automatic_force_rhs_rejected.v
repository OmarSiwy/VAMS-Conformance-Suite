//! inherited IEEE 1364-2005 10.2.3
//! reject-only cannot name a variable of an automatic task or function
// The RHS of force reads an automatic variable; §10.2.3 forbids it
// (automatic_error10), with the notAutomatic check's message. VerA currently
// accepts this use; the fixture is expected to FAIL, verifying the vera-bug
// claim.
// Under `--run` VerA accepts this use (the claim); a `--check` probe refuses
// the whole module with E1103 (contract device), which is unrelated.
module triage_automatic_force_rhs_rejected;
  reg global;

  task automatic auto_task;
    reg local;
    begin : block
      force global = local;
    end
  endtask
endmodule
