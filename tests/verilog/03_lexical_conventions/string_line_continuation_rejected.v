//! inherited IEEE 1364-2005 3.6
//! reject E0138
// A string is contained on a single line; the backslash-newline continuation
// is IEEE 1800 (string12).
module triage_string_line_continuation_rejected;
  initial begin
    if ("this matches" == "this\
 matches") $display("PASSED");
  end
endmodule
