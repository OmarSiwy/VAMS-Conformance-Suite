// IEEE 1364-2005 §17.1.1.7, p. 285: "The %s format specifier is used to print
// ASCII codes as characters. For each %s specification that appears in a
// string, a corresponding argument shall follow the string in the argument
// list."
//
// "%s" is the whole argument list: no argument follows it. Legal neighbour:
// display_packed_ascii.v's $display("string=[%s]", 32'h00414243).
//! inherited IEEE 1364-2005 17.1.1.7
//! reject E1100
//! reject missing display argument
//! neighbour display_packed_ascii.v
module b_17_1_1_7_string_missing_argument_rejected;
  initial $display("name=%s");
endmodule
