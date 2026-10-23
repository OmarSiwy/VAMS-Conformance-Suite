// IEEE 1364-2005 §5.2.3.3, p. 60: "The null string ("") shall be considered
// equivalent to the ASCII NUL ("\0"), which has a value zero (0), which is
// different from a string "0"."
//
//   n = "" -> 00;   n = "\0" -> 00;   n = "0" -> 30 ("0" is ASCII 8'h30)
//   "" == "\0" -> 1;  "" == 0 -> 1;  "" == "0" -> 0
//! inherited IEEE 1364-2005 5.2.3.3
module b_5_2_3_3_null_string;
  reg [7:0] n;
  initial begin
    n = "";
    $write("%h ", n);
    n = "\0";
    $write("%h ", n);
    n = "0";
    $display("%h", n);
    $display("%b%b%b", "" == "\0", "" == 0, "" == "0");
    $finish(0);
  end
endmodule
