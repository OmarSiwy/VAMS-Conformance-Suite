//! inherited IEEE 1364-2005 5.1.13
// With an x/z condition the result is the bitwise blend of the two operands;
// for a real result that blend is 0, not either arm (pr2453002).
module triage_conditional_real_x;
  parameter udef = 1'bx;
  real r = udef ? 6 : 6.0;

  initial begin
    if (r == 0.0) $display("PASSED"); else $display("FAILED %f", r);
  end
endmodule
