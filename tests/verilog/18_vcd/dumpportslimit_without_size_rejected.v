// IEEE 1364-2005 §18.3.4, p. 340: "The filesize argument is required, and it
// specifies the maximum size in bytes for the associated file_pathname."
// Syntax 18-24: `$dumpportslimit ( filesize , file_pathname ) ;`. §18.3.7's
// bare-name form is only for "the tasks that have only optional arguments".
//
// `$dumpportslimit;` has no filesize. Legal neighbour:
// dumpportslimit_stops_with_comment.v's `$dumpportslimit(4000, ...)`.
//! inherited IEEE 1364-2005 18.3.4
//! reject E1100
//! reject size
//! neighbour dumpportslimit_stops_with_comment.v
`timescale 1ns/1ns
module b_18_3_4_dumpportslimit_without_size_rejected_dev(a, y);
  input a;
  output y;
  assign y = ~a;
endmodule

module b_18_3_4_dumpportslimit_without_size_rejected;
  reg a;
  wire y, w;
  b_18_3_4_dumpportslimit_without_size_rejected_dev u(a, y);
  b_18_3_4_dumpportslimit_without_size_rejected_dev v(a, w);
  initial begin
    a = 1'b0;
    $dumpports(u, "b_18_3_4_nosize.evcd");
    $dumpportslimit;
    #1 a = 1'b1;
  end
endmodule
