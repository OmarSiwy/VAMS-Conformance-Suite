// IEEE 1364-2005 §17.9.1: "The seed argument controls the numbers that
// $random returns so that different seeds generate different random streams."
// A call with no seed argument draws from a stream the clause leaves to the
// tool. VerA's choice (specification/Vague_Decisions.md) is one hidden seed per run,
// starting at 0, advanced by the §17.9.3 listing like any other seed. This pins
// that choice by an identity, so no digit of the stream is written here:
//   a = the first seedless $random;
//   b = $random(s) with s = 0, the first draw of a stream seeded 0.
// Under VerA's choice they are the same draw: "same=1".
// A second pair checks the hidden seed advanced: the second seedless draw is
// the second draw of the s stream: "same=1".
//! inherited IEEE 1364-2005 17.9.1
module b_17_9_1_seedless_random_starts_at_seed_0;
  integer s, a, b;
  initial begin
    s = 0;
    a = $random;
    b = $random(s);
    $display("same=%0d", a == b);
    a = $random;
    b = $random(s);
    $display("same=%0d", a == b);
  end
endmodule
