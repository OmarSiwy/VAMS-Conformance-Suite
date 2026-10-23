//! inherited IEEE 1364-2005 17.1.1.7
// %s prints the string's bytes and never prints its leading zero bytes: the
// three zero bytes before "Hello" in the 64-bit reg are not output
// (br_gh827/string5).
module triage_string_leading_zeros;
  reg [8*8-1:0] s;

  initial begin
    s = "Hello";
    $display("[%s]", s);
  end
endmodule
