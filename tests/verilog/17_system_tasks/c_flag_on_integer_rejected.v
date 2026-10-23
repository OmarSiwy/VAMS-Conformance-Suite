// IEEE 1364-2005 §17.1.1.2 grants "the full formatting capabilities available
// in the C language" to "the format specifications in Table 17-3", the real
// ones. The integer conversions of Table 17-2 (%h %d %o %b %c %s ...) are
// sized by §17.1.1.3 instead ("the values written to the output file (or
// terminal) are sized automatically"), whose one override is "inserting a
// zero" (`%0d`). No clause says what C's '-', '+' or ' ' does to an
// automatically sized field, so VerA refuses them, E0827, rather than read
// them and print the field as if they were not there (#43). (The '#' flag is
// E0825 on every conversion but %e, %f and %g, in both contexts.)
//
// `%-5d` puts C's '-' on a Table 17-2 conversion. Legal neighbour:
// real_c_flags.v, the same flag on %f, rendered.
//! inherited IEEE 1364-2005 17.1.1.2
//! reject E0827
//! neighbour real_c_flags.v
module b_17_1_1_2_c_flag_on_integer_rejected;
  initial $display("[%-5d]", 1);
endmodule
