// IEEE 1364-2005 §27.33.1.1 and Table 27-6: a blocking assignment's
// cbStmt runs just before the assignment. The C application arms callbacks
// from $arm during this process, without a timing control or suspension.
// It must observe q = 0, 1 and 3 before q = 1, 2 and 4 respectively.
// Removing the registration suppresses q = 3, and re-arming takes effect
// before the very next assignment in the same process.
module audit_stmt_registration_during_call;
  integer q;
  initial begin
    q = 0;
    $arm;
    q = 1;
    q = 2;
    $disarm;
    q = 3;
    $arm;
    q = 4;
    $finish(0);
  end
endmodule
