// IEEE 1364-2005 §3.2, p. 8: "White space shall contain the characters for
// spaces, tabs, newlines, and formfeeds. These characters shall be ignored
// except when they serve to separate other lexical tokens. However, blanks
// and tabs shall be considered significant characters in strings (see 3.6)."
//
// Below, a tab, a formfeed and newlines separate tokens (reg<TAB>[3:0],
// x<FF>=<FF>4'd5) and are otherwise ignored: x = 5, y = x + 1 = 6.
// The string "a  b<TAB>c" holds two blanks and a raw tab (not the \t escape);
// each is a character: a=61, blank=20, blank=20, b=62, tab=09, c=63, so the
// 48-bit s is 612020620963.
// Printed: "5 6 612020620963".
//! inherited IEEE 1364-2005 3.2
module b_3_2_white_space;
  reg	[3:0]	x, y;
  reg [47:0] s;
  initial begin
    x=4'd5;
    y
      =
        x + 1;
    s = "a  b	c";
    $display("%0d %0d %h", x, y, s);
    $finish(0);
  end
endmodule
