// IEEE 1364-2005 §17.2.3, pp. 289-290: "The $swrite family of tasks is based
// on the $fwrite family of tasks and accepts the same type of arguments as
// the tasks upon which it is based, with one exception: The first argument to
// $swrite shall be a reg variable to which the resulting string shall be
// written" ... "Unlike the display and write family of output system tasks,
// $sformat always interprets its second argument, and only its second
// argument, as a format string. ... No other arguments are interpreted as
// format strings." ... "The variable output_reg is assigned using the string
// assignment to variable rules, as specified in 5.2.3."
// §5.2.3.2, p. 59: "When strings are assigned to variables, the values stored
// shall be padded on the left with zeros." §3.6.2, p. 13: "If a string is
// larger than the destination string variable, the string is right-justified,
// and the leftmost characters are truncated." §17.1.1.7: %s prints "leading
// zeros are never printed".
//
// s is 64 bits (8 characters), f is 32 bits (4 characters).
//   $swrite(s, "v=%0d", 8'd42)      "v=42", zero-padded on the left:
//                                   s = 64'h00000000_763d3432 -> [v=42] and
//                                   %h 00000000763d3432
//   $swriteh(s, 8'hab, "|", 4'h5)   no format: hex, as $fwriteh -> [ab|5]
//   $swriteb(s, 3'b101, "/", 2'b0x) binary -> [101/0x]
//   $swriteo(s, 6'o17)              octal, two digits for 6 bits -> [17]
//   $swrite(s, 8'd7, ":", 4'd9)     decimal, sized (§17.1.1.3): 8 bits take
//                                   3 columns, 4 bits take 2 -> [  7: 9]
//   $sformat(s, "%0d-%0d", 3, 4)    -> [3-4]
//   $sformat(s, "%0d%s", 5, "%d")   the third argument is NOT a format: %s
//                                   prints its characters -> [5%d]
//   $swrite(f, "abcdef")            6 characters into 4: the leftmost two
//                                   are truncated -> [cdef]
//! inherited IEEE 1364-2005 17.2.3
module b_17_2_3_string_output;
  reg [8*8:1] s;
  reg [8*4:1] f;
  initial begin
    $swrite(s, "v=%0d", 8'd42);
    $display("[%s] %h", s, s);
    $swriteh(s, 8'hab, "|", 4'h5);
    $display("[%s]", s);
    $swriteb(s, 3'b101, "/", 2'b0x);
    $display("[%s]", s);
    $swriteo(s, 6'o17);
    $display("[%s]", s);
    $swrite(s, 8'd7, ":", 4'd9);
    $display("[%s]", s);
    $sformat(s, "%0d-%0d", 3, 4);
    $display("[%s]", s);
    $sformat(s, "%0d%s", 5, "%d");
    $display("[%s]", s);
    $swrite(f, "abcdef");
    $display("[%s]", f);
    $finish(0);
  end
endmodule
