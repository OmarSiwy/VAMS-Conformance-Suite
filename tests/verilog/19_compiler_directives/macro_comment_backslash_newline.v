//! inherited IEEE 1364-2005 19.3.1
// A backslash-newline continues macro text inside a // comment, and the
// comment is then dropped (br_gh435).
`define display_passed \
  initial begin // comment \
    $display("PASSED"); \
  end

module triage_macro_comment_backslash_newline;
`display_passed
endmodule
