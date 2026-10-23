// IEEE 1364-2005 §18.1.5, p. 328: "The $dumplimit task can be used to set the
// size of the VCD file." ... "The filesize argument specifies the maximum
// size of the VCD file in bytes. When the size of the VCD file reaches this
// number of bytes, the dumping stops, and a comment is inserted in the VCD
// file indicating the dump limit was reached."
// §18.2.3.1, p. 332: "The $comment section provides a means of inserting a
// comment in the VCD file." Syntax 18-9: `$comment comment_text $end`.
//
// The dump is read back during the simulation after a $dumpflush (§18.1.6),
// split into white-space separated tokens, as in
// version_names_dumpfile_literal.v. Nothing a writer chooses
// (codes, header text, where exactly the limit bites) is printed; two
// properties are.
//
// HAND DERIVATION:
//   The limit is 4000 bytes. u.a toggles at #1, #2, ..., #2000, so an
//   unlimited dump holds 2000 time records, each at least `#n` and one
//   scalar change `0c` (value and code) with white space: at least 5 bytes,
//   10000 bytes in all, more than 4000 (u.k, the loop counter, is selected
//   too and only adds bytes). So the dump stops before its end:
//     the record #2000 is not in the file              -> t2000=0
//   and the comment that says so is the last thing the dump wrote: no time
//   record or value follows the last $comment section after
//   $enddefinitions                                    -> comment_last=1
//   (comment_last also needs a $comment to exist at all: it starts at 0.)
//! inherited IEEE 1364-2005 18.1.5 18.2.3.1
`timescale 1ns/1ns
module b_18_1_5_dut;
  reg a;
  integer k;
  initial begin
    a = 1'b0;
    for (k = 1; k <= 2000; k = k + 1) #1 a = ~a;
  end
endmodule

// Dumps u and reads the dump back; its own variables are not selected.
module b_18_1_5_dumplimit_stops_with_comment;
  b_18_1_5_dut u();
  integer fd, c, header, in_comment, comment_last, t2000;
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
    $dumpfile("b_18_1_5_limit.vcd");
    $dumplimit(4000);
    $dumpvars(1, u);
    #2001 $dumpflush;
    fd = $fopen("b_18_1_5_limit.vcd", "r");
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
