// IEEE 1364-2005 §17.9.1: "The seed argument shall be either a reg, an
// integer, or a time variable." §17.9.2 makes it "an inout argument; that
// is, a value is passed to the function, and a different value is
// returned" — a constant has nowhere to receive that value.
//! inherited IEEE 1364-2005 17.9.1
//! reject the seed argument shall be a reg, integer or time variable
module audit_random_seed_constant_rejected;
  integer r;
  initial r = $random(5);
endmodule
