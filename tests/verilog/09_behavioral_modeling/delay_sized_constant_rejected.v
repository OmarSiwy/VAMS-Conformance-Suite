//! inherited IEEE 1364-2005 9.7.1 A.6.5
//! reject unexpected token: found 64'd2147483648
// A bare delay's delay_value is an unsigned_number, real_number or identifier;
// a sized constant needs parentheses around the mintypmax_expression
// (audit_time_stime_wrap). VerA accepts the sized form; the fixture is
// expected to FAIL, verifying the vera-bug claim.
module triage_delay_sized_constant_rejected;
  initial #64'd2147483648 $display("late");
endmodule
