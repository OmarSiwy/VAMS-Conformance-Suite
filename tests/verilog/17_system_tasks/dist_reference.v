// IEEE 1364-2005 §17.9.2: "For each system function, the seed argument is an
// inout argument; that is, a value is passed to the function, and a
// different value is returned. The system functions shall always return the
// same value given the same seed." §17.9.3: "The algorithm for these
// functions is defined by the following C code", Table 17-17 mapping each
// $dist_ name to its rtl_dist_ routine.
//
// HAND DERIVATION from the listing. Every routine draws through `uniform`,
// whose step is seed' = 69069*seed + 1 (32-bit wrap). From seed 1 that is
// 69070, 475628535, -1017563188, 772999773, -417135238, ...; from 7 it is
// 483484, -965981971, -1386778934.
//  $dist_uniform(7, -5, 5): end++ -> uniform(seed, -5, 6) = -4.99876..;
//    r < 0 so i = (long)(r - 1) = -5, and i < start is clamped to -5
//    (seed 483484). Then 3 (seed -965981971) and 2 (seed -1386778934).
//  $dist_normal(1, 100, 10): the first Marsaglia pair (-0.99997, -0.77852)
//    has s = 1.606 >= 1 and is rejected; the second (0.52616, -0.64004),
//    s = 0.68650, gives 0.52616*sqrt(-2 ln s / s)*10 + 100 = 105.508 ->
//    (long)(r + 0.5) = 106, after four steps (seed 772999773).
//  $dist_exponential(1, 50): u = 1.6093e-5, -ln(u)*50 = 551.86 -> 552,
//    one step (seed 69070).
//  $dist_poisson(1, 4): e^-4 = 0.018316; the first uniform 1.6093e-5 is
//    already below it, n = 0 (seed 69070). From 69070: 0.11074, then
//    *0.76308 = 0.084504, then *0.17998 = 0.015209 < e^-4, n = 2 after three
//    steps (seed 772999773).
//  $dist_chi_square(1, 3): df odd, so one normal(0, 1) = 0.55080 (the pair
//    above, four steps), squared 0.30338; then k = 2 adds 2*exponential(1)
//    = 2*0.10217: 0.50771 -> 1, five steps (seed -417135238).
//  $dist_t(1, 4): chi_square(4) = 2*e1 + 2*e2 = 26.475 (two steps), then
//    normal(0, 1) from the third step, which is the accepted pair above:
//    0.55080 (two steps), 0.55080/sqrt(26.475/4) = 0.21409 -> 0 (seed
//    772999773, the fourth).
//  $dist_erlang(1, 2, 30): -30*ln(1.6093e-5 * 0.11074)/2 = 198.57 -> 199,
//    two steps (seed 475628535).
// These are the digits the listing produces; the rounding of each real draw
// is rtl_dist_*'s `(long)(r+0.5)`, mirrored for a negative r.
//! inherited IEEE 1364-2005 17.9.2,17.9.3
//! expect stdout dist_reference.expected.txt
module audit_dist_reference;
  integer seed, r;
  initial begin
    seed = 7;
    r = $dist_uniform(seed, -5, 5); $display("uniform %0d %0d", r, seed);
    r = $dist_uniform(seed, -5, 5); $display("uniform %0d %0d", r, seed);
    r = $dist_uniform(seed, -5, 5); $display("uniform %0d %0d", r, seed);
    seed = 1; r = $dist_normal(seed, 100, 10); $display("normal %0d %0d", r, seed);
    seed = 1; r = $dist_exponential(seed, 50); $display("exponential %0d %0d", r, seed);
    seed = 1; r = $dist_poisson(seed, 4); $display("poisson %0d %0d", r, seed);
    r = $dist_poisson(seed, 4); $display("poisson %0d %0d", r, seed);
    seed = 1; r = $dist_chi_square(seed, 3); $display("chi_square %0d %0d", r, seed);
    seed = 1; r = $dist_t(seed, 4); $display("t %0d %0d", r, seed);
    seed = 1; r = $dist_erlang(seed, 2, 30); $display("erlang %0d %0d", r, seed);
    // start >= end returns start without drawing: the seed is unchanged.
    seed = 1; r = $dist_uniform(seed, 3, 3); $display("degenerate %0d %0d", r, seed);
  end
endmodule
