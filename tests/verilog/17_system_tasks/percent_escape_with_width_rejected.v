// IEEE 1364-2005 §17.1.1.1: "The escape sequences given in Table 17-1, when
// included in a string argument, cause special characters to be displayed."
// Table 17-1's last row is `%%`, "the % character": two characters. VAMS
// §9.4.2's Table 9-21 lists the same row.
//
// `%5%` puts a width between them, which makes no escape of Table 17-1 and
// no format specification of §17.1.1.2. The real conversions' C grant does
// not reach it: C11 7.21.6.1p8, "The complete conversion specification shall
// be %%". The digital engine refuses it, E0826, as lowering does in the
// analog context (#42), rather than print a `%` or take an argument for it.
//
// Legal neighbour: escape_sequences.v, whose "%%|..." prints one
// `%`.
//! inherited IEEE 1364-2005 17.1.1.1
//! reject E0826
//! neighbour escape_sequences.v
module b_17_1_1_1_percent_escape_with_width_rejected;
  initial $display("%5%");
endmodule
