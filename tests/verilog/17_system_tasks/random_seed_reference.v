// IEEE 1364-2005 §17.9.1: "The seed argument controls the numbers that
// $random returns so that different seeds generate different random
// streams. The seed argument shall be either a reg, an integer, or a time
// variable." §17.9.3 Table 17-17 defines $random as the listing's
// `rtl_dist_uniform (seed, LONG_MIN, LONG_MAX)`, and §17.9.2 makes the seed
// "an inout argument; that is, a value is passed to the function, and a
// different value is returned".
//
// HAND DERIVATION from the §17.9.3 C listing, seed = 0:
//   uniform: *seed == 0 -> 259341593; *seed = 69069*259341593 + 1
//     = 17912464486918, mod 2^32 = 2450862598 (as long: -1844104698)
//   (2450862598 >> 9) | 0x3f800000 as a float = 1 + 4786841*2^-23;
//   c = c + c*2^-23 = 1.5706361020369428
//   c = (2^31-1 - -2^31)*(c - 1) + -2^31 = 303379747.5949521
//   rtl_dist_uniform's third branch: r = (c + 2^31)/4294967295*4294967296
//     - 2^31 = 303379748.1655884, r >= 0 so i = (long)r = 303379748.
// The same steps from the written-back seeds give -1064739199 (seed
// 1082744015) and -2071669239 (seed 75814084): the three values Icarus
// Verilog's copy of the listing prints for a zero seed.
//
// Example 1: "($random % b) gives a number in the following range:
// [(-b+1): (b-1)]". From seed -1844104698 the draw is -1064739199;
// -1064739199 % 60 = -(60*17745653 + 19) % 60 = -19 (§4.1.5: the sign of
// the first operand).
// Example 2: "{$random} % 60" is unsigned: 303379748 = 60*5056329 + 8 -> 8.
//
// A time variable carries the same stream: its first two draws from 0 are
// the integer's. Its written-back value is not printed: the listing's seed
// is a 32-bit long, and how its 64 bits are filled is not stated.
//! lrm 9.13.1
//! lrm 9.13.1:1
//! lrm 9.13.1:4
//! inherited IEEE 1364-2005 17.9.1,17.9.3
//! expect stdout random_seed_reference.expected.txt
module audit_random_seed_reference;
  integer seed, r;
  time ts;
  initial begin
    seed = 0;
    r = $random(seed); $display("r1=%0d seed=%0d", r, seed);
    r = $random(seed); $display("r2=%0d seed=%0d", r, seed);
    r = $random(seed); $display("r3=%0d seed=%0d", r, seed);
    seed = -1844104698;
    r = $random(seed) % 60; $display("mod=%0d", r);
    seed = 0;
    r = {$random(seed)} % 60; $display("umod=%0d", r);
    ts = 0;
    r = $random(ts); $display("t1=%0d", r);
    r = $random(ts); $display("t2=%0d", r);
  end
endmodule
