// IEEE 1364-2005 §17.1.1.2: "The format specifications in Table 17-3 are used
// with real numbers and have the full formatting capabilities available in the
// C language." C11 7.21.6.1p6 lists five flag characters ('-' left-justify,
// '+' always a sign, ' ' a space for a missing sign, '0' pad with zeros after
// the sign, '#' the alternative form), so each one renders on %e, %f and %g.
// Before #43 the digital engine read none of them: '-', '+', ' ' and '#'
// were refused as unknown conversions, and the '0' of `%08.3f` was read as a
// width digit and padded with spaces.
//
// HAND DERIVATION, one line each (C11 7.21.6.1p8 for the bodies; every value
// is an exact binary fraction, so no rounding is involved):
//   %-8.2f   of 2.5   "2.50" (4), '-' pads 4 spaces on the RIGHT
//                                                  -> [2.50    ]
//   %+e      of 1.5   six fractional digits, '+' spells the sign
//                                                  -> [+1.500000e+00]
//   % .1f    of 3.0   ' ' where the sign would go  -> [ 3.0]
//   %08.3f   of -2.5  "-2.500" (6), '0' fills 2 zeros after the sign
//                                                  -> [-002.500]
//   %-+10.1e of 2.0   "+2.0e+00" (8), left in 10   -> [+2.0e+00  ]
//   %#.0f    of 2.0   no fractional digit; '#' keeps the point -> 2.
//   %#g      of 1.5   P = 6, X = 0: style f with 5 places, "1.50000", and
//                     '#' keeps the trailing zeros  -> 1.50000
//                                                  -> [2.|1.50000]
//
// Legal neighbour of c_flag_on_integer_rejected.v: the same
// flags on a Table 17-2 conversion are refused (E0827).
//! inherited IEEE 1364-2005 17.1.1.2
//! expect stdout real_c_flags.expected.txt
module b_17_1_1_2_real_c_flags;
  real r;
  initial begin
    r = -2.5;
    $display("[%-8.2f]", 2.5);
    $display("[%+e]", 1.5);
    $display("[% .1f]", 3.0);
    $display("[%08.3f]", r);
    $display("[%-+10.1e]", 2.0);
    $display("[%#.0f|%#g]", 2.0, 1.5);
  end
endmodule
