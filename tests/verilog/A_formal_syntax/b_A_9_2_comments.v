// IEEE 1364-2005 A.9.2, p. 508:
//   comment ::= one_line_comment | block_comment
//   one_line_comment ::= // comment_text \n
//   block_comment ::= /* comment_text */
//   comment_text ::= { Any_ASCII_character }
//
// comment_text is any character, so `//` inside a block comment and `/*`
// inside a one-line comment are just text; a block comment may span lines
// and sit between the tokens of an expression. The comments below hide
// assignments that must not run: only r = a + b = 3 + 4 = 7 does.
// Output: "r=7".
//! inherited IEEE 1364-2005 A.9.2
module b_A_9_2_comments;
  integer a, b, r;
  initial begin
    a = 3;
    b = 4;
    /* r = 100; // not a line comment: still inside this block comment
       r = 200; */
    // r = 300; /* not a block comment opener
    r = a /* between tokens */ + /**/ b; // trailing
    $display("r=%0d", r);
    $finish(0);
  end
endmodule
