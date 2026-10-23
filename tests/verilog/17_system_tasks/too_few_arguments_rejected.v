// IEEE 1364-2005 §17.1.1, p. 278: "The special character % indicates that the
// next character should be interpreted as a format specification that
// establishes the display format for a subsequent expression argument (see
// Table 17-2). For each % character (except %m and %%) that appears in a
// string, a corresponding expression argument shall be supplied after the
// string."
//
// The string has two % characters (%d, %h) and one expression follows it, so
// %h has no argument. Legal neighbour: display_write_runs.v, where
// "A%0d" and "B%h" are each followed by their expression.
//! inherited IEEE 1364-2005 17.1.1
//! reject E1100
//! reject missing display argument
//! neighbour display_write_runs.v
module b_17_1_1_too_few_arguments_rejected;
  initial $display("%d then %h", 7);
endmodule
