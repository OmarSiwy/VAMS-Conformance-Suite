// IEEE 1364-2005 §17.3.2: $timeformat "specifies how the %t format
// specification reports time information", in units of 10^units_number s
// with precision_number digits after the decimal point; Table 17-11's
// defaults are the design's smallest precision, 0 digits, no suffix, 20
// columns. The clause's own example hands %t `$realtime`, a real: the real
// time is what is reported, not a whole count of module units (#64: VerA
// rounded a real operand to an integer of the module's unit first).
//
// `timescale 10ns/1ns. `#1.55` is 15.5 ns, rounded to the 1 ns precision
// (§19.8): 16 ns. Then $realtime = 1.6 (units of 10 ns, §17.7.2) and $time
// = 2 (rounded, §17.7.1).
//   default format, units -9: $realtime 1.6 x 10 ns = 16 ns, 0 digits, in
//     20 columns -> 18 spaces then "16"           (the bug: 2 units -> "20")
//   $timeformat(-9, 3, "", 0):
//     $realtime 1.6 -> 16 ns    -> "16.000"        (the bug: "20.000")
//     literal 1.55  -> 15.5 ns  -> "15.500"        (the bug: "20.000")
//     $time 2       -> 20 ns    -> "20.000"        (an integral operand)
//! inherited IEEE 1364-2005 17.3.2 17.7.2
`timescale 10ns/1ns
module b_17_3_2_timeformat_real_operand;
  initial begin
    #1.55;
    $display("[%t]", $realtime);
    $timeformat(-9, 3, "", 0);
    $display("[%t] [%t] [%t]", $realtime, 1.55, $time);
    $finish(0);
  end
endmodule
