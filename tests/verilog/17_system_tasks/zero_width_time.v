// IEEE 1364-2005 §17.1.1.3, p. 282: "The automatic sizing of displayed data
// can be overridden by inserting a zero between the % character and the
// letter that indicates the radix". §17.3.2, p. 300, Table 17-11: the %t
// format's automatic size is $timeformat's minimum_field_width, 20 by
// default, and the default units are the smallest time precision (1 ns here)
// with precision 0 and no suffix.
//
// At time 5:
//   default format: %0t -> "5", %t -> 19 spaces then "5"
//   $timeformat(-9, 2, " ns", 10): %0t -> "5.00 ns", %t -> "   5.00 ns"
//! inherited IEEE 1364-2005 17.1.1.3 17.3.2
`timescale 1ns/1ns
module b_17_1_1_3_zero_width_time;
  initial begin
    #5 $display("[%0t] [%t]", $time, $time);
    $timeformat(-9, 2, " ns", 10);
    $display("[%0t] [%t]", $time, $time);
    $finish(0);
  end
endmodule
