// IEEE 1364-2005 §3.1, p. 8: "A lexical token shall consist of one or more
// characters. The layout of tokens in a source file shall be free format;
// that is, spaces and newlines shall not be syntactically significant other
// than being token separators".
//
// Because a space separates tokens, `= =` is two assignment tokens, not the
// equality operator ==, and `a = = 1` is not an expression. Legal neighbour:
// free_format_layout.v, where spaces only separate whole tokens.
//! inherited IEEE 1364-2005 3.1
//! reject E0207
//! reject unexpected token: found `=`
//! neighbour free_format_layout.v
module b_3_1_split_operator_token_rejected;
  reg a;
  initial begin
    a = 1;
    if (a = = 1) $display("equal");
  end
endmodule
