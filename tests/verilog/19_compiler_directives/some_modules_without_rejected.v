// IEEE 1364-2005 §19.8, p. 358: "If there is no `timescale specified or it
// has been reset by a `resetall directive, the time unit and precision are
// simulator-specific. It shall be an error if some modules have a `timescale
// specified and others do not."
//
// b_19_8_untimed precedes every `timescale, so it has none; the top module
// has one. Legal neighbour: units_and_precision.v, where every module
// follows a `timescale.
//! inherited IEEE 1364-2005 19.8
//! reject E1100
//! reject it shall be an error if some modules have a `timescale specified and others do not
//! neighbour units_and_precision.v
module b_19_8_untimed;
  initial $display("untimed");
endmodule
`timescale 1 ns / 1 ns
module b_19_8_some_modules_without_rejected;
  b_19_8_untimed u();
  initial $display("timed");
endmodule
