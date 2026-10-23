// IEEE 1364-2005 A.9.4, p. 509:
//   white_space ::= space | tab | newline | eof
// Details, p. 509: "5) End of file."
//
// Tokens separated by each kind of white_space: spaces, a tab (between
// `integer` and `n`), newlines inside one statement, and the end of file
// ending the text after `endmodule` with no newline. n = 2 + 3 = 5.
// Output: "n=5".
//! inherited IEEE 1364-2005 A.9.4
module b_A_9_4_white_space;
  integer	n;
  initial begin
    n = 2
      +
      3;
    $display("n=%0d", n);
    $finish(0);
  end
endmodule