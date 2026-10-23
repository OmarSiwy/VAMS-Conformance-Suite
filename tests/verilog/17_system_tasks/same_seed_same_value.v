// IEEE 1364-2005 §17.9, p. 311: "There is a set of random number generators
// that return integer values distributed according to standard probabilistic
// functions." §17.9.2, p. 312: "For each system function, the seed argument
// is an inout argument; that is, a value is passed to the function, and a
// different value is returned. The system functions shall always return the
// same value given the same seed." ... "In the $dist_uniform function, the
// start and end arguments are integer inputs that bound the values returned."
// §17.9.1, p. 312: "Example 2 ... gives rand a positive value from 0 to 59:
// rand = {$random} % 60;"
//
// The values themselves are the §17.9.3 algorithm's (dist_reference.v
// and random_seed_reference.v pin them); here only the relations the
// clauses state are printed, as 0/1:
//   same:   seed = 7, a = $dist_uniform(seed, 0, 10), seed = 7 again,
//           b = $dist_uniform(seed, 0, 10) -> a == b
//   bound:  0 <= a <= 10
//   moved:  the seed was written: it is no longer 7
//   again:  the same for $dist_normal(seed, 0, 5) from seed 7 -> equal
//   random: seed = 3, {$random(seed)} % 60 twice from seed 3 -> equal, and
//           in 0..59
//! inherited IEEE 1364-2005 17.9 17.9.1 17.9.2
`timescale 1 ns / 1 ns
module b_17_9_2_same_seed_same_value;
  integer seed, a, b;
  reg [23:0] r1, r2;
  initial begin
    seed = 7;
    a = $dist_uniform(seed, 0, 10);
    $display("moved=%0d", seed != 7);
    seed = 7;
    b = $dist_uniform(seed, 0, 10);
    $display("same=%0d bound=%0d", a == b, a >= 0 && a <= 10);
    seed = 7;
    a = $dist_normal(seed, 0, 5);
    seed = 7;
    b = $dist_normal(seed, 0, 5);
    $display("again=%0d", a == b);
    seed = 3;
    r1 = {$random(seed)} % 60;
    seed = 3;
    r2 = {$random(seed)} % 60;
    $display("random=%0d range=%0d", r1 == r2, r1 <= 59);
    $finish(0);
  end
endmodule
