// IEEE 1364-2005 §17.3.2, p. 300: "The units number argument shall be an
// integer in the range from 0 to -15. This argument represents the time unit
// as shown in Table 17-10." Table 17-10 runs from 0 (1 s) to -15 (1 fs).
//
// -16 (100 as) is outside that range, and the argument is a constant, so the
// call is illegal as written. Legal neighbour: timeformat_runtime_arguments.v
// and timeformat.v, whose units numbers are in the table.
//! inherited IEEE 1364-2005 17.3.2
//! reject E1100
//! reject 0 to -15
//! neighbour timeformat_runtime_arguments.v
//! neighbour timeformat.v
`timescale 1 ns / 1 ps
module b_17_3_2_timeformat_units_range_rejected;
  initial begin
    $timeformat(-16, 2, " as", 10);
    $display("%t", $realtime);
  end
endmodule
