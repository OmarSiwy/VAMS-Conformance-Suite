// AMS2.8.1: every listed whitespace terminates, and is not part of the name.
// Declaration terminators are respectively space, tab, newline, formfeed.
// References use ordinary spelling: same object identity must be preserved.
//! lrm 2.8.1
//! expect stdout ams_lexical_escaped_terminators.expected.txt
//! inherited IEEE 1364-2005 3.7.1 (space, tab, newline; the formfeed terminator is AMS 2.8.1's)
module audit_ams_lexical_escaped_terminators;
integer \space_end , \tab_end	, \line_end
, \form_end;
initial begin
  space_end=1; tab_end=2; line_end=3; form_end=4;
  $display("%0d %0d %0d %0d", \space_end , \tab_end	, \line_end
, \form_end);
end
endmodule
