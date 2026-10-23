// IEEE 1364-2005 §17.2.1, p. 287: "The type is a character string or a reg
// containing a character string of one of the following forms in Table 17-7,
// which indicates how the file should be opened." Table 17-7 lists r, rb, w,
// wb, a, ab, r+, r+b, rb+, w+, w+b, wb+, a+, a+b and ab+.
//
// "q" is none of them, and the type is a literal, so the call is illegal as
// written. Legal neighbour: append_writes_at_end.v opens with "w",
// "a" and "r".
//! inherited IEEE 1364-2005 17.2.1
//! reject E1100
//! reject Table 17-7
//! neighbour append_writes_at_end.v
module b_17_2_1_fopen_type_rejected;
  integer fd;
  initial fd = $fopen("b_17_2_1_fopen_type.txt", "q");
endmodule
