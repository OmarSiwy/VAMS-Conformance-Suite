// IEEE 1364-2005 §3.1, p. 8: "Verilog HDL source text files shall be a stream
// of lexical tokens. A lexical token shall consist of one or more characters.
// The layout of tokens in a source file shall be free format; that is, spaces
// and newlines shall not be syntactically significant other than being token
// separators, except for escaped identifiers (see 3.7.1)."
//
// The same statements written three ways must mean the same thing:
//   packed, no separators where none are needed: a=3;b=4;c=a+b; -> c = 7
//   one token per line: d = a * b over six lines -> 12
//   many statements on one line, then a = a<<1 split across lines -> 3<<1 = 6
// The exception: the escaped identifier \a+b ends at the space after it, so
// `\a+b +1` is the identifier a+b plus 1: \a+b = 10 -> 11.
// Printed: "7 12 6 11".
//! lrm 2.2
//! lrm 2.2:3
//! lrm 2.2:2
//! inherited IEEE 1364-2005 3.1
module b_3_1_free_format_layout;reg[7:0]a,b,c,d,e;integer \a+b ;
  initial begin
    a=3;b=4;c=a+b;
    d
    =
    a
    *
    b
    ;
    \a+b = 10; e = \a+b +1; a = a
      <<
        1;
    $display("%0d %0d %0d %0d", c, d, a, e);
    $finish(0);
  end
endmodule
