// IEEE 1364-2005 §17.2.3, p. 290: "This format argument can be a static
// string, such as "data is %d" or can be a reg variable whose content is
// interpreted as the format string."
//
// fmt holds the characters "x=%h!" (5 characters in 64 bits, zero-padded on
// the left, §5.2.3.2). As a format, %h takes 8'hc3 -> "x=c3!", so
// $display("[%s]", s) prints [x=c3!].
//! inherited IEEE 1364-2005 17.2.3
// native-required
module b_17_2_3_sformat_variable_format;
  reg [8*8:1] s, fmt;
  initial begin
    fmt = "x=%h!";
    $sformat(s, fmt, 8'hc3);
    $display("[%s]", s);
    $finish(0);
  end
endmodule
