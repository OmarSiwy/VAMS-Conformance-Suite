//! inherited IEEE 1364-2005 14.2.5
//! reject same number of bits
// A parallel path joins terminals of equal width; a 1-bit in => 8-bit out is
// an error (par_mismatch).
module triage_parallel_path_width_mismatch_rejected(out, in);
  output [7:0] out;
  input in;

  assign out = {8{in}};

  specify
    (in => out) = 2;
  endspecify
endmodule
