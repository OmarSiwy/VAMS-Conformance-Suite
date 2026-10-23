// IEEE 1364-2005 §17.1.2, p. 285: "The arguments for this task are specified
// in exactly the same manner as for the $display system task--including the
// use of escape sequences for special characters and format specifications
// (see 17.1.1)." and §17.1.1, p. 278: "For each % character (except %m and
// %%) that appears in a string, a corresponding expression argument shall be
// supplied after the string."
//
// $strobe's %h has no expression after the string. Legal neighbour:
// strobe_end_of_step.v's $strobe("strobe a=%0d", a).
//! inherited IEEE 1364-2005 17.1.2
//! reject E1100
//! reject missing display argument
//! neighbour strobe_end_of_step.v
module b_17_1_2_strobe_missing_argument_rejected;
  reg [7:0] a;
  initial begin
    a = 8'h5a;
    $strobe("a=%h");
  end
endmodule
