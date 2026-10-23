// IEEE 1364-2005 §18.3.4, p. 340: "The $dumpportslimit system task allows
// control of the VCD file size." Syntax 18-24: `$dumpportslimit ( filesize ,
// file_pathname ) ;`. "The filesize argument is required, and it specifies
// the maximum size in bytes for the associated file_pathname. When this
// filesize is reached, the dumping stops, and a comment is inserted into
// file_pathname indicating the size limit was attained."
//
// The four-state twin is dumplimit_stops_with_comment.v; the same
// two properties are read back here, after $dumpportsflush, from the tokens
// of the extended file.
//
// HAND DERIVATION:
//   The limit is 4000 bytes. a toggles at #1, #2, ..., #2000, and each step
//   changes both ports of u (y = ~a), so an unlimited dump holds 2000 time
//   records of at least `#n` and two `pX s0 s1 <c` changes (at least 8
//   bytes each with the separating white space): more than 30000 bytes. So
//   the dump stops before its end:
//     the record #2000 is not in the file              -> t2000=0
//   and the comment that says so is the last thing the dump wrote: no time
//   record or value follows the last $comment section after
//   $enddefinitions                                    -> comment_last=1
//! inherited IEEE 1364-2005 18.3.4
// native-required
`timescale 1ns/1ns
module b_18_3_4_dev(a, y);
  input a;
  output y;
  assign y = ~a;
endmodule

module b_18_3_4_dumpportslimit_stops_with_comment;
  reg a;
  wire y;
  b_18_3_4_dev u(a, y);
  integer k, fd, c, header, in_comment, comment_last, t2000;
  reg [8*64:1] tok;

  task token;
    begin
      if (in_comment) begin
        if (tok == "$end") in_comment = 0;
      end else if (tok == "$comment") begin
        in_comment = 1;
        if (!header) comment_last = 1;
      end else if (tok == "$enddefinitions") header = 0;
      else if (!header) begin
        comment_last = 0;
        if (tok == "#2000") t2000 = 1;
      end
    end
  endtask

  initial begin
    a = 1'b0;
    $dumpports(b_18_3_4_dumpportslimit_stops_with_comment.u, "b_18_3_4_limit.evcd");
    $dumpportslimit(4000, "b_18_3_4_limit.evcd");
    for (k = 1; k <= 2000; k = k + 1) #1 a = ~a;
    #1 $dumpportsflush("b_18_3_4_limit.evcd");
    fd = $fopen("b_18_3_4_limit.evcd", "r");
    header = 1;
    in_comment = 0;
    comment_last = 0;
    t2000 = 0;
    tok = 0;
    c = $fgetc(fd);
    while (c != -1) begin
      if (c == " " || c == "\n" || c == "\t" || c == 8'd13) begin
        if (tok != 0) token;
        tok = 0;
      end else tok = {tok, c[7:0]};
      c = $fgetc(fd);
    end
    if (tok != 0) token;
    $fclose(fd);
    $display("t2000=%0d comment_last=%0d", t2000, comment_last);
  end
endmodule
