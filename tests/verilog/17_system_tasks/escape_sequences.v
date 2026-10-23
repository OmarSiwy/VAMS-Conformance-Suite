// IEEE 1364-2005 §17.1.1.1, pp. 278-279: "The escape sequences given in
// Table 17-1, when included in a string argument, cause special characters to
// be displayed." Table 17-1: \n newline, \t tab, \\ the \ character, \" the "
// character, "\ddd A character specified in 1-3 octal digits (0 <= d <= 7).
// If fewer than three characters are used, the following character shall not
// be an octal digit.", %% the % character. The clause's example,
// $display("\\\t\\\n\"\123"), "shall display the following:
//   \           \
//   "S"
//
// Line 1, the clause's example, character by character:
//   \\ -> \   \t -> TAB   \\ -> \   \n -> newline   \" -> "   \123 -> octal
//   123 = 64 + 16 + 3 = 83 = 'S'; $display then ends the line. Output:
//   "\" TAB "\" / "\"S" (the example's wide gap is the tab).
// Line 2, "%%|\101\60\0612|\t|":
//   %% -> %; \101 = 65 = 'A'; \60 (two digits, followed by \, not an octal
//   digit) = 48 = '0'; \061 (three digits) = 49 = '1', and the 2 after it is
//   an ordinary character -> "%|A012|" TAB "|".
//! inherited IEEE 1364-2005 17.1.1.1
module b_17_1_1_1_escape_sequences;
  initial begin
    $display("\\\t\\\n\"\123");
    $display("%%|\101\60\0612|\t|");
    $finish(0);
  end
endmodule
