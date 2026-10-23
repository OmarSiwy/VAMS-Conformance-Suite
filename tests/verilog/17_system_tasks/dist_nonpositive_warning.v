// IEEE 1364-2005 §17.9.2: "For the exponential, poisson, chi-square, t, and
// erlang functions, the arguments mean, degree_of_freedom, and k_stage shall
// be greater than 0." The §17.9.3 listing's answer to a mean of 0, e.g.
// rtl_dist_exponential: `if(mean>0) {...} else { print_error("WARNING:
// Exponential distribution must have a positive mean\n"); i=0; }` — it
// returns 0 and never calls `uniform`, so the seed is not written.
// The mean is a variable, so this is a run-time warning and not a refusal.
//! inherited IEEE 1364-2005 17.9.2
module audit_dist_nonpositive_warning;
  integer seed, mean, r;
  initial begin
    seed = 1; mean = 0; r = 99;
    r = $dist_exponential(seed, mean);
    $display("r=%0d seed=%0d", r, seed);
  end
endmodule
