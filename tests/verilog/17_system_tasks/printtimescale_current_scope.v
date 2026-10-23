// IEEE 1364-2005 §17.3.1, p. 299: "This system task can be specified with or
// without an argument. — When no argument is specified, $printtimescale
// displays the time unit and precision of the module that is the current
// scope." ... "The timescale information shall appear in the following
// format: Time scale of (module_name) is unit / precision"
//
// The call has no argument and sits in the top module, whose `timescale is
// 1 ms / 1 us, so the current scope's unit is 1ms and its precision 1us. The
// module is the top, so its module name and its hierarchical name are one
// string and the line does not depend on which of the two a tool prints:
//   Time scale of (b_17_3_1_printtimescale_current_scope) is 1ms / 1us
// The LRM's own example writes the unit with no space ("is 1ns / 1ns") for a
// directive written `1 ns / 1 ns`, which is the spelling expected here.
//! inherited IEEE 1364-2005 17.3.1
`timescale 1 ms / 1 us
module b_17_3_1_printtimescale_current_scope;
  initial begin
    $printtimescale;
    $finish(0);
  end
endmodule
