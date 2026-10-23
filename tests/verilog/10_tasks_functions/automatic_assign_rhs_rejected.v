//! inherited IEEE 1364-2005 10.2.3
//! reject-only cannot name a variable of an automatic task or function
// The RHS of a procedural continuous assignment reads an automatic variable;
// §10.2.3 forbids it (automatic_error7), with the notAutomatic check's message.
// VerA currently accepts this use; the fixture is expected to FAIL, verifying
// the vera-bug claim.
// Under `--run` VerA accepts this use (the claim); a `--check` probe refuses
// the whole module with E1103 (contract device), which is unrelated.
module triage_automatic_assign_rhs_rejected;
  reg global;

  task automatic auto_task;
    reg local;
    begin : block
      assign global = local;
    end
  endtask
endmodule
